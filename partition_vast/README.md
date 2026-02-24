# Vast partition

In the vast partition we have a:

- Temporary folder
    - That is supplied in jobs to avoid filling /tmp

- Proj folder
    - All involved projects are listed here
    - Stores cache analysis and intermediate results organized by project.

- Apps keep tools that normally have isues with licensing and can't be freely distributed, like the eukaryotic gene prediction tool GeneMark.
    Tools are saved here and their path is exported to the global $PATH

- ref stores databases and reference sequences