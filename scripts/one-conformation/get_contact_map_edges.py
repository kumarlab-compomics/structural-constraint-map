import mdtraj as md
from contact_map import ContactFrequency, ContactDifference
from pandas import *
import argparse
import numpy as np

parser = argparse.ArgumentParser()
parser.add_argument("-p", "--pdb", help = "pdb file")
parser.add_argument("-o", "--output", help = "output file name")
args = parser.parse_args()

traj = md.load(args.pdb)

frame_contacts = ContactFrequency(traj,n_neighbors_ignored=0)
df = frame_contacts.residue_contacts.df

df = df.fillna(0)
df = df.where(np.triu(np.ones(df.shape)).astype(bool))
df = df.stack().reset_index()
df.columns = ['residue1','residue2','weight']

df['residue1'] += 1
df['residue2'] += 1

df = df.loc[df.residue1.ne(df.residue2)] #keep non-self rows

df.to_csv(args.output, sep=",", header = False, index = False)
