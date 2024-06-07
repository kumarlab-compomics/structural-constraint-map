#CLI arg #1: directory with pdbs
#CLI arg #2: bond_energy or contact (to serve as edge weights)

home="${HOME}/structural-constraint-map/scripts/one-conformation"

for i in $1/*.pdb
do

sbatch $home/run_ring_to_walktrap.sh $i $2

done
