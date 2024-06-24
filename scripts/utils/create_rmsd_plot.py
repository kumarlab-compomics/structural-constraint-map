from prody import *
from pylab import * #matplotlib?
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("-p", "--pdb", help = "multimodel pdb file")
parser.add_argument("-o", "--output", help = "plot output file name")
args = parser.parse_args()

p = parsePDB(args.pdb)
print(args.pdb)

rmsd_mean = []

for i in range(p.numCoordsets()):
	p.setACSIndex(i)
	alignCoordsets(p)
	rmsd = calcRMSD(p)
	rmsd_mean.append(rmsd.sum() / (len(rmsd) - 1))

bar(arange(1, len(rmsd_mean) + 1), rmsd_mean)
xlabel('Conformation index')
ylabel('Mean RMSD');

print(mean(rmsd_mean))

savefig(args.output, bbox_inches='tight')
