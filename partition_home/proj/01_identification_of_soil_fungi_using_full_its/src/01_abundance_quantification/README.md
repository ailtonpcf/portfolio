# Analysis 01: Performs abundance quantification

- rules.smk describes the steps to be performed.
    - In the top we define important variables, like workdir Then you specify for the partition that allows for havy I/O.
    - It import the rules of two other snakemake files.
    - It generates the directly acyclic graph to solve file dependencies (files exist/don't exist/outdated).
- run_mock.sh It's a bash script that submits snakemake worflow to SLURM with defined resource requirements.
    - Snakemake submit new jobs by the profile present in the 00_defaults folder.
- smk.config keep variables, paths that are used by snakemake in a yaml format.


