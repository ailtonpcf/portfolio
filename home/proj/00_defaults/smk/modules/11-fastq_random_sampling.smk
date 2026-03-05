rule subsample_fastq:
    input:
        fw = os.path.join(config['PROJ'], config['FOLDERS']['input_reformat'], "{ID}_1.clean.fq.gz"),
        rv = os.path.join(config['PROJ'], config['FOLDERS']['input_reformat'], "{ID}_2.clean.fq.gz")
    output:
        fw = os.path.join(config['PROJ'], config['FOLDERS']['output_reformat'], "{ID}_{fraction}_{seed}_1.fq.gz"),
        rv = os.path.join(config['PROJ'], config['FOLDERS']['output_reformat'], "{ID}_{fraction}_{seed}_2.fq.gz")
    singularity:
        config['IMAGES']['bbtools']
    threads: 8
    shell:
        """
        reformat.sh \
            t={threads} \
            in={input.fw} \
            in2={input.rv} \
            out={output.fw} \
            out2={output.rv} \
            sampleseed={wildcards.seed} \
            samplereadstarget={wildcards.fraction}
        """