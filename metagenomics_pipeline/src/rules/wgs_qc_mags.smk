rule checkm:
    input:
        "results/binning/binning.done"
    output:
        "results/qc/checkm_report.tsv"
    singularity:
        "https://depot.galaxyproject.org/singularity/checkm-genome:1.2.2--pyhdfd78af_1"
    shell:
        """
        checkm lineage_wf \
          results/binning \
          results/qc/checkm \
          -t 32

        cp results/qc/checkm/lineage.ms {output}
        """