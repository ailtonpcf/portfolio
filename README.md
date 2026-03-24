# Metagenomics Pipeline (WGS)

## Overview

This repository contains a modular and reproducible **Snakemake pipeline** for whole-genome shotgun (WGS) metagenomics data analysis. It covers all major steps from raw sequencing reads to metagenome-assembled genomes (MAGs) and quality assessment.

The pipeline is designed to be:

* **Simple**: clear folder structure and minimal configuration
* **Reproducible**: consistent outputs and environment control
* **Modular**: each step is isolated and easy to extend

---

## Workflow

The pipeline follows a standard metagenomics workflow:

```
Raw Reads
   ↓
Quality Control (fastp)
   ↓
Host Decontamination (Bowtie2)
   ↓
Clean Reads
   ↓
Assembly (MEGAHIT)
   ↓
Binning (MetaWRAP)
   ↓
MAG Quality Control (CheckM)
```

---

## Directory Structure

```
.
├── data/
│   └── raw/                # Input FASTQ files
│
├── resources/
│   └── host_index/         # Host genome index for decontamination
│
├── results/
│   ├── trim/               # Trimmed reads
│   ├── clean/              # Decontaminated reads
│   ├── assembly/           # Contigs
│   ├── binning/            # MAGs
│   └── qc/                 # Reports and QC outputs
│
├── src/
│   ├── config.yaml         # Pipeline configuration
│   ├── main.smk            # Main workflow
│   └── rules/              # Modular rule files
│
└── env/                    # Conda environments
```

---

## Input Data

Place paired-end FASTQ files in:

```
data/raw/
```

Naming convention (required):

```
sample1_1.fastq.gz
sample1_2.fastq.gz
```

---

## Configuration

Edit `src/config.yaml` to define:

* samples to process

Example:

```yaml
samples:
  - sample1
  - sample2

run:
  decontaminate: true
```

---

## Installation

Install snakemake using conda:

```
conda env create -f env/snakemake7.32.yml
```

---

## Usage

Run the full pipeline:

```
bash run_wgs_metagenomics.sh
```

Run a dry test:

```
snakemake -n -s src/main.smk
```

Generate a DAG (workflow visualization):

```
snakemake --dag -s src/main.smk | dot -Tpng > dag.png
```

---

## Output

Key outputs include:

* **Quality reports**: `results/qc/*.html`
* **Clean reads**: `results/clean/`
* **Assemblies**: `results/assembly/*.contigs.fa`
* **Binning results**: `results/binning/`
* **MAG quality reports**: `results/qc/checkm_report.tsv`

---

## Features

* Modular Snakemake design (`rules/` directory)
* Clean and intuitive folder structure
* Config-driven parameters (no hardcoded tuning)
* Supports scaling from laptop to cluster environments

---

## Notes

* The pipeline assumes paired-end Illumina reads
* Host genome index must be pre-built in `resources/host_index/`
* Output directories are created automatically

---

## Future Extensions

This pipeline can be extended with:

* Functional annotation (e.g., eggNOG)
* Taxonomic profiling
* Network inference (e.g., FastSpar, Spiec-Easi)
* Machine learning analyses (e.g., feature selection)

---
