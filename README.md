# eggd_apheleia app

Given the file ID for a Uranus sample's exon-level Athena coverage file, this app calculates two ratios using mean exon coverage in the KMT2A gene:

- exon 3 / exon 27
- (exon 3 + exon 5) / exon 27

If both of these ratios surpass certain predetermined threshold values, this suggests the possible presence of a partial tandem duplication (KMT2A-PTD) in that sample.

The thresholds are determined as the lowest value calculated by Apheleia from 6 confirmed positive cases. They are:

- exon 3 / exon 27: 1.1793
- (exon 3 + exon 5) / exon 27: 2.28548

This combination of exon ratios was chosen because it was the simplest combination which can exclude a known false positive among control samples used for testing. Further information can be found at https://cuhbioinformatics.atlassian.net/wiki/spaces/URA/pages/3045458090/231205+eggd+hydra+v0.0.2

This app is intended for inclusion in the Uranus workflow for somatic variant calling in haematological oncology cases.

## Usage

dx run (app id) -iexon_stats=(file id) -y

The app takes one mandatory input argument, exon_stats, which is the file ID for a Uranus sample's exon-level Athena coverage file.

It returns as output a single .tsv file, which lists the mean coverage values for exons 3, 5 and 27, the ratios described above, and whether or not each ratio is above its threshold for calling putative KMT2A PTDs.

The final column in the output workbook lists whether any of exons 3, 5 or 27 have less than 90% coverage at 250x, which is a QC threshold used in the Uranus workflow.

## References

The original work on identification of KMT2A-PTDs using exon coverage ratios is described in:

McKerrell T., Moreno T., Vassiliou G.S., et al.; 2016. Development and validation of a comprehensive genomic diagnostic tool for myeloid malignancies. Blood 128(1), e1-e9
