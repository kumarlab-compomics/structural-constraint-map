#CLI arg #1: directory with pdbs
#CLI arg #2: bond_energy or contact (to serve as edge weights)
#CLI arg #3: cluster name
#CLI arg #4: ensemble or single (conformation)
#CLI arg #5: starting index (with reference to ls of input pdb dir)
#CLI arg #6: ending index (with reference to ls of input pdb dir)



if [[ $4 == "ensemble" ]]; then
	input=/cluster/projects/kumargroup/isoform-constraint-map/structure/combined_community_detection
elif [[ $4 == "single" ]]; then 
	input=/cluster/projects/kumargroup/isoform-constraint-map/structure/single_conf_community_detection
else
	echo "please select one of ensemble or single as command line argument 4 to specify whether you want a conformational ensemble analysis or a single stucture analysis"
fi

home="${HOME}/structural-constraint-map/scripts/one-conformation"
input=/cluster/projects/kumargroup/isoform-constraint-map/structure/combined_community_detection


#ls -1 $1/*pdb > input.txt #UNCOMMENT THIS IF THERE ARE ANY CHANGES TO THE INPUT DIRECTORY
#find ../combined_community_detection/colabfold -name "*.pdb" > input.txt #TEMP ALTERNATIVE FOR V LARGE DIRECTORIES
readarray -t files < input.txt

start=$5
end=$6

echo "start line=${start}; end line=${end}"

for (( i=$start; i<=$end; i++ ))
do
	current=${files[$i]}
	file="$(basename "$current")"
	isoform="${file%%.*}"
	enst=$(awk '{split($0, a, "[_.]"); print a[1]}' <<< "$file")
	gene=$(awk '{split($0, a, "[_.]"); print a[2]}' <<< "$file")

	if [ ! -f "$input/$gene/$enst/${enst}_${gene}_walktrap_output.txt" ] ; then
		echo "submitting ${isoform}"
		sbatch $home/run_walktrap_array.sh $current $2 $3 $4
	else
		echo "${isoform} is done"
	fi
done
