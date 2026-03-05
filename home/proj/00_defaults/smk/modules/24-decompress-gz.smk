# Tip: one binner at a time to speedup
rule decompress:
    input:
        "file.fq.gz"
    output:
        "file.fq"
    threads: 4
    shell:
        """
        pigz --processes {threads} --decompress --keep --stdout {input} > {output}
        """