
#' VS Code–friendly wrapper to select run folders
#'
#' Runs \code{check_files_and_list_subfolders()} and
#' \code{list_subfolders()} and selects
#' one or more subfolders automatically.
#'
#' @param preselect Optional numeric vector (indexes) or character vector (folder names) to select subfolders.
#' If NULL, all subfolders are selected.
#'
#' @return A list of selected subfolder entries.
#'
#' Lists available subfolders and allows the user to select
#' one or more subfolders by number, similar to the Python version.
#'
#' @return A list of selected subfolder entries.

library(stringr)   # for str_split, str_trim
library(crayon)    # for yellow(), red(), blue(), green()

scan_run_folder <- function() {
  
  # Path to the script directory
  script_directory <- get_script_directory()
  print(script_directory)
  
  # Get subfolders and their status
  subfolder_status_list <- check_files_and_list_subfolders(script_directory)
  selected_subfolders <- list_subfolders(subfolder_status_list)
  
  if (length(selected_subfolders) == 0) {
    cat("No subfolders found in the 'runs' directory.\n")
    return(NULL)
  }
  
  # Display numbered list of available subfolders
  folder_names <- sapply(selected_subfolders, `[[`, "folder")
  # cat("\nAvailable subfolders:\n")
  # for (i in seq_along(folder_names)) {
  #   cat(i, ". ", folder_names[i], "\n", sep = "")
  # }
  
  # Ask user to input numbers (all at once, like Python input)
  cat("\nEnter the numbers of the subfolders (e.g., 1 2 3): ")
  # choices <- scan(what = integer(), quiet = TRUE)
  input <- readLines("stdin", n = 1)
  choices <- as.integer(strsplit(input, "\\s+")[[1]])
  
  # Validate selections
  choices <- choices[choices >= 1 & choices <= length(selected_subfolders)]
  if (length(choices) == 0) {
    cat("No valid selections made. Returning NULL.\n")
    return(NULL)
  }
  
  # Select subfolders based on user input
  n <- length(selected_subfolders)
  chosen <- lapply(choices, function(choice) selected_subfolders[[n - choice + 1]])
  
  return(chosen)
}
