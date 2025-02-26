from prody import *
import pandas as pd
import argparse
import numpy as np

parser = argparse.ArgumentParser()
parser.add_argument("-e", "--ensemble", help = "conformational ensemble pdb from alphaflow")
parser.add_argument("-s", "--single", help = "single conformation pdb from colabfold")
parser.add_argument("-t", "--transcript", help = "transcript name in enst_gene form")
parser.add_argument("-o", "--output", help = "output file name")
args = parser.parse_args()

aflow = parsePDB(args.ensemble)
afold = parsePDB(args.single)

betas = afold.ca.getBetas()
resnums = afold.ca.getResnums()

# get rmsf values for each alpha carbon
calphas = aflow.select('calpha')
alignCoordsets(aflow)
rmsfs = np.round(calcRMSF(calphas),2)

df = pd.DataFrame({'transcript': args.transcript, 'resnum':resnums, 'plddt':betas, 'rmsf':rmsfs}) ### in the future: maybe join by resnum instead of doing a straight cbind here

df.to_csv(args.output, index=False, header=False)
