# Personal bioinformatics practices

This repository provides an overview of personal bioinformatics practices. /home and /vast represent different partitions in an HPC cluster.

- /home
    - /home/proj is the main folder that contains different projects.
        - Each subfolder contains different data types, such as spreadsheets, PDFs and code.
    - Scripts and finished results should be stored here.
    - Analysis with high I/O is not allowed in this partition.
- /vast
    - is where cache and heavy analysis are kept.
    - /vast/tmp is a temporary directory that is often supplied in jobs when the tools allow it

Besides, /home/proj/00_defaults provides resources that are reused in Snakemake workflows for similarity searches (like BLAST), NGS quality control (including trimming), and so on. Check it out!