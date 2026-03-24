configfile: "src/config.yaml"

SAMPLES = config["samples"]

include: "src/rules/qc_short_pe.smk"
include: "src/rules/wgs_decontaminate_host.smk"
include: "src/rules/wgs_assembly.smk"
include: "src/rules/wgs_binning.smk"
include: "src/rules/wgs_qc_mags.smk"

def get_reads(sample):
    if config["run"]["decontaminate"]:
        return [
            f"results/clean/{sample}_1.clean.fastq.gz",
            f"results/clean/{sample}_2.clean.fastq.gz"
        ]
    else:
        return [
            f"results/trim/{sample}_1.trim.fastq.gz",
            f"results/trim/{sample}_2.trim.fastq.gz"
        ]

rule all:
    input:
        expand("results/qc/{sample}.html", sample=SAMPLES),
        expand("results/assembly/{sample}.contigs.fa", sample=SAMPLES),
        "results/binning/binning.done",
        "results/qc/checkm_report.tsv"