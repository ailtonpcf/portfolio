rule HMMER_create_profile:
    input:
        "file.afa"
    output:
        os.path.join(config['TASK'], config['FOLDERS']['hmm'], "profile.hmm")
    params:
        omp=lambda wildcards, threads: threads
    singularity:
        os.path.join(config['IMAGES']['hmmer'])
    threads: 24
    resources:
        mem_mb=247000
    shell:
        """
        export OMP_NUM_THREADS={params.omp};

        hmmbuild \
            --cpus {threads} \
            {output} \
            {input}
        """

rule HMMER_hmmsearch:
    input:
        hmm = os.path.join(config['TASK'], config['FOLDERS']['hmm'], "profile.hmm"),
        seqs = "{ID}.fa"
    output:
        os.path.join(config['TASK'], config['FOLDERS']['hmm_res'], "{ID}.txt")
    params:
        omp=lambda wildcards, threads: threads
    singularity:
        os.path.join(config['IMAGES']['hmmer'])
    threads: 24
    resources:
        mem_mb=247000
    shell:
        """
        export OMP_NUM_THREADS={params.omp};

        hmmsearch \
            --cpu {threads} \
            {input.hmm} \
            {input.seqs} \
            > {output}
        """