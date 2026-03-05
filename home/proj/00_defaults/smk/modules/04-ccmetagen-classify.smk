def get_mem_mb(wildcards, attempt):
    return attempt * 650000

rule kma_reference_to_shared_memory:
    output:
       os.path.join(config['TASK'], "db-shared.done")
    params:
        idx_base="/work/qi47rin/TASK/02-compost-microbes/cache/29-compost76-wgs-ccmetagen/kma-indexes/all_king"
    singularity:
        "https://depot.galaxyproject.org/singularity/ccmetagen:1.4.1--pyh7cba7a3_0"
    threads: 1
    resources:
        partition='fat',
        mem_mb=get_mem_mb
    retries: 3
    shell:
        """
        kma shm -t_db {params.idx_base} -shmLvl 1
        touch {output}
        """

rule kma_alignment:
    input:
        r1="{ID}_1.clean.fq.gz",
        r2="{ID}_2.clean.fq.gz",
        link=os.path.join(config['TASK'], "db-shared.done")
    output:
        res=os.path.join(config['TASK'],   "aligned/{ID}.res"),
        map_= os.path.join(config['TASK'], "aligned/{ID}.mapstat"),
        fsa = os.path.join(config['TASK'], "aligned/{ID}.fsa"),
        aln = os.path.join(config['TASK'], "aligned/{ID}.aln"),
        frag = os.path.join(config['TASK'], "aligned/{ID}.frag.gz")
    params:
        out_dir=os.path.join(config['TASK'], "aligned"),
        prefix=os.path.join(config['TASK'], "aligned/{ID}"),
        idx_base="/work/qi47rin/TASK/02-compost-microbes/cache/29-compost76-wgs-ccmetagen/kma-indexes/all_king",
        omp=lambda wildcards, threads: threads,
        opt = "-1t1 -mem_mode -and -apm f -ef -shm"
    singularity:
        "https://depot.galaxyproject.org/singularity/ccmetagen:1.4.1--pyh7cba7a3_0"
    threads: 12
    resources:
        partition='fat',
        mem_mb=get_mem_mb,
        time='1-00:00:00'
    shell:
        """
        export OMP_NUM_THREADS={params.omp};
        mkdir -p {params.out_dir}

        kma -ipe \
            {input.r1} \
            {input.r2} \
            -t_db {params.idx_base} \
            -o {params.prefix} \
            -t {threads} \
            {params.opt}
        """

rule CCMetagen__update_database:
    input:
        py="/home/qi47rin/proj/00-default/scripts/update_ncbi_taxa.py"
    output:
        touch(os.path.join(config['TASK'], "ncbitaxa.updated"))
    conda:
        os.path.join(config['homedir'], "src/00-conda/ccmetagen.yaml")
    threads: 1
    shell:
        """
        python {input.py}
        """

rule CCMetagen__extract_alignment:
    input:
        link = os.path.join(config['TASK'], "ncbitaxa.updated"),
        res = os.path.join(config['TASK'], "aligned/{ID}.res"),
        map_= os.path.join(config['TASK'], "aligned/{ID}.mapstat")
    output:
        os.path.join(config['TASK'], "ccmetagen-results/{ID}.ccm.csv")
    params:
        out=os.path.join(config['TASK'], "ccmetagen-results/{ID}"),
        opt="-ef y"
    conda:
        os.path.join(config['homedir'], "src/00-conda/ccmetagen.yaml")
    threads: 1
    shell:
        """
        CCMetagen.py \
            -i {input.res} \
            -o {params.out} \
            -map {input.map_} \
            {params.opt}
        """