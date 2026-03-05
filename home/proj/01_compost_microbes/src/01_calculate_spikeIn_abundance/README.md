# Analysis 01: Estimating spike-in abundances

The merge_genomes rule in the rules.smk file concatenates all spike-in genomes and the genomes of the microbial standard used. Samples are aligned against these genome references, with unaligned reads discarded. As all the rules in samtools.smk have been imported, only those with file dependencies in the direct acyclic graph (DAG) will be used. These include samtools_view, samtools_sort and samtools_idxstats. In Snakemake, the first rule is always executed (in this pipeline, the rule targets) and often carries the final files that trigger the DAG.

- rules.smk describes the steps to be performed.
    - In the top section, important variables are defined, such as workdir. Then, for the partition that allows for heavy I/O, you specify [...]
    - It imports the rules of two other Snakemake files.
    - It generates a directed acyclic graph to solve file dependencies (files exist/don't exist/are outdated).
- run_mock.sh is a bash script that submits the Snakemake workflow to SLURM with the defined resource requirements.
    - Snakemake submits new jobs using the profile in the 00_defaults folder.
- smk.config stores the variables and paths used by Snakemake in YAML format.


