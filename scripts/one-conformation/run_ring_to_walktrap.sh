#!/bin/bash
#SBATCH -N 1 # Ensure that all cores are on one machine
#SBATCH -c 1
#SBATCH --mem=500M
#SBATCH -t 0-00:20 # Runtime in D-HH:MM
#SBATCH -J run_walktrap

#script to run constraint map steps for each isoform starting with RING to community visualization

start=`date +%s`
source /home/nhanafi/projects/def-sushant/nhanafi/envs/md/bin/activate

home="${HOME}/structural-constraint-map/scripts/one-conformation"

pdb=$1

file="$(basename "$pdb")"
isoform="${file%%.*}"
echo "Beginning processing for ${isoform}"

if [[ $2 == "bond_energy" ]]; then
	echo "Edges set to BOND ENERGY"
	mkdir -p ${isoform}
	project_dir=${isoform} 
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
	mkdir -p ${isoform}
	project_dir=${isoform}
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

### EXIT STATUS CHECK ### from https://stackoverflow.com/questions/26675681/how-to-check-the-exit-status-using-an-if-statement
EXITCODE=$?
test $EXITCODE -eq 0 && echo "SUCCESS" || echo "ERROR";
exit $EXITCODE

end=`date +%s`
runtime=$((end-start))
echo "Runtime is ${runtime}"


