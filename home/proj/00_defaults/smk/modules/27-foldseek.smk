FOLDSEEK_DB_NAME_MAP = {
    'Alphafold-Swiss-Prot':'Alphafold/Swiss-Prot',
    'Alphafold-UniProt50':'Alphafold/UniProt50',
    'ESMAtlas30':'ESMAtlas30',
    'PDB':'PDB',
    'BFMD':'BFMD',
    'BFVD':'BFVD'
}

rule foldseek_download_database:
    output:
        os.path.join(config['FOLDSEEK_DB_DIR'], "databases/{FOLDSEEK_DB_KEY}_ca")
    params:
        db_name    = lambda wildcards: FOLDSEEK_DB_NAME_MAP[wildcards.FOLDSEEK_DB_KEY],
        omp        = lambda wildcards, threads: threads,
        tmp_dir    = lambda wildcards: os.path.join(config['TASK'], "tmp"),
    singularity:
        "https://depot.galaxyproject.org/singularity/foldseek:10.941cd33--h5021889_0"
    threads: 8
    resources:
        mem_mb    = 50000,
        partition = "gpu,gpu-veo",
        gres      = "gpu:a100:1"
    shell:
        """
        export OMP_NUM_THREADS={params.omp};
        mkdir -p {params.tmp_dir}
        foldseek databases {params.db_name} {output} {params.tmp_dir} --threads {threads} --compressed 1
        """

rule foldseek_pad_database:
    input:
        os.path.join(config['FOLDSEEK_DB_DIR'], "databases/{FOLDSEEK_DB_KEY}_ca")
    output:
        os.path.join(config['FOLDSEEK_DB_DIR'], "pad-databases/{FOLDSEEK_DB_KEY}")
    params:
        omp=lambda wildcards, threads: threads,
        tmp_dir=lambda wildcards, output: os.path.dirname(output[0]),
        opt="-v 3"
    singularity:
        "https://depot.galaxyproject.org/singularity/foldseek:10.941cd33--h5021889_0"
    threads: 1
    resources:
        mem_mb    = 50000,
        partition = "gpu,gpu-veo",
        gres      = "gpu:a100:1"
    shell:
        """
        export OMP_NUM_THREADS={params.omp};
        rm -rf {output}
        mkdir -p {params.tmp_dir}
        foldseek makepaddedseqdb {input} {output} {params.opt}
        """

rule foldseek_create_db:
    input:
        os.path.join(config['TASK'], "structure/{ID}")
    output: 
        os.path.join(config['TASK'], "pdb-database/{ID}")
    params:
        omp         = lambda wildcards, threads: threads,
        opt         = "--gpu 1"
    singularity:
        "https://depot.galaxyproject.org/singularity/foldseek:10.941cd33--h5021889_0"
    threads: 32
    resources:
        mem_mb    = 50000,
        partition = "gpu,gpu-veo",
        gres      = "gpu:a100:1"
    shell: 
        """
        export OMP_NUM_THREADS={params.omp};
        foldseek createdb {input} {output} {params.opt} --threads {threads}
        """

rule foldseek_search:
    input:
        query_pdb = os.path.join(config['TASK'], "pdb-database/{ID}"),
        target_db = os.path.join(config['FOLDSEEK_DB_DIR'], "pad-databases/{FOLDSEEK_DB_KEY}")
    output: 
        os.path.join(config['TASK'], "foldseek-search/{ID}/{ID}_{FOLDSEEK_DB_KEY}")
    params:
        omp         = lambda wildcards, threads: threads,
        opt         = "-a --gpu 1",
        tmp_dir     = lambda wildcards: os.path.join(config['TASK'], "tmp"),
        out_dir     = os.path.join(config['TASK'], "foldseek-search/{ID}")
    singularity:
        "https://depot.galaxyproject.org/singularity/foldseek:10.941cd33--h5021889_0"
    threads: 32
    resources:
        mem_mb    = 50000,
        partition = "gpu,gpu-veo",
        gres      = "gpu:a100:1"
    shell: 
        """
        export OMP_NUM_THREADS={params.omp};
        mkdir -p {params.tmp_dir} {params.out_dir}
        foldseek search {input.query_pdb} {input.target_db} {output} {params.tmp_dir} --threads {threads} {params.opt}
        touch {output}
        """

rule foldseek_convertalis:
    input:
        query_pdb = os.path.join(config['TASK'], "pdb-database/{ID}"),
        target_db = os.path.join(config['FOLDSEEK_DB_DIR'], "pad-databases/{FOLDSEEK_DB_KEY}"),
        result_db = os.path.join(config['TASK'], "foldseek-search/{ID}/{ID}_{FOLDSEEK_DB_KEY}")
    output: 
        os.path.join(config['TASK'], "results/{ID}_{FOLDSEEK_DB_KEY}.tsv")
    params:
        omp         = lambda wildcards, threads: threads,
        format_mode = "--format-mode 4",
        opt         = "--format-output query,target,theader,evalue,prob,qtmscore,ttmscore,alnlen,alntmscore,rmsd,bits,qcov",
    singularity:
        "https://depot.galaxyproject.org/singularity/foldseek:10.941cd33--h5021889_0"
    threads: 32
    resources:
        mem_mb    = 50000,
        partition = "gpu,gpu-veo",
        gres      = "gpu:a100:1"
    shell: 
        """
        export OMP_NUM_THREADS={params.omp};
        foldseek convertalis {input.query_pdb} {input.target_db} {input.result_db} {output} --threads {threads} {params.format_mode} {params.opt}
        """
