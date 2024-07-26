#CLI arg #1: directory with pdbs

home="${HOME}/structural-constraint-map/scripts/splicing"

for i in $1/*.pdb
do

sbatch $home/get_splicing_features.sh $i

done
