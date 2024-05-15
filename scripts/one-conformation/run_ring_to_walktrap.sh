#!/bin/bash

#script to run constraint map steps for each isoform starting with RING to community visualization

start=`date +%s`
source ~/envs/clustering/bin/activate

pdb=$1

file="$(basename "$pdb")"
isoform="${file%%.*}"
echo "Beginning processing for ${isoform}"

mkdir -p "$isoform"

### RING ###
echo "Running RING now"
ring -i $pdb --best_edge -g 1 --out_dir $isoform
echo "Done RING"

### COMMUNITY DETECTION PRE-PROCESSING ###

echo "Getting number of residues"
python get_num_residues.py -p $pdb -o $isoform/${isoform}_resnum.txt

echo "Now getting walktrap input file ready"
module load R
Rscript walktrap_preprocessing_one_conformation.R $isoform/${pdb}_ringEdges $isoform/${isoform}_resnum.txt $isoform/${isoform}_walktrap_input.txt
echo "Walktrap input ready"

### COMMUNITY DETECTION ###

echo "Beginning community detection"
python walktrap_translated_seq.py $isoform/${isoform}_walktrap_input.txt $isoform/${isoform}_walktrap_output.txt
echo "Community detection complete"

### RE-WRITING B-FACTORS in PDB FOR VISUALIZATION ###

echo "Re-writing B-factors in PDB"
python sub_bfactor_wCommunities.py -c $isoform/${isoform}_walktrap_output.txt -p $pdb -o $isoform/${isoform}_rewritten.pdb
echo "Done re-writing B-factors"

#cp to home directory so that I can scp it out
cp $isoform/${isoform}_rewritten.pdb ~/files_to_scp/pdbs

### EXIT STATUS CHECK ### from https://stackoverflow.com/questions/26675681/how-to-check-the-exit-status-using-an-if-statement
EXITCODE=$?
test $EXITCODE -eq 0 && echo "SUCCESS" || echo "ERROR";
exit $EXITCODE

end=`date +%s`
runtime=$((end-start))
echo "Runtime is ${runtime}"


