from prody import *
import pandas as pd
import argparse

parser = argparse.ArgumentParser()
#parser.parse_args()
parser.add_argument("-c", "--communities", help = "walktrap output")
parser.add_argument("-p", "--pdb", help = "pdb file")
parser.add_argument("-o", "--output", help = "output file name")
args = parser.parse_args()

colnames = ['resnum', 'community'] 
df = pd.read_csv(args.communities, header = None, names = colnames)
pdb = parsePDB(args.pdb)

#get array of residue numbers
num = pdb.getResnums()

#name column to facilitate joining step later
num_df = pd.DataFrame(num, columns=['resnum'])

merged_df =  num_df.merge(df, on = 'resnum', how='left')
pdb.setBetas(merged_df['community'])

writePDB(args.output, pdb)
