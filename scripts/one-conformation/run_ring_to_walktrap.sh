#!/bin/bash
#SBATCH -N 1 # Ensure that all cores are on one machine
#SBATCH -c 1
#SBATCH --mem=750M
#SBATCH -t 0-00:15 # Runtime in D-HH:MM
#SBATCH -J run_walktrap
#SBATCH --output=/cluster/projects/kumargroup/isoform-constraint-map/structure/sbatch_out/%j.out

#script to run constraint map steps for each isoform starting with RING to community visualization

echo $(date)

if [[ $3 == "beluga" ]]; then
	source /home/nhanafi/projects/def-sushant/nhanafi/envs/structural_constraint/bin/activate
elif [[ $3 == "cedar" ]]; then
	source /project/6069023/structural_constraint/envs/network_env/bin/activate
elif [[ $3 == "narval" ]]; then
	source /home/nhanafi/projects/def-sushant/nhanafi/envs/md/bin/activate
elif [[ $3 == "h4h" ]]; then
	source ~/envs/clustering/bin/activate
else
	echo "Please select one of beluga, cedar, narval or h4h for as CLI arg #3 in order to load the correct venv"
fi

home="${HOME}/structural-constraint-map/scripts/one-conformation"

pdb=$1

file="$(basename "$pdb")"
isoform="${file%%.*}"
enst=$(awk '{split($0, a, "[_.]"); print a[1]}' <<< "$file")
gene=$(awk '{split($0, a, "[_.]"); print a[2]}' <<< "$file")

echo "Beginning processing for ${isoform}"

if [[ $2 == "bond_energy" ]]; then
	echo "Edges set to BOND ENERGY"
	mkdir -p ${gene}/${enst}
	project_dir=${gene}/${enst}
	### RING ###
		echo "Running RING now"
		ring -i $pdb --all_edges -g 1 --out_dir $project_dir
		echo "Done RING"

	### COMMUNITY DETECTION PRE-PROCESSING ###

		echo "Getting number of residues"
		python $home/get_num_residues.py -p $pdb -o $project_dir/${isoform}_resnum.txt

		echo "Now getting walktrap input file ready"

		module load R
		Rscript $home/walktrap_preprocessing_one_conformation.R $project_dir/${pdb}_ringEdges $project_dir/${isoform}_resnum.txt $project_dir/${isoform}_walktrap_input.txt
		echo "Walktrap input ready"

elif [[ $2 == "contact" ]]; then
	mkdir -p ${gene}/${enst}
	project_dir=${gene}/${enst}
	echo "Edges set to CONTACT"
	### COMMUNITY DETECTION PRE-PROCESSING ###
		python $home/get_contact_map_edges.py -p $pdb -o $project_dir/${isoform}_walktrap_input.txt

else
	echo "Please select either bond_energy or contact as the edge for CLI arg 2"
	exit 1
fi

### COMMUNITY DETECTION ###

echo "Beginning community detection"
python $home/walktrap_translated_seq.py $project_dir/${isoform}_walktrap_input.txt $project_dir/${isoform}_walktrap_output.txt
echo "Community detection complete"

### RE-WRITING B-FACTORS in PDB FOR VISUALIZATION ###

echo "Re-writing B-factors in PDB"
python $home/sub_bfactor_wCommunities.py -c $project_dir/${isoform}_walktrap_output.txt -p $pdb -o $project_dir/${isoform}_${2}_rewritten.pdb
echo "Done re-writing B-factors"

#cp to home directory so that I can scp it out
#cp $project_dir/${isoform}_${2}_rewritten.pdb ~/files_to_scp/pdbs



### GETTING RESIDUE LEVEL METRICS ###

echo "Getting residue level metrics"
python $home/get_residue_level_metrics_part1.py -c $project_dir/${isoform}_walktrap_output.txt -p $pdb -o $project_dir/${isoform}_residues.csv

module load R/4.2.1
Rscript $home/get_residue_level_metrics_part2.R $project_dir/${isoform}_walktrap_input.txt $project_dir/${isoform}_residues.csv $project_dir/${isoform}_all_residue_metrics.csv

### WRITING TRANSCRIPT-LEVEL SUMMARY CSV ###

echo "Writing summary csv"
python $home/summarize_communities.py -c $project_dir/${isoform}_walktrap_output.txt -o $project_dir/${isoform}_summary.csv -p $pdb -i $project_dir/${isoform}_walktrap_input.txt -n $4
echo "Done writing summary csv"  

echo $(date +%T)

### EXIT STATUS CHECK ### from https://stackoverflow.com/questions/26675681/how-to-check-the-exit-status-using-an-if-statement
EXITCODE=$?
test $EXITCODE -eq 0 && echo "SUCCESS" || echo "ERROR";
exit $EXITCODE
