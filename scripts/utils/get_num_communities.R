
suppressMessages(library(data.table))

args = commandArgs(trailingOnly=TRUE)

df = fread(args[1], stringsAsFactors = F)

print(args[1])

print(max(df$V2) +1)
