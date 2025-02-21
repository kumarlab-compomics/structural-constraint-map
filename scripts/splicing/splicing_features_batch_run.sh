#!/bin/bash

#CLI arg #1: directory with pdbs

home="${HOME}/structural-constraint-map/scripts/splicing"
input=/cluster/projects/kumargroup/isoform-constraint-map/structure/single_conf_community_detection

#ls -1 $1/*pdb > input.txt #UNCOMMENT THIS IF THERE ARE ANY CHANGES TO THE INPUT DIRECTORY
#find ../combined_community_detection/colabfold -name "*.pdb" > input.txt #TEMP ALTERNATIVE FOR V LARGE DIRECTORIES
readarray -t files < input.txt

start=$2
end=$3


echo "start line=${start}; end line=${end}"

for (( i=$start; i<=$end; i++ ))
do
	current=${files[$i]}
	file="$(basename "$current")"
	isoform="${file%%.*}"
	enst=$(awk '{split($0, a, "[_.]"); print a[1]}' <<< "$file")
	gene=$(awk '{split($0, a, "[_.]"); print a[2]}' <<< "$file")

	if [ ! -f "$input/$gene/$enst/${enst}_${gene}_surface_area_accessibility.csv" ] ; then
		echo "submitting ${isoform}"
		sbatch $home/get_splicing_features.sh $current
	else
		echo "${isoform} is done"
	fi
done
