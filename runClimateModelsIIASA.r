library(optparse)
library(readxl)
library(dplyr)
library(ggplot2)
library(stringr)
library(magclass)
library(quitte)

# ------------------- Environment Variables ----------------------

setEnvironmentVariables <- function(model) {
  if (model == "ciceroscm") {
    Sys.setenv(CICEROSCM_WORKER_NUMBER = "4")
    Sys.setenv(CICEROSCM_WORKER_ROOT_DIR = tempdir())
  } else if (model == "magicc") {
    rootDefault <- normalizePath(file.path(scriptDir, "climate-assessment", "magicc-files"))
    rootDir <- Sys.getenv("MAGICC_ROOT_FILES_DIR", unset = rootDefault)
    Sys.setenv(MAGICC_ROOT_FILES_DIR = rootDir)
    Sys.setenv(MAGICC_EXECUTABLE_7 = file.path(rootDir, "bin", "magicc"))
    Sys.setenv(MAGICC_WORKER_NUMBER = "4")
    Sys.setenv(MAGICC_WORKER_ROOT_DIR = tempdir())
    
    cat("🔧 MAGICC root directory:", rootDir, "\n")
    cat("🔧 MAGICC executable:", Sys.getenv("MAGICC_EXECUTABLE_7"), "\n")
  }
}

# ------------------- Model Configuration ----------------------

getModelConfig <- function(model, emissionsFile, outputDir) {
  if (model == "ciceroscm") {
    probFile <- file.path(scriptDir, "climate-assessment", "data", "cicero", "subset_cscm_configfile.json")
    expectedFile <- file.path(scriptDir, "climate-assessment", "tests", "test-data", "expected-output-wg3", "two_ips_climate_cicero.xlsx")
    version <- "v2019vCH4"
  } else if (model == "magicc") {
    root <- Sys.getenv("MAGICC_ROOT_FILES_DIR")
    probFile <- file.path(root, "magicc-ar6-0fd0f62-f023edb-drawnset", "0fd0f62-derived-metrics-id-f023edb-drawnset.json")
    expectedFile <- file.path(scriptDir, "climate-assessment", "tests", "test-data", "expected-output-wg3", "two_ips_climate_magicc.xlsx")
    version <- "v7.5.3"
  } else {
    stop("Unsupported model")
  }

  venvActivate<- file.path(scriptDir, "climate-assessment",".venv-new","Scripts","activate.bat")
  script <- file.path(scriptDir, "climate-assessment","scripts","run_workflow.py")
  
  list(
    modelVersion = version,
    probabilisticFile = normalizePath(probFile),
    expectedOutputFile = normalizePath(expectedFile),
    emissionsFile = emissionsFile,
    outputDir = outputDir,
    venvActivate = venvActivate,
    script = script
  )
}

# ------------------- Main Workflow Runner ----------------------

runAssessment <- function(model, emissionsFile, outputDir) {
  setEnvironmentVariables(model)
  config <- getModelConfig(model, emissionsFile, outputDir)
  venvActivate <- config$venvActivate
  script <- config$script
  modelVersion <- config$modelVersion
  probFile <- config$probabilisticFile
  
  numCfgs <- 600
  scenarioBatchSize <- 20
  infillingDb <- normalizePath(file.path(
    scriptDir, "climate-assessment", "data",
    "1652361598937-ar6_emissions_vetted_infillerdatabase_10.5281-zenodo.6390768.csv"
  ))
  
  cat("Running", toupper(model), "model assessment...\n")

  # Create the command
  cmd <- sprintf(
    '"%s" && python "%s" "%s" "%s" --model "%s" --model-version "%s" --num-cfgs %s --probabilistic-file "%s" --infilling-database "%s" --scenario-batch-size "%s"',
    venvActivate,
    script,
    emissionsFile,
    outputDir,
    model,
    modelVersion,
    numCfgs,
    probFile,
    infillingDb,
  scenarioBatchSize
  )

  # Run the command
  system(cmd)
}

# ------------------- Load and Compare Results ----------------------

loadResults <- function(outputDir, emissionsFile) {
  base <- tools::file_path_sans_ext(basename(emissionsFile))
  fileOut <- file.path(outputDir, paste0(base, "_alloutput.xlsx"))
  
  if (!file.exists(fileOut)) {
    stop("Missing output file: ", fileOut)
  }
  
  outputFile <- read_excel(fileOut)
  output <- as.quitte(outputFile) %>% as.magpie()
  
  expectedFile <- file.path(scriptDir, "climate-assessment", "tests", "test-data", "expected-output-wg3", "two_ips_climate_cicero.xlsx")
  tempExpected <- read_excel(expectedFile)
  expected <- as.quitte(tempExpected) %>% as.magpie()
  
  list(output = output, expected = expected)
}

# ------------------- Plotting ----------------------

visualizeOutput <- function(output, defaultOutput = NULL) {
  cat("Plotting median global surface temperature\n")

  var <- grep("\\|Surface Temperature \\(GSAT).*50", getItems(output, dim = 3), value = TRUE)
  defaultVar <- grep("\\|Surface Temperature \\(GSAT).*50", getItems(defaultOutput, dim = 3), value = TRUE)
  scenario <- getItems(output, dim = "scenario")
  defaultScenario <- getItems(defaultOutput, dim = "scenario")
  
  # Validate existence of variable
  if (!var %in% getItems(output, dim = 3)) {
    stop(paste("Variable not found in output:", var))
  }

  # Convert to data frames
  runDf <- as.data.frame(output["World", , var])
  runDf$Source <- scenario
  defaultDfs <- lapply(seq_along(defaultVar), function(i) {
  df <- as.data.frame(defaultOutput["World", , defaultVar[i]])
  df$Source <- defaultScenario[i]
  return(df)
  })

  # Combine all into one for ggplot
  allDfs <- rbind(runDf, do.call(rbind, defaultDfs))

  # Rename for ggplot clarity
  names(allDfs)[names(allDfs) == "period"] <- "Year"
  names(allDfs)[names(allDfs) == "Value"] <- "Temperature"
  names(allDfs)[names(allDfs) == "Data2"] <- "Scenario"

  # Clean up year (since it's in yXXXX format)
  allDfs$Year <- as.numeric(gsub("y", "", allDfs$Year))

  ggplot(allDfs, aes(x = Year, y = Temperature, color = Scenario, linetype = Scenario)) +
    geom_line(size = 1.2) +
    labs(title = "Global warming above the 1850–1900 mean",
         y = "°C", x = "Year", color = "Scenario", linetype = "Scenario") + theme_minimal() 
}

# ------------------- Main Entrypoint ----------------------
scriptDir <- "C:/Users/at39/2-Models"

optionList <- list(
  make_option("--model", type = "character", default = "ciceroscm"),
  make_option("--emissions", type = "character"),
  make_option("--output", type = "character")
)

opt <- parse_args(OptionParser(option_list = optionList))

if (!is.null(opt$model) && !is.null(opt$emissions) && !is.null(opt$output)) {
  runAssessment(opt$model, opt$emissions, opt$output)
} else {
  cat("⚙️ No CLI args, using defaults...\n")
  model <- "ciceroscm"
  runFolder <- "daily_npi"
  emissions <- normalizePath(file.path(scriptDir, "OPEN-PROM", "runs", runFolder, "emissions.csv"))
  output <- normalizePath(file.path(scriptDir,"OPEN-PROM", "runs", runFolder, paste0("EmissionsOutput-", model)))
  
  runAssessment(model, emissions, output)
  
  results <- loadResults(output, emissions)
  visualizeOutput(results$output, results$expected)
}
