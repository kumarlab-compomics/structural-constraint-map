from prody import *
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("-e", "--ensemble", help = "conformational ensemble pdb from alphaflow")
parser.add_argument("-s", "--single", help = "single conformation pdb from colabfold")
parser.add_argument("-o", "--output", help = "output file name")
args = parser.parse_args()

aflow = parsePDB(args.ensemble)
afold = parsePDB(args.single)

ag = aflow.copy()
ag.addCoordset(afold.getCoords())

writePDB(args.output, ag)
