#!/bin/bash

module add mambaforge-22.9.0
mamba activate /storage/brno2/home/kratka/.conda/envs/snakemake

input_file="results/subsampling_table_test.tsv"
background_data_dir="results/raw"
pathogen_data="results/pathogens/nipah/nipah_novaseq_100k"
counter=1

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
    seqtk sample -s 1 "$background_data_dir/$sample_name"_1.fastq "$background_reads" > "results/combined/"temp.fastq"
    # pathogen
    seqtk sample -s 1 "$pathogen_data"_1.fastq "$pathogen_reads" >> "results/combined/"temp.fastq"
    # mix 
    total_reads=$((background_reads + pathogen_reads))
    print $total_reads
    seqtk sample -s 1 "results/combined/temp.fastq" $total_reads" > "results/combined/"$counter_$sample_name"_1.fastq"

    # Subsample the reverse reads
    # background
    seqtk sample -s 1 "$background_data_dir/$sample_name"_2.fastq "$background_reads" > "results/combined/"temp.fastq"
    # pathogen
    seqtk sample -s 1 "$pathogen_data"_2.fastq "$pathogen_reads" >> "results/combined/"temp.fastq"
    # mix
    seqtk sample -s 1 "results/combined/temp.fastq "$total_reads" > "results/combined/"$counter_$sample_name"_2.fastq"

    # Increase the counter
    counter=$((counter + 1))


done < "$input_file"

# Remove the temporary file
rm "results/combined/temp.fastq"