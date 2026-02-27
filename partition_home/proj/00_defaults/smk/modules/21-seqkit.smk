rule find_patterns:
    output:
        "slices.fa"
    singularity:
        "https://depot.galaxyproject.org/singularity/seqkit:2.7.0--h9ee0642_0"
    params:
        opt="--by-name --use-regexp --pattern string_to_find",
        fasta="genome.fa"
    threads: 4
    shell:
        """
        seqkit grep --threads {threads} {params.opt} {params.fasta} > {output}
        """

rule seqkit_filter_seqs_from_file_ids:
    input:
        fa="file.fa",
        txt="ids.list"
    output:
        "filtered_seqs.fa"
    singularity:
        "https://depot.galaxyproject.org/singularity/seqkit:2.7.0--h9ee0642_0"
    threads: 4
    shell:
        """
        seqkit grep --threads {threads} -if {input.txt} {input.fa} -o {output}
        """
