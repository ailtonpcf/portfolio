rule binning:
    input:
        contigs="results/assembly/{sample}.contigs.fa"
    output:
        touch("results/binning/binning.done")
    conda:
        "env/metawrap1.3.yaml"
    shell:
        """
        metawrap binning \
          -o results/binning \
          -t 32 \
          -a {input.contigs} \
          results/clean/{wildcards.sample}_1.clean.fastq.gz \
          results/clean/{wildcards.sample}_2.clean.fastq.gz
        """