rule compost_wgs__download_fungal_genomes_for_krakenUniq:
    output:
         directory(os.path.join(config['PROJ'], config['FOLDERS']['genomes'], "fungi"))
    conda:
        os.path.join(config['homedir'], config['ENVIRONMENTS']['krakenUniq'])
    threads: 24
    shell:
        """
        krakenuniq-download \
            --db {output} \
            --threads {threads} \
            genbank/fungi/Any \
            refseq/fungi/Any
        """

rule compost_wgs__download_bacterial_genomes_for_krakenUniq:
    output:
         directory(os.path.join(config['PROJ'], config['FOLDERS']['genomes'], "bacteria"))
    conda:
        os.path.join(config['homedir'], config['ENVIRONMENTS']['krakenUniq'])
    threads: 24
    resources:
        mem_mb=50000
    shell:
        """
        krakenuniq-download \
            --db {output} \
            --threads {threads} \
            refseq/bacteria/Any \
            genbank/bacteria/Any
        """

rule compost_wgs__download_viral_genomes_for_krakenUniq:
    output:
         directory(os.path.join(config['PROJ'], config['FOLDERS']['genomes'], "virus"))
    conda:
        os.path.join(config['homedir'], config['ENVIRONMENTS']['krakenUniq'])
    threads: 24
    shell:
        """
        krakenuniq-download \
            --db {output} \
            --threads {threads} \
            refseq/viral/Any \
            genbank/viral/Any
        """

rule compost_wgs__download_archaeal_genomes_for_krakenUniq:
    output:
        directory(os.path.join(config['PROJ'], config['FOLDERS']['genomes'], "archaea"))
    conda:
        os.path.join(config['homedir'], config['ENVIRONMENTS']['krakenUniq'])
    threads: 24
    shell:
        """
        krakenuniq-download \
            --db {output} \
            --threads {threads} \
            refseq/archaea/Any \
            genbank/archaea/Any
        """

rule compost_wgs__download_protozoal_genomes_for_krakenUniq:
    output:
        directory(os.path.join(config['PROJ'], config['FOLDERS']['genomes'], "protozoa"))
    conda:
        os.path.join(config['homedir'], config['ENVIRONMENTS']['krakenUniq'])
    threads: 24
    shell:
        """
        krakenuniq-download \
            --db {output} \
            --threads {threads} \
            refseq/protozoa/Any \
            genbank/protozoa/Any
        """

rule compost_wgs__filter_genomes_for_krakenUniq:
    input:
        protozoa=rules.compost_wgs__download_protozoal_genomes_for_krakenUniq.output,
        archaea=rules.compost_wgs__download_archaeal_genomes_for_krakenUniq.output,
        virus=rules.compost_wgs__download_viral_genomes_for_krakenUniq.output,
        bacteria=rules.compost_wgs__download_bacterial_genomes_for_krakenUniq.output,
        fungi=rules.compost_wgs__download_fungal_genomes_for_krakenUniq.output,
        script=config['SCRIPTS']['genomes_single_species']
    output:
        directory(os.path.join(config['PROJ'], config['FOLDERS']['filt_gen']))
    conda:
        os.path.join(config['homedir'], config['ENVIRONMENTS']['rtidyverse'])
    threads: 1
    shell:
        """
        Rscript {input.script} {output}
        """