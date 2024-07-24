# Enterovirus D68 Nextstrain Analysis
Performs a full Nextstrain analysis on Enterovirus D68 - currently a >=700bp VP1 run and a >=6000bp full-genome run. More may be added in future. 

**_Important note:_** This repository is currently in the process of being adapted to a new method of fetching new sequences, after the sunsetting (discontinuation) of ViPR. The intermediate solution is _not ideal_ but is temporary while we transition. Instructions below will adapt to reflect the current best way to run builds! 

**Thank you for your patience and understanding during this transition!**

Currently, the code will construct a local 'database' of the sequences you already have downloaded from NCBI. When you fetch new metadata from NCBI Virus, it will compare what's new against what you already have, and only download new sequences.

### Data
Note that the data used for these runs is *not* part of this repository. You can download publicly available data using the instructions below to add to your own run, and add any of your own data, too (see notes below on this).

## Getting Started 

To download files from NCBI you will need to provide an email address. This should be put in a `.env` file in the base directory, in the format `EMAIL=user@example.com` (add the `.env` file to your `.gitignore` to stop it being pushed publicly). To use this method of accessing the email, you will need to install the `dotenv` package - you can do this via PyPI with `pip install python-dotenv` (or via conda/micromamba with `conda install -c bioconda python-dotenv`)

### Data Download 
To run automatically-downloaded VP1 sequences with this pipeline, you'll need to install local BLAST for this analysis to work. Do this with: 
`sudo apt-get install ncbi-blast+` (or via conda/micromamba with `conda install -c bioconda blast`).

You should download metadata from [NCBI Virus](https://www.ncbi.nlm.nih.gov/labs/virus/vssi/#/find-data/virus), using TaxonID 42789 for EV-D68. After applying filters (if appropriate, see below), _do not select any rows_ and use the 'Download' button in the top-left. Select 'Results Table' and 'CSV format'. Select that you want to download all records.

Select all columns, and leave the accession without version.

Move this file into either `genome/data` or `vp1/data` as appropriate, and rename it to something sensible. 

### Data Preparation
You will now need to adapt the NCBI Virus download file to a format that will work with the older scripts (which expect ViPR input). As noted above, this is temporary and imperfect, but we are working on adapting this properly.

Run the `scripts/modifyNCBIVirus_to_old.R` in the commandline, passing in as command-line arguments the file you downloaded and is now in `/data` (as a csv), and your preferred output file, also in `/data` (a tsv).
If you struggle to run R on the command-line, you can also run the code in line-by-line in R or Rstudio, see the R script for how to do this.

Ensure that the name of your output file from the R script matches the name of the input files in Snakemake file under `rule files` for `raw_insdc_genome` and `raw_insdc_vp1`. 

#### For Full-Genome Run
Download in _CSV format_ all samples that are taxon ID 42789 in NCBI Virus, using the filters (on the left) to select only sequences with sequence length min:6400, max:8000.

**BE AWARE** There are two full-genome sequences with strain name `US/MO/14-18949` - accession numbers KM851227 and MH708882. MH708882 is a *mouse-adapted strain* and should be excluded. It is in `genome/config/dropped_strains.txt` as US/MO/14-18949-Mouse. The `scripts/vipr_parse.py` script will rename the strain name of MH708882 automatically to MO/14-18949-Mouse in both `genome/genbank/genbank_sequences.fasta` and `genome/genbank/genbank_meta.tsv`.
*(This is not a problem for the VP1 run, as the accession is added to the strain name, making them distinguishable. This new name for the mouse-adapted sequence is then in `vp1/config/dropped_strains.txt`.)*

#### For VP1 Run
Download in _CSV format_ all samples that are taxon ID 42789 in NCBI Virus, without using the filters.

#### Adding Additional Data
If you have other sequences & metadata (manually curated) that you'd like to add, you can include these in by replacing `manual_seqs` and `manual_meta`. These will not be blasted, so ensure they are either full-genome or contain the VP1 gene, depending on the run. Ensure the metadata format matches the columns and formatting expected in `results/metadata.tsv` (generated when you run using only NCBI data).

### Regions
This script will allow you to look at sequences by region as well as country. The Snakefile is already set up for this kind of analysis, and region will be automatically generated for all downloaded sequences.

*However*, you should ensure any additional metadata files have an additional column called 'region' with an entry for each sample.

### Running
The call needs to specify the 'length' being run (vp1 or genome) and can also specify the minimum length and maximum year of sequences to be included. See comments at the beginning of the Snakefile for more explanation and examples. Notes that specifying '2018y' will include sequences UP TO 2019.0 (2018 will be the last year included). 

There are also some Snakemake rules to make running some 'default' runs easier. (Ex: `snakemake default_genome` to run the default genome build.)

Due to changes in how `augur` works, filtering is temporarily adjusted until a workaround is found. Previously, full-genome runs were filtered to 200 sequences per month per country per year, while VP1 runs were filtered to 20 sequences per month per country per year. Currently, full-genome runs are filtered to 2400 sequences per country per year, and VP1 runs are filtered to 240 sequences per country per year -- there is no 'month' filter.

If minimum sequence length isn't specified, the defaults are >=700bp and >=6000bp for VP1 and genome runs, respectively.

Initial runs may take some time, as downloading all sequences from GenBank is slow.

All accession numbers are compared, so a sequence already included in additional sequence/metadata files will not be downloaded from GenBank, if you have included the accession number in the metadata.

## Reruns
This Snakefile is written to make adding new data from NCBI Virus easier. Simply download the latest full collection of samples from NCBI Virus (using the same instructions as above), place the new file in the `genome/data/` or `vp1/data/` subfolder, and repeat the above instructions. Run an appropriate `snakemake` command, and the script should automatically only download and BLAST sequences with accesssion numbers that have not previously been checked (even if they were not included in the analysis). 

After adding any new sequences, the a new full Nextstrain analysis will proceed. 

# Input Files
Download and prepare the appropriate sequences from NCBI Virus as described in Getting Started step above, with the resulting `.tsv` file(s) in `genome/data/` and/or `vpi/data/`. Running `snakemake [length]/temp/genbank_sequences.fasta` (where `[length]` is either 'genome' or 'vp1') will parse, format, and BLAST (for vp1) sequences from Genbank and create (within the `genome` and/or `vp1` folder) a 'genbank' folder with the files `genbank_meta.tsv` and `genbank_sequences.fasta`, which serve as the Genbank sequence starting points.

You can also have sequences to add manually, via the filenames `manual_seqs` and `manual_meta` in the appropriate `vp1` or `genome` folder. These must also be formatted and already checked that they are either full-genome or contain VP1 (depending on the run). Data replacing or extending the 'Swedish' data in the top-level `data` folder should be full-genome, as it will be used in both full-genome and VP1 runs.

You can add some extra data, particularly for sequences from GenBank where more detailed information can be scraped from papers, using the file named by `extra_meta`. This file should be tab-delimited with five columns: accession, date, age, sex, symptom, country, region. The data will be matched up to the combined metadata (from all of the above files) by accession. Dates need to be in the format YYYY-MM-DD and sex as `M` or `F`. Age can be multiple formats, such as: 2y3m, 20m, 2y, 15d, <12y, >79y, .5-10y. Unless specified by 'm' or 'd', numbers are taken as years: 2 is 2 years and 0.3 is 0.3 years. Ranges and greater-/less-than can be in months or years: 10m-3y. Symptoms can be as you wish, but should be consistent ('afm' and 'AFM' will be two different things).

# Technical Notes

## Strain names
In downloads as specified above, `strain` is not a unique identifier, as multiple segments may come from the same `strain`. This causes problems unique to VP1 analysis (with full-genome, this is not an issue). To handle this, in the VP1 run, the `vipr_parse.py` script generates new `strain` identifiers by combining the original `strain` column with the accession number, separated by a double-underscore. 

Unlike the VP1 run, strain names are not modified during the full-genome run.

## Blasting
Sequences from NCBI are not reliably labelled with the segment(s) they include (excepting whole-genome, it seems). In order to decide which sequences contain VP1, this script creates a local BLAST database against an EV-D68 reference genome VP1 sequence, then BLASTs all downloaded sequences against it. 

Sequences with matches of at least 300bp in VP1 are allowed to go into the final file. Because the default length for VP1 runs is 700bp, the script will report how many sequences are >=700bp and how many are between 300bp and 700bp. Further filtering for length will occur during the `filter` step.

For the default VP1 run, sequences with matches of at least 700bp are included. This was chosen because in initial runs in 2018, using >=600bp added only 47 sequences more and >=800bp lost 289 sequences. Only the matching sequence segment is taken for analysis.

When only whole-genome sequences are used, no BLASTing is done.

## Reruns
This Snakefile saves a copy of the most recently run parsed, downloaded ViPR file, and uses this to decide whether an accession number is 'new.' If you delete or modify the files in the 'genbank' folder that's created, then you may trigger a completely new run.



