rule trimming:
    input:
        r1=os.path.join(config['PROJ'], config['FOLDERS']['raw'], "{ID}_1.fq.gz"),
        r2=os.path.join(config['PROJ'], config['FOLDERS']['raw'], "{ID}_2.fq.gz")
    output:
        r1=os.path.join(config['PROJ'], config['FOLDERS']['trim'], "{ID}_1.trim.fq.gz"),
        r2=os.path.join(config['PROJ'], config['FOLDERS']['trim'], "{ID}_2.trim.fq.gz"),
        html=os.path.join(config['PROJ'], config['FOLDERS']['trim'], "{ID}.html"),
        json=os.path.join(config['PROJ'], config['FOLDERS']['trim'], "{ID}.fastp.json")
    singularity:
        config['IMAGES']['fastp']
    params:
        omp=lambda wildcards, threads: threads
    threads: 8
    shell:
        """
        export OMP_NUM_THREADS={params.omp};

        fastp \
            --in1 {input.r1} \
            --in2 {input.r2} \
            --out1 {output.r1} \
            --out2 {output.r2} \
            --json {output.json} \
            --html {output.html} \
            --thread {threads} \
            --cut_mean_quality 20 \
            --length_required 100 \
            --detect_adapter_for_pe \
            --cut_front \
            --cut_tail \
            -q 15
        """

rule human_decontamination_bwa_index:
    input:
        config['REFERENCE']['hs_genome']
    output:
        directory(os.path.join(config['PROJ'], config['FOLDERS']['hsa_index']))
    singularity:
        config['IMAGES']['bwaMem2']
    params:
        ref=os.path.join(config['PROJ'], config['FOLDERS']['hsa_index'], "grch38"),
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

rule human_decontamination_bwa_alignment:
    input:
        ref=os.path.join(config['PROJ'], config['FOLDERS']['hsa_index']),
        r1=os.path.join(config['PROJ'], config['FOLDERS']['trim'], "{ID}_1.trim.fq.gz"),
        r2=os.path.join(config['PROJ'], config['FOLDERS']['trim'], "{ID}_2.trim.fq.gz"),
    output:
        os.path.join(config['PROJ'], config['FOLDERS']['hsa_aln'], "{ID}.sam")
    params:
        ref=os.path.join(config['PROJ'], config['FOLDERS']['hsa_index'], "grch38"),
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


rule human_decontamination_filter_unaligned:
    input:
        os.path.join(config['PROJ'], config['FOLDERS']['hsa_aln'], "{ID}.sam")
    output:
        os.path.join(config['PROJ'], config['FOLDERS']['hsa_unal'], "{ID}.clean.bam")
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

rule human_decontamination_sort_bam:
    input:
        os.path.join(config['PROJ'], config['FOLDERS']['hsa_unal'], "{ID}.clean.bam")
    output:
        os.path.join(config['PROJ'], config['FOLDERS']['hsa_sort'], "{ID}.clean.sort.bam")
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

rule non_human_reads:
    input:
        os.path.join(config['PROJ'], config['FOLDERS']['hsa_sort'], "{ID}.clean.sort.bam")
    output:
        r1=os.path.join(config['PROJ'], config['FOLDERS']['hsa_clean'], "{ID}_1.clean.fq.gz"), 
        r2=os.path.join(config['PROJ'], config['FOLDERS']['hsa_clean'], "{ID}_2.clean.fq.gz")
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