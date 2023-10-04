#!/bin/bash

main() {

    # output lines as executed, stop at any non-zero exit codes
    set -exo pipefail

    # download input file
    dx-download-all-inputs

    # get mean coverage values for exons 3 and 27
    exon3=$(awk -F"\t" '$4 == "KMT2A" && $6 == "3" {print $8}' "$hydra_input_path")
    exon27=$(awk -F"\t" '$4 == "KMT2A" && $6 == "27" {print $8}' "$hydra_input_path")

    # divide the two together
    coverage_ratio=$(bc <<< "scale=5 ; $exon3 / $exon27")

    # create output dir and output file
    output_dir="${HOME}/out/hydra_output/eggd_hydra/"
    output_file="${output_dir}${hydra_input_prefix}_hydra_output.tsv"

    mkdir -p "$output_dir"

    printf "sample\texon_3\texon_27\tratio\n%s\t%f\t%f\t%f\n" \
    "$hydra_input_prefix" "$exon3" "$exon27" "$coverage_ratio" \
    > "$output_file"

    # upload output
    dx-upload-all-outputs
}
