#!/bin/bash

#SBATCH --job-name=COMPOST_ITS2                                             # Job name
#SBATCH --ntasks=1                                                          # Run a single task
#SBATCH --cpus-per-task=1                                                   # Number of CPU cores per task
#SBATCH --mem=20G                                                           # Job memory request
#SBATCH --time=14-00:00:0                                                   # Time limit hrs:min:sec
#SBATCH --output=../../logs/26-compost-its2/compost_its2_%j.log             # Standard output and error log
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

SCRATCH="/scratch"
PROJ="/home"

mamba activate snakemake

snakemake  \
    --snakefile rules.smk \
    --profile /home/qi47rin/proj/02-compost-microbes/src/ \
    --singularity-prefix cache/00-singularity \
    --conda-prefix cache/00-conda-env \
    --singularity-args "--bind $SCRATCH" \
    --singularity-args "--bind $PROJ" \
    --conda-frontend mamba \
    --nolock

