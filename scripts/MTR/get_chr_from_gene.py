"""
Last modified: 2024-05-20
Given a gene name, this script identifies the chromosome where the gene is located.
"""

import pandas as pd
import sys

GENE = sys.argv[1]
fmapping = '/cluster/projects/kumargroup/isoform-constraint-map/MTR/COSMIC_CGC_tier1/input/mart_export_gene_chr_processed_unique.txt'
dfmapping = pd.read_csv(fmapping)

CHROMOSOME = dfmapping[dfmapping['Gene'] == GENE].iloc[0]['chr']

print(CHROMOSOME)
