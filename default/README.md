# Default Resources

This directory functions as a centralized repository for components that are reused across various pipelines and workflow steps. Consolidating these resources ensures methodological consistency and simplifies maintenance across different software releases.

---

## 🛠 Snakemake Modules

These modules are pre-configured analysis units designed for seamless integration into larger workflows. Current implementations include:

### Taxonomic Profiling
* **Framework:** QIIME2
* **Platform:** Illumina short-read sequencing
* **Markers:** 16S and ITS ribosomal RNA genes

---

## 🛠 Snakemake Profiles

Profiles serve as standardized configuration templates that Snakemake uses to interface with High-Performance Computing (HPC) schedulers. They automate the resource allocation and job submission logic required for different execution environments.

