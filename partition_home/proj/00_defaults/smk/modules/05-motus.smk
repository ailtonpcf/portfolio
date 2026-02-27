rule mOTU_database:
    output:
        os.path.join(config['PROJ'], "db.done"),
    conda:
        os.path.join(config['homedir'], "src/00-conda/motus.yaml")
    threads: 1
    shell:
        """
        motus downloadDB
        touch {output}
        """

rule run_mOTU:
    input:
        r1pd = os.path.join(config['PROJ'], config['FOLDERS']['fastq'], "{ID}_1.clean.fq.gz"),
        r2pd = os.path.join(config['PROJ'], config['FOLDERS']['fastq'], "{ID}_2.clean.fq.gz"),
        db = os.path.join(config['PROJ'], "db.done")
    output:
        os.path.join(config['PROJ'], config['FOLDERS']['motu'], "{ID}.raw.tsv")
    conda:
        os.path.join(config['homedir'], "src/00-conda/motus.yaml")
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
            -f {input.r1pd} \
            -r {input.r2pd} \
            -o {output}\
            -n {wildcards.ID} \
            -t {threads}
        """