rule fastp:
    input:
        r1="data/raw/{sample}_1.fastq.gz",
        r2="data/raw/{sample}_2.fastq.gz"
    output:
        r1="results/trim/{sample}_1.trim.fastq.gz",
        r2="results/trim/{sample}_2.trim.fastq.gz",
        html="results/qc/{sample}.html",
        json="results/qc/{sample}.json"
    threads: 8
    singularity:
        "https://depot.galaxyproject.org/singularity/fastp:0.23.4--hadf994f_1"
    shell:
        """
        fastp \
          --in1 {input.r1} --in2 {input.r2} \
          --out1 {output.r1} --out2 {output.r2} \
          --html {output.html} --json {output.json} \
          --thread {threads}
        """