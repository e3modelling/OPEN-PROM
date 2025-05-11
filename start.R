### Script for OPEN-PROM model execution and other associated tasks.
library(jsonlite)

# Various flags used to modify script behavior
withRunFolder = TRUE # Set to FALSE to disable model run folder creation and file copying
withSync = TRUE # Set to FALSE to disable model run sync to SharePoint
withReport = TRUE # Set to FALSE to disable the report output script execution (applicable to research mode only)
uploadGDX = FALSE # Set to TRUE to include GDX files in the uploaded archive

### Define function that saves model metadata into a JSON file.

saveMetadata<- function(DevMode) {

  # Gather Git information with system calls
  commit_author <- system("git log -1 --format=%an", intern = TRUE)
  commit_hash <- system("git log -1 --format=%H", intern = TRUE)
  commit_comment <- system("git log -1 --format=%B", intern = TRUE)
  commit_date <- system("git log -1 --format=%ad", intern = TRUE)
  branch_name <- system("git rev-parse --abbrev-ref HEAD", intern = TRUE)
  git_status <- system("git status -s", intern = TRUE)
  system("git diff --output=git_diff.txt")
  
  if(length(git_status) == 0) git_status <- "There are no changes made."
  
  # Organize Git information into a list
  git_info <- list(
    "Author" = commit_author,
    "Branch Name" = branch_name,
    "Commit Comment" = commit_comment,
    "Git Status" = git_status,
    "Commit Hash" = commit_hash,
    "Date" = commit_date
  )
 
  # Save the appropriate region mapping for each type of run (Development / Research).
  if(DevMode == 0) {
    
    mapping <- "regionmappingOPDEV3.csv"

  } else if (DevMode == 1) {

    mapping <- "regionmappingOPDEV2.csv"
  }

  # Get the model run description from config file
  run_desc <- NULL
  if (file.exists('config.json')) {
    config <- fromJSON('config.json')
    desc_config <- config$description
  }

  if(!is.null(desc_config) && nzchar(trimws(desc_config)) ) {
    run_desc <- desc_config

  } else {
    run_desc <- "Default model run description."
  }

  # Collect model information in a list
  model_info <- list(
    "Region Mapping" = mapping,
    "Run Description" = run_desc
  )

  # Convert to JSON and save to file
  data_to_save <- list("Git Information" = git_info, "Model Information" = model_info)
  json_data <- toJSON(data_to_save, pretty = TRUE)
  write(json_data, file = "metadata.json")
  
  cat("Metadata has been saved to metadata.json\n")
  
}

### Define a function that creates a separate folder for each model run.

createRunFolder <- function(scenario = "default") {

  # generate name of run folder
  folderName <- paste(scenario, format(Sys.time(), "%Y-%m-%d_%H-%M-%S"), sep="_")

  # create run folder under /runs
  if (!file.exists("runs")) dir.create("runs")
  runfolder <- paste0("runs/", folderName)
  dir.create(runfolder)

  # copy necessary files to folder
  file.copy(grep(".gms$",dir(), value = TRUE), to = runfolder)
  file.copy(grep(".csv$",dir(), value = TRUE), to = runfolder)
  file.copy(grep("*.R$",dir(), value = TRUE), to = runfolder)
  file.copy(grep("*.json$",dir(), value = TRUE), to = runfolder)
  file.copy("conopt.opt", to = runfolder)
  file.copy("git_diff.txt", to = runfolder)  
  file.copy("data", to = runfolder, recursive = TRUE)
  file.copy("core", to = runfolder, recursive = TRUE)
  file.copy("modules", to = runfolder, recursive = TRUE)
  
  # switch to the run folder
  setwd(runfolder)
}

### Define a function that archives and uploads each model run to a cloud
syncRun<- function() {

  folder_path <- getwd()
  archive_name <- paste0(basename(folder_path), ".tgz")
  
  # Create tgz archive with the files of each model run
  all_files <- list.files(folder_path, recursive = TRUE, all.files = TRUE)

  # Include GDX files based on user preference
  if(uploadGDX) {
    files_to_archive <- all_files
  } else {
    files_to_archive <- all_files[!grepl("\\.gdx$", all_files, ignore.case = TRUE)]
  }

  # Validate the model runs SharePoint path
  if (file.exists('config.json')) {

    config <- fromJSON('config.json')
    model_runs_path <- config$model_runs_path

    if(!is.null(model_runs_path) && file.exists(model_runs_path) && file.info(model_runs_path)$isdir) {
     
      # Copy the archive to the user-specified directory
      tar(tarfile = archive_name, files = files_to_archive, compression = "gzip", tar = "internal")

      destination_path <- file.path(model_runs_path, basename(archive_name))
      if( file.copy(archive_name, destination_path, overwrite = TRUE) ) {
        cat("File copied successfully to", destination_path, "\n")
      } 

    } else {
      cat("Please enter a valid model runs SharePoint directory path.\n")
      quit()      
    }

  } else if (!file.exists('config.json')) {

    cat("Please create a configuration file (config.json).\n")
    quit()
  }

  # Delete the archive if it exists
  if (file.exists(archive_name)) {
    file.remove(archive_name)
  }
  
}

