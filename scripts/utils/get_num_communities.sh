
module load r/4.4.0 

for i in */*_walktrap_output.txt;
do
Rscript ~/structural-constraint-map/scripts/utils/get_num_communities.R $i
done
