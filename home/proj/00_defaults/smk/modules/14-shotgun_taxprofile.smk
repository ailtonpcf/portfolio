rule taxonomic_profiling_Kuniq_custom:
    input:
        r1=os.path.join(config['PROJ'], config['FOLDERS']['input_kuniq'], "{ID}_1.fq.gz"),
        r2=os.path.join(config['PROJ'], config['FOLDERS']['input_kuniq'], "{ID}_2.fq.gz"),
        db=config['REFERENCE']
    output:
        os.path.join(config['PROJ'], config['FOLDERS']['output_kuniq'], "{ID}.out")
    params:
        analysis=os.path.join(config['FOLDERS']['scratch'], "taxonomic-profiling", "{ID}"),
        full_db=os.path.join(config['workdir'], config['REFERENCE']),
        out=os.path.join(config['workdir'], config['PROJ'], config['FOLDERS']['taxonomy'])
    conda:
        os.path.join(config['workdir'], config['ENVIRONMENTS']['krakenUniq'])
    threads: 48
    resources:
        mem_mb=247000,
        tmpdir=os.path.join(config['FOLDERS']['scratch'], "taxonomic-profiling")
    shell:
        """
        rm -rf {params.analysis}
        mkdir -p {params.analysis}
        cp {input.r1} {input.r2} {params.analysis}
        cd {params.analysis}

        krakenuniq \
            --threads {threads} \
            --preload-size 20G \
            --db {params.full_db} \
            --report-file {wildcards.ID}.report \
            --only-classified-output \
            --paired \
            *_1.fq.gz \
            *_2.fq.gz > {wildcards.ID}.out && \
        cp {wildcards.ID}.* {params.out}
        rm -r {params.analysis}
        """