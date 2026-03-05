import pandas as pd
import os
configfile: "/home/proj/02-compost-microbes/src/26-compost76-its2-abundances/smk.config"
workdir: config['workdir']

module qc_its2:
    snakefile: "/home/proj/02-compost-microbes/src/00-pipelines/quality_control_se.smk"
    config: config

module profile_its2:
    snakefile: "/home/proj/02-compost-microbes/src/00-pipelines/01-closed-otu-picking.smk"
    config: config

use rule * from profile_its2
use rule * from qc_its2

SAMPLE, = glob_wildcards(os.path.join(config['FOLDERS']['raw'], "{ID}.fastq.gz"))

rule all:
    input:
        expand(os.path.join(config['FOLDERS']['raw'], "{ID}.fastq.gz"),ID = SAMPLE),
        expand(os.path.join(config['PROJ'], config['FOLDERS']['trim_se'], "{ID}.{EXT}"),ID = SAMPLE, EXT = ['trim.fq.gz', 'html', 'fastp.json']),
        os.path.join(config['PROJ'], config['FOLDERS']['multiqc']),
        expand(os.path.join(config['PROJ'], config['FOLDERS']['manifest'], "{DB}.tsv"), DB = ['unite97dyn']),
        expand(os.path.join(config['REFERENCE'], "{DB}.fna"), DB = ['unite97dyn']),
        expand(os.path.join(config['PROJ'], config['FOLDERS']['abundance'], "{DB}-feature-table-abundances.tsv"), DB = ['unite97dyn'])
    default_target: True

# overwrite rule input synthax
use rule trimming_merged_pe from qc_its2 with:
    input:
        os.path.join(config['FOLDERS']['raw'], "{ID}.fastq.gz")
    params:
        adapter= "--adapter_sequence GCATCGATGAAGAACGCAGC",
        omp=lambda wildcards, threads: threads

rule multiqc_collect_reports:
    input:
        expand(os.path.join(config['PROJ'], config['FOLDERS']['trim_se'], "{ID}.fastp.json"),ID = SAMPLE)
    output:
        directory(os.path.join(config['PROJ'], config['FOLDERS']['multiqc']))
    params:
        os.path.join(config['PROJ'], config['FOLDERS']['trim_se'])
    singularity:
        config['IMAGES']['multiqc']
    shell:
        """
        multiqc \
            --force \
            --dirs \
            --dirs-depth 1 \
            --outdir {output} {params}
        """

rule create_manifest:
    input:
        expand(os.path.join(config['PROJ'], config['FOLDERS']['trim_se'], "{ID}.trim.fq.gz"), ID = SAMPLE)
    output:
        os.path.join(config['PROJ'], config['FOLDERS']['manifest'], "{DB}.tsv")
    run:
        with open(output[0], "w") as manifest:
            manifest.write("sample-id\tabsolute-filepath\n")

            for file_path in input:
                # Extract the sample ID and file path from the input file path
                sample_id = file_path.split("/")[-1].split(".")[0]
                full_path = f"{config['workdir']}/{file_path}"
                manifest.write(f"{sample_id}\t{full_path}\n")
