#!/bin/bash

#SBATCH -N 1 # Ensure that all cores are on one machine
#SBATCH -c 1
#SBATCH -p all
#SBATCH --mem=5G
#SBATCH -t 0-00:10 # Runtime in D-HH:MM


source ~/envs/clustering/bin/activate
module load R/4.2.1 

pdb=$1
home="${HOME}/structural-constraint-map/scripts/one-conformation"
gene=$2
enst=$3
input="/cluster/projects/kumargroup/isoform-constraint-map/structure/single_conf_community_detection/${gene}/${enst}"
output=$4

echo "Getting residue level metrics"

# get residue level metrics part 1
python $home/get_residue_level_metrics_part1_SINGLE.py -c $input/${enst}_${gene}_walktrap_output.txt -p $pdb -o $output/temp/${enst}_${gene}_residues.csv
## ADD ENSMBLE PDB

# get residue level metrics part 2
Rscript $home/get_residue_level_metrics_part2_SINGLE.R $input/${enst}_${gene}_walktrap_input.txt \
	$output/temp/${enst}_${gene}_residues.csv \
	$input/${enst}_${gene}_surface_area_accessibility.csv \
	$input/${enst}_${gene}_frustration_index.txt \
	$output/single_conf_residue_level_metrics/${enst}_${gene}_all_residue_metrics.csv


# get transcript level summary
python $home/summarize_communities_SINGLE.py -c $input/${enst}_${gene}_walktrap_output.txt \
	-o $output/single_conf_summary_metrics/${enst}_${gene}_summary.csv \
	-p $pdb \
	-i $input/${enst}_${gene}_walktrap_input.txt

# clean up
rm $output/temp/${enst}_${gene}_residues.csv
	
