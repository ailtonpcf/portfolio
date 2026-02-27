rule decontamination_bwamem2_index:
    input:
        "reference.fa"
    output:
        directory(os.path.join(config['TASK'], config['FOLDERS']['index']))
    singularity:
        config['IMAGES']['bwaMem2']
    params:
        ref=os.path.join(config['TASK'], config['FOLDERS']['index'], config['INDEX_BASE']),
        omp=lambda wildcards, threads: threads
    threads: 8
    resources:
        mem_mb=100000
    shell:
        """
        export OMP_NUM_THREADS={params.omp};

        mkdir -p {output} &&
        bwa-mem2 index -p {params.ref} {input}
        """

rule decontamination_bwamem2_alignment:
    input:
        ref=os.path.join(config['TASK'], config['FOLDERS']['index']),
        r1= "{ID}_1.fq.gz",
        r2= "{ID}_2.fq.gz"
    output:
        os.path.join(config['TASK'], config['FOLDERS']['aln'], "{ID}.sam")
    params:
        ref=os.path.join(config['TASK'], config['FOLDERS']['index'], config['INDEX_BASE']),
        omp=lambda wildcards, threads: threads
    singularity:
        config['IMAGES']['bwaMem2']
    threads: 8
    resources:
        mem_mb=100000
    shell:
        """
        export OMP_NUM_THREADS={params.omp};

        bwa-mem2 mem -t {threads} {params.ref} {input.r1} {input.r2} > {output}
        """


rule decontamination_filter_unaligned:
    input:
        os.path.join(config['TASK'], config['FOLDERS']['aln'], "{ID}.sam")
    output:
        os.path.join(config['TASK'], config['FOLDERS']['unal'], "{ID}.clean.bam")
    singularity:
        config['IMAGES']['samtools']
    params:
        omp=lambda wildcards, threads: threads
    threads: 8
    resources:
        mem_mb=100000
    shell:
        """
        export OMP_NUM_THREADS={params.omp};

        samtools view -b -f 4 -@{threads} {input} > {output}
        """

rule decontamination_sort_bam:
    input:
        os.path.join(config['TASK'], config['FOLDERS']['unal'], "{ID}.clean.bam")
    output:
        os.path.join(config['TASK'], config['FOLDERS']['sort'], "{ID}.clean.sort.bam")
    singularity:
        config['IMAGES']['samtools']
    params:
        omp=lambda wildcards, threads: threads
    threads: 8
    resources:
        mem_mb=100000
    shell:
        """
        export OMP_NUM_THREADS={params.omp};

        samtools sort -n -@{threads} -o {output} {input}
        """

rule decontamination_clean_reads:
    input:
        os.path.join(config['TASK'], config['FOLDERS']['sort'], "{ID}.clean.sort.bam")
    output:
        r1=os.path.join(config['TASK'], config['FOLDERS']['clean'], "{ID}_1.clean.fq.gz"), 
        r2=os.path.join(config['TASK'], config['FOLDERS']['clean'], "{ID}_2.clean.fq.gz")
    singularity:
        config['IMAGES']['samtools']
    params:
        omp=lambda wildcards, threads: threads
    threads: 8
    resources:
        mem_mb=100000
    shell:
        """
        export OMP_NUM_THREADS={params.omp};

        samtools fastq \
            -@{threads} \
            -1 {output.r1} \
            -2 {output.r2} \
            -0 /dev/null \
            -s /dev/null \
            -n \
            {input}
        """