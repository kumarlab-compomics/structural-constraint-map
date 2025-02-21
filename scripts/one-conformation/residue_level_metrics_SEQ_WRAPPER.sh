#!/bin/bash

#SBATCH -N 1 # Ensure that all cores are on one machine
#SBATCH -c 1
#SBATCH -p all
#SBATCH --mem=5G
#SBATCH -t 0-00:10 # Runtime in D-HH:MM
#SBATCH --mail-type=ALL
#SBATCH --mail-user=nour.hanafi@mail.utoronto.ca


source ~/envs/clustering/bin/activate
home="${HOME}/structural-constraint-map/scripts/one-conformation"

echo "Getting residue level metrics"

module load R/4.2.1 parallel

LIST_INPUT=$2

names=($(cat $LIST_INPUT)) #this will save a list
line=${names[${SLURM_ARRAY_TASK_ID}]} #get the line

# ENST00000371588,ENST00000371588.10,ENSG00000000419.14,DPM1,MANE
# ENST00000367771,ENST00000367771.11,ENSG00000000457.14,SCYL3,MANE
gene=$(cut -d"," -f4 <<< "$line")
echo $gene
isoform=$(cut -d"," -f1 <<< "$line")
echo $isoform

Rscript $home/get_residue_level_metrics_part2_SEQ.R $1/$gene/$isoform/${isoform}_${gene}.gplmDCA \
	$1/$gene/$isoform/${isoform}_${gene}_walktrap_translated_seq.csv \
	${isoform}_${gene} \
	sequence_residue_level_metrics/${isoform}_${gene}_all_residue_metrics.csv \
	sequence_summary_metrics/${isoform}_${gene}_summary.csv
