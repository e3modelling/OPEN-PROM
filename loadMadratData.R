print("Generating input data with mrprom/MADRAT and copying to OPEN-PROM")
library(mrprom)
dev <- unclass(Sys.time()) # create a unique dataset name based on current time
fname <- paste0("rev0",dev,"_a9c72a01_open_prom.tgz") # file name
# run the fullOPEN-PROM function generating the whole input dataset of OPEN-PROM
# retrieveData contains a call to fullOPEN-PROM
retrieveData("OPEN_PROM",puc=F,renv=F,regionmapping = "regionmappingOPDEV2.csv",dev=dev)
# copy the dataset into the model
file.copy(paste0(getConfig("outputfolder"),"/",fname),fname)
utils::untar(fname)