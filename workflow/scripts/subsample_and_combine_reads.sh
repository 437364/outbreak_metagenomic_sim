#!/bin/bash

module add mambaforge-22.9.0
mamba activate /storage/brno2/home/kratka/.conda/envs/snakemake
module load seqtk

input_file="results/subsampling_table_test.tsv"
background_data_dir="results/raw"
pathogen_data="results/pathogens/nipah/nipah_novaseq_100k"
counter=1
echo "Counter: $counter"


# Read and process the TSV file
while IFS=$'\t' read -r sample_name collection_date sample_shortname total_reads days infected calculated_abundance background_reads lambda pathogen_reads actual_abundance
do
    # Skip the header line
    if [[ "$sample_name" == "Sample Name" ]]; then
        continue
    fi

    # print the values
    echo "Sample Name: $sample_name"
    echo "Background reads: $background_reads"
    echo "Pathogen reads: $pathogen_reads"

    # Subsample the forward reads
    # background
    back_1="seqtk sample -s1 ${background_data_dir}/${sample_name}_1.fastq ${background_reads} > results/combined/${counter}_${sample_name}_1.fastq
    eval $back_1
    # pathogen
    pat_1="seqtk sample -s1 ${pathogen_data}_1.fastq ${pathogen_reads} >> results/combined/${counter}_${sample_name}_1.fastq
    eval $pat_1

    # Subsample the reverse reads
    # background
    back_2="seqtk sample -s1 ${background_data_dir}/${sample_name}_2.fastq ${background_reads} > results/combined/${counter}_${sample_name}_2.fastq
    eval $back_2
    # pathogen
    pat_2="seqtk sample -s1 ${pathogen_data}_2.fastq ${pathogen_reads} >> results/combined/${counter}_${sample_name}_2.fastq
    eval $pat_2


    # Increase the counter
    counter=$((counter + 1))
    echo "Counter: $counter"


done < "$input_file"