# eggd_hydra app

Given the name or ID of a DNAnexus project, this app identifies all exon_stats.tsv files within that project and calculates ratios of mean exon coverage in the KMT2A gene:

- exon 3 / exon 27
- (exon 3 + exon 5) / exon 27

If both of these ratios surpass certain predetermined threshold values, this suggests the possible presence of a partial tandem duplication (KMT2A-PTD) in that sample.

The thresholds are determined as the lowest value calculated by Hydra from 6 confirmed positive cases. They are:

- exon 3: 1.1793
- exons 3 & 5: 2.28548

This app is intended for inclusion in the Uranus workflow for somatic variant calling in haematological oncology cases.

## Usage

dx run (app id) -ihydra_input_project=(project id or name) -y

The app takes one non-optional input argument, hydra_input_project, which is the name or object ID of a DNAnexus project.

It returns as output a single .tsv file, which lists the mean coverage values for exons 3, 5 and 27, the ratios described above, and whether or not each ratio is above the threshold, for each sample in the project which has an exon_stats.tsv file. If a file is archived, no data will be returned.

## References

The original work on identification of KMT2A-PTDs using exon coverage ratios is described in:
McKerrell T., Moreno T., Vassiliou G.S., et al.; 2016. Development and validation of a comprehensive genomic diagnostic tool for myeloid malignancies. Blood 128(1), e1-e9
