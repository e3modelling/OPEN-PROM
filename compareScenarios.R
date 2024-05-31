# This script generates a mif file for comparison of OPEN-PROM run folder
# data with MENA-EDS and ENERDATA

setwd(paste0(getwd(),"/runs"))

dirs <- list.dirs()

files <- list.files()
files <- as.data.frame(files)

vals <- interaction(files$files)
opts <- as.character(unique(vals))
print_choices <- print(opts)
choice <- gms::getLine()
choice <- unlist(strsplit(choice, ","))

scenario <- files[unique(vals) %in% opts[as.integer(choice)],]

scenario_n <- basename(dirs)

for (i in scenario) {
  setwd(dirs[which(scenario_n == i)])
  source("reportOutput.R")
  reporting <- read.report("reporting.mif")
  setwd("..")
  write.report(reporting, file="compareScenarios.mif", append = TRUE)
}

