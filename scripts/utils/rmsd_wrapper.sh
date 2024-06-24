
source /lustre06/project/6069023/nhanafi/envs/md/bin/activate

for i in *.pdb
do
file="$(basename "$i")"
isoform="${file%%.*}"
python ~/structural-constraint-map/scripts/utils/create_rmsd_plot.py -p $i -o ${isoform}_rmsd.png
done
