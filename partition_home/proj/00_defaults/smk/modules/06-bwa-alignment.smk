rule bwa_mem2_index:
    input:
        "{REFERENCE}.fa"
    output:
        os.path.join(config['TASK'], "bwa-mem2-index/{REFERENCE}.pac")
    params:
        idx=lambda wc, output: output[0].replace(".pac", "")
    singularity:
        "https://depot.galaxyproject.org/singularity/bwa-mem2:2.2.1--he70b90d_8"
    threads: 1
    resources:
        mem_mb=50000
    shell:
        """
        bwa-mem2 index -p {params.idx} {input}
        """

rule bwa_mem2_alignment:
    input:
        ref=os.path.join(config['TASK'], "bwa-mem2-index/{REFERENCE}.pac"),
        r1=os.path.join(config['TASK'], "{ID}_1.fq.gz"),
        r2=os.path.join(config['TASK'], "{ID}_2.fq.gz"),
    output:
        temp(os.path.join(config['TASK'], "sam/{ID}.{REFERENCE}.sam"))
    params:
        idx=lambda wc, input: input.ref.replace(".pac", "")
    singularity:
        "https://depot.galaxyproject.org/singularity/bwa-mem2:2.2.1--he70b90d_8"
    resources:
        mem_mb=50000
    threads: 8
    shell:
        """
        bwa-mem2 mem -t {threads} {params.idx} {input.r1} {input.r2} -o {output}
        """

rule bwa_mem2_se_alignment:
    input:
        ref=os.path.join(config['TASK'], "bwa-mem2-index/{REFERENCE}.pac"),
        r1=os.path.join(config['TASK'], "{ID}_1.fq.gz")
    output:
        temp(os.path.join(config['TASK'], "sam/{ID}.{REFERENCE}.sam")),
    params:
        idx=os.path.join(config['TASK'], "bwa-mem2-index/{REFERENCE}")
    singularity:
        "https://depot.galaxyproject.org/singularity/bwa-mem2:2.2.1--he70b90d_8"
    resources:
        mem_mb=50000
    threads: 8
    shell:
        """
        bwa-mem2 mem -t {threads} {params.idx} {input.r1} -o {output}
        """

rule samtools_sam_to_bam:
    input:
        os.path.join(config['TASK'], "sam/{ID}.{REFERENCE}.sam")
    output:
        temp(os.path.join(config['TASK'], "bam/{ID}.{REFERENCE}.bam"))
    params:
        opt="-q 30"
    singularity:
        "https://depot.galaxyproject.org/singularity/samtools:1.18--hd87286a_0"
    threads: 8
    resources:
        mem_mb=50000
    shell:
        """
        samtools view -@ {threads} {params.opt} -hbS {input} > {output}
        """

rule samtools_sort:
    input:
        os.path.join(config['TASK'], "bam/{ID}.{REFERENCE}.bam")
    output:
        bam=temp(os.path.join(config['TASK'], "sorted-bam/{ID}.{REFERENCE}.sorted.bam")),
        bai=temp(os.path.join(config['TASK'], "sorted-bam/{ID}.{REFERENCE}.sorted.bam.bai"))
    singularity:
        "https://depot.galaxyproject.org/singularity/samtools:1.18--hd87286a_0"
    threads: 8
    resources:
        mem_mb=50000
    shell:
        """
        samtools sort -@ {threads} {input} -o {output.bam}
        samtools index -@ {threads} {output.bam}
        """

rule samtools_coverage:
    input:
        os.path.join(config['TASK'], "sorted-bam/{ID}.{REFERENCE}.sorted.bam")
    output: 
       os.path.join(config['TASK'], "coverage/{ID}.{REFERENCE}.txt")
    singularity:
        "https://depot.galaxyproject.org/singularity/samtools:1.18--hd87286a_0"
    threads: 1
    resources:
        mem_mb=50000
    shell: 
        """
        samtools coverage {input} -o {output}
        """

rule samtools_flagstat:
    input:
        os.path.join(config['TASK'], "sorted-bam/{ID}.{REFERENCE}.sorted.bam")
    output: 
       os.path.join(config['TASK'], "flagstat/{ID}.{REFERENCE}.txt")
    singularity:
        "https://depot.galaxyproject.org/singularity/samtools:1.18--hd87286a_0"
    threads: 1
    resources:
        mem_mb=50000
    shell: 
        """
        samtools flagstat -@ {threads} {input} -O tsv > {output}
        """