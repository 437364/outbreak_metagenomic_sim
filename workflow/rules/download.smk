import os
import pandas as pd

# create a dictionary from input table of samples that contains sample name + sra id
samples_information = pd.read_csv("results/SraRunTable_filtered_ordered.csv", sep=',', index_col=False)
sra_id = list(samples_information['Run'])
sample_id = list(samples_information['Sample Name'])
samples_dict = dict(zip(sample_id, sra_id))

configfile: "config/profile/config.yaml"

# rule all doesn't do anything, it just asks for its input files and thereby triggers subsequent rules
rule all:
	input:
	# input of the all rule are dictionary keys refered to as a wildcard "sample"
		expand("results/raw/{sample}_1.fastq", sample=samples_dict.keys())
 
rule download_sra:
	params:
	# get a corresponding value from the dictionary
	# needs to use the lambda function
		sra_id = lambda w: samples_dict[w.sample]
	output:
		fq1 = "results/raw/{sample}_1.fastq",
		fq2 = "results/raw/{sample}_2.fastq"
	resources:
		memgb="8gb",
		walltime="24:00:00",
		cpus=1

	run:
		print(wildcards.sample)
		print(params.sra_id)
		shell("""
		module add mambaforge-22.9.0
		conda activate sra-tools-3.0.3
		export OMP_NUM_THREADS=$PBS_NUM_PPN
		prefetch {params.sra_id} --max-size 100000000 -O results/sra/
		fasterq-dump -f -p --split-3 results/sra/{params.sra_id}/{params.sra_id}.sra -o results/raw/{wildcards.sample}
		rm -r results/sra/{params.sra_id}
		""")