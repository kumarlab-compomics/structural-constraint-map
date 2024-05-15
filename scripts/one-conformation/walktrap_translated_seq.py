"""
Performs community detection by using Walktrap algorithm implemented in igraph-python
Script copied from google colab.
Last modified: 2024-02-15
Started: 2024-02-15
"""

import igraph as ig
from igraph import Graph
import pandas as pd
import sys

# Define a functions to perform clustering using walktrap
def detect_communities_walktrap(graph, n_nodes, fout):

  # Obtain weights
  e_weights = graph.es["weight"]

  # Create a list whose length is # of nodes (starts from 1)
  list_AAidx = [i for i in range(1, n_nodes+1)]

  # Run the walktrap algorithm
  tree_WalkTrap = graph.community_walktrap(weights=e_weights)
  communities_WalkTrap = tree_WalkTrap.as_clustering()
  cmty_membership_WalkTrap = communities_WalkTrap.membership
  print(cmty_membership_WalkTrap)

  # Convert the clustering result to a dataframe
  dfout_walktrap = pd.DataFrame(list(zip(list_AAidx, cmty_membership_WalkTrap)),
               columns =["AAidx", "cmty_ID"])
  # Write the clustering result to an output file
  dfout_walktrap.to_csv(fout, index=False, header=None)


# Define a function that, for a given sample, reads DCA output, processes it, generate a graph, and runs community detection
def weight_to_clusters_translatedW_seq(f_input, f_output):

  # Read data into dataframe
  dfW = pd.read_csv(f_input, names=["idx1", "idx2", "weight"])

  # Obtain # of nodes
  n_nodes = int(dfW.iloc[-1]["idx2"])

  # For edges of which weight is <= 0, replace the edge weight with a tiny value
  dfW_translated = dfW.copy()
  dfW_translated["weight"].values[dfW_translated["weight"].values <= 0] = 0.000000000000000000001

  # Generate a graph
  gW_translated = Graph.DataFrame(dfW_translated, directed=False, vertices=None, use_vids=False)

  # Detect communities
  detect_communities_walktrap(gW_translated, n_nodes, f_output)

# Driver
#fin = "ENST00000374479_FUCA1.gplmDCA"
#fout = "ENST00000374479_FUCA1_walktrap_translated_seq.csv"
fin = sys.argv[1] #e.g. "ENST00000374479_FUCA1.gplmDCA"
fout = sys.argv[2] #e.g. "ENST00000374479_FUCA1_walktrap_translated_seq.csv"
weight_to_clusters_translatedW_seq(fin, fout)
