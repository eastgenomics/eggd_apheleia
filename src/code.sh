#!/bin/bash

main() {

    # output lines as executed, stop at any non-zero exit codes
    set -exo pipefail

    # the only input is exon_stats, which is an Athena output file
    dx-download-all-inputs

    # define sample name, make output dir and file
    sample="${exon_stats_prefix%%_exon_stats}"
    output_dir="${HOME}/out/apheleia_tsv/eggd_apheleia/"
    apheleia_tsv="${output_dir}${sample}_apheleia_output.tsv"

    mkdir -p "$output_dir"
    printf "sample\texon_3\texon_5\texon_27\texon_3_ratio\texons_3_plus_5_ratio\texon_3_pass\texons_3_plus_5_pass\tprediction\t250x_issue\n" > "$apheleia_tsv"

    # check all exons of interest have >90% at 250x coverage
    cov_issues=""
    for exon in "3" "5" "27"; do
        cov_250=$(awk -F "\t" -v exon="$exon" '$4=="KMT2A" && $6==exon {print $11}' "$exon_stats_path")
        if [[ $(bc -l <<< "${cov_250} <= 90") -eq 1 ]]; then
            cov_issues="${cov_issues}${exon} "
        fi
    done

    # get raw mean coverage for exons of interest
    exon_3=$(awk -F"\t" '$4 == "KMT2A" && $6 == "3" {print $8}' "$exon_stats_path")
    exon_5=$(awk -F"\t" '$4 == "KMT2A" && $6 == "5" {print $8}' "$exon_stats_path")
    exon_27=$(awk -F"\t" '$4 == "KMT2A" && $6 == "27" {print $8}' "$exon_stats_path")

    # calculate ratios
    ratio_3=$(bc <<< "scale=5 ; ${exon_3} / ${exon_27}")
    ratio_3_plus_5=$(bc <<< "scale=5 ; (${exon_3} + ${exon_5}) / ${exon_27}")

    # compare ratios to thresholds
    pass_3=false
    pass_3_plus_5=false
    prediction=false

    if [[ $(bc -l <<< "${ratio_3} >= 1.1793") -eq 1  ]]; then
        pass_3=true
    fi

    if [[ $(bc -l <<< "${ratio_3_plus_5} >= 2.28548") -eq 1 ]]; then
        pass_3_plus_5=true
    fi

    if [[ "$pass_3" == true ]] && [[ "$pass_3_plus_5" == true ]]; then
        prediction=true
    fi

    # add to output file
    printf "%s\t%f\t%f\t%f\t%f\t%f\t%s\t%s\t%s\t%s\n" \
    "$sample" "$exon_3" "$exon_5" "$exon_27" "$ratio_3" "$ratio_3_plus_5" "$pass_3" "$pass_3_plus_5" "$prediction" "$cov_issues" \
    >> "$apheleia_tsv"

    # upload output
    dx-upload-all-outputs
    }
