suppressMessages(library(dplyr))
suppressMessages(library(data.table))

args = commandArgs(trailingOnly=TRUE)

df_f = fread(args[1], stringsAsFactors = F)
df_sa = fread(args[2], stringsAsFactor= F)
df_sa$V2 = round(df_sa$V2,3)

enst = args[3]

frustration = paste(shQuote(df_f$FrstIndex), collapse=",")
surface_area = paste(shQuote(df_sa$V2), collapse=",")

frustration = gsub('^', '\"[', frustration)
frustration = gsub('$', ']\"', frustration)

surface_area = gsub('^', '\"[', surface_area)
surface_area = gsub('$', ']\"', surface_area)

df_final_frus = data.frame(enst, frustration)
df_final_sa = data.frame(enst, surface_area)

write.table(df_final_frus, args[4], quote = F, row.names = F, col.names = F, sep = "\t")
write.table(df_final_sa, args[5], quote = F, row.names = F, col.names = F, sep = "\t")

