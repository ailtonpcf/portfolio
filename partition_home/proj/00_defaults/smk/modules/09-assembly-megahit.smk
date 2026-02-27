rule megahit_reads_to_contigs:
    input:
        r1= "{ID}_1.fq.gz",
        r2= "{ID}_2.fq.gz"
    output:
        os.path.join(config['TASK'], config['FOLDERS']['assembly'], "{ID}.contigs.fa")
    params:
        omp=lambda wildcards, threads: threads,
        out_dir = os.path.join(config['TASK'], config['FOLDERS']['assembly']),
        opt= "--min-contig-len 300 --memory 0.9"
    singularity:
        os.path.join(config['IMAGES']['megahit'])
    threads: 24
    resources:
        mem_mb=247000
    shell:
        """
        export OMP_NUM_THREADS={params.omp};

        megahit \
            -1 {input.r1} \
            -2 {input.r2} \
            -t {threads} \
            {params.opt} \
            --out-dir {params.out_dir} \
            --out-prefix {wildcards.ID}
        """