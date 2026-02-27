rule blast_makedb:
    input:
        "/work/qi47rin/proj/02-compost-microbes/cache/50-prokaryotic-mags/bins-dereplicated/dereplicated_genomes/bin.{REFERENCE}.fa"
    output: 
       os.path.join(config['TMP'], "indexes/{REFERENCE}.nsq")
    params:
        prefix = lambda wc, output: output[0].replace(".nsq", ""),
        opt    = "-dbtype nucl"
    singularity:
        "https://depot.galaxyproject.org/singularity/blast:2.17.0--h66d330f_0"
    shell:
        """
        makeblastdb -in {input} {params.opt} -out {params.prefix}
        """

rule blastn:
    input:
        query    = os.path.join(config['TASK'], "fasta/{ID}.fa"),
        database = os.path.join(config['TMP'], "indexes/{REFERENCE}.nsq")
    output: 
       os.path.join(config['TASK'], "blastn-results/{ID}.{REFERENCE}.tsv")
    params:
        database = lambda wc, input: input.database.replace(".nsq", ""),
        opt      = "-outfmt '6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore qcovs'",
    singularity:
        "https://depot.galaxyproject.org/singularity/blast:2.17.0--h66d330f_0"
    threads: 8
    shell:
        """
        blastn -query {input.query} -db {params.database} -out {output} {params.opt} -num_threads {threads}
        """