suppressMessages(library(dplyr))
suppressMessages(library(data.table))
suppressMessages(library(igraph))

args = commandArgs(trailingOnly=TRUE)

c_in = c("res1","res2","edge")
df_in = fread(args[1], stringsAsFactors = F, col.names = c_in) #walktrap input
df_c = fread(args[2], stringsAsFactors = F) #walktrap output
df_c = df_c %>% dplyr::rename(resnum = V1, community = V2)

get_residue_metrics_SEQ <- function(df_in, df_c){

	df = df_c

	#remove edges with weight 0
	df_in = df_in %>% filter(edge > 0)

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
	df = df %>% mutate(transcript = args[3]) %>% relocate(transcript, .before = resnum)

#	write.table(df_c, args[3], sep = ",", quote = F, row.names = F)
	return(df)
}

get_transcript_summary_SEQ <- function(df_in, df_c){

        #remove edges with weight 0
        df_in = df_in %>% filter(edge > 0)

        #create graph
        g = graph_from_data_frame(df_in, directed = FALSE)

        #set weight attribute
        g = set_edge_attr(g, "weight", index=E(g), df_in$edge)

	num_c = max(df_c$community)+1
	edensity = edge_density(g)
	ts = data.frame(C1 = args[3], C2 = num_c, C3 = edensity)
	return(ts)
}


t = get_residue_metrics_SEQ(df_in, df_c)
write.table(t, args[4], sep = ",", quote = F, row.names = F, col.names = F)

ts = get_transcript_summary_SEQ(df_in, df_c)
write.table(ts, args[5], sep = ",", quote = F, row.names = F, col.names = F)


