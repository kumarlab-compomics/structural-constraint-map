library(frustratometeR)
library(reticulate)

args = commandArgs(trailingOnly=TRUE)

use_python("~/envs/clustering/bin/python")
Sys.setenv(RETICULATE_PYTHON = "~/envs/clustering/bin/python")
reticulate::py_config()

PdbFile <- args[1] #must use full path
ResultsDir <- args[2] #must use full path

dir.create(file.path(ResultsDir))

Pdb_conf <- calculate_frustration(PdbFile = PdbFile, Mode = "singleresidue", ResultsDir = ResultsDir, Graphics = TRUE)
