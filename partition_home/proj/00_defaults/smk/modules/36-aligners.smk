rule strobealign_alignment:
    input:
        r1="reads/{ID}_1.clean.fq.gz",
        r2="reads/{ID}_2.clean.fq.gz",
        ref="ref/{REFERENCE}.fa"
    output:
        temp(os.path.join(config['TASK'], "strobealign/{ID}__{REFERENCE}.sam"))
    params:
        opt="-U",
    singularity:
        "https://depot.galaxyproject.org/singularity/strobealign:0.16.1--h5ca1c30_0"
    threads: 8
    resources:
        mem_mb    = "5000"
    shell:
        """
        strobealign -t {threads} {params.opt} {input.ref} {input.r1} {input.r2} > {output}
        """