from prody import *
import pandas as pd
import argparse
import os

parser = argparse.ArgumentParser()
parser.add_argument("-c", "--communities", help = "walktrap output")
parser.add_argument("-p", "--pdb", help = "colabfold pdb file")
parser.add_argument("-e", "--ensemble", help = "alphaflow pdb file")
parser.add_argument("-o", "--output", help = "name of output file")
args = parser.parse_args()

colnames = ['resnum', 'community']
colnames_in = ["res1","res2","edge"]
df = pd.read_csv(args.communities, header = None, names = colnames)
pdb = parsePDB(args.pdb)
aflow = parsePDB(args.ensemble)

filename= os.path.basename(args.communities)
s = filename.split('_')

#get transcript name
transcript = '_'.join(s[:2])

a=pdb.getResnums()
b=pdb.getResnames()

df_pdb = pd.DataFrame()
#convert arrays into df columns for pd operations
df_pdb = pd.DataFrame()
df_pdb['resnum']=pd.Series(a)
df_pdb['resname']=pd.Series(b)
df_pdb['transcript'] = transcript

df_pdb = df_pdb.drop_duplicates()

# get and add per-residue pLDDT scores
betas = pdb.ca.getBetas()
df_pdb['per_residue_plddt']=pd.Series(betas)


# get rmsf values for each alpha carbon
calphas = aflow.select('calpha')
alignCoordsets(aflow)
rmsf = calcRMSF(calphas)
df_pdb['rmsf'] = pd.Series(rmsf)

#merging with communities
merged_df =  df.merge(df_pdb, on = 'resnum', how='left')

#rearrange cols so transcript column is first
merged_df = merged_df[['transcript', 'resnum', 'resname', 'community', 'per_residue_plddt', 'rmsf']]

merged_df.to_csv(args.output, header = True, index = False)

