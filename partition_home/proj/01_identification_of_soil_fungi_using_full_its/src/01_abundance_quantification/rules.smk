configfile: "/home/proj/02-compost-microbes/src/112-quantify-mock-spikein-sensitive/smk.config"
workdir: config['workdir']
include: "/home/proj/00-default/smk-functions/resources.py"

module aligners:
    snakefile: "/home/proj/00-default/smk-modules/aligners.smk"
    config: config

module samtools:
    snakefile: "/home/proj/00-default/smk-modules/samtools.smk"
    config: config

use rule * from samtools

rule targets:
    input:
        expand(os.path.join(config['TASK'], "idxstats/{ID}.{REFERENCE}.txt"), ID=['mock_01', 'mock_02', 'mock_03'], REFERENCE=['spikeIn_zymo'])
    default_target: True

rule merge_genomes:
    input:
        spike_dir="/work/ref/03-spike-in-genomes",
        zymo_dir="/work/ref/zymobiomics/genomes"
    output:
        temp(os.path.join(config['TASK'], "reference/{REFERENCE}.fa"))
    shell:
        """
        cat {input.spike_dir}/*.fna {input.zymo_dir}/*.fna > {output}
        """

# Discard what's not aligned
use rule strobealign_alignment from aligners with:
    input:
        r1="/vast/proj/02-compost-microbes/raw/07-compost-spikein-data/{ID}_1.fq.gz",
        r2="/vast/proj/02-compost-microbes/raw/07-compost-spikein-data/{ID}_2.fq.gz",
        ref=os.path.join(config['TASK'], "reference/{REFERENCE}.fa")
    output:
        temp(os.path.join(config['TASK'], "strobealign/{ID}.{REFERENCE}.sam"))
    params:
        opt="-U"

# -F 2304 Only primary reads aligned
use rule samtools_view from samtools with:
    input:
        os.path.join(config['TASK'], "strobealign/{ID}.{REFERENCE}.sam")
    params:
        opt="-F 2304"