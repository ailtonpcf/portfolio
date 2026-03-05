rule kma_index_reference:
    input:
        "genomes_concat.fa"
    output:
        os.path.join(config['TASK'], "kma-indexes/db-build.done")
    params:
        idx_base=os.path.join(config['TASK'], "kma-indexes/all_king"),
        idx_dir =os.path.join(config['TASK'], "kma-indexes"),
    singularity:
        "https://depot.galaxyproject.org/singularity/ccmetagen:1.4.1--pyh7cba7a3_0"
    threads: 2
    resources:
        partition='fat',
        mem_mb=1300000
    retries: 2
    shell:
        """
        mkdir -p {params.idx_dir}
        kma_index -i {input} -o {params.idx_base} -NI -Sparse -
        touch {output}
        """