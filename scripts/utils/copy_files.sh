#!/bin/bash

#usage: sh ~/structural_constraint_map/scripts/utils/copy_files.sh <file containing transcripts in transcript_gene form> <file extension excluding initial period>

while IFS=_ read -r transcript gene; do
    echo $transcript $gene
    cp /cluster/projects/kumargroup/yumika_v2/clustering/$gene/$transcript/${transcript}_${gene}.${2} ${transcript}_${gene}.${2}
done <$1
