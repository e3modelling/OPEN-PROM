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

# Creating datasets for research and development mode
if (!is.null(DevMode) && DevMode == 0) {
    library(mrprom)
    print( paste("Generating research mode data with mrprom ver.", packageVersion("mrprom")) )
    fname <- paste0("rev0",dev,"_1f966d19_open_prom.tgz") # file name
    # run the fullOPEN-PROM function generating the whole input dataset of OPEN-PROM
    # retrieveData contains a call to fullOPEN-PROM
    retrieveData("OPEN_PROM",puc=F,renv=F,regionmapping = "regionmappingOP5.csv",dev=dev)
    file.copy(paste0(getConfig("outputfolder"),"/",fname),fname)
    
} else if (!is.null(DevMode) && DevMode == 1) {
    library(mrprom)
    print( paste("Generating development mode data with mrprom ver.", packageVersion("mrprom")) )
    fname <- paste0("rev0",dev,"_h12_open_prom.tgz") # file name
    retrieveData("OPEN_PROM",puc=F,renv=F,regionmapping = "h12.csv",dev=dev)
    file.copy(paste0(getConfig("outputfolder"),"/",fname),fname)

} else if (!is.null(DevMode) && DevMode == 2) {
    print("Getting data for test mode")
    url <- 'https://drive.usercontent.google.com/u/0/uc?id=1YTO3jaqFbZJ5x_J2JfSsVYljXtHBHk0p&export=download'
    fname <- 'dummy_data.tgz' 
    download.file(url, fname, mode="wb")
}

# Extracting the CSV files into the data folder
utils::untar(fname, exdir = "./data")