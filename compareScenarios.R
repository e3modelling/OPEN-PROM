# This script generates a mif file for comparison of OPEN-PROM run folder
# data with MENA-EDS and ENERDATA
library(coda)

#setwd("C:/Users/sioutas/github/open-prom-goxygen/runs")

dirs <- list.dirs()

files <- list.files()
files <- as.data.frame(files)

vals <- interaction(files$files)
opts <- as.character(unique(vals))
choice <- multi.menu(opts, title = "Select run folders")
scenario <- files[unique(vals) %in% opts[choice],]

scenario_n <- basename(dirs)

for (i in scenario) {
  setwd(dirs[which(scenario_n == i)])
  source("reportOutput.R")
  setwd("..")
}

