suppressMessages(library(dplyr))
suppressMessages(library(data.table))
suppressMessages(library(igraph))

args = commandArgs(trailingOnly=TRUE)

c_in = c("res1","res2","edge")
df_in = fread(args[1], stringsAsFactors = F, col.names = c_in) #walktrap input
df_c = fread(args[2], stringsAsFactors = F) # processed walktrap output from part 1 script
#df_c = df_c %>% dplyr::rename(resnum = V1, community = V2)

df_sa = fread(args[3], stringsAsFactors = F)
df_sa = df_sa %>% dplyr::rename(resnum = V1, surface_area_accessibility = V2)

df_fi = fread(args[4], stringsAsFactors = F)
df_fi = df_fi %>% dplyr::rename(resnum = Res, frustration_index = FrstIndex)

df_hp = fread("~/structural-constraint-map/data/aa_hydrophobicity_measures_JPepSci_1995.tsv", stringsAsFactors = F) #hydrophobicity scale

get_residue_metrics <- function(df_in, df_c, df_hp, df_sa, df_fi){

	# add in hydrophobicity
	df = left_join(df_c, df_hp, by = "resname")

	# add in surface area, frustration index, and per-residue pLDDT
	df = left_join(df, df_sa, by = "resnum")
	df = left_join(df, df_fi %>% select(resnum, frustration_index), by = "resnum")

	#remove edges with weight 0
	df_in = df_in %>% filter(edge != 0)

	#create graph 
	g = graph_from_data_frame(df_in, directed = FALSE)

	#set weight attribute
	g = set_edge_attr(g, "weight", index=E(g), df_in$edge)

	#node level metrics

	#get node-specific graph metrics
	df = df %>% mutate(normalized_degree = degree(g, normalized = T))
	df = df %>% mutate(strength = strength(g))
	df = df %>% mutate(perc_strength = percent_rank(strength))
	df = df %>% mutate(normalized_closeness = closeness(g, normalized= T))
	df = df %>% mutate(normalized_betweenness = betweenness(g, directed = FALSE, normalized = T))
	df = df %>% mutate(scaled_eigen_centrality = eigen_centrality(g, directed = F)$vector)
	df = df %>% mutate(transitivity = transitivity(g, type = "weighted"))

	return(df)
}

t = get_residue_metrics(df_in, df_c, df_hp, df_sa, df_fi)
write.table(t, args[5], sep = ",", quote = F, row.names = F, col.names = F)


