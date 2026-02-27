rule mmseqs_download_database:
    output: 
       os.path.join(config['MMSEQS2_DB_DIR'], "{MMSEQS2_DB_NAME}/{MMSEQS2_DB_NAME}")
    params:
        omp=lambda wildcards, threads: threads,
        tmp_dir="/vast/qi47rin/tmp"
    singularity:
        "https://depot.galaxyproject.org/singularity/mmseqs2:17.b804f--hd6d6fdc_1"
    threads: 8
    resources:
        mem_mb=50000
    shell: 
        """
        export OMP_NUM_THREADS={params.omp};
        mkdir -p {params.tmp_dir}
        mmseqs databases {wildcards.MMSEQS2_DB_NAME} {output} {params.tmp_dir} --threads {threads} --compressed 1
        """

rule mmseqs_import_sequences:
    input:
        os.path.join("{ID}")
    output: 
       os.path.join(config['TASK'], "seqs-db/{ID}")
    params:
        omp=lambda wildcards, threads: threads,
        opt=""
    singularity:
        "https://depot.galaxyproject.org/singularity/mmseqs2:17.b804f--hd6d6fdc_1"
    threads: 8
    shell: 
        """
        export OMP_NUM_THREADS={params.omp};
        mmseqs createdb {input} {output} {params.opt} --compressed 1
        """

rule mmseqs_taxonomy:
    input:
        seq_db=os.path.join(config['TASK'], "seqs-db/{ID}"),
        ref_db=os.path.join(config['MMSEQS2_DB_DIR'], "{MMSEQS2_DB_NAME}/{MMSEQS2_DB_NAME}")
    output: 
       os.path.join(config['TASK'], "taxonomy-db/{ID}.{MMSEQS2_DB_NAME}")
    params:
        omp=lambda wildcards, threads: threads,
        tmp_dir="/vast/qi47rin/tmp",
        opt="--tax-lineage 1"
    singularity:
        "https://depot.galaxyproject.org/singularity/mmseqs2:17.b804f--hd6d6fdc_1"
    retries: 3
    threads: 48
    resources:
        mem_mb=247000
    shell: 
        """
        export OMP_NUM_THREADS={params.omp};
        rm -rf {output}*
        mkdir -p {params.tmp_dir}
        mmseqs taxonomy {input.seq_db} {input.ref_db} {output} {params.tmp_dir} --threads {threads} {params.opt}
        touch {output}
        """

rule mmseqs_taxonomy_to_tsv:
    input:
        seq_db=os.path.join(config['TASK'], "seqs-db/{ID}"),
        ref_db=os.path.join(config['MMSEQS2_DB_DIR'], "{MMSEQS2_DB_NAME}/{MMSEQS2_DB_NAME}"),
        tax_db=os.path.join(config['TASK'], "taxonomy-db/{ID}.{MMSEQS2_DB_NAME}"),
    output: 
       os.path.join(config['TASK'], "taxonomy-tbl/{ID}.{MMSEQS2_DB_NAME}.tsv")
    params:
        omp=lambda wildcards, threads: threads,
        tmp_dir="/vast/qi47rin/tmp"
    singularity:
        "https://depot.galaxyproject.org/singularity/mmseqs2:17.b804f--hd6d6fdc_1"
    threads: 24
    shell: 
        """
        mmseqs createtsv {input.seq_db} {input.ref_db} {input.tax_db} {output} --threads {threads} 
        """

rule mmseqs_taxonomy_report:
    input:
        ref_db=os.path.join(config['MMSEQS2_DB_DIR'], "{MMSEQS2_DB_NAME}/{MMSEQS2_DB_NAME}"),
        tax_db=os.path.join(config['TASK'], "taxonomy-db/{ID}.{MMSEQS2_DB_NAME}"),
    output: 
       kraken=os.path.join(config['TASK'], "taxonomy-report/{ID}.{MMSEQS2_DB_NAME}.tsv"),
       krona=os.path.join(config['TASK'], "taxonomy-report/{ID}.{MMSEQS2_DB_NAME}.html")
    params:
        omp=lambda wildcards, threads: threads,
        tmp_dir="/vast/qi47rin/tmp"
    singularity:
        "https://depot.galaxyproject.org/singularity/mmseqs2:17.b804f--hd6d6fdc_1"
    threads: 8
    shell: 
        """
        mmseqs taxonomyreport {input.ref_db} {input.tax_db} {output.kraken} --threads {threads} --report-mode 0
        mmseqs taxonomyreport {input.ref_db} {input.tax_db} {output.krona} --threads {threads} --report-mode 1
        """

rule mmseqs_blast:
    input:
        seq_db=os.path.join(config['TASK'], "seqs-db/{ID}"),
        ref_db=os.path.join(config['MMSEQS2_DB_DIR'], "{MMSEQS2_DB_NAME}/{MMSEQS2_DB_NAME}")
    output: 
       os.path.join(config['TASK'], "search-db/{ID}.{MMSEQS2_DB_NAME}")
    params:
        omp=lambda wildcards, threads: threads,
        tmp_dir="/vast/qi47rin/tmp",
        opt="-a --cov-mode 2 --min-seq-id 0.9 --search-type 2 --orf-start-mode 0 --max-seqs 1",
    singularity:
        "https://depot.galaxyproject.org/singularity/mmseqs2:17.b804f--hd6d6fdc_1"
    threads: 48
    resources:
        mem_mb=247000
    shell: 
        """
        export OMP_NUM_THREADS={params.omp};
        mkdir -p {params.tmp_dir}
        mmseqs search {input.seq_db} {input.ref_db} {output} {params.tmp_dir} --threads {threads} {params.opt}
        touch {output}
        """

rule mmseqs_search_to_tsv:
    input:
        seq_db=os.path.join(config['TASK'], "seqs-db/{ID}"),
        ref_db=os.path.join(config['MMSEQS2_DB_DIR'], "{MMSEQS2_DB_NAME}/{MMSEQS2_DB_NAME}"),
        res_db=os.path.join(config['TASK'], "search-db/{ID}.{MMSEQS2_DB_NAME}")
    output: 
       os.path.join(config['TASK'], "search-tbl/{ID}.{MMSEQS2_DB_NAME}.tsv")
    params:
        tmp_dir="/vast/qi47rin/tmp",
        opt="--format-mode 4 \
            --format-output query,target,theader,evalue,bits,pident,qstart,qend,qlen,tstart,tend,tlen,alnlen,qcov,tcov"
    singularity:
        "https://depot.galaxyproject.org/singularity/mmseqs2:17.b804f--hd6d6fdc_1"
    threads: 24
    resources:
        mem_mb=50000
    shell: 
        """
        mmseqs convertalis {input.seq_db} {input.ref_db} {input.res_db} {output} --threads {threads} {params.opt}
        """