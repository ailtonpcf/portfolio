rule indexing_bam:
    input:
        os.path.join(config['TASK'], config['FOLDERS']['sorted'], "{ID}.sorted.bam")
    output:
        os.path.join(config['TASK'], config['FOLDERS']['sorted'], "{ID}.sorted.bam.bai")
    singularity:
        config['IMAGES']['samtools']
    threads: 1
    shell:
        """
        samtools index {input} {output}
        """

rule report_alignment_summary:
    input:
        set_order=rules.indexing_bam.output,
        bam=os.path.join(config['TASK'], config['FOLDERS']['sorted'], "{ID}.sorted.bam")
    output:
        os.path.join(config['TASK'], config['FOLDERS']['stats'], "{ID}.txt")
    singularity:
        config['IMAGES']['samtools']
    threads: 1
    shell:
        """
        samtools idxstats {input.bam} > {output}
        """