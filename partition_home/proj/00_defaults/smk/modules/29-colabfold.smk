# Downloading the weights require to mout singularity args /work/qi47rin/ref:/cache
rule colabFold_download_weights:
    output: 
       "/work/qi47rin/ref/colabfold/params/download_finished.txt"
    params:
        cache_dir="/work/qi47rin/ref"
    singularity:
        "docker://ghcr.io/sokrypton/colabfold:1.5.5-cuda12.2.2"
    threads: 8
    resources:
        mem_mb=50000,
        partition="gpu,gpu-veo,gpu-test",
        gres="gpu:a100:1",
        time="12:00:00"
    shell: 
        """
        python -m colabfold.download
        touch {output}
        """

rule colabFold_structure_prediction:
    input: 
       fa="seqs.faa",
       db="/work/qi47rin/ref/colabfold/params/download_finished.txt"
    output:
        directory(os.path.join(config['TASK'], "structure/{ID}"))
    params:
        out_dir=os.path.join(config['TASK'], "structure/{ID}"),
        omp=lambda wildcards, threads: threads,
        opt="--random-seed 1"
    singularity:
        "docker://ghcr.io/sokrypton/colabfold:1.5.5-cuda12.2.2"
    threads: 32
    resources:
        mem_mb=100000,
        partition="gpu,gpu-veo,gpu-test",
        gres="gpu:a100:1",
        time="12:00:00"
    shell: 
        """
        export OMP_NUM_THREADS={params.omp};
        mkdir -p {output}
        nvidia-smi
        colabfold_batch {params.opt} {input.fa} {params.out_dir} --msa-only
        colabfold_batch {params.opt} {input.fa} {params.out_dir}
        """

