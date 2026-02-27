rule QC_MAGs_checkMk:
    output:
        "checkm_report.tsv"
    singularity:
        "https://depot.galaxyproject.org/singularity/checkm-genome:1.2.2--pyhdfd78af_1"
    params:
        fasta_dir="dir",
        checkm_dbpath="dir",
        out="dir",
        opt="-x fa --tab_table"
    threads: 8
    shell:
        """
        export CHECKM_DATA_PATH={params.checkm_dbpath}
        mkdir -p {params.out}
        checkm lineage_wf -t {threads} {params.opt} --file {output} {params.fasta_dir} {params.out}
        """

rule EukCC_folder:
    output:
        "eukcc.done"
    singularity:
        "https://depot.galaxyproject.org/singularity/eukcc:2.1.0--pypyhdfd78af_0"
    params:
        fasta_dir="dir",
        eukcc_dbpath="dir",
        euk_out="dir",
        opt=""
    threads: 8
    shell:
        """
        export EUKCC2_DB={params.eukcc_dbpath}
        eukcc folder --out {params.euk_out} --threads {threads} {params.opt} {params.fasta_dir}
        touch {output}
        """

rule EukCC_single:
    input:
        "bin.fa"
    output:
        "eukcc.done"
    singularity:
        "https://depot.galaxyproject.org/singularity/eukcc:2.1.0--pypyhdfd78af_0"
    params:
        eukcc_dbpath="dir",
        euk_out="dir",
        opt=""
    threads: 8
    shell:
        """
        export EUKCC2_DB={params.eukcc_dbpath}
        mkdir -p {params.euk_out}
        eukcc single --out {params.euk_out} --threads {threads} {params.opt} {input}
        touch {output}
        """