rule trimming_merged_pe:
    input:
        os.path.join(config['PROJ'], config['FOLDERS']['raw_fq_se'], "{ID}.fq.gz")
    output:
        out=os.path.join(config['PROJ'], config['FOLDERS']['trim_se'], "{ID}.trim.fq.gz"),
        html=os.path.join(config['PROJ'], config['FOLDERS']['trim_se'], "{ID}.html"),
        json=os.path.join(config['PROJ'], config['FOLDERS']['trim_se'], "{ID}.fastp.json")
    singularity:
        config['IMAGES']['fastp']
    params:
        omp=lambda wildcards, threads: threads,
        adapter= ""
    threads: 8
    shell:
        """
        export OMP_NUM_THREADS={params.omp};

        fastp \
            -i {input} \
            -o {output.out} \
            --json {output.json} \
            --html {output.html} \
            --thread {threads} \
            --cut_mean_quality 15 \
            --length_required 100 \
            --cut_front \
            --cut_tail \
            {params.adapter} \
            -q 15
        """