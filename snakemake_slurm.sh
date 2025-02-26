#!/bin/bash
#SBATCH --job-name=communities
#SBATCH --time=24:00:00
#SBATCH --ntasks-per-node=1
#SBATCH --mem=1G
#SBATCH --output=%x-%j.out


module load snakemake
source ~/envs/clustering/bin/activate
slurm=~/structural-constraint-map/slurm_profile
snakefile=~/structural-constraint-map/Snakefile

snakemake -s $snakefile --configfile config.yaml --cores 1 --profile $slurm
