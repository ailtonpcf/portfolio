rule generate_reads:
    input:
        "fragments.fa"
    output:
        r1="fragments_1.fq.gz",
        r2="fragments_2.fq.gz"
    singularity:
        "https://depot.galaxyproject.org/singularity/art:3.11.14--h2d50403_1"
    params:
        opt="--paired --len 150 --fcov 20 --mflen 200 --sdev 10",
        prefix="out",
        seed=1
    threads: 1
    shell:
        """
        art_illumina {params.opt} \
            --rndSeed {params.seed} \
            --in {input} \
            --out {params.prefix}
        """

rule compress_reads:
    input:
        r1="fragments_1.fq"
    output:
        r1="fragments_1.fq.gz"
    threads: 1
    shell:
        """
        pigz -p {threads} --stdout {input} > {output}
        """