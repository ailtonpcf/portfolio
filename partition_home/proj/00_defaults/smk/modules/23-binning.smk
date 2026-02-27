# Tip: one binner at a time to speedup
rule metawrap:
    output:
        "binning.done"
    params:
        dir="binning_outdir",
        opt="--metabat2",
        reads_pattern="path",
        fasta="path_to_mags",
        omp=lambda wildcards, threads: threads
    conda:
        "/home/qi47rin/proj/00-default/conda/metawrap1.3.yaml"
    threads: 8
    resources:
        mem_mb="247000"
    shell:
        """
        export OMP_NUM_THREADS={params.omp};

        mkdir -p {params.dir}

        metawrap binning \
            -o {params.dir} \
            -t {threads} \
            -a {params.fasta} \
            {params.opt} \
            {params.reads_pattern}

        touch {output}
        """