#' Check run folders and generate status list
#'
#' Scans the \code{runs} directory inside a given base path and evaluates
#' each subfolder for required files such as \code{main.gms}, \code{main.log},
#' \code{main.lst}, and optional files like \code{git_diff.txt}. The function
#' determines run status (FAILED, COMPLETED, PENDING), extracts the final year,
#' checks calibration settings, and flags modified runs.
#'
#' @param base_path Character path to the root directory containing \code{runs/}.
#' @param flag Logical, reserved for extended modelstat checks. Default: FALSE.
#'
#' @return A list where each element contains:
#'   \itemize{
#'     \item \code{message} — formatted status message
#'     \item \code{folder}  — full path of the run folder
#'   }
#'

check_files_and_list_subfolders <- function(base_path, flag = FALSE) {
  runs_path <- file.path(base_path, "runs")
  subfolders <- dir(runs_path, full.names = TRUE, recursive = FALSE)
  subfolders <- subfolders[file.info(subfolders)$isdir]
  
  folder_names <- basename(subfolders)
  max_folder_name_length <- max(nchar(folder_names))
  max_status_length <- 35
  max_year_length <- 4
  
  current_time <- as.numeric(Sys.time())
  max_modification_threshold <- 120
  max_mod_time <- current_time - max_modification_threshold
  
  subfolder_status_list <- list()
  
  for (folder in subfolders) {
    main_gms_path <- file.path(folder, "main.gms")
    main_lst_path <- file.path(folder, "main.lst")
    main_log_path <- file.path(folder, "main.log")
    git_diff_path <- file.path(folder, "git_diff.txt")
    
    folder_name <- basename(folder)
    status <- ""
    run_type <- "Run: Vanilla"
    
    # Determine calibration mode
    if (file.exists(main_gms_path)) {
      gms_txt <- readLines(main_gms_path, warn = FALSE)
      if (any(grepl("\\$setGlobal Calibration on", gms_txt)))
        run_type <- "Run: Calibration"
    }
    
    modified_status <- ifelse(file.exists(git_diff_path), "Yes", "No")
    
    if (!file.exists(main_gms_path)) {
      status <- sprintf("%-*s", max_status_length,
                        "Missing: main.gms  Status: NOT A RUN")
      
    } else if (!file.exists(main_lst_path) || !file.exists(main_log_path)) {
      
      if (current_time > max_mod_time) {
        status <- sprintf("%-*s", max_status_length,
                          "main.lst or main.log missing -> FAILED Year: None Horizon: None")
      } else {
        status <- sprintf("%-*s", max_status_length,
                          "Missing: main.lst or main.log Status: PENDING")
      }
      
    } else {
      # Extract end year
      gms_lines <- readLines(main_gms_path, warn = FALSE)
      end_line <- gms_lines[grepl("\\$evalGlobal fEndY", gms_lines)]
      end_horizon_year <- ifelse(length(end_line) > 0,
                                 tail(str_split(end_line, "\\s+")[[1]], 1), "NA")
      
      log_lines <- readLines(main_log_path, warn = FALSE)
      
      year <- NA
      running_year <- NA
      
      loop_lines <- grep("--- LOOPS an =", log_lines, value = TRUE)
      if (length(loop_lines) > 0) {
        year <- str_trim(str_split(loop_lines[length(loop_lines)], "=")[[1]][2])
        running_year <- year
      }
      
      log_time <- as.numeric(file.info(main_log_path)$mtime)
      time_diff <- current_time - log_time
      modification_threshold <- 15
      completed <- any(grepl("\\*\\*\\* Status: Normal completion", log_lines))
      
      if (completed) {
        status <- sprintf("%-*s", max_status_length,
                          paste("Missing: NONE Status: COMPLETED Year:", year,
                                "Horizon:", end_horizon_year))
        
      } else if (!completed && time_diff < modification_threshold) {
        status <- sprintf("%-*s", max_status_length,
                          paste("Missing: NONE Status: PENDING Running_Year:",
                                running_year, "Horizon:", end_horizon_year))
        
      } else {
        status <- sprintf("%-*s", max_status_length,
                          paste("main.log -> FAILED Status: FAILED Year:", year,
                                "Horizon:", end_horizon_year))
      }
    }
    
    msg <- sprintf("%-*s %s %s Modified: %s",
                   max_folder_name_length, folder_name,
                   status, run_type, modified_status)
    
    subfolder_status_list[[length(subfolder_status_list) + 1]] <-
      list(message = msg, folder = folder)
  }
  
  subfolder_status_list <- subfolder_status_list[
    order(sapply(subfolder_status_list, function(x) file.info(x$folder)$ctime))
  ]
  
  return(subfolder_status_list)
}

#' Get the directory of the currently running script
#'
#' Works in Rscript, RStudio, and interactive sessions.
#'
#' @return Character path of the script directory

get_script_directory <- function() {
  # Rscript
  cmd_args <- commandArgs(trailingOnly = FALSE)
  file_arg <- "--file="
  file_index <- grep(file_arg, cmd_args)
  
  if (length(file_index) > 0) {
    script_path <- sub(file_arg, "", cmd_args[file_index])
    return(dirname(normalizePath(script_path)))
  }
  
  # RStudio
  if (rstudioapi::isAvailable()) {
    script_path <- rstudioapi::getSourceEditorContext()$path
    if (nzchar(script_path)) return(dirname(normalizePath(script_path)))
  }
  
  # Sourced or interactive
  if (!is.null(sys.frame(1)$ofile)) {
    return(dirname(normalizePath(sys.frame(1)$ofile)))
  }
  
  # Fallback
  return(normalizePath(getwd()))
}

#' Display numbered, color-coded subfolder status list
#'
#' Prints the list produced by \code{check_files_and_list_subfolders()} in
#' reverse order, applying color coding:
#' \itemize{
#'   \item Red — FAILED
#'   \item Blue — PENDING
#'   \item Green — COMPLETED
#' }
#'
#' @param subfolder_status_list List output from
#'   \code{\link{check_files_and_list_subfolders}}.
#'

list_subfolders <- function(subfolder_status_list) {
  if (length(subfolder_status_list) == 0) {
    cat("No subfolders found in the 'runs' directory.\n")
    return(list())
  }
  
  cat(yellow("List of subfolders...\n\n"))
  
  n <- length(subfolder_status_list)
  
  for (i in seq_along(subfolder_status_list)) {
    num <- n - i + 1
    msg <- subfolder_status_list[[i]]$message
    
    colored_msg <- if (grepl("FAILED", msg)) red(msg)
    else if (grepl("PENDING", msg)) blue(msg)
    else if (grepl("COMPLETED", msg)) green(msg)
    else msg
    
    cat(sprintf("%2d. %s\n", num, colored_msg))
  }
  
  return(subfolder_status_list)
}

