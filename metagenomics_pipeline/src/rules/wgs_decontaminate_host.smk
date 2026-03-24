rule decontaminate:
    input:
        r1="results/trim/{sample}_1.trim.fastq.gz",
        r2="results/trim/{sample}_2.trim.fastq.gz"
    output:
        r1="results/clean/{sample}_1.clean.fastq.gz",
        r2="results/clean/{sample}_2.clean.fastq.gz"
    threads: 16
    conda:
        "env/decontamination.yaml"
    shell:
        """
        bowtie2 -x resources/host_index/genome \
          -1 {input.r1} -2 {input.r2} \
          --very-sensitive -p {threads} \
        | samtools view -b -f 12 -F 256 \
        | samtools fastq \
          -1 {output.r1} -2 {output.r2}
        """