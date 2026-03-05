rule sratools_fasterqdump:
    output:
        r1=temp(os.path.join(config['TASK'], "sra-data/{ID}_1.fastq")),
        r2=temp(os.path.join(config['TASK'], "sra-data/{ID}_2.fastq"))
    params:
        outdir = os.path.join(config['TASK'], "sra-data"),
        extra="--skip-technical --split-3"
    threads: 8
    singularity:
        "https://depot.galaxyproject.org/singularity/sra-tools:3.2.1--h4304569_1"
    shell:
        """
        fasterq-dump {wildcards.ID} \
            --outdir {params.outdir} \
            --threads {threads} \
            {params.extra}
        """

rule pigz_compress:
    input:
        r1=os.path.join(config['TASK'], "sra-data/{ID}_1.fastq"),
        r2=os.path.join(config['TASK'], "sra-data/{ID}_2.fastq")
    output:
        r1=os.path.join(config['TASK'], "sra-data/{ID}_1.fastq.gz"),
        r2=os.path.join(config['TASK'], "sra-data/{ID}_2.fastq.gz")
    threads: 8
    shell:
        """
        pigz --keep --processes {threads} {input.r1} {input.r2}
        """