### Define a function that returns the scenario name
setScenarioName <- function(scen_default) {

  scen_config <- NULL
  # Reading the scenario name from config file
  if (file.exists('config.json')) {
    config <- fromJSON('config.json')
    scen_config <- config$scenario_name
  }

  # Checking if the scenario name is NULL or empty string
  if(!is.null(scen_config) && nzchar(trimws(scen_config)) ) {
    scen <- scen_config
  
  } else {
    # If the config scenario name is not valid, get the default one
    # as specified in each VS Code task, e.g. DEV, DEVNEWDATA etc
    cat("Invalid scenario name or missing config file, setting default name.\n")
    scen <- scen_default

  }
  
  return(scen)
}

### Executing the VS Code tasks

# Optionally setting a custom GAMS path
if (file.exists('config.json')) {
  config <- fromJSON('config.json')
  gams_path <- config$gams_path

  # Checking if the specified path exists and is a directory
  if(!is.null(gams_path) && file.exists(gams_path) && file.info(gams_path)$isdir) {
    gams <- paste0(gams_path,'gams')

  } else {
    cat("The specified custom GAMS path is not valid. Using the default path.\n")
    gams <- 'gams'
  }

} else {

# Use the default gams command if config.json doesn't exist.
  gams <- 'gams'
}

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
    if(withRunFolder) createRunFolder(setScenarioName("DEV"))

    shell(paste0(gams,' main.gms --DevMode=1 --GenerateInput=off -logOption 4 -Idir=./data 2>&1 | tee full.log'))

    if(withRunFolder && withSync) syncRun()

} else if (!is.null(task) && task == 1) {

    # Running task OPEN-PROM DEV NEW DATA
    saveMetadata(DevMode = 1)
    if(withRunFolder) createRunFolder(setScenarioName("DEVNEWDATA"))

    shell(paste0(gams,' main.gms --DevMode=1 --GenerateInput=on -logOption 4 -Idir=./data 2>&1 | tee full.log'))

    if(withRunFolder) {
      file.copy("data", to = '../../', recursive = TRUE) # Copying generated data to parent folder for future runs
      
      if(withSync) syncRun()
    }        

} else if (!is.null(task) && task == 2) {
    
    # Running task OPEN-PROM RESEARCH
    saveMetadata(DevMode = 0)
    if(withRunFolder) createRunFolder(setScenarioName("RES"))

    shell(paste0(gams,' main.gms --DevMode=0 --GenerateInput=off -logOption 4 -Idir=./data 2>&1 | tee full.log'))

    if(withRunFolder && withSync) syncRun()

    if(withRunFolder && withReport) {

      run_path <- getwd()
      setwd("../../") # Going back to root folder
      cat("Executing the report output script\n")
      report_cmd <- paste0("RScript ./reportOutput.R ", run_path) # Executing the report output script on the current run path
      shell(report_cmd)
    } 

} else if (!is.null(task) && task == 3) {
    
    # Running task OPEN-PROM RESEARCH NEW DATA
    saveMetadata(DevMode = 0)
    if(withRunFolder) createRunFolder(setScenarioName("RESNEWDATA"))

    shell(paste0(gams,' main.gms --DevMode=0 --GenerateInput=on -logOption 4 -Idir=./data 2>&1 | tee full.log'))

    if(withRunFolder) {
      file.copy("data", to = '../../', recursive = TRUE)

      if(withSync) syncRun()

    }    

    if(withRunFolder && withReport) {

      run_path <- getwd()
      setwd("../../") # Going back to root folder
      cat("Executing the report output script\n")
      report_cmd <- paste0("RScript ./reportOutput.R ", run_path) # Executing the report output script on the current run path
      shell(report_cmd)
    } 

} else if (!is.null(task) && task == 4) {
  
  # Debugging mode
  shell(paste0(gams,' main.gms -logOption 4 -a=ce -Idir=./data 2>&1 | tee full.log'))

}
