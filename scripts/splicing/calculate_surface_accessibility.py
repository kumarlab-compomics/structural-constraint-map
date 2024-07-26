import argparse
import pandas as pd
from Bio.PDB import PDBParser
from Bio.PDB.SASA import ShrakeRupley

parser = argparse.ArgumentParser()
parser.add_argument("-p", "--pdb", help = "pdb file")
parser.add_argument("-i", "--isoform", help = "isoform name")
parser.add_argument("-o", "--output", help = "output file name")
args = parser.parse_args()

p = PDBParser()
struct = p.get_structure(args.isoform, args.pdb)

sr = ShrakeRupley()
sr.compute(struct, level="R")

sasa_metrics = {}
for model in struct:
    for chain in model:
        for residue in chain:
            res_name = residue.resname
            res_num = residue.id[1]
            sasa = residue.sasa
            sasa_metrics[(res_num)] = sasa

df = pd.DataFrame(sasa_metrics.items())

df.to_csv(args.output,sep = ",", header = False, index = False)
