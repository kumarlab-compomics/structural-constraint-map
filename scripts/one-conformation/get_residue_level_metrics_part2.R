suppressMessages(library(dplyr))
suppressMessages(library(data.table))
suppressMessages(library(igraph))

args = commandArgs(trailingOnly=TRUE)

c_in = c("res1","res2","edge")
df_in = fread(args[1], stringsAsFactors = F, col.names = c_in) #walktrap input
df_c = fread(args[2], stringsAsFactors = F) #walktrap communities with residue names
df_hp = fread("~/structural-constraint-map/data/aa_hydrophobicity_measures_JPepSci_1995.tsv", stringsAsFactors = F) #hydrophobicity scale

#df_in = fread("p38_backbone_ensemble_walktrap_input.txt", stringsAsFactors = F, col.names = c_in)

#add hydrophobicity
df_c = left_join(df_c, df_hp, by = "resname")

#remove edges with weight 0
df_in = df_in %>% filter(edge != 0)

#create graph 
g = graph_from_data_frame(df_in, directed = FALSE)

#set weight attribute
g = set_edge_attr(g, "weight", index=E(g), df_in$edge)

#node level metrics

#get node-specific graph metrics
df_c = df_c %>% mutate(normalized_degree = round(degree(g, normalized = T),2))
df_c = df_c %>% mutate(strength = round(strength(g),2))

df_c = df_c %>% mutate(normalized_closeness = round(closeness(g, normalized= T),2))
df_c = df_c %>% mutate(normalized_betweenness = round(betweenness(g, directed = FALSE, normalized = T),2))
df_c = df_c %>% mutate(scaled_eigen_centrality = round(eigen_centrality(g, directed = F)$vector, 2))
df_c = df_c %>% mutate(alpha_centrality = round(alpha_centrality(g),2))
df_c = df_c %>% mutate(scaled_authority_hub_score = round(authority_score(g)$vector,2))

df_c = df_c %>% mutate(transitivity = round(transitivity(g, type = "weighted"),2))

write.table(df_c, args[3], sep = ",", quote = F, row.names = F)

