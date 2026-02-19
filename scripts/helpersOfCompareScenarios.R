#' Check run folders and generate status list
#'
#' CamelCase version
#'
checkFilesAndListSubfolders <- function(basePath, flag = FALSE) {
  runsPath <- file.path(basePath, "runs")
  subfolders <- dir(runsPath, full.names = TRUE, recursive = FALSE)
  subfolders <- subfolders[file.info(subfolders)$isdir]
  
  folderNames <- basename(subfolders)
  maxFolderNameLength <- max(nchar(folderNames))
  maxStatusLength <- 35
  maxYearLength <- 4
  
  currentTime <- as.numeric(Sys.time())
  maxModificationThreshold <- 120
  maxModTime <- currentTime - maxModificationThreshold
  
  subfolderStatusList <- list()
  
  for (folder in subfolders) {
    mainGmsPath <- file.path(folder, "main.gms")
    mainLstPath <- file.path(folder, "main.lst")
    mainLogPath <- file.path(folder, "main.log")
    gitDiffPath <- file.path(folder, "git_diff.txt")
    
    folderName <- basename(folder)
    status <- ""
    runType <- "Run: Vanilla"
    
    # Determine calibration mode
    if (file.exists(mainGmsPath)) {
      gmsTxt <- readLines(mainGmsPath, warn = FALSE)
      if (any(grepl("\\$setGlobal Calibration on", gmsTxt)))
        runType <- "Run: Calibration"
    }
    
    modifiedStatus <- ifelse(file.exists(gitDiffPath), "Yes", "No")
    
    if (!file.exists(mainGmsPath)) {
      status <- sprintf("%-*s", maxStatusLength,
                        "Missing: main.gms  Status: NOT A RUN")
      
    } else if (!file.exists(mainLstPath) || !file.exists(mainLogPath)) {
      
      if (currentTime > maxModTime) {
        status <- sprintf("%-*s", maxStatusLength,
                          "main.lst or main.log missing -> FAILED Year: None Horizon: None")
      } else {
        status <- sprintf("%-*s", maxStatusLength,
                          "Missing: main.lst or main.log Status: PENDING")
      }
      
    } else {
      # Extract end year
      gmsLines <- readLines(mainGmsPath, warn = FALSE)
      endLine <- gmsLines[grepl("\\$evalGlobal fEndY", gmsLines)]
      endHorizonYear <- ifelse(
        length(endLine) > 0,
        tail(str_split(endLine, "\\s+")[[1]], 1),
        "NA"
      )
      
      logLines <- readLines(mainLogPath, warn = FALSE)
      
      year <- NA
      runningYear <- NA
      
      loopLines <- grep("--- LOOPS an =", logLines, value = TRUE)
      if (length(loopLines) > 0) {
        year <- str_trim(str_split(loopLines[length(loopLines)], "=")[[1]][2])
        runningYear <- year
      }
      
      logTime <- as.numeric(file.info(mainLogPath)$mtime)
      timeDiff <- currentTime - logTime
      modificationThreshold <- 15
      completed <- any(grepl("\\*\\*\\* Status: Normal completion", logLines))
      
      if (completed) {
        status <- sprintf("%-*s", maxStatusLength,
                          paste("Missing: NONE Status: COMPLETED Year:", year,
                                "Horizon:", endHorizonYear))
        
      } else if (!completed && timeDiff < modificationThreshold) {
        status <- sprintf("%-*s", maxStatusLength,
                          paste("Missing: NONE Status: PENDING Running_Year:",
                                runningYear, "Horizon:", endHorizonYear))
        
      } else {
        status <- sprintf("%-*s", maxStatusLength,
                          paste("main.log -> FAILED Status: FAILED Year:", year,
                                "Horizon:", endHorizonYear))
      }
    }
    
    msg <- sprintf("%-*s %s %s Modified: %s",
                   maxFolderNameLength, folderName,
                   status, runType, modifiedStatus)
    
    subfolderStatusList[[length(subfolderStatusList) + 1]] <-
      list(message = msg, folder = folder)
  }
  
  subfolderStatusList <- subfolderStatusList[
    order(sapply(subfolderStatusList, function(x) file.info(x$folder)$ctime))
  ]
  
  return(subfolderStatusList)
}

#' Get directory of the current script
#' CamelCase version
#'
getScriptDirectory <- function() {
  cmdArgs <- commandArgs(trailingOnly = FALSE)
  fileArg <- "--file="
  fileIndex <- grep(fileArg, cmdArgs)
  
  if (length(fileIndex) > 0) {
    scriptPath <- sub(fileArg, "", cmdArgs[fileIndex])
    return(dirname(normalizePath(scriptPath)))
  }
  
  if (rstudioapi::isAvailable()) {
    scriptPath <- rstudioapi::getSourceEditorContext()$path
    if (nzchar(scriptPath)) return(dirname(normalizePath(scriptPath)))
  }
  
  if (!is.null(sys.frame(1)$ofile)) {
    return(dirname(normalizePath(sys.frame(1)$ofile)))
  }
  
  return(normalizePath(getwd()))
}

#' Display numbered, color-coded subfolder list
#' CamelCase version
#'
listSubfolders <- function(subfolderStatusList) {
  if (length(subfolderStatusList) == 0) {
    cat("No subfolders found in the 'runs' directory.\n")
    return(list())
  }
  
  cat(yellow("List of subfolders...\n\n"))
  
  n <- length(subfolderStatusList)
  
  for (i in seq_along(subfolderStatusList)) {
    num <- n - i + 1
    msg <- subfolderStatusList[[i]]$message
    
    coloredMsg <- if (grepl("FAILED", msg)) red(msg)
    else if (grepl("PENDING", msg)) blue(msg)
    else if (grepl("COMPLETED", msg)) green(msg)
    else msg
    
    cat(sprintf("%2d. %s\n", num, coloredMsg))
  }
  
  return(subfolderStatusList)
}