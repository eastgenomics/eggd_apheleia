#!/bin/bash

# output lines as executed, stop at any non-zero exit codes
set -exo pipefail

# download input file
dx-download-all-inputs

# get mean coverage values for exons 3 and 27
exon3=$(awk -F"\t" '$4 == "KMT2A" && $6 == "3" {print $8}' "$ptd_input_path")
exon27=$(awk -F"\t" '$4 == "KMT2A" && $6 == "27" {print $8}' "$ptd_input_path")

# divide the two together
coverage_ratio=$(bc <<< "scale=5 ; $exon3 / $exon27")

# create output dir and output file
output_dir="${HOME}/out/ptd_output/eggd_kmt2a_ptds/"
output_file="${output_dir}${ptd_input_prefix}_kmt2a_ptd_ratio.tsv"

mkdir -p "$output_dir"

printf "exon_3\texon_27\tratio\n%f\t%f\t%f\n" \
"${exon3}" "${exon27}" "${coverage_ratio}" \
> "$output_file"

# upload output
dx-upload-all-outputs
