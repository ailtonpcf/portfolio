rule bam_for_comebin:
    output:
        bam="bam_outdir"
    params:
        reads_pattern="path",
        fasta="path_to_mags",
        omp=lambda wildcards, threads: threads,
        gen_cov_script="path_to.sh"
    conda:
        "/home/qi47rin/proj/00-default/conda/comebin.yaml"
    threads: 48
    resources:
        mem_mb="247000"
    shell:
        """
        export OMP_NUM_THREADS={params.omp};

        bash {params.gen_cov_script} \
            -a {params.fasta} \
            -t {threads} \
            -o {output.bam} \
            {params.reads_pattern}
        """

rule comebin:
    input:
        bam="bam_outdir"
    output:
        bins="bins_outdir"
    params:
        fasta="path_to_mags",
        omp=lambda wildcards, threads: threads,
        comebin_script="path_to.sh"
    conda:
        "/home/qi47rin/proj/00-default/conda/comebin.yaml"
    threads: 48
    resources:
        partition="gpu",
        mem_mb="247000"
    shell:
        """
        export OMP_NUM_THREADS={params.omp};

        bash {params.comebin_script}\
            -a {params.fasta} \
            -o {output.bins} \
            -p {input.bam} \
            -t {threads}
        """

rule comebin_gpu:
    input:
        bam="bam_outdir"
    output:
        bins="bins_outdir"
    params:
        fasta="path_to_mags",
        omp=lambda wildcards, threads: threads,
        gpu_module="module load nvidia/cuda/11.8.0",
        comebin_script="path_to.sh"
    conda:
        "/home/qi47rin/proj/00-default/conda/comebin.yaml"
    threads: 48
    resources:
        partition="gpu",
        mem_mb="247000"
    shell:
        """
        export OMP_NUM_THREADS={params.omp};

        {params.gpu_module}

        bash {params.comebin_script}\
            -a {params.fasta} \
            -o {output.bins} \
            -p {input.bam} \
            -t {threads}
        """