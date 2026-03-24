rule megahit:
    input:
        r1="results/clean/{sample}_1.clean.fastq.gz",
        r2="results/clean/{sample}_2.clean.fastq.gz"
    output:
        "results/assembly/{sample}.contigs.fa"
    threads: 32
    singularity:
        "https://depot.galaxyproject.org/singularity/megahit:1.2.9--h43eeafb_5"
    shell:
        """
        megahit \
          -1 {input.r1} -2 {input.r2} \
          -o results/assembly/{wildcards.sample} \
          -t {threads}

        mv results/assembly/{wildcards.sample}/final.contigs.fa {output}
        """