# Load necessary libraries/functions
library(gms)

# Function to read and process reportOutput.R
read_and_process_report <- function(base_path, scenario_name) {
  scenario_path <- file.path(base_path, "runs", scenario_name)
  setwd(scenario_path)
  source("reportOutput.R")
  reporting <- read.report("reporting.mif")
  setwd(base_path)  # Reset back to the base path
  return(reporting)
}

# Main script
compareScenarios <- function(base_path) {
  library(magclass)
  setwd(base_path)
  
  # List all subdirectories in the "runs" directory
  dirs <- list.dirs("runs", full.names = TRUE, recursive = FALSE)
  
  # List all files in the "runs" directory
  files <- list.files("runs", full.names = TRUE, recursive = FALSE)
  
  # Filter out only directories (excluding files)
  dirs <- dirs[dir.exists(dirs)]
  
  # Prompt user to select scenarios to compare
  cat("Available scenarios:\n")
  for (i in seq_along(dirs)) {
    cat(i, ": ", basename(dirs[i]), "\n")
  }
  
  choices <- readline(prompt = "Enter scenario numbers separated by commas (e.g., 1,2): ")
  choices <- unlist(strsplit(choices, ","))

  # Validate user input
  choices <- as.integer(choices)
  choices <- choices[choices >= 1 & choices <= length(dirs)]
  
  # Retrieve selected scenarios
  selected_scenarios <- dirs[choices]
  
  # Initialize an empty list to store reporting data
  all_reporting <- list()
  
  # Process each selected scenario
  for (scenario_path in selected_scenarios) {
    scenario_name <- basename(scenario_path)
    cat("Processing scenario:", scenario_name, "\n")
    
    # Read and process reportOutput.R for the current scenario
    reporting <- read_and_process_report(base_path, scenario_name)
    
    # Store reporting data in the list
    all_reporting[[scenario_name]] <- reporting
  }
  
  # Combine all reporting data into a single report
  combined_report <- do.call(rbind, all_reporting)
  
  # Write the combined report to compareScenarios.mif file
  write.report(combined_report, file = "compareScenarios.mif", append = FALSE)
  
  cat("Comparison report generated: compareScenarios.mif\n")
}

# Command-line argument handling
args <- commandArgs(trailingOnly = TRUE)

if (length(args) == 0) {
  cat("Please provide the base path as a command-line argument.\n")
  cat("Example usage: Rscript compareScenarios.R /path/to/base_directory\n")
} else {
  base_path <- args[1]
  compareScenarios(base_path)
}
