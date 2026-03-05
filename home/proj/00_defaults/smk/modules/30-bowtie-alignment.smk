rule bowtie2_index:
    input:
        "/work/qi47rin/proj/02-compost-microbes/cache/21-raspir/fixed-fasta/genomes.fa"
    output:
        directory("/work/qi47rin/proj/02-compost-microbes/cache/21-raspir/b2-indexes")
    params:
        idx="/work/qi47rin/proj/02-compost-microbes/cache/21-raspir/b2-indexes/raspir",
        omp=lambda wildcards, threads: threads,
    conda:
        os.path.join(config['homedir'], "src/00-conda/raspir.yaml")
    threads: 8
    resources:
        mem_mb=100000
    shell:
        """
        export OMP_NUM_THREADS={params.omp};

        mkdir -p {output}
        bowtie2-build --threads {threads} {input} {params.idx}
        """

rule bowtie2_alignment:
    input:
        r1 = "/work/qi47rin/proj/02-compost-microbes/cache/21-raspir/data/{ID}_1.clean.fq.gz",
        r2 = "/work/qi47rin/proj/02-compost-microbes/cache/21-raspir/data/{ID}_2.clean.fq.gz",
        idx= rules.bowtie2_indexing.output
    output:
        "/work/qi47rin/proj/02-compost-microbes/cache/21-raspir/b2-alignment-sam/{ID}.sam"
    params:
        idx=rules.bowtie2_indexing.params[0],
        omp=lambda wildcards, threads: threads,
    conda:
        os.path.join(config['homedir'], "src/00-conda/raspir.yaml")
    threads: 48
    resources:
        mem_mb=248000
    shell:
        """
        export OMP_NUM_THREADS={params.omp};

        bowtie2 --quiet --omit-sec-seq --no-discordant --no-unal -p {threads} -x {params.idx} -1 {input.r1} -2 {input.r2} -S {output}
        """