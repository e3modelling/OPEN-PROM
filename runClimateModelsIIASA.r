library(optparse)
library(readxl)
library(dplyr)
library(ggplot2)
library(stringr)
library(magclass)
library(quitte)

# --- Convert Windows-style path to WSL-compatible path ---
to_wsl_path <- function(path) {
  path <- normalizePath(path, winslash = "/", mustWork = FALSE)
  # Convert "C:/Users/..." → "/mnt/c/Users/..."
  gsub("^([A-Za-z]):", "/mnt/\\L\\1", path, perl = TRUE)
}
# ------------------- Model Configuration ----------------------

getModelConfig <- function(model, emissionsFile, outputDir) {
  if (model == "ciceroscm") {
    probFile <- file.path(scriptDir, "climate-assessment", "data", "cicero", "subset_cscm_configfile.json")
    expectedFile <- file.path(scriptDir, "climate-assessment", "tests", "test-data", "expected-output-wg3", "two_ips_climate_cicero.xlsx")
    version <- "v2019vCH4"
    venvActivate<- file.path(scriptDir, "climate-assessment",".venv-new","Scripts","activate.bat")
    script <- file.path(scriptDir, "climate-assessment","scripts","run_workflow.py")
  } else if (model == "magicc") {
    probFile <- to_wsl_path(file.path(scriptDir,"climate-assessment","magicc-files", "0fd0f62-derived-metrics-id-f023edb-drawnset.json"))
    expectedFile <- file.path(scriptDir, "climate-assessment", "tests", "test-data", "expected-output-wg3", "two_ips_climate_magicc.xlsx")
    version <- "v7.5.3"
    venvActivate<- to_wsl_path(file.path(scriptDir, "climate-assessment",".venv","bin","python"))
    script <- to_wsl_path(file.path(scriptDir, "climate-assessment","scripts","run_workflow.py"))
  } else {
    stop("Unsupported model")
  }
  
  list(
    modelVersion = version,
    probabilisticFile = probFile,
    expectedOutputFile = expectedFile,
    emissionsFile = emissionsFile,
    outputDir = outputDir,
    venvActivate = venvActivate,
    script = script
  )
}

# ------------------- Main Workflow Runner ----------------------

runAssessment <- function(model, emissionsFile, outputDir) {
  #setEnvironmentVariables(model)
  config <- getModelConfig(model, emissionsFile, outputDir)
  venvActivate <- config$venvActivate
  script <- config$script
  modelVersion <- config$modelVersion
  probFile <- config$probabilisticFile 
  numCfgs <- 600
  scenarioBatchSize <- 20

  infillingDb <- file.path(
    scriptDir, "climate-assessment", "data",
    "1652361598937-ar6_emissions_vetted_infillerdatabase_10.5281-zenodo.6390768.csv"
  )
 
  cat("Running", toupper(model), "model assessment...\n")

  # Create the command
if (model == "ciceroscm") {
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
  } else if (model == "magicc") {
  # Use paste and shQuote instead of sprintf
  # sprintf escapes the quotes (") with backslashes (\") because it's assembling a string that will be passed as a single argument to another command like system().
  # Example=--model \"magicc\" 
  cmd <- paste(
  'wsl',
  'bash -c',
  shQuote(
    paste(
      venvActivate,
      script,
      to_wsl_path(emissionsFile),
      to_wsl_path(outputDir),
      '--model', model,
      '--model-version',modelVersion,
      '--num-cfgs',numCfgs,
      '--probabilistic-file',probFile,
      '--infilling-database',to_wsl_path(infillingDb)
    )
  )
)
  print(cmd)
  } else {
    stop("Unsupported model")
  }
  system(cmd)
}

# ------------------- Load and Compare Results ----------------------

loadResults <- function(model, emissionsFile, outputDir) {
  base <- tools::file_path_sans_ext(basename(emissionsFile))
  fileOut <- file.path(outputDir, paste0(base, "_alloutput.xlsx"))
  config <- getModelConfig(model, emissionsFile, outputDir)
  
  if (!file.exists(fileOut)) {
    stop("Missing output file: ", fileOut)
  }
  
  outputFile <- read_excel(fileOut)
  output <- as.quitte(outputFile) %>% as.magpie()

  expectedFile <- read_excel(config$expectedOutputFile)
  expected <- as.quitte(expectedFile) %>% as.magpie()
  
  list(output = output, expected = expected)
}

# ------------------- Plotting ----------------------

visualizeOutput <- function(outputDir,output, defaultOutput = NULL) {
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

  p <- ggplot(allDfs, aes(x = Year, y = Temperature, color = Scenario, linetype = Scenario)) +
    geom_line(size = 1.2) +
    labs(title = "Global warming above the 1850–1900 mean",
         y = "°C", x = "Year", color = "Scenario", linetype = "Scenario") + theme_bw()
  print(p)
  plotOut <- file.path(outputDir, "Global_Mean_Temperature.png")
  ggsave(filename = plotOut, plot = p, width = 10, height = 6, dpi = 300)
}

# ------------------- Main Entrypoint ----------------------
scriptDir <- "C:/Users/at39/2-Models"

# Define CLI options
# Example paths 
#
optionList <- list(
  make_option("--model", type = "character", default = "ciceroscm",
              help = "Climate model to run (magicc or ciceroscm)"),
  make_option("--runFolder", type = "character", default = "daily_npi",
              help = "Name of the scenario (subfolder) under runs/ containing emissions file"),
  make_option("--emissions", type = "character", default = NULL,
              help = "Optional: custom path to emissions CSV"),
  make_option("--output", type = "character", default = NULL,
              help = "Optional: custom path to output directory")
)

opt <- parse_args(OptionParser(option_list = optionList))

# Apply defaults if model or run-folder missing
if (is.null(opt$model) || is.null(opt$`run-folder`)) {
  cat("No --model or --runFolder provided. Using defaults: model = 'ciceroscm', runFolder = 'daily_npi'\n")
  model <- "ciceroscm"
  runFolder <- "daily_npi"
} else {
  model <- opt$model
  runFolder <- opt$runFolder
}

if (is.null(opt$emissions)) {
  emissions <- normalizePath(file.path(scriptDir, "OPEN-PROM", "runs", runFolder, "emissions.csv"))
} else {
  emissions <- normalizePath(opt$emissions)
}

if (is.null(opt$output)) {
  output <- normalizePath(file.path(scriptDir, "OPEN-PROM", "runs", runFolder, paste0("EmissionsOutput-", model)))
} else {
  output <- normalizePath(opt$output)
}

if (!dir.exists(output)) {
  dir.create(output, recursive = TRUE)
}

runAssessment(model, emissions, output)

results <- loadResults(model, emissions, output)
visualizeOutput(output,results$output, results$expected)
