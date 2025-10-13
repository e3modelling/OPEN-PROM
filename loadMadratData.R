library(dplyr)
print("Creating input data with mrprom/MADRAT and copying to OPEN-PROM")

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
fnameTargets <- NULL
# Creating datasets for research and development mode
if (!is.null(DevMode) && DevMode == 0) {
    library(mrprom)
    print( paste("Generating research mode data with mrprom ver.", packageVersion("mrprom")) )
    fname <- paste0("rev0",dev,"_d9e03f92_open_prom.tgz") # file name
    fnameTargets <- paste0("rev0",dev,"_d9e03f92_targets.tgz")
    # run the fullOPEN-PROM function generating the whole input dataset of OPEN-PROM
    # retrieveData contains a call to fullOPEN-PROM
    
    retrieveData("OPEN_PROM",puc=F,renv=F,regionmapping = "regionmappingOPDEV3.csv",dev=dev)
    # retrieve targets for calibration
    #setConfig(ignorecache = T)
    
    retrieveData("TARGETS",puc=F,renv=F,regionmapping = "regionmappingOPDEV3.csv",dev=dev)
    file.copy(paste0(getConfig("outputfolder"),"/",fname),fname)
    file.copy(paste0(getConfig("outputfolder"),"/",fnameTargets),fnameTargets)
    
} else if (!is.null(DevMode) && DevMode == 1) {
    library(mrprom)
    print( paste("Generating development mode data with mrprom ver.", packageVersion("mrprom")) )
    fname <- paste0("rev0",dev,"_bdd58f98_open_prom.tgz") # file name
    retrieveData("OPEN_PROM",puc=F,renv=F,regionmapping = "regionmappingOPDEV4.csv",dev=dev)
    file.copy(paste0(getConfig("outputfolder"),"/",fname),fname)

} else if (!is.null(DevMode) && DevMode == 2) {
    print("Getting data for test mode")
    url <- 'https://drive.google.com/uc?export=download&id=1_IbBdi3UtVPJ5KFCs_7G1qzaCLrv-S61'
    fname <- 'dummy_data.tgz' 
    download.file(url, fname, mode="wb")
}

# Extracting the CSV files into the data folder
utils::untar(fname, exdir = "./data")

# Extracting the CSV files into the targets folder
utils::untar(fnameTargets, exdir = "./targets")
