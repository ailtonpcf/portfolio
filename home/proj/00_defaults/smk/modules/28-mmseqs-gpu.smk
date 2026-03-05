rule mmseqs_pad_database_for_gpu:
    input:
        os.path.join(config['MMSEQS2_DB_DIR'], "{MMSEQS2_DB_NAME}/{MMSEQS2_DB_NAME}")
    output:
        os.path.join(config['MMSEQS2_DB_DIR'], "pad-databases/{MMSEQS2_DB_NAME}/{MMSEQS2_DB_NAME}")
    params:
        omp=lambda wildcards, threads: threads,
        tmp_dir=os.path.join(config['TMP'])
    singularity:
        "https://depot.galaxyproject.org/singularity/mmseqs2:17.b804f--hd6d6fdc_1"
    threads: 48
    resources:
        mem_mb    = 247000,
        partition = "gpu,gpu-veo",
        gres      = "gpu:a100:1",
        time      = "3-00:00:00"
    shell:
        """
        mkdir -p {params.tmp_dir}
        mmseqs makepaddedseqdb {input} {output} --threads {threads}
        touch {output}
        """

rule mmseqs_taxonomy_gpu:
    input:
        seq_db=os.path.join(config['TASK'], "seqs-db/{ID}"),
        ref_db=os.path.join(config['MMSEQS2_DB_DIR'], "pad-databases/{MMSEQS2_DB_NAME}/{MMSEQS2_DB_NAME}")
    output: 
       os.path.join(config['TASK'], "taxonomy-db/{ID}.{MMSEQS2_DB_NAME}")
    params:
        omp=lambda wildcards, threads: threads,
        tmp_dir=os.path.join(config['TMP']),
        devices="CUDA_VISIBLE_DEVICES=0",
        opt="--tax-lineage 1"
    singularity:
        "/home/groups/Fungal/singularity_images2/mmseqs2_master-cuda12.sif"
    retries: 3
    threads: 48
    resources:
        mem_mb    = 500000,
        partition = "gpu,gpu-veo",
        gres      = "gpu:a100:1",
        time      = "3-00:00:00"
    shell: 
        """
        export OMP_NUM_THREADS={params.omp};
        rm -rf {output}*
        mkdir -p {params.tmp_dir}
        module purge
        module load nvidia/cuda/12.4.0
        nvidia-smi

        {params.devices} mmseqs_avx2 taxonomy {input.seq_db} {input.ref_db} {output} {params.tmp_dir} --threads {threads} {params.opt} --gpu 1 
        touch {output}
        """

rule mmseqs_blast_gpu:
    input:
        seq_db=os.path.join(config['TASK'], "seqs-db/{ID}"),
        ref_db=os.path.join(config['MMSEQS2_DB_DIR'], "pad-databases/{MMSEQS2_DB_NAME}/{MMSEQS2_DB_NAME}"),
    output: 
       os.path.join(config['TASK'], "search-db/{ID}.{MMSEQS2_DB_NAME}")
    params:
        omp=lambda wildcards, threads: threads,
        tmp_dir=os.path.join(config['TMP']),
        opt="-a",
        devices="CUDA_VISIBLE_DEVICES=0",
    singularity:
        "https://depot.galaxyproject.org/singularity/mmseqs2:17.b804f--hd6d6fdc_1"
    threads: 48
    resources:
        mem_mb    = 500000,
        partition = "gpu,gpu-veo",
        gres      = "gpu:a100:1",
        time      = "3-00:00:00"
    shell: 
        """
        export OMP_NUM_THREADS={params.omp};
        mkdir -p {params.tmp_dir}
        module purge
        module load nvidia/cuda/12.4.0
        nvidia-smi

        {params.devices} mmseqs search {input.seq_db} {input.ref_db} {output} {params.tmp_dir} --threads {threads} {params.opt} --gpu 1 
        touch {output}
        """