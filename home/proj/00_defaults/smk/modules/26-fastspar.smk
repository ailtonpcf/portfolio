
rule bootstrap_counts:
    input:
        "abundance.tsv"
    output:
        touch(os.path.join(config['PROJ'], "bootstrap.done"))
    conda:
        "/home/qi47rin/proj/00-default/conda/fastspar.yaml"
    params:
        out_dir = os.path.join(config['PROJ'], "bootstrap-counts"),
        prefix  = os.path.join(config['PROJ'], "bootstrap-counts/bootstrap"),
        perm = 1000
    threads: 48
    shell:
        """
        mkdir -p {params.out_dir}

        fastspar_bootstrap \
            --otu_table {input} \
            --number {params.perm} \
            --prefix {params.prefix} \
            --threads {threads}
        """

rule correlation_from_bootstrap:
    input:
        os.path.join(config['PROJ'], "bootstrap.done")
    output:
        touch(os.path.join(config['PROJ'], "correlation.done"))
    params:
        perm = 1000,
        out_dir = os.path.join(config['PROJ'], "bootstrap-correlation"),
        cor_dir = os.path.join(config['PROJ'], "bootstrap-correlation/cor_{/}"),
        cov_dir = os.path.join(config['PROJ'], "bootstrap-correlation/cov_{/}"),
        prefix = os.path.join(config['PROJ'], "bootstrap-counts")
    conda:
        "/home/qi47rin/proj/00-default/conda/fastspar.yaml"
    threads: 48
    shell:
        """
        mkdir -p {params.out_dir}

        parallel fastspar \
            --otu_table {{}} \
            --correlation {params.cor_dir} \
            --covariance {params.cov_dir} \
            --yes \
            -i 5 ::: {params.prefix}/*
        """

rule median_correlation:
    input:
        "abundance.tsv"
    output:
        cor=os.path.join(config['PROJ'], "median-correlation.tsv"),
        cov=os.path.join(config['PROJ'], "median-covariance.tsv")
    conda:
        "/home/qi47rin/proj/00-default/conda/fastspar.yaml"
    threads: 1
    shell:
        """

        fastspar \
            --otu_table {input} \
            --correlation {output.cor} \
            --covariance {output.cov}\
            --threads {threads} \
            --yes
        """

rule pvalue_from_bootstrap:
    input:
        tbl = "abundance.tsv",
        med_cor=os.path.join(config['PROJ'], "median-correlation.tsv"),
        link = os.path.join(config['PROJ'], "correlation.done")
    output:
        os.path.join(config['PROJ'], "bootstrap-pvalues/pvalues.tsv")
    conda:
        "/home/qi47rin/proj/00-default/conda/fastspar.yaml"
    threads: 48
    params:
        out_dir = os.path.join(config['PROJ'], "bootstrap-pvalues"),
        prefix  = os.path.join(config['PROJ'], "bootstrap-correlation", "cor_bootstrap_"),
        perm=1000
    shell:
        """
        mkdir -p {params.out_dir}

        fastspar_pvalues \
            --otu_table {input.tbl} \
            --correlation {input.med_cor} \
            --prefix {params.prefix} \
            --permutations {params.perm} \
            --outfile {output} \
            --threads {threads}
        """
