import pandas as pd
import argparse
import os
from prody import *
import statistics
import igraph as ig

parser = argparse.ArgumentParser()
parser.add_argument("-c", "--communities", help = "walktrap output")
parser.add_argument("-o", "--output", help = "summary file output name")
parser.add_argument("-p", "--pdb", help = "multimodel pdb file")
parser.add_argument("-i", "--walktrap_input", help = "walktrap input file that contains edges")
args = parser.parse_args()

colnames_in = ["res1","res2","edge"]
df_in = pd.read_csv(args.walktrap_input, header = None, names = colnames_in)
df=pd.read_csv(args.communities, header = None)
filename= os.path.basename(args.communities)
s = filename.split('_')

#get transcript name
transcript = '_'.join(s[:2])

#get number of communities
num_c=max(df[1])+1

p = parsePDB(args.pdb)

#get edge density of isoform
g=ig.Graph.DataFrame(df_in)
df_in = df_in.loc[df_in['edge'] > 0] #remove 0 edges
edensity = g.density()

#get length of protein
protein_length = p.numResidues()

data=[[transcript,num_c,edensity, protein_length]]

df2 = pd.DataFrame(data)
df2.to_csv(args.output, index=False, header=False)
