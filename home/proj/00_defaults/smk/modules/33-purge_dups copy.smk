configfile: "/home/qi47rin/colab/isabell-klawonn/src/02-qc-assembly/smk.config"
workdir: config['workdir']

rule targets:
    input:
        expand(os.path.join(config['TASK'], "busco-purge_dups/{ID}"), ID = ["35", "28"])

rule purge_dups_config:
    input:
        genome = "cache/01-chytrid-fltr-size-assemblers-metwrap-rmDups-min500b/{BINNER}/{ASSEMBLER}/{OVERLAP}/{BINNER}_bins/bin.{ID}.fa",
        fq_lis  = "cache/01-chytrid-fltr-size-assemblers-metwrap-rmDups-min500b/fq_list.txt"
    output:
        os.path.join(config['TASK'], "purge_dups/{BINNER}.{ASSEMBLER}.{OVERLAP}.bin{ID}/config.json")
    params:
        out = lambda wildcards, output: os.path.dirname(output[0]),
    conda:
        "purge_dups"
    threads: 1
    shell:
        """
        pd_config.py -l {params.out} -n {output} {input.genome} {input.fq_lis}
        """

rule purge_dups_run:
    input:
        config = os.path.join(config['TASK'], "purge_dups/{BINNER}.{ASSEMBLER}.{OVERLAP}.bin{ID}/config.json"),
        genome = "cache/01-chytrid-fltr-size-assemblers-metwrap-rmDups-min500b/{BINNER}/{ASSEMBLER}/{OVERLAP}/{BINNER}_bins/bin.{ID}.fa",
        fastq  = "cache/01-chytrid-fltr-size-assemblers-metwrap-rmDups-min500b/reads-by-size/{OVERLAP}.fastq"
    output:
        touch(os.path.join(config['TASK'], "purge_dups/{BINNER}.{ASSEMBLER}.{OVERLAP}.bin{ID}/done.txt"))
    params:
        opt         = "-p bash",
        out         = lambda wildcards, output: os.path.dirname(output[0]),
        scripts_dir = "/vast/qi47rin/proj/00-git/purge_dups/src"
    conda:
        "purge_dups"
    threads: 48
    shell:
        """
        run_purge_dups.py {params.opt} {input.config} {params.scripts_dir} bin.{wildcards.ID}
        mv bin.{wildcards.ID} {params.out}
        """

rule busco:
    input:
        "cache/01-chytrid-fltr-size-assemblers-metwrap-rmDups-min500b/purge_dups/bin.{ID}/seqs/bin.{ID}.purged.fa"
    output:
        out_dir=directory(os.path.join(config['TASK'], "busco-purge_dups/{ID}"))
    params:
        lineage="/home/qi47rin/ref/06-busco/v5/lineages/chytridiomycota_odb12",
        mode="genome",
        extra="--long --augustus --offline",
    threads: 8
    retries: 3
    wrapper:
        "v7.2.0/bio/busco"

