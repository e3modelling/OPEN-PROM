library(jsonlite)

# Script for OPEN-PROM model execution and other associated tasks.

# 0 - Define a function that saves metadata about the model run

saveMetadata<- function() {
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
  
  # Wrap the git_info list into another list to create the "Git information" hierarchy
  data_to_save <- list("Git Information" = git_info)
  
  # Convert to JSON and save to file
  json_data <- toJSON(data_to_save, pretty = TRUE)
  write(json_data, file = "metadata.json")
  
  cat("Git information has been saved to metadata.json\n")
}

# 1 - Creating a separate folder for each model run.

createRunFolder = TRUE # Set to FALSE to disable run folder creation and file copying

if(createRunFolder) {

# generate metadata file
saveMetadata()

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
file.copy("metadata.json", to = runfolder)
file.copy("data", to = runfolder, recursive = TRUE)

# switch to the run folder
setwd(runfolder)

}

# 2 - Executing the VS Code tasks

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
    system("gams main.gms --DevMode=1 --GenerateInput=off -logOption 4 -Idir=./data")

} else if (!is.null(task) && task == 1) {

    # Running task OPEN-PROM DEV NEW DATA
    system("gams main.gms --DevMode=1 --GenerateInput=on -logOption 4 -Idir=./data")
    if(createRunFolder) {
      file.copy("data", to = '../../', recursive = TRUE) # Copying generated data to parent folder for future runs
      }        

} else if (!is.null(task) && task == 2) {
    
    # Running task OPEN-PROM RESEARCH
    system("gams main.gms --DevMode=0 --GenerateInput=off -logOption 4 -Idir=./data")

} else if (!is.null(task) && task == 3) {
    
    # Running task OPEN-PROM RESEARCH NEW DATA
    system("gams main.gms --DevMode=0 --GenerateInput=on -logOption 4 -Idir=./data")
    if(createRunFolder) {
      file.copy("data", to = '../../', recursive = TRUE)
      }    
}