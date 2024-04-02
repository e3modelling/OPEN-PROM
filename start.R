library(jsonlite)

### Script for OPEN-PROM model execution and other associated tasks.

withRunFolder = TRUE # Set to FALSE to disable run folder creation and file copying

### 0 - Define function that saves model metadata into a JSON file.

saveMetadata<- function(DevMode) {

  # Gather Git information with system calls
  commit_author <- system("git log -1 --format=%an", intern = TRUE)
  commit_hash <- system("git log -1 --format=%H", intern = TRUE)
  commit_comment <- system("git log -1 --format=%B", intern = TRUE)
  commit_date <- system("git log -1 --format=%ad", intern = TRUE)
  branch_name <- system("git rev-parse --abbrev-ref HEAD", intern = TRUE)
  
  # Organize information into a list
  git_info <- list(
    "Author" = commit_author,
    "Commit Hash" = commit_hash,
    "Commit Comment" = commit_comment,
    "Date" = commit_date,
    "Branch Name" = branch_name
  )
 
  # Save the appropriate region mapping for each type of run (Development / Research).
  if(DevMode == 0) {
    
    model_info <- list('Region Mapping' = "regionmappingOP5.csv")

    } else if (DevMode == 1) {

      model_info <- list('Region Mapping' = "regionmappingOPDEV2.csv")
    }

  # Convert to JSON and save to file
  data_to_save <- list("Git Information" = git_info, "Model Information" = model_info)
  json_data <- toJSON(data_to_save, pretty = TRUE)
  write(json_data, file = "metadata.json")
  
  cat("Metadata has been saved to metadata.json\n")
  
}

### 1 - Define a function that creates a separate folder for each model run.

createRunFolder <- function() {

  # generate name of run folder
  scenario <- "default"
  folderName <- paste(scenario, format(Sys.time(), "%d-%m-%Y_%H-%M-%S"), sep="_")

  # create run folder under /runs
  if (!file.exists("runs")) dir.create("runs")
  runfolder <- paste0("runs/", folderName)
  dir.create(runfolder)

  # copy necessary files to folder
  file.copy(grep(".gms$",dir(), value = TRUE), to = runfolder)
  file.copy(grep(".csv$",dir(), value = TRUE), to = runfolder)
  file.copy(grep("*.R$",dir(), value = TRUE), to = runfolder)
  file.copy("conopt.opt", to = runfolder)
  file.copy("metadata.json", to = runfolder)
  file.copy("data", to = runfolder, recursive = TRUE)

  # switch to the run folder
  setwd(runfolder)

}

### 2 - Executing the VS Code tasks

# Parsing the command line argument
args <- commandArgs(trailingOnly = TRUE)
task <- NULL

for (arg in args) {
  key_value <- strsplit(arg, "=")[[1]]
  
  if (key_value[1] == "task") {
    task <- as.numeric(key_value[2])
  }
}

# Setting the appropriate GAMS flags for each task
if (!is.null(task) && task == 0) {

    # Running task OPEN-PROM DEV
    saveMetadata(DevMode = 1)
    if(withRunFolder) { createRunFolder() }

    system("gams main.gms --DevMode=1 --GenerateInput=off -logOption 4 -Idir=./data")

} else if (!is.null(task) && task == 1) {

    # Running task OPEN-PROM DEV NEW DATA
    saveMetadata(DevMode = 1)
    if(withRunFolder) { createRunFolder() }

    system("gams main.gms --DevMode=1 --GenerateInput=on -logOption 4 -Idir=./data")

    if(withRunFolder) {
      file.copy("data", to = '../../', recursive = TRUE) # Copying generated data to parent folder for future runs
      }        

} else if (!is.null(task) && task == 2) {
    
    # Running task OPEN-PROM RESEARCH
    saveMetadata(DevMode = 0)
    if(withRunFolder) { createRunFolder() }

    system("gams main.gms --DevMode=0 --GenerateInput=off -logOption 4 -Idir=./data")

} else if (!is.null(task) && task == 3) {
    
    # Running task OPEN-PROM RESEARCH NEW DATA
    saveMetadata(DevMode = 0)
    if(withRunFolder) { createRunFolder() }

    system("gams main.gms --DevMode=0 --GenerateInput=on -logOption 4 -Idir=./data")

    if(withRunFolder) {
      file.copy("data", to = '../../', recursive = TRUE)
      }    
}