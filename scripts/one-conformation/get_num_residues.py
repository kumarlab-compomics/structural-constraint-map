from prody import *
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("-p", "--pdb", help = "pdb file")
parser.add_argument("-o", "--output", help = "output file name")
args = parser.parse_args()

pdb = parsePDB(args.pdb)

#keep and count only alpha carbons (as proxy for amino acids)
ca = pdb.select('calpha')
num = pdb.getResnums().max()

#write to file

f = open(args.output, 'w')
out = str(num) + "\n"
f.write(out)
f.close()
