#!/bin/bash
#SBATCH -N 1 # Ensure that all cores are on one machine
#SBATCH -c 1
#SBATCH --mem=750M
#SBATCH -t 0-00:15 # Runtime in D-HH:MM
#SBATCH -J per_res_metrics
#SBATCH --output=/cluster/projects/kumargroup/isoform-constraint-map/structure/sbatch_out/per_residue_plddt_rmsf/%j.out

echo $1
echo $2 $3
python ~/structural-constraint-map/scripts/one-conformation/get_per_residue_plddt_rmsf.py -e $1 -s colabfold/${2}_${3}* -t ${2}_${3} -o $3/$2/${2}_${3}_per_residue_plddt_rmsf.csv
