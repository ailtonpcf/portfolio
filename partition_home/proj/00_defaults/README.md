# Partition home

Default folder harbors modular resources for conda, R and snakemake.

- conda keeps recipes for installing specific tool versions.
    - Manual or used by snakemake.
- R have custom functions used across different projects/tasks.
- smk keep modules, group of rules to perform a given task
    - As an example we have strobealign and samtools module.
    - Profile is a template that snakemake uses to submit jobs through slurm


