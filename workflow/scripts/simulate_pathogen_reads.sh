#!/bin/bash

module add mambaforge-22.9.0
mamba activate /storage/brno2/home/kratka/.conda/envs/snakemake
cd /storage/brno2/home/kratka/outbreak_metagenomic_sim/
iss generate -p 4 --seed 1 -g results/pathogens/nipah/GCF_000863625.1_ViralProj15443_genomic.fna -n 100000 -m NovaSeq -o results/pathogens/nipah/nipah_novaseq_100k