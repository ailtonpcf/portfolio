rule samtools_view:
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
    shell: 
        """
        samtools flagstat -@ {threads} {input} -O tsv > {output}
        """

# That's the easiest to get reads aligned to the reference in tsv format
# Output
# reference_name   reference_length   mapped_reads   unmapped_reads
rule samtools_idxstats:
    input:
        os.path.join(config['TASK'], "sorted-bam/{ID}.{REFERENCE}.sorted.bam")
    output: 
       os.path.join(config['TASK'], "idxstats/{ID}.{REFERENCE}.txt")
    singularity:
        "https://depot.galaxyproject.org/singularity/samtools:1.18--hd87286a_0"
    threads: 1
    shell: 
        """
        samtools idxstats {input} > {output}
        """