# Remove spurious contamination from bins
rule FCS_adaptor_screen:
    input:
        "cache/01-chytrid-fltr-size-assemblers-metwrap-rmDups-min1kb/{BINNER}/{ASSEMBLER}/{OVERLAP}/{BINNER}_bins/bin.{ID}.fa"
    output: 
       os.path.join(config['TASK'], "fcs-adaptor-screen/{BINNER}.{ASSEMBLER}.{OVERLAP}.{ID}/fcs_adaptor_report.txt/fcs_adaptor_report.txt")
    params:
        out = lambda wildcards, output: os.path.dirname(output[0].replace("fcs_adaptor_report.txt", "")),
        sif = "/home/groups/Fungal/singularity_images/fcs-adaptor.sif"
    threads: 1
    resources:
        mem_mb    = 50000,
        partition = "short",
        time      = "3:00:00"
    shell: 
        """
        mkdir -p {params.out} 
        export NCBI_FCS_REPORT_ANALYTICS=0

        /home/groups/Fungal/marion/softwares/FCS/run_fcsadaptor.sh \
            --fasta-input {input} \
            --output-dir {params.out} \
            --euk \
            --container-engine singularity \
            --image {params.sif}
        """

rule FCS_adaptor_clean:
    input:
        genome = "cache/01-chytrid-fltr-size-assemblers-metwrap-rmDups-min1kb/{BINNER}/{ASSEMBLER}/{OVERLAP}/{BINNER}_bins/bin.{ID}.fa",
        report = os.path.join(config['TASK'], "fcs-adaptor-screen/{BINNER}.{ASSEMBLER}.{OVERLAP}.{ID}/fcs_adaptor_report.txt/fcs_adaptor_report.txt")
    output:
        clean  = os.path.join(config['TASK'], "fcs-adaptor-clean/{BINNER}.{ASSEMBLER}.{OVERLAP}/{ID}.clean.fasta"),
        contam = os.path.join(config['TASK'], "fcs-adaptor-clean/{BINNER}.{ASSEMBLER}.{OVERLAP}/{ID}.contam.fasta"),
    params:
        sif = "/home/groups/Fungal/singularity_images/fcs-gx.sif",
        out = lambda wildcards, output: os.path.dirname(output.clean)
    conda: "python3.8"
    threads: 1
    resources:
        mem_mb    = 50000,
        partition = "short",
        time      = "3:00:00"
    shell: 
        """
        export FCS_DEFAULT_IMAGE={params.sif}
        export NCBI_FCS_REPORT_ANALYTICS=0

        mkdir -p {params.out}

        cat {input} | \
        python3 /home/groups/Fungal/marion/softwares/FCS/fcs.py clean genome \
            --action-report {input.report} \
            --output {output.clean} \
            --contam-fasta-out {output.contam}
        """

rule FCS_gx_screen:
    input:
        os.path.join(config['TASK'], "fcs-adaptor-clean/{BINNER}.{ASSEMBLER}.{OVERLAP}/{ID}.clean.fasta"),
    output:
        os.path.join(config['TASK'], "fcs-gx-screen/{BINNER}.{ASSEMBLER}.{OVERLAP}.{ID}.{TAXID}/{ID}.clean.{TAXID}.fcs_gx_report.txt")
    params:
        sif = "/home/groups/Fungal/singularity_images/fcs-gx.sif",
        opt = "--tax-id {TAXID}",
        gx_db = "/home/groups/Fungal/marion/softwares/FCS/gxdb",
        out = lambda wildcards, output: os.path.dirname(output[0])
    conda: "python3.8"
    threads: 1
    resources:
        mem_mb    = 600000,
        partition = "fat",
        time      = "3-00:00:00"
    shell: 
        """
        export FCS_DEFAULT_IMAGE={params.sif}
        export NCBI_FCS_REPORT_ANALYTICS=0

        python3 /home/groups/Fungal/marion/softwares/FCS/fcs.py screen genome \
            --fasta {input} \
            --out-dir {params.out} \
            --gx-db  {params.gx_db} \
            {params.opt}
        """

rule FCS_gx_clean:
    input:
        genome = os.path.join(config['TASK'], "fcs-adaptor-clean/{BINNER}.{ASSEMBLER}.{OVERLAP}/{ID}.clean.fasta"),
        report = os.path.join(config['TASK'], "fcs-gx-screen/{BINNER}.{ASSEMBLER}.{OVERLAP}.{ID}.{TAXID}/{ID}.clean.{TAXID}.fcs_gx_report.txt")
    output:
        clean  = os.path.join(config['TASK'], "fcs-gx-clean/{BINNER}.{ASSEMBLER}.{OVERLAP}.{ID}.{TAXID}.clean.fasta"),
        contam = os.path.join(config['TASK'], "fcs-gx-clean/{BINNER}.{ASSEMBLER}.{OVERLAP}.{ID}.{TAXID}.contam.fasta")
    params:
        sif = "/home/groups/Fungal/singularity_images/fcs-gx.sif",
        out = lambda wildcards, output: os.path.dirname(output[0])
    conda: "python3.8"
    threads: 1
    resources:
        mem_mb    = 600000,
        partition = "fat",
        time      = "3-00:00:00"
    shell: 
        """
        export FCS_DEFAULT_IMAGE={params.sif}
        export NCBI_FCS_REPORT_ANALYTICS=0

        cat {input.genome} | python3 /home/groups/Fungal/marion/softwares/FCS/fcs.py clean genome \
            --action-report {input.report} \
            --output {output.clean} \
            --contam-fasta-out {output.contam}
        """
