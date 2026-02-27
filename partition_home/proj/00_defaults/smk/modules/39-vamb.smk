configfile: "/home/qi47rin/colab/isabell-klawonn/src/01-metagenome-assembly-eukaryotes/smk.config"
workdir: config['workdir']

module taxonomy:
    snakefile: "/home/qi47rin/proj/00-default/smk-modules/28-mmseqs.smk"
    config: config

rule all:
    input:
        expand(os.path.join(config['TASK'], "vamb/taxvamb/{SAMPLE}-{MMSEQS2_DB_NAME}"), SAMPLE="m64046_250130_135130", MMSEQS2_DB_NAME="UniRef90")

use rule mmseqs_import_sequences from taxonomy as mmseqs_import_sequences_raw with:
    input:
        "/home/qi47rin/colab/isabell-klawonn/raw/{SAMPLE}.hifi_reads.fasta.gz"
    output: 
        os.path.join(config['TASK'], "mmseqs2/seqs-db/{SAMPLE}")
    resources:
        mem_mb=247000

use rule mmseqs_taxonomy from taxonomy as taxonomy_raw_reads with:
    input:
        seq_db=os.path.join(config['TASK'], "mmseqs2/seqs-db/{SAMPLE}"),
        ref_db=os.path.join(config['MMSEQS2_DB_DIR'], "{MMSEQS2_DB_NAME}/{MMSEQS2_DB_NAME}")
    output: 
       os.path.join(config['TASK'], "mmseqs2/taxonomy-db/{SAMPLE}.{MMSEQS2_DB_NAME}")
    params:
        omp=lambda wildcards, threads: threads,
        tmp_dir=os.path.join(config['TMP'], "{SAMPLE}"),
        opt="--tax-lineage 1"


use rule mmseqs_taxonomy_to_tsv from taxonomy as mmseqs_taxonomy_to_tsv_raw with:
    input:
        seq_db=os.path.join(config['TASK'], "mmseqs2/seqs-db/{SAMPLE}"),
        ref_db=os.path.join(config['MMSEQS2_DB_DIR'], "{MMSEQS2_DB_NAME}/{MMSEQS2_DB_NAME}"),
        tax_db=os.path.join(config['TASK'], "mmseqs2/taxonomy-db/{SAMPLE}.{MMSEQS2_DB_NAME}"),
    output: 
       os.path.join(config['TASK'], "mmseqs2/taxonomy-tbl/{SAMPLE}.{MMSEQS2_DB_NAME}.tsv")
    resources:
        mem_mb=247000


rule remove_contaminants:
    input:
        os.path.join(config['TASK'], "mmseqs2/taxonomy-tbl/{SAMPLE}.{MMSEQS2_DB_NAME}.tsv")
    output:
        ctg=os.path.join(config['TASK'], "mmseqs2/{SAMPLE}.{MMSEQS2_DB_NAME}.contigs.txt"),
        tax=os.path.join(config['TASK'], "mmseqs2/{SAMPLE}.{MMSEQS2_DB_NAME}.taxonomy.tsv")
    params:
        opt=""
    threads: 8
    resources:
        mem_mb=20000
    shell:
        """
        grep -Ev "Viridiplantae|Viruses|Metazoa|Bacteria|Archaea" {input} > {output.tax}
        awk '{{print $1}}' {output.tax} > {output.ctg}
        """

rule taxconvert:
    input:
        os.path.join(config['TASK'], "mmseqs2/{SAMPLE}.{MMSEQS2_DB_NAME}.taxonomy.tsv")
    output:
        os.path.join(config['TASK'], "vamb/taxconvert/{SAMPLE}.{MMSEQS2_DB_NAME}.tsv")
    threads: 1
    conda: "taxconverter"
    shell:
        """
        taxconverter mmseqs2 -i {input} -o {output}
        """

rule remove_uninformative_ranks:
    input:
        os.path.join(config['TASK'], "vamb/taxconvert/{SAMPLE}.{MMSEQS2_DB_NAME}.tsv")
    output:
        os.path.join(config['TASK'], "vamb/taxconvert/{SAMPLE}.{MMSEQS2_DB_NAME}.fixed.tsv")
    threads: 1
    shell:
        """
        sed -E 's/;-_[^;]+//g; s/-_[^;]+;//g; s/-_[^;]+$//g' {input} > {output}
        """

rule long_euk_contigs:
    input:
        fa="/home/qi47rin/colab/isabell-klawonn/raw/{SAMPLE}.hifi_reads.fasta.gz",
        txt=os.path.join(config['TASK'], "mmseqs2/{SAMPLE}.{MMSEQS2_DB_NAME}.contigs.txt")
    output:
        os.path.join(config['TASK'], "contigs-filtered/{SAMPLE}.{MMSEQS2_DB_NAME}.long.euk.fa")
    singularity:
        "https://depot.galaxyproject.org/singularity/seqkit:2.7.0--h9ee0642_0"
    threads: 4
    shell:
        """
        seqkit grep --threads {threads} -if {input.txt} {input.fa} -o {output}
        """

rule strobealign:
    input:
        fq="/home/qi47rin/colab/isabell-klawonn/raw/{SAMPLE}.hifi_reads.fastq.gz",
        ref=os.path.join(config['TASK'], "contigs-filtered/{SAMPLE}.{MMSEQS2_DB_NAME}.long.euk.fa"),
    output:
        os.path.join(config['TASK'], "strobealign/{SAMPLE}/{MMSEQS2_DB_NAME}.txt")
    params:
        opt=""
    singularity:
        "https://depot.galaxyproject.org/singularity/strobealign:0.16.1--h5ca1c30_0"
    threads: 8
    resources:
        mem_mb=40000
    shell:
        """
        strobealign -t {threads} --aemb {input.ref} {input.fq} > {output}
        """

rule merge_abundances:
    input:
        os.path.join(config['TASK'], "strobealign/{SAMPLE}/{MMSEQS2_DB_NAME}.txt")
    output:
        os.path.join(config['TASK'], "vamb/abundance/{SAMPLE}.{MMSEQS2_DB_NAME}.tsv")
    params:
        script_dir="/vast/qi47rin/proj/00-git/vamb/src",
        abundances_dir = lambda wc, input: os.path.dirname(input[0])
    conda: "vamb"
    threads: 8
    resources:
        mem_mb=20000
    shell:
        """
        python {params.script_dir}/merge_aemb.py {params.abundances_dir} {output}
        """

rule taxometer:
    input:
        abun=os.path.join(config['TASK'], "vamb/abundance/{SAMPLE}.{MMSEQS2_DB_NAME}.tsv"),
        fast=os.path.join(config['TASK'], "contigs-filtered/{SAMPLE}.{MMSEQS2_DB_NAME}.long.euk.fa"),
        taxo=os.path.join(config['TASK'], "vamb/taxconvert/{SAMPLE}.{MMSEQS2_DB_NAME}.fixed.tsv")
    output:
        os.path.join(config['TASK'], "vamb/taxometer/{SAMPLE}-{MMSEQS2_DB_NAME}/results_taxometer.tsv")
    params:
        bamDir="cache/102-refine-eukaryotic-bins/metabat2/work_files",
        out_dir= lambda wc, output: os.path.dirname(output[0]),
        opt="-m 2000 --seed 1"
    threads: 48
    conda: "vamb"
    resources:
        mem_mb=50000,
    shell:
        """
        rm -rf {params.out_dir}

        vamb taxometer \
            --outdir {params.out_dir} \
            -p {threads} {params.opt} \
            --abundance_tsv {input.abun} \
            --taxonomy {input.taxo} \
            --fasta {input.fast}
        """

rule taxvamb:
    input:
        abun=os.path.join(config['TASK'], "vamb/abundance/{SAMPLE}.{MMSEQS2_DB_NAME}.tsv"),
        taxo=os.path.join(config['TASK'], "vamb/taxometer/{SAMPLE}-{MMSEQS2_DB_NAME}/results_taxometer.tsv"),
        fast=os.path.join(config['TASK'], "contigs-filtered/{SAMPLE}.{MMSEQS2_DB_NAME}.long.euk.fa"),
    output:
        directory(os.path.join(config['TASK'], "vamb/taxvamb/{SAMPLE}-{MMSEQS2_DB_NAME}"))
    params:
        bamDir="cache/102-refine-eukaryotic-bins/metabat2/work_files",
        opt="-m 2000 --minfasta 200000 --seed 1 --no_predict"
    threads: 48
    conda: "vamb"
    resources:
        mem_mb=50000
    shell:
        """
        rm -rf {output}

        vamb bin taxvamb \
            --outdir {output} \
            -p {threads} {params.opt} \
            --abundance_tsv {input.abun} \
            --taxonomy {input.taxo} \
            --fasta {input.fast}
        """