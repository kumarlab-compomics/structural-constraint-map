#!/bin/bash
#SBATCH -N 1 # Ensure that all cores are on one machine
#SBATCH -c 1
#SBATCH --mem=500M
#SBATCH -t 0-02:00 # Runtime in D-HH:MM
#SBATCH -J concatenate_output
#SBATCH --output=/cluster/projects/kumargroup/isoform-constraint-map/structure/sbatch_out/%j.out

# run this script in the directory that contains the gene/alt directories - output will be moved to 'concatenated_output' one dir up
# this script appends so make sure that you have a fresh file at the beginning each time
# CLI 1 is pdb directory to get names from
# CLI 2 is file key words you are interested in

#suffix=*${1} 
#find -type f -name "${suffix}" -print | xargs cat >> $2
#mv $2 ../concatenated_output

if [[ $3 == "ensemble" ]]; then
	ls -1 $1/*pdb > input_concat.txt
	sed -i 's/.pdb//g' input_concat.txt
	sed -i 's/alphaflow\///g' input_concat.txt

	while IFS=_ read -r transcript gene; do
    		echo $transcript $gene
		echo "/cluster/projects/kumargroup/isoform-constraint-map/structure/combined_community_detection/$gene/$transcript/${transcript}_${gene}_${2}.csv" >> ensemble_${2}_paths.txt	
	done <input_concat.txt
	xargs cat < ensemble_${2}_paths.txt > ../concatenated_output/all_ensemble_${2}.temp
	grep -v "transcript" ../concatenated_output/all_ensemble_${2}.temp > ../concatenated_output/all_ensemble_${2}.csv
	rm ../concatenated_output/all_ensemble_${2}.temp

elif [[ $3 == "single" ]]; then
	#ls -1 $1/*pdb > input_concat.txt	
	#sed -i 's/..\/combined_community_detection\/colabfold\///g' input_concat.txt
	#sed -i 's/\.msa_unrelaxed_rank_.*_alphafold2_ptm_model_.*_seed_.*\.pdb//g' input_concat.txt
	#sed -i 's/.pdb//g' input_concat.txt

	find $1 -type f -name '*.pdb' > input_concat.txt
        sed -i 's/.pdb//g' input_concat.txt
        sed -i 's/..\/combined_community_detection\/alphaflow\///g' input_concat.txt

	while IFS=_ read -r transcript gene; do
    		echo $transcript $gene
		echo "/cluster/projects/kumargroup/isoform-constraint-map/structure/single_conf_community_detection/$gene/$transcript/${transcript}_${gene}_${2}.csv" >> single_${2}_paths.txt
	done <input_concat.txt
	xargs cat < single_${2}_paths.txt > ../concatenated_output/all_single_${2}.temp
	grep -v	"transcript" ../concatenated_output/all_single_${2}.temp > ../concatenated_output/all_single_${2}.csv
	rm ../concatenated_output/all_ensemble_${2}.temp

else 
	echo "please select one of ensemble or single for CLI #3!"
fi
