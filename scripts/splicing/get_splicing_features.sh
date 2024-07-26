#!/bin/bash
#SBATCH -N 1 # Ensure that all cores are on one machine
#SBATCH -c 1
#SBATCH --mem=250M
#SBATCH -t 0-00:05 # Runtime in D-HH:MM
#SBATCH -J get_splicing_features
#SBATCH --output=/cluster/projects/kumargroup/isoform-constraint-map/structure/sbatch_out_splicing/%j.out

#script to get splicing features for each transcript

echo $(date)

source ~/envs/clustering/bin/activate

pdb=$1

file="$(basename "$pdb")"
fp="$(readlink -f "$pdb")"
isoform="${file%%.*}"

echo $isoform

enst=$(awk '{split($0, a, "[_.]"); print a[1]}' <<< "$file")
gene=$(awk '{split($0, a, "[_.]"); print a[2]}' <<< "$file")

# get frustration indices
echo "CALCULATING SINGLE-RESIDUE FRUSTRATION"
Rscript ~/structural-constraint-map/scripts/splicing/calculate_frustration.R $fp /cluster/projects/kumargroup/isoform-constraint-map/structure/single_conf_community_detection/$gene/$enst

#cleanup
echo "CLEANING UP"
mv /cluster/projects/kumargroup/isoform-constraint-map/structure/single_conf_community_detection/$gene/$enst/*.done/FrustrationData/*.pdb_singleresidue /cluster/projects/kumargroup/isoform-constraint-map/structure/single_conf_community_detection/$gene/$enst/${enst}_${gene}_frustration_index.txt
rm -r /cluster/projects/kumargroup/isoform-constraint-map/structure/single_conf_community_detection/$gene/$enst/*.done

# get surface accessibility
echo "CALCULATING SINGLE_RESIDUE SURFACE AREA ACCESSIBILITY"
python ~/structural-constraint-map/scripts/splicing/calculate_surface_accessibility.py -p $pdb -i $isoform -o $gene/$enst/${isoform}_surface_area_accessibility.csv

# combine all residues into row
echo "CLEANING UP"
Rscript ~/structural-constraint-map/scripts/splicing/summarize_splicing_features.R $gene/$enst/${enst}_${gene}_frustration_index.txt $gene/$enst/${isoform}_surface_area_accessibility.csv $enst $gene/$enst/${enst}_${gene}_frustration_summary.tsv $gene/$enst/${enst}_${gene}_surface_area_summary.tsv

echo "DONE"
echo $(date +%T)
