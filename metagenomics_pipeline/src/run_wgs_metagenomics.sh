#!/bin/bash

#SBATCH --job-name=WGS_PIPELINE                                             	# Job name
#SBATCH --ntasks=1                                                          	# Run a single task
#SBATCH --cpus-per-task=1                                                   	# Number of CPU cores per task
#SBATCH --mem=20G                                                           	# Job memory request
#SBATCH --time=3-00:00:0                                                    	# Time limit hrs:min:sec
#SBATCH --output=../../logs/wgs/wgs_%j.log             				# Standard output and error log
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

snakemake  \
    --snakefile main.smk \
    --profile profile \
    --singularity-prefix cache/00-singularity \
    --conda-prefix cache/00-conda-env \
    --singularity-args "--bind /scratch:/scratch" \
    --conda-frontend mamba \
    --nolock

