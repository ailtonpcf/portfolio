rule fragment_sequences:
    input:
        "genome.fa"
    output:
        "slices.fa"
    singularity:
        "https://depot.galaxyproject.org/singularity/seqkit:2.7.0--h9ee0642_0"
    params:
        opt="--window 1000 --step 1000 --greedy"
    threads: 1
    shell:
        """
        seqkit sliding {params.opt} {input} > {output}
        """