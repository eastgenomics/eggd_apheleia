# eggd_hydra app

Given the name or ID of a DNAnexus project, this app identifies all exon_stats.tsv files within that project and calculates the ratio of exon 3 to exon 27 mean coverage in the KMT2A gene. If this ratio surpasses a threshold value this suggests the possible presence of a partial tandem duplication (KMT2A-PTD) in that sample.

This app is intended for inclusion in the Uranus workflow for somatic variant calling in haematological oncology cases.

## Usage

dx run (app id) -ihydra_input_project=(project id or name) -y

The app takes one non-optional input argument, hydra_input_project, which is the name or object ID of a DNAnexus project.

It returns as output a single .tsv file, which lists the mean coverage values for exons 3 and 27, the ratio of one to the other, and whether or not this ratio is above the threshold, for each sample in the project which has an exon_stats.tsv file. If a file is archived, no data will be returned.
