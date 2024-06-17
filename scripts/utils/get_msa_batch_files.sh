#!/bin/bash

#usage: sh ~/structural_constraint_map/scripts/utils/get_msa_batch_soft_links.sh <file containing transcripts in transcript_gene form> <symlink/copy> <target directory>


if [ $2 == "symlink" ]; then
while IFS=_ read -r transcript gene; do
    ln -s /cluster/projects/kumargroup/yumika_v2/clustering/$gene/$transcript/${transcript}_${gene}.msa.a3m $3
done <$1

elif [ $2 == "copy" ]; then
while IFS=_ read -r transcript gene; do
    cp /cluster/projects/kumargroup/yumika_v2/clustering/$gene/$transcript/${transcript}_${gene}.msa.a3m $3
done <$1

else
echo "Please choose one of symlink or copy as CLI arg #2"
fi
