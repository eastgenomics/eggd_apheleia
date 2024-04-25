#!/bin/bash

main() {

    # output lines as executed, stop at any non-zero exit codes
    set -exo pipefail

    # the only input is exon_stats, a .tsv file output by Athena
    dx-download-all-inputs

    # define sample name, make output dir and file
    sample="${exon_stats_prefix%%_exon_stats}"
    output_dir="${HOME}/out/apheleia_tsv/"
    output_file="${output_dir}${sample}_apheleia_output.tsv"

    mkdir -p "$output_dir"

    # initialise variables
    exons="3 4 5 6"
    predicted_ptd="true"
    output_str=""
    cov_issues=""

    # get header row, check fields 4, 6, 8 & 11 are as expected
    headers=$(awk -F "\t" 'FNR==1 {print $4 " " $6 " " $8 " " $11}' "$exon_stats_path")

    if [[ "$headers" != "gene exon mean 250x" ]]; then
        echo "ERROR: Relevant columns are not in the expected places."
        exit 1
    fi

    # get mean coverage for KMT2A exon 27
    exon_27=$(awk -F "\t" '$4=="KMT2A" && $6=="27" {print $8}' "$exon_stats_path")

    # for each of the canonical PTD exons (KMT2A exons 3-6)...
    for exon in $exons; do

        # get mean exon coverage from input file
        coverage=$(awk -F"\t" -v exon="$exon" '$4=="KMT2A" && $6==exon {print $8}' "$exon_stats_path")

        # calculate ratio compared to exon 27, to 7 decimal places
        ratio=$(bc <<< "scale=7 ; ${coverage} / ${exon_27}")

        # define the ratio threshold for each exon
        if [[ "$exon" == "3" ]]; then
            threshold="1.1793"
        elif [[ "$exon" == "4" ]]; then
            threshold="0.9055"
        elif [[ "$exon" == "5" ]]; then
            threshold="0.9279"
        elif [[ "$exon" == "6" ]]; then
            threshold="0.8521"
        fi

        # if any exon doesn't pass its threshold, PTD prediction is false
        if [[ $(bc -l <<< "${ratio} < ${threshold}") -eq 1  ]]; then
            predicted_ptd="false"
            echo "exon ${exon} fails, threshold is ${threshold} but ratio is ${ratio}"
        fi

        # add exon's coverage, ratio and threshold to output string
        output_str="${output_str}${coverage}\t${ratio}\t${threshold}\t"

        # if 250x coverage is <=90%, note that the exon has coverage issues
        cov_250=$(awk -F "\t" -v exon="$exon" '$4=="KMT2A" && $6==exon {print $11}' "$exon_stats_path")

        if [[ $(bc -l <<< "${cov_250} <= 90") -eq 1 ]]; then
            cov_issues="${cov_issues}${exon} "
        fi
    done

    # add data to output file
    printf "sample\tpredicted_ptd\texon_3_mean_coverage\texon_3_ratio\texon_3_threshold\texon_4_mean_coverage\texon_4_ratio\texon_4_threshold\texon_5_mean_coverage\texon_5_ratio\texon_5_threshold\texon_6_mean_coverage\texon_6_ratio\texon_6_threshold\texon_27_mean_coverage\t250x_coverage_issues\n" > "$output_file"
    printf "%s\t%s\t%b%s\t%s\n" "$sample" "$predicted_ptd" "$output_str" "$exon_27" "$cov_issues" >> "$output_file"

    # add executable name and version to output
    job_id="$DX_JOB_ID"
    job_name=$(dx describe "$job_id" --json | jq -r '.name')
    printf "\nFile generated on:\t%s\nExecutable:\t%s\nJob ID:\t%s\n" "$(date '+%Y-%m-%d %H:%M:%S')\n" "$job_name" "$job_id" >> "$output_file"

    # add disclaimer that apheleia is currently only suitable for research use
    printf "\nPlease note that this output is not currently validated for clinical use, and is provided for research use only." >> "$output_file"

    # upload output
    dx-upload-all-outputs
    }
