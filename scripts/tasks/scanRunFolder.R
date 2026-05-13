#' VS Code–friendly wrapper to select run folders (camelCase)
#'
#' Runs \code{checkFilesAndListSubfolders()} and
#' \code{listSubfolders()} and selects
#' one or more subfolders automatically.
#'
#' @param preselect Optional numeric vector (indexes) or character vector (folder names) to select subfolders.
#' If NULL, all subfolders are selected.
#'
#' @return A list of selected subfolder entries.

library(stringr)   # for str_split, str_trim
library(crayon)    # for yellow(), red(), blue(), green()

scanRunFolder <- function(preselect = NULL) {
  
  # Path to the script directory
  scriptDirectory <- getScriptDirectory()
  print(scriptDirectory)
  
  # Get subfolders and their status
  subfolderStatusList <- checkFilesAndListSubfolders(scriptDirectory)
  selectedSubfolders <- listSubfolders(subfolderStatusList)
  
  if (length(selectedSubfolders) == 0) {
    cat("No subfolders found in the 'runs' directory.\n")
    return(NULL)
  }
  
  # Display numbered list of available subfolders
  folderNames <- sapply(selectedSubfolders, `[[`, "folder")
  
  # Ask user to input numbers (all at once, like Python input)
  cat("\nEnter the numbers of the subfolders (e.g., 1 2 3): ")
  input <- readLines("stdin", n = 1)
  choices <- as.integer(str_split(input, "\\s+")[[1]])
  
  # Validate selections
  choices <- choices[choices >= 1 & choices <= length(selectedSubfolders)]
  if (length(choices) == 0) {
    cat("No valid selections made. Returning NULL.\n")
    return(NULL)
  }
  
  # Select subfolders based on user input
  n <- length(selectedSubfolders)
  chosenSubfolders <- lapply(choices, function(choice) selectedSubfolders[[n - choice + 1]])
  
  return(chosenSubfolders)
}