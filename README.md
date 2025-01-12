# Repository for project "Simulating metagenomic data for novel pathogen outbreak detection"

This is my final project for the [Biosecurity Fundamentals course](https://biosecurityfundamentals.com/pandemics/) in collaboration with [Nucleic Acid Observatory](https://naobservatory.org/)

# How to use this repository
This repository contains the code for a demonstration of simulation of metagenomic data workflow. The code was executed on the [MetaCentrum HPC](https://metavo.metacentrum.cz/en/index.html), use on a different platform requires modification. The workflow has three steps better described in the [project report](https://github.com/437364/outbreak_metagenomic_sim/blob/main/results/report.pdf):

## Step 1: Background metagenomic data
[rules/download_background.smk](https://github.com/437364/outbreak_metagenomic_sim/blob/main/workflow/rules/download_background.smk) 

- downloads the background metagenomic data from the NCBI SRA database. The data is downloaded in the form of fastq files and stored in the data/raw directory, later used for subsampling
- then, quality assessment is performed on the downloaded data using FastQC and MultiQC tools. The results are stored in the results/fastqc and results/multiqc directories
- multiqc_general_stats.txt read counts are later used to limit the maximum number of reads for sumbsampling 
- is implemented in snakemake to better manage a large number of files and parallelization
- when the background data contains high level of duplication, it might not be suitable for the simulation, method for using such background data could be developed later ([see issue](https://github.com/437364/outbreak_metagenomic_sim/issues/3)) 

## Step 2: Pathogen data
[scripts/simulate_pathogen_reads.sh](https://github.com/437364/outbreak_metagenomic_sim/blob/main/workflow/scripts/simulate_pathogen_reads.sh)

- generates pair-end _in silico_ pathogen read fastqs from a genome fasta file using the InSilicoSeq tool and stores them in the results/pathogens/{pathogen_name} directory to be later used for subsampling
- fragment size setting and modifying read size could be developed later ([see issue](https://github.com/437364/outbreak_metagenomic_sim/issues/8))
- generates WGS reads, method for simulating amplicon data could be developed later ([see issue](https://github.com/437364/outbreak_metagenomic_sim/issues/5))
- an option for adding adapters to the simulated reads could be developed later ([see issue](https://github.com/437364/outbreak_metagenomic_sim/issues/1))

## Step 3: Growth calculation and subsampling
[notebooks/calculate_outbreak_growth.ipynb](https://github.com/437364/outbreak_metagenomic_sim/blob/main/workflow/notebooks/calculate_outbreak_growth.ipynb)

- multiple parameters can be easily modified in the simulation:
    - maximum number of reads in each sample
    - minimum number of reads in each sample
    - number of samples
    - conversion factor B (see [Grimm _et al._ 2023](https://doi.org/10.1101/2023.12.22.23300450) for more details)
    - generation time
    - reproduction number
    - starting prevalence
- generates [results/subsampling_table.tsv](https://github.com/437364/outbreak_metagenomic_sim/blob/main/results/subsampling_table.tsv) with background and pathogen abundances and read numbers to be used for subsampling 
- adding random noise to the calculated pathogen abundance values could be developed later ([see issue](https://github.com/437364/outbreak_metagenomic_sim/issues/2))
- a parameter for fluctuating reproduction number could be added later ([see issue](https://github.com/437364/outbreak_metagenomic_sim/issues/4))
- a estimation of decreasing shedding rate could be added later ([see issue](https://github.com/437364/outbreak_metagenomic_sim/issues/9))

[scripts/subsample_and_combine_reads.sh](https://github.com/437364/outbreak_metagenomic_sim/blob/main/workflow/scripts/subsample_and_combine_reads.sh)

- subsamples the background and pathogen reads using seqtk according to the subsampling table and concatenates them into paired-end fastq files
- simulated samples are stored in the results/combined directory
- combining the reads is done without mixing the order of background and pathogen reads, a method for mixing could be developed later ([see issue](https://github.com/437364/outbreak_metagenomic_sim/issues/6))
- parallelization of the subsampling could be developed later ([see issue](https://github.com/437364/outbreak_metagenomic_sim/issues/7))





