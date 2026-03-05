rule genome_metrics:
    output:
        "genome-length/counts.tsv"
    singularity:
        "https://depot.galaxyproject.org/singularity/seqkit:2.7.0--h9ee0642_0"
    params:
        fa_dir="",
        opt="--tabular"
    threads: 8
    shell:
        """
        seqkit \
            stats {params.opt} \
            -j {threads} \
            -o {output} \
            --infile-list <(find {params.fa_dir} -name "*.fna") \
        """