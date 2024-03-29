#library(gitr)
# Script for OPEN-PROM model execution and other associated tasks 

createRunFolder = 1 # Set to 0 to disable run folder creation and file copying

if(createRunFolder == 1) {

# generate name of run folder
scenario <- "default"
folderName <- paste(scenario, format(Sys.time(), "%e-%m-%Y_%H-%M-%S"), sep="_")

# create run folder under /runs
if (!file.exists("runs")) dir.create("runs")
runfolder <- paste0("runs/", folderName)
dir.create(runfolder)

# copy necessary files to folder
file.copy(grep(".gms$",dir(), value = TRUE), to = runfolder)
file.copy(grep(".csv$",dir(), value = TRUE), to = runfolder)
file.copy(grep("*.R$",dir(), value = TRUE), to = runfolder)
file.copy("conopt.opt", to = runfolder)
file.copy("data", to = runfolder, recursive = TRUE)

# switch to the run folder
setwd(runfolder)

}

# run model
system("gams main.gms --DevMode=0 --GenerateInput=off -logOption 4 -Idir=./data")

