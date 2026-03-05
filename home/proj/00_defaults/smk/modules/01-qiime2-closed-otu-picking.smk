rule qiime_import_data:
    input:
        os.path.join(config['PROJ'], config['FOLDERS']['manifest'], "{DB}.tsv")
    output:
        os.path.join(config['PROJ'], config['FOLDERS']['samples_artifact'], "{DB}.qza")
    singularity:
        config['IMAGES']['qiime2']
    shell:
        """
        qiime tools import \
            --type 'SampleData[SequencesWithQuality]' \
            --input-path {input} \
            --output-path {output} \
            --input-format SingleEndFastqManifestPhred33V2
        """

rule qiime_import_reference:
    input:
        os.path.join(config['REFERENCE'], "{DB}.fna")
    output:
        os.path.join(config['PROJ'], config['FOLDERS']['reference_artifact'], "{DB}_seq.qza")
    singularity:
        config['IMAGES']['qiime2']
    shell:
        """
        qiime tools import \
            --type 'FeatureData[Sequence]' \
            --input-path {input} \
            --output-path {output}
        """

rule qiime_dereplicate:
    input:
        os.path.join(config['PROJ'], config['FOLDERS']['samples_artifact'], "{DB}.qza")
    output:
        tbl = os.path.join(config['PROJ'], config['FOLDERS']['dereplicated'], "{DB}.tbl.qza"),
        seq = os.path.join(config['PROJ'], config['FOLDERS']['dereplicated'], "{DB}.seq.qza")
    singularity:
        config['IMAGES']['qiime2']
    resources:
        mem_mb=247000
    shell:
        """
        qiime vsearch dereplicate-sequences \
            --i-sequences {input} \
            --o-dereplicated-table {output.tbl} \
            --o-dereplicated-sequences {output.seq}
        """

rule qiime_closed_reference:
    input:
        ref = os.path.join(config['PROJ'], config['FOLDERS']['reference_artifact'], "{DB}_seq.qza"),
        tbl = os.path.join(config['PROJ'], config['FOLDERS']['dereplicated'], "{DB}.tbl.qza"),
        seq = os.path.join(config['PROJ'], config['FOLDERS']['dereplicated'], "{DB}.seq.qza")
    output:
        tbl = os.path.join(config['PROJ'], config['FOLDERS']['otu_closed'], "{DB}.tbl.qza"),
        seq = os.path.join(config['PROJ'], config['FOLDERS']['otu_closed'], "{DB}.seq.qza"),
        unm = os.path.join(config['PROJ'], config['FOLDERS']['otu_closed'], "{DB}.unmatch.qza")
    threads: 24
    params:
        omp=lambda wildcards, threads: threads
    resources:
        mem_mb=247000
    singularity:
        config['IMAGES']['qiime2']
    shell:
        """
        export OMP_NUM_THREADS={params.omp};

        qiime vsearch cluster-features-closed-reference \
            --p-threads {threads} \
            --i-table {input.tbl} \
            --i-sequences {input.seq} \
            --i-reference-sequences {input.ref} \
            --p-perc-identity 0.97 \
            --o-clustered-table {output.tbl} \
            --o-clustered-sequences {output.seq} \
            --o-unmatched-sequences {output.unm}
        """

rule qiime_export:
    input:
        os.path.join(config['PROJ'], config['FOLDERS']['otu_closed'], "{DB}.tbl.qza")
    output:
        os.path.join(config['PROJ'], config['FOLDERS']['export'], "{DB}-feature-table.biom")
    params:
        os.path.join(config['PROJ'], config['FOLDERS']['export'])
    singularity:
        config['IMAGES']['qiime2']
    shell:
        """
        qiime tools export \
            --input-path {input} \
            --output-path {params}
        
        mv {params}/feature-table.biom {output}
        """

rule add_taxonomy2biom:
    input:
        biom = os.path.join(config['PROJ'], config['FOLDERS']['export'], "{DB}-feature-table.biom"),
        tax = os.path.join(config['REFERENCE'], "{DB}_tax.txt")
    output:
        os.path.join(config['PROJ'], config['FOLDERS']['add_tax'], "{DB}-feature-table.biom")
    singularity:
        config['IMAGES']['qiime2']
    shell:
        """
        biom add-metadata \
            -i {input.biom} \
            -o {output} \
            --observation-metadata-fp {input.tax} \
            --observation-header OTUID,TAXONOMY \
            --sc-separated taxonomy
        """

rule abundance_from_biom:
    input:
        os.path.join(config['PROJ'], config['FOLDERS']['add_tax'], "{DB}-feature-table.biom")
    output:
        os.path.join(config['PROJ'], config['FOLDERS']['abundance'], "{DB}-feature-table-abundances.tsv")
    singularity:
        config['IMAGES']['qiime2']
    shell:
        """
        biom convert \
            -i {input} \
            -o {output} \
            --to-tsv
        """