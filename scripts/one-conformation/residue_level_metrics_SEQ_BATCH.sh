#!/bin/bash

# This script is a driver script to run a bash script that gets residue level metrics for sequence 
# Last modified: 2024-10-31
# Created: 2024-10-31


dir=/cluster/projects/kumargroup/yumika_v2/clustering

# MANE
#for i in {00..00}; # for batch 00. SUBMITTED 2024-10-29
#for i in {01..01}; # for batch 01. SUBMITTED 2024-09-22
#for i in {02..02}; # for batch 02. SUBMITTED 2024-09-22
for i in {03..03}; # for batch 03. SUBMITTED 2024-09-22
do
  	echo "batch $i"
	mkdir -p sequence_residue_level_metrics
	mkdir -p sequence_summary_metrics

        MANE_ALT="MANE"
        var_jobname="$MANE_ALT"_"$i"_sequence_residue_level_metrics
	var_outfile=../slurm/"$MANE_ALT"/"$i"/%j.out
	var_errfile=../slurm/"$MANE_ALT"/"$i"/%j.err

        input_transcript_list=/cluster/projects/kumargroup/isoform-constraint-map/randomize_network/sequence/input/MANE/67198t_MANE_modified_"$i".csv
#TEST	input_transcript_list=input_test.csv
	
        sbatch --job-name=$var_jobname --output=$var_outfile --error=$var_errfile --array=0-$(wc -l $input_transcript_list | cut -d ' ' -f1) \
               ~/structural-constraint-map/scripts/one-conformation/residue_level_metrics_SEQ_WRAPPER.sh $dir $input_transcript_list
done
