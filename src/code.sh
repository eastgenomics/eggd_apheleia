#!/bin/bash

main() {

    # output lines as executed, stop at any non-zero exit codes
    set -exo pipefail

    dx-download-all-inputs

    # get ids of all exon_stats files for the project
    file_ids=$(dx find data \
    --name "*exon_stats.tsv" \
    --project "$hydra_input_project" \
    --brief)

    # make output dir and file
    output_dir="${HOME}/out/hydra_output/eggd_hydra/"
    output_file="${output_dir}hydra_output_${hydra_input_project}.tsv"

    mkdir -p "$output_dir"
    printf "sample\texon_3\texon_5\texon_27\tratio_3_only\tratio_3_and_5\tpass_3_only\tpass_3_and_5\tpass_overall\t250x_issue\n" > "$output_file"

    # evaluate each exon_stats file against exon coverage thresholds
    for file_id in $file_ids; do

        # get file name, sample id, and archival state
        state=$(dx describe "$file_id" --json | jq -r '.archivalState')
        file_name=$(dx describe "$file_id" --json | jq -r '.name')
        sample_id="${file_name%%_exon_stats.tsv}"

        if [[ "$state" == "live" ]]; then

            # download the file if it isn't archived
            dx download "$file_id" -f

            # check all exons of interest have >90% at 250x coverage
            cov_issues=""
            for exon in "3" "5" "27"; do
                cov_250=$(awk -F"\t" -v exon="$exon" '$4=="KMT2A" && $6==exon {print $11}' "$file_name")
                if (( $cov_250 <= 90 )); then
                    cov_issues="${cov_issues}${exon} "
                fi
            done

            # get mean coverage for exons of interest
            exon_3=$(awk -F"\t" '$4 == "KMT2A" && $6 == "3" {print $8}' "$file_name")
            exon_5=$(awk -F"\t" '$4 == "KMT2A" && $6 == "5" {print $8}' "$file_name")
            exon_27=$(awk -F"\t" '$4 == "KMT2A" && $6 == "27" {print $8}' "$file_name")

            # calculate ratios
            ratio_3_only=$(bc <<< "scale=5 ; $exon_3 / $exon_27")
            ratio_3_and_5=$(bc <<< "scale=5 ; ($exon_3 + $exon_5) / $exon_27")

            # compare ratios to thresholds
            pass_3_only=false
            pass_3_and_5=false
            pass_overall=false

            if [[ $(bc -l <<< "$ratio_3_only >= 1.1793") -eq 1  ]]; then
                pass_3_only=true
            fi

            if [[ $(bc -l <<< "$ratio_3_and_5 >= 2.28548") -eq 1 ]]; then
                pass_3_and_5=true
            fi

            if [[ "$pass_3_only" == true ]] && [[ "$pass_3_and_5" == true ]]; then
                pass_overall=true
            fi

            # add to output file
            printf "%s\t%f\t%f\t%f\t%f\t%f\t%s\t%s\t%s\t%s\n" \
            "$sample_id" "$exon_3" "$exon_5" "$exon_27" "$ratio_3_only" "$ratio_3_and_5" "$pass_3_only" "$pass_3_and_5" "$pass_overall" "$cov_issues" \
            >> "$output_file"

        else
            # archived files don't get processed
            echo "${file_name} not processed because file is archived"
            printf "%s\t\t\tNo data, file is archived\n" "$sample_id" >> "$output_file"

        fi
    done

    # upload output
    dx-upload-all-outputs
    }
