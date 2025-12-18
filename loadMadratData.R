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
    # Load mrprom library with error handling
    tryCatch({
        library(mrprom)
    }, error = function(e) {
        cat("ERROR: Failed to load mrprom library:\n", conditionMessage(e), "\n")
        stop("Cannot load required mrprom library. Please ensure it is properly installed.")
    })
    
    print( paste("Generating research mode data with mrprom ver.", installed.packages()["mrprom","Version"]) )
    fname <- paste0("rev0",dev,"_dabc6ef9_open_prom.tgz") # file name
    fnameTargets <- paste0("rev0",dev,"_dabc6ef9_targets.tgz")
    # run the fullOPEN-PROM function generating the whole input dataset of OPEN-PROM
    # retrieveData contains a call to fullOPEN-PROM
    
    cat("Retrieving OPEN_PROM data...\n")
    tryCatch({
        retrieveData("OPEN_PROM",puc=F,renv=F,regionmapping = "regionmappingOPDEV5.csv",dev=dev)
    }, error = function(e) {
        cat("ERROR: Failed to retrieve OPEN_PROM data:\n", conditionMessage(e), "\n")
        stop("Data retrieval for OPEN_PROM failed. Terminating data generation.")
    })
    
    # retrieve targets for calibration
    #setConfig(ignorecache = T)
    cat("Retrieving TARGETS data...\n")
    tryCatch({
        retrieveData("TARGETS",puc=F,renv=F,regionmapping = "regionmappingOPDEV5.csv",dev=dev)
    }, error = function(e) {
        cat("ERROR: Failed to retrieve TARGETS data:\n", conditionMessage(e), "\n")
        stop("Data retrieval for TARGETS failed. Terminating data generation.")
    })
    
    # Copy generated files with error handling
    src_fname <- paste0(getConfig("outputfolder"),"/",fname)
    src_targets <- paste0(getConfig("outputfolder"),"/",fnameTargets)
    
    if (!file.exists(src_fname)) {
        cat("ERROR: Generated OPEN_PROM data file not found:", src_fname, "\n")
        stop("Expected data file was not generated. Data generation failed.")
    }
    
    if (!file.exists(src_targets)) {
        cat("ERROR: Generated TARGETS data file not found:", src_targets, "\n")
        stop("Expected targets file was not generated. Data generation failed.")
    }
    
    if (!file.copy(src_fname, fname)) {
        cat("ERROR: Failed to copy OPEN_PROM data file\n")
        stop("File copy operation failed for OPEN_PROM data.")
    }
    
    if (!file.copy(src_targets, fnameTargets)) {
        cat("ERROR: Failed to copy TARGETS data file\n")
        stop("File copy operation failed for TARGETS data.")
    }
    
    cat("Research mode data generation completed successfully.\n")
    
} else if (!is.null(DevMode) && DevMode == 1) {
    library(mrprom)
    print( paste("Generating development mode data with mrprom ver.", installed.packages()["mrprom","Version"]) )
    fname <- paste0("rev0",dev,"_bdd58f98_open_prom.tgz") # file name
    retrieveData("OPEN_PROM",puc=F,renv=F,regionmapping = "regionmappingOPDEV4.csv",dev=dev)
    file.copy(paste0(getConfig("outputfolder"),"/",fname),fname)

} else if (!is.null(DevMode) && DevMode == 2) {
    print("Getting data for test mode")
    url <- 'https://drive.google.com/uc?export=download&id=1_IbBdi3UtVPJ5KFCs_7G1qzaCLrv-S61'
    fname <- 'dummy_data.tgz' 
    download.file(url, fname, mode="wb")
}

# Verify that we have a data file to extract
if (!exists("fname") || is.null(fname) || !file.exists(fname)) {
    cat("ERROR: No data file available for extraction\n")
    stop("Data generation failed - no archive file to extract.")
}

# Extracting the CSV files into the data folder
cat("Extracting data from:", fname, "\n")
tryCatch({
    utils::untar(fname, exdir = "./data")
}, error = function(e) {
    cat("ERROR: Failed to extract data archive:\n", conditionMessage(e), "\n")
    stop("Data extraction failed. Archive file may be corrupted.")
})

# Verify data extraction was successful
if (!dir.exists("./data") || length(list.files("./data", pattern = "\\.csv$")) == 0) {
    cat("ERROR: Data extraction verification failed - no CSV files found\n")
    stop("Data extraction failed - no data files were extracted.")
}

cat("Data extraction completed successfully.\n")

# Extract targets if available
if (!is.null(fnameTargets)) {
    if (file.exists(fnameTargets)) {
        cat("Extracting targets from:", fnameTargets, "\n")
        tryCatch({
            utils::untar(fnameTargets, exdir = "./targets")
        }, error = function(e) {
            cat("ERROR: Failed to extract targets archive:\n", conditionMessage(e), "\n")
            stop("Targets extraction failed. Archive file may be corrupted.")
        })
        
        # Verify targets extraction
        if (!dir.exists("./targets")) {
            cat("ERROR: Targets extraction verification failed - targets directory not created\n")
            stop("Targets extraction failed.")
        }
        
        cat("Targets extraction completed successfully.\n")
    } else {
        cat("WARNING: Targets file specified but not found:", fnameTargets, "\n")
    }
}
# Extracting the CSV files into the targets folder

