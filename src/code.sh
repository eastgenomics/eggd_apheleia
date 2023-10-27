#!/bin/bash

main() {

    # output lines as executed, stop at any non-zero exit codes
    set -exo pipefail

    dx-download-all-inputs

    # get ids of all exon_stats files for that project
    coverage_files=$(dx find data \
    --name "*exon_stats.tsv" \
    --project "$hydra_input_project" \
    --brief)

    # make output dir and file
    output_dir="${HOME}/out/hydra_output/eggd_hydra/"
    output_file="${output_dir}hydra_output_${hydra_input_project}.tsv"

    mkdir -p "$output_dir"
    printf "sample\texon_3\texon_27\tratio\tover_threshold\n" > "$output_file"

    for coverage_file in $coverage_files; do

        # get the file name, sample id, and archival state
        state=$(dx describe "$coverage_file" --json | jq -r '.archivalState')
        file_name=$(dx describe "$coverage_file" --json | jq -r '.name')
        sample_id="${file_name%%_exon_stats.tsv}"

        if [[ "$state" == "live" ]]; then

            # download the file if it isn't archived
            dx download "$coverage_file" -f

            # get mean coverage values for exons 3 and 27
            exon3=$(awk -F"\t" '$4 == "KMT2A" && $6 == "3" {print $8}' "$file_name")
            exon27=$(awk -F"\t" '$4 == "KMT2A" && $6 == "27" {print $8}' "$file_name")

            # divide the two together
            coverage_ratio=$(bc <<< "scale=5 ; $exon3 / $exon27")

            # compare ratio to threshold
            if [[ $(bc -l <<< "$coverage_ratio >= 1.1793") -eq 1 ]]; then
                over_threshold=true
            else
                over_threshold=false
            fi

            # add to output file
            printf "%s\t%f\t%f\t%f\t%s\n" \
            "$sample_id" "$exon3" "$exon27" "$coverage_ratio" "$over_threshold" \
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
