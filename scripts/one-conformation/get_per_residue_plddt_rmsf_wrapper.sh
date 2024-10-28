#!/bin/bash
#SBATCH -N 1 # Ensure that all cores are on one machine
#SBATCH -c 1
#SBATCH --mem=750M
#SBATCH -t 0-02:00 # Runtime in D-HH:MM
#SBATCH -J master_per_res_metrics

source ~/envs/clustering/bin/activate

home="${HOME}/structural-constraint-map/scripts/one-conformation"

#ls -1 alphaflow/*pdb > input.txt
readarray -t files < input.txt

start=$1
end=$2

echo "start line=${start}; end line=${end}"


for (( i=$start; i<=$end; i++ ))
do
        current=${files[$i]}
        file="$(basename "$current")"
        isoform="${file%%.*}"
        enst=$(awk '{split($0, a, "[_.]"); print a[1]}' <<< "$file")
        gene=$(awk '{split($0, a, "[_.]"); print a[2]}' <<< "$file")

        echo "submitting ${isoform}"
        sbatch $home/submit_per_residue_plddt_rmsf.sh $current $enst $gene
done

