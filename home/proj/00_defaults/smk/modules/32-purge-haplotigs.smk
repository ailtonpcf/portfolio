rule minimap_align_pacbio_hifi:
    input:
        genome = os.path.join(config['TASK'], "genome/{ID}.fa"),
        fastq  = os.path.join(config['TASK'], "reads.fq"),
    output:
        os.path.join(config['TASK'], "bam/{ID}.bam")
    params:
        opt="--secondary=no"
    singularity:
        "https://depot.galaxyproject.org/singularity/purge_haplotigs:1.1.3--hdfd78af_0"
    shell:
        """
        minimap2 -ax map-hifi -t {threads} {input.genome} {input.fastq} | \
            samtools sort -o {output}
        """

rule purge_haplotigs_histogram:
    input:
        genome = os.path.join(config['TASK'], "genome/{ID}.fa"),
        bam    = os.path.join(config['TASK'], "bam/{ID}.bam")
    output: 
       os.path.join(config['TASK'], "histogram/{ID}.bam.200.gencov")
    params:
        gencov  = lambda wc, output: os.path.basename(output[0]),
        png     = lambda wc, output: os.path.basename(output[0]).replace(".200.gencov", ".histogram.200.png"),
        out_dir = lambda wc, output: os.path.dirname(output[0]),
        opt     = "-d 30"
    singularity:
        "https://depot.galaxyproject.org/singularity/purge_haplotigs:1.1.3--hdfd78af_0"
    threads: 8
    shell: 
        """
        mkdir -p {params.out_dir}
        purge_haplotigs hist -b {input.bam} -g {input.genome} -t {threads} {params.opt}
        mv {params.gencov} {params.png} {params.out_dir}
        """

# params is library specific
rule purge_haplotigs_coverage:
    input:
        coverage = os.path.join(config['TASK'], "histogram/{ID}.bam.200.gencov")
    output: 
       os.path.join(config['TASK'], "coverage/{ID}.stats.csv")
    params:
        omp=lambda wildcards, threads: threads,
        out=lambda wildcards, output: os.path.dirname(output[0]),
        opt="-l 1 -m 3 -h 10 -j 10 -s 10"
    singularity:
        "https://depot.galaxyproject.org/singularity/purge_haplotigs:1.1.3--hdfd78af_0"
    threads: 1
    shell: 
        """
        purge_haplotigs cov -i {input.coverage} {params.opt} -o {output} 
        """

rule purge_haplotigs_purge:
    input:
        genome   = os.path.join(config['TASK'], "genome/{ID}.fa"),
        coverage = os.path.join(config['TASK'], "coverage/{ID}.stats.csv"),
        bam      = os.path.join(config['TASK'], "bam/{ID}.bam")
    output:
        primary     = os.path.join(config['TASK'], "purged/curated.fasta"),
        alternative = os.path.join(config['TASK'], "purged/curated.haplotigs.fasta")
    params:
        out=lambda wildcards, output: os.path.join(os.path.dirname(output[0]), "curated"),
        opt="-d"
    singularity:
        "https://depot.galaxyproject.org/singularity/purge_haplotigs:1.1.3--hdfd78af_0"
    threads: 48
    resources:
        mem_mb="247000"
    shell:
        """
        purge_haplotigs purge {params.opt} -g {input.genome} -c {input.coverage} -t {threads} -o {params.out}  -b {input.bam}
        """

rule purge_haplotigs_clip:
    input:
        primary     = os.path.join(config['TASK'], "purged/curated.fasta"),
        alternative = os.path.join(config['TASK'], "purged/curated.haplotigs.fasta")
    output:
        os.path.join(config['TASK'], "clip/clip.fasta")
    params:
        out=lambda wildcards, output: os.path.join(os.path.dirname(output[0]), "clip"),
    singularity:
        "https://depot.galaxyproject.org/singularity/purge_haplotigs:1.1.3--hdfd78af_0"
    threads: 1
    shell:
        """
        purge_haplotigs clip -p {input.primary} -h {input.alternative} -o {params.out} -t {threads}
        """