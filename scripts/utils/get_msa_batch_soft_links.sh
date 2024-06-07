#!/bin/bash

#usage: sh ~/structural_constraint_map/scripts/utils/get_msa_batch_soft_links.sh <file containing transcripts in transcript_gene form>

while IFS=_ read -r transcript gene; do
    ln -s /cluster/projects/kumargroup/yumika_v2/clustering/$gene/$transcript/${transcript}_${gene}.msa.a3m .
done <$1
