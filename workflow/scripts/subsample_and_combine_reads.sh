#!/bin/bash

# mixing will take a long time, so it is disabled by default
mix=1

module add mambaforge-22.9.0
mamba activate /storage/brno2/home/kratka/.conda/envs/snakemake
module load seqtk

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
    back_1="seqtk sample -s1 ${background_data_dir}/${sample_name}_1.fastq ${background_reads} > results/combined/temp.fastq"
    echo $back_1
    eval $back_1
    # pathogen
    pat_1="seqtk sample -s1 ${pathogen_data}_1.fastq ${pathogen_reads} >> results/combined/temp.fastq"
    echo $pat_1
    eval $pat_1
    # mix 
    total_reads=$((background_reads + pathogen_reads))
    echo "Total reads: $total_reads"
    if [ $mix -eq 1 ]; then
        mix_1="seqtk sample -s100 results/combined/temp.fastq ${total_reads} > results/combined/${counter}_${sample_name}_1.fastq"
        echo $mix_1
        eval $mix_1
    else
        cp results/combined/temp.fastq results/combined/${counter}_${sample_name}_1.fastq
    fi

    # Subsample the reverse reads
    # background
    back_2="seqtk sample -s1 ${background_data_dir}/${sample_name}_2.fastq ${background_reads} > results/combined/temp.fastq"
    eval $back_2
    # pathogen
    pat_2="seqtk sample -s1 ${pathogen_data}_2.fastq ${pathogen_reads} >> results/combined/temp.fastq"
    eval $pat_2
    # mix
    if [ $mix -eq 1 ]; then
        mix_2="seqtk sample -s100 results/combined/temp.fastq ${total_reads} > results/combined/${counter}_${sample_name}_2.fastq"
        echo $mix_2
        eval $mix_2
    else
        cp results/combined/temp.fastq results/combined/${counter}_${sample_name}_2.fastq
    fi

    # Increase the counter
    counter=$((counter + 1))
    # for now quit after the first sample
    break


done < "$input_file"

# Remove the temporary file
rm results/combined/temp.fastq