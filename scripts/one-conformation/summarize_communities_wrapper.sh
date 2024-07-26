#!/bin/bash

source ~/envs/clustering/bin/activate

for i in */*/*_walktrap_output.txt;
do
file="$(basename "$i")"
isoform=$(cut -d_ -f1-2 <<< "$file")
echo $isoform

path="$(dirname "$i")"

python ~/structural-constraint-map/scripts/one-conformation/summarize_communities.py -c $i -m $1 -p $path/${isoform}_contact_rewritten.pdb -i $path/${isoform}_walktrap_input.txt

