import mdtraj as md
from contact_map import ContactFrequency, ContactDifference
from pandas import *
import argparse
import numpy as np

parser = argparse.ArgumentParser()
parser.add_argument("-p", "--pdb", help = "pdb file")
parser.add_argument("-o", "--output", help = "output file name")
parser.add_argument("-c", "--cutoff", type = float, help = "distance cut-off in nm")
args = parser.parse_args()

traj = md.load(args.pdb)

# restrict to only alpha carbons
alphas = traj.topology.select("protein and name == 'CA'")
ca_traj = traj.atom_slice(alphas)

cutoff = args.cutoff

frame_contacts = ContactFrequency(ca_traj,n_neighbors_ignored=0, cutoff=cutoff)
df = frame_contacts.residue_contacts.df

df = df.fillna(0)
df = df.where(np.triu(np.ones(df.shape)).astype(bool))
df = df.stack().reset_index()
df.columns = ['residue1','residue2','weight']

df['residue1'] += 1
df['residue2'] += 1

df = df.loc[df.residue1.ne(df.residue2)] #keep non-self rows

df.to_csv(args.output, sep=",", header = False, index = False)
