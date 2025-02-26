source ~/envs/clustering/bin/activate

home="${HOME}/structural-constraint-map/scripts/one-conformation"
mkdir -p combined

for i in alphaflow/*.pdb;
do
pdb=$i

file="$(basename "$pdb")"
isoform="${file%%.*}"
enst=$(awk '{split($0, a, "[_.]"); print a[1]}' <<< "$file")
gene=$(awk '{split($0, a, "[_.]"); print a[2]}' <<< "$file")

python $home/combine_conformations.py -e $i -s colabfold/${enst}_${gene}* -o combined/${enst}_${gene}_combined_conformations.pdb
done
