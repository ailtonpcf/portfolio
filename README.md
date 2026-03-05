# Personal bioinformatics practices

This repository provides an overview of personal bioinformatics practices.

- /home/${USER}
    - /home/${USER}/proj is the main folder that contains different projects and collaborations.
        - Within proj, files are allocated in:
            - doc: For reports, outlines and manuscripts.
            - raw: For metadata, like NCBI genome accessions used along that project.
            - log: For Software logs
            - res: To storage final results, like figures, spreadsheets ...
            - src: For code
    - /home/${USER}/proj/00_defaults
        - Store scripts, functions, modules ... information previously generated and can be reused for other jobs.
        - Here we have conda yaml recipes, snakemake modules, R custom functions ... 
    - Analysis with high I/O are not performed here, unless otherwise requested

- /other_partition
    - Is where cache and heavy analysis are performed
    - /other_partition/tmp is a temporary directory that is often supplied in jobs to avoid filling /tmp

