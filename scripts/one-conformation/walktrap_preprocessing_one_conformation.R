suppressWarnings(library(dplyr))
library(data.table)
library(stringr)
library(tidyr)

args = commandArgs(trailingOnly=TRUE)

df_be = fread(args[1], stringsAsFactors = F)

n = as.numeric(readLines(args[2], n=1))

df_be = df_be %>% rename(residue1 = NodeId1, residue2 = NodeId2)

#rename columns before using this
clean_residue_names <- function(df){
  df$residue1 = as.numeric(str_extract(df$residue1, "[:digit:]+"))
  df$residue2 = as.numeric(str_extract(df$residue2, "[:digit:]+"))
  
  return(df)
}

add_zeros <- function(df, seq_len){
  a = c(1:seq_len) #where n is the sequence length
  b = c(1:seq_len) 
  all_pos = expand.grid(a, b) #all possible combinations
  all_pos = all_pos %>% rename(residue1 = Var1, residue2 = Var2)
  jb = c("residue1", "residue2")
  df = full_join(all_pos, df, by = jb)
  #df = df %>% mutate(scaled_edge = replace_na(Energy, 0))
  df[is.na(df)] = 0
  df = df %>% rename(scaled_edge = Energy)
  df = df %>% dplyr::select(residue1, residue2, scaled_edge)
  #df = df %>% group_by(residue1, residue2) %>% slice_max(scaled_edge, with_ties = F)
  return(df)
}

df_be = clean_residue_names(df_be)
df_be$Interaction = sub("\\:.*", "", df_be$Interaction)
df_be = df_be %>% select(residue1, residue2, Energy)
df_be = add_zeros(df_be, n)

#keep only lower triangle of comparisons
#mat = df_be %>% pivot_wider(names_from = residue2, values_from = scaled_edge)
#mat$residue1 = NULL
#df2=data.frame(t(combn(names(mat),2)), weight=t(mat)[lower.tri(mat)])

write.table(df_be, args[3], col.names = F, sep = ",", row.names =  F, quote = F)


