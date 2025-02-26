#!/bin/bash

# This script is a driver script to run a bash script that gets residue level metrics for single conformation
# Last modified: 2024-10-31
# Created: 2024-10-31

# RUN THIS IN THE SINGLE CONF MASTER INPUT DIR -> this is distinct from the sequence script that runs in the master output dir

dir=/cluster/projects/kumargroup/isoform-constraint-map/structure/single_conf_community_detection

#CLI arg #1: directory with pdbs

home="${HOME}/structural-constraint-map/scripts/one-conformation"
output=/cluster/projects/kumargroup/isoform-constraint-map/metrics/single_conformation_metrics/output
master=/cluster/projects/kumargroup/isoform-constraint-map/metrics/single_conformation_metrics

#ls -1 $1/*pdb > input.txt #UNCOMMENT THIS IF THERE ARE ANY CHANGES TO THE INPUT DIRECTORY
#find ../combined_community_detection/colabfold -name "*.pdb" > input.txt #TEMP ALTERNATIVE FOR V LARGE DIRECTORIES
readarray -t files < $dir/input.txt

start=$2
end=$3

mkdir -p $output/single_conf_residue_level_metrics
mkdir -p $output/single_conf_summary_metrics
mkdir -p $output/temp

var_outfile=$master/slurm/%j.out
var_errfile=$master/slurm/%j.err

echo "start line=${start}; end line=${end}"

for (( i=$start; i<=$end; i++ ))
do
  	current=${files[$i]}
        file="$(basename "$current")"
        isoform="${file%%.*}"
        enst=$(awk '{split($0, a, "[_.]"); print a[1]}' <<< "$file")
        gene=$(awk '{split($0, a, "[_.]"); print a[2]}' <<< "$file")

        if [ ! -f "$output/single_conf_residue_level_metrics/${enst}_${gene}_all_residue_metrics.csv" ] ; then
                echo "submitting ${isoform}"
                sbatch --output=$var_outfile --error=$var_errfile $home/residue_level_metrics_SINGLE_WRAPPER.sh $current $gene $enst $output
        else
            	echo "${isoform} is done"
        fi
done
