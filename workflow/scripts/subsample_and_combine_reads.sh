#!/bin/bash

# prepare the environment
module add mambaforge-22.9.0
mamba activate /storage/brno2/home/kratka/.conda/envs/snakemake
module load seqtk

# define input files
input_file="results/subsampling_table_test.tsv"
background_data_dir="results/raw"
pathogen_data="results/pathogens/nipah/nipah_novaseq_100k"

#initialize smaple counter
counter=1
echo "Counter: $counter"


# read and process the TSV file
mkdir -p results/combined

while IFS=$'\t' read -r sample_name collection_date sample_shortname total_reads days infected calculated_abundance background_reads lambda pathogen_reads actual_abundance
do
    # skip the header line
    if [[ "$sample_name" == "Sample Name" ]]; then
        continue
    fi

    # print the values
    echo "Sample Name: $sample_name"
    echo "Background reads: $background_reads"
    echo "Pathogen reads: $pathogen_reads"

    for i in {1..2} #for forward and reverse files
    do
        # subsample the background reads
        cmd="seqtk sample -s1 ${background_data_dir}/${sample_name}_${i}.fastq ${background_reads} > results/combined/${counter}_${sample_name}_${i}.fastq"
        echo $cmd
        eval $cmd
        # subsample the pathogen reads
        cmd="seqtk sample -s1 ${pathogen_data}_${i}.fastq ${pathogen_reads} >> results/combined/${counter}_${sample_name}_${i}.fastq"   
        echo $cmd
        eval $cmd

    # increase the counter
    counter=$((counter + 1))
    echo "Counter: $counter"

    done
done < $input_file