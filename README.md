# eggd_apheleia app

Predicts the potential presence or absence of partial tandem duplications (PTDs) in the KMT2A gene, for samples processed via the Uranus workflow for somatic variant calling in haematological oncology cases.

## Approach

Given the file ID for a sample's exon-level Athena output, the app extracts mean coverage values for specific KMT2A exons and uses them to calculate four ratios:

- exon 3 / exon 27
- exon 4 / exon 27
- exon 5 / exon 27
- exon 6 / exon 27

If a ratio surpasses a predetermined threshold (defined as the lowest ratio value seen among confirmed positive cases), this indicates raised coverage in that exon. If all four ratios surpass their thresholds, this suggests the possible presence of a partial tandem duplication (KMT2A-PTD) in that sample.

Current threshold values for each ratio are:

- exon 3 / exon 27: 1.1793
- exon 4 / exon 27: 0.9055
- exon 5 / exon 27: 0.9279
- exon 6 / exon 27: 0.8521

## Usage

dx run (app id) -iexon_stats=(file id) -y

The app takes one mandatory input argument, exon_stats, which is the file ID for a Uranus sample's exon-level Athena coverage file.

It returns as output a single .tsv file containing the following data:

- Sample name
- Prediction for whether or not a PTD is present
- Mean coverage value for each exon
- Ratio calculated for each exon
- Threshold value for each exon ratio
- A list of exons with <=90% coverage at 250x

## References

The original work on identification of KMT2A-PTDs using exon coverage ratios is described in:

McKerrell T., Moreno T., Vassiliou G.S., et al.; 2016. Development and validation of a comprehensive genomic diagnostic tool for myeloid malignancies. Blood 128(1), e1-e9

This app was based on the TandemHunter app developed by the bioinformatics team at NEY GLH.
