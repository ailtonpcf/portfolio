rule kma_clean_memory:
    output:
        touch(os.path.join(config['TASK'], "shared.destroyed"))
    params:
        idx_base="/work/qi47rin/proj/02-compost-microbes/cache/29-compost76-wgs-ccmetagen/kma-indexes/all_king"
    singularity:
        "https://depot.galaxyproject.org/singularity/ccmetagen:1.4.1--pyh7cba7a3_0"
    resources:
        partition='fat',
        mem_mb=10000
    shell:
        """
        kma shm -t_db {params.idx_base} -shmLvl 1 -destroy
        """