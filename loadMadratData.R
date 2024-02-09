print("Generating input data with mrprom/MADRAT and copying to OPEN-PROM")
library(mrprom)

# create a unique dataset name based on current time
dev <- unclass(Sys.time())

# Parsing the command line argument
args <- commandArgs(trailingOnly = TRUE)
DevMode <- NULL

for (arg in args) {
  key_value <- strsplit(arg, "=")[[1]]
  
  if (key_value[1] == "DevMode") {
    DevMode <- as.numeric(key_value[2])
  }
}

# Creating datasets for research and development mode
if (!is.null(DevMode) && DevMode == 0) {
    print("Creating data for research mode")
    fname <- paste0("rev0",dev,"_28b9ea46_open_prom.tgz") # file name
    # run the fullOPEN-PROM function generating the whole input dataset of OPEN-PROM
    # retrieveData contains a call to fullOPEN-PROM
    retrieveData("OPEN_PROM",puc=F,renv=F,regionmapping = "regionmappingOP.csv",dev=dev)
    
} else if (!is.null(DevMode) && DevMode == 1) {
    print("Creating data for development mode")
    fname <- paste0("rev0",dev,"_a9c72a01_open_prom.tgz") # file name
    retrieveData("OPEN_PROM",puc=F,renv=F,regionmapping = "regionmappingOPDEV2.csv",dev=dev)
}

# copy the dataset into the model
file.copy(paste0(getConfig("outputfolder"),"/",fname),fname)
utils::untar(fname, exdir = "./data")