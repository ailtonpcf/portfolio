#!/bin/bash

#SBATCH --job-name=SPIKEin                                                      # Job name
#SBATCH --ntasks=1                                                              # Run a single task
#SBATCH --cpus-per-task=1                                                       # Number of CPU cores per task
#SBATCH --mem=20G                                                               # Job memory request
#SBATCH --time=14-00:00:0                                                       # Time limit hrs:min:sec
#SBATCH --output=../../logs/112-quantify-mock-spikein-sensitive/mock_%j.log     # Standard output and error log
#SBATCH --partition=long

echo "Date              = $(date)"
echo "Hostname          = $(hostname -s)"
echo "Working Directory = $(pwd)"
echo ""
echo "Number of Nodes Allocated      = $SLURM_JOB_NUM_NODES"
echo "Number of Tasks Allocated      = $SLURM_NTASKS"
echo "Number of Cores/Task Allocated = $SLURM_CPUS_PER_TASK"
echo "" 

# Activate local conda environment
source /home/${USER}/.bashrc

mamba activate snakemake

snakemake \
    --snakefile rules.smk \
    --profile /home/proj/00-default/smk-profiles/standard/ \
    --singularity-prefix /vast/proj/02-compost-microbes/cache/00-singularity \
    --conda-prefix /vast/proj/02-compost-microbes/cache/00-conda-env \
    --singularity-args "--bind /home:/home,/work:/work,/vast:/vast,/veodata:/veodata" \
    --conda-frontend mamba \
    --nolock \
    --rerun-incomplete \
    --keep-incomplete \
    --allow-ambiguity \
    --keep-going \
    --rerun-triggers mtime 