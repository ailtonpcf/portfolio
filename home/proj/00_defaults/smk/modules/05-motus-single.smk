rule mOTU_database:
    output:
        os.path.join(config['PROJ'], "db.done"),
    conda:
        "/home/qi47rin/proj/00-default/conda/motus.yaml"
    threads: 1
    shell:
        """
        motus downloadDB
        touch {output}
        """

rule run_mOTU_single:
    input:
        single = os.path.join(config['PROJ'], "{ID}.fasta"),
        db = os.path.join(config['PROJ'], "db.done")
    output:
        os.path.join(config['PROJ'], "{ID}.tsv")
    conda:
        "/home/qi47rin/proj/00-default/conda/motus.yaml"
    params:
        omp=lambda wildcards, threads: threads
    resources:
        mem_mb=50000
    threads: 8
    shell:
        """
        export OMP_NUM_THREADS={params.omp};

        motus profile \
            -u \
            -c \
            -q \
            -s {input.single} \
            -o {output}\
            -n {wildcards.ID} \
            -t {threads}
        """

rule merge_profiles:
    input:
        "run_mOTU.files"
    output:
        os.path.join(config['PROJ'], "merged-profiles/prokaryotes.tsv")
    conda:
        "/home/qi47rin/proj/00-default/conda/motus.yaml"
    params:
        omp=lambda wildcards, threads: threads,
        profiles_dir="directory"
    resources:
        mem_mb=50000
    threads: 8
    shell:
        """
        export OMP_NUM_THREADS={params.omp};

        motus merge \
            -d {params.profiles_dir} \
            -o {output} \
            -t {threads}
        """