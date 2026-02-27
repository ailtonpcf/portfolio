rule compost_wgs__create_kuniq_database:
    input:
        os.path.join(config['PROJ'], config['FOLDERS']['filt_gen'])
    output:
        directory(os.path.join(config['PROJ'], config['FOLDERS']['custom_db']))
    singularity:
        config['IMAGES']['kuniq']
    threads: 36
    params:
        omp=lambda wildcards, threads: threads,
        options = ""
    resources:
        mem_mb=3800000,
        time='3-00:00:00',
        partition='fat'
    shell:
        """
        export OMP_NUM_THREADS={params.omp};

        krakenuniq-build \
            --library-dir {input} \
            --taxonomy-dir {input} \
            --db {output} \
            --kmer-len 31 \
            --threads {threads} \
            --taxids-for-genomes \
            --taxids-for-sequences \
            --jellyfish-bin $(type -P -a jellyfish) \
            {params.options}
        """