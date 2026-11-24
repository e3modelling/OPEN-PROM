# ============================================================
# Climate Model (Emulator) Assessment Runner
# ============================================================
# Runs the IIASA climate-assessment workflow (MAGICC or CICERO-SCM) on the
# emissions.csv of an OPEN-PROM run folder and plots median GSAT against the
# climate-assessment reference output. See tutorial 13 for the installation.
#
# The Python workflow always runs inside WSL (Linux): MAGICC needs Linux
# libraries. From Windows the script calls `wsl bash`; if R itself runs inside
# WSL/Linux, bash is called directly.
#
# Usage (from the OPEN-PROM root, or the VS Code task "RUN CLIMATE EMULATOR"):
#   Rscript scripts/tools/runClimateModels.r --model magicc --runFolder <name>
#   Rscript scripts/tools/runClimateModels.r --model ciceroscm --emissions <file> --output <dir>
#   --runFolder defaults to "latest": the most recent runs/* folder containing emissions.csv.
#
# Location of climate-assessment: config.json -> paths.climate_assessment_path,
# otherwise ../climate-assessment (same parent folder as OPEN-PROM).
#
# Outputs: <output>/<emissions>_alloutput.xlsx and <output>/Global_Mean_Temperature.png
# (default <output> = runs/<runFolder>/EmissionsOutput-<model>).
#
# Climate feedback loop 1 (OPEN-PROM -> MAGICC -> RIME -> OPEN-PROM): after MAGICC,
#   scripts/tools/rimeMaps.py       median GSAT -> RIME degree-day maps (rime_maps_<ind>.nc)
#   scripts/tools/climDegreeDays.py maps -> iClimDegDays.csv (+ _absolute.csv, _diagnostics.png)
# run with the RIME environment (paths.rime_path, installed by scripts/tools/installRimeWSL.sh).
# Settings: config.json -> "climate_feedback". --steps rime reruns RIME on an existing MAGICC output.
#
# R packages: optparse, jsonlite, readxl, dplyr, ggplot2, magclass, quitte

suppressPackageStartupMessages({
  library(optparse)
  library(jsonlite)
  library(readxl)
  library(dplyr)
  library(ggplot2)
  library(magclass)
  library(quitte)
})

# Default for missing settings: NULL or a single empty string (lists and vectors are kept as they are).
`%||%` <- function(a, b) if (is.null(a) || (is.character(a) && length(a) == 1 && !nzchar(a))) b else a
onWindows <- .Platform$OS.type == "windows"

# ------------------- Paths ----------------------

# "C:/Users/..." -> "/mnt/c/Users/..." (no-op when R already runs in Linux)
toLinuxPath <- function(path) {
  path <- normalizePath(path, winslash = "/", mustWork = FALSE)
  if (!onWindows) return(path)
  gsub("^([A-Za-z]):", "/mnt/\\L\\1", path, perl = TRUE)
}

# Single-quote for bash, so spaces and non-ASCII characters in paths are safe.
bashQuote <- function(x) paste0("'", gsub("'", "'\\\\''", x), "'")

findClimateAssessment <- function(cfg) {
  path <- cfg$paths$climate_assessment_path %||% file.path("..", "climate-assessment")
  path <- normalizePath(path, winslash = "/", mustWork = FALSE)
  if (!dir.exists(path)) {
    stop("climate-assessment not found at ", path,
         ". Set paths.climate_assessment_path in config.json (see tutorial 13).")
  }
  path
}

latestRunWithEmissions <- function() {
  dirs <- list.dirs("runs", recursive = FALSE)
  dirs <- dirs[file.exists(file.path(dirs, "emissions.csv"))]
  if (!length(dirs)) stop("No runs/* folder with an emissions.csv found. Pass --runFolder or --emissions.")
  basename(dirs[which.max(file.mtime(dirs))])
}

# ------------------- Model configuration ----------------------

getModelConfig <- function(model, caDir) {
  switch(model,
    ciceroscm = list(
      version      = "v2019vCH4",
      probFile     = file.path(caDir, "data", "cicero", "subset_cscm_configfile.json"),
      expectedFile = file.path(caDir, "tests", "test-data", "expected-output-wg3", "two_ips_climate_cicero.xlsx"),
      extraArgs    = c("--scenario-batch-size", "20")
    ),
    magicc = list(
      version      = "v7.5.3",
      probFile     = file.path(caDir, "magicc-files", "0fd0f62-derived-metrics-id-f023edb-drawnset.json"),
      expectedFile = file.path(caDir, "tests", "test-data", "expected-output-wg3", "two_ips_climate_magicc.xlsx"),
      extraArgs    = character(0)
    ),
    stop("Unsupported --model '", model, "'. Use magicc or ciceroscm.")
  )
}

# ------------------- Run the Python workflow in WSL ----------------------

runAssessment <- function(model, caDir, emissionsFile, outputDir) {
  cfg <- getModelConfig(model, caDir)
  for (f in c(cfg$probFile, emissionsFile)) if (!file.exists(f)) stop("Missing file: ", f)

  infillingDb <- file.path(caDir, "data",
    "1652361598937-ar6_emissions_vetted_infillerdatabase_10.5281-zenodo.6390768.csv")

  args <- c(
    toLinuxPath(emissionsFile), toLinuxPath(outputDir),
    "--model", model,
    "--model-version", cfg$version,
    "--num-cfgs", "600",
    "--probabilistic-file", toLinuxPath(cfg$probFile),
    "--infilling-database", toLinuxPath(infillingDb),
    cfg$extraArgs
  )

  cat("Running", toupper(model), "assessment in WSL...\n")
  # cd into climate-assessment so its .env (MAGICC executable, workers) is picked up.
  runPython(caDir, ".venv/bin/python", "scripts/run_workflow.py", args, "climate-assessment workflow")
}

# Run a Python script inside WSL (or bash directly when R runs in Linux). The command
# goes through a temporary bash script: avoids Windows -> WSL quoting problems; binary
# mode keeps the LF line endings bash requires.
runPython <- function(workDir, python, script, args, what) {
  lines <- c(
    "set -e",
    paste("cd", bashQuote(toLinuxPath(workDir))),
    paste(bashQuote(python), bashQuote(script), paste(bashQuote(args), collapse = " "))
  )
  shFile <- tempfile(fileext = ".sh")
  con <- file(shFile, open = "wb")
  writeLines(enc2utf8(lines), con, sep = "\n", useBytes = TRUE)
  close(con)
  status <- if (onWindows) {
    system2("wsl", c("bash", shQuote(toLinuxPath(shFile))))
  } else {
    system2("bash", shQuote(shFile))
  }
  unlink(shFile)
  if (!identical(as.integer(status), 0L)) stop(what, " failed (exit status ", status, ").")
}

# ------------------- RIME: degree days for the buildings climate feedback ----------------------

findRegionMapping <- function(fb) {
  path <- fb$regionmapping %||% system.file("extdata", "regional", "regionmappingOPDEV5.csv", package = "mrprom")
  if (!nzchar(path) || !file.exists(path)) {
    stop("OPEN-PROM region mapping not found. Install mrprom or set climate_feedback.regionmapping in config.json.")
  }
  path
}

runRime <- function(cfg, gsatFile, outputDir) {
  fb <- cfg$climate_feedback %||% list()
  rimePath <- normalizePath(cfg$paths$rime_path %||% file.path("..", "rime"), winslash = "/", mustWork = FALSE)
  if (!dir.exists(rimePath)) stop("RIME not found at ", rimePath, ". Run scripts/tools/installRimeWSL.sh (tutorial 16).")
  dataDir <- normalizePath(cfg$paths$rime_data_path %||% file.path("..", "rime-data"), winslash = "/", mustWork = FALSE)
  dir.create(dataDir, recursive = TRUE, showWarnings = FALSE)
  python <- paste0(toLinuxPath(rimePath), "/.venv/bin/python")
  indicators <- c(fb$cdd_indicator %||% "sdd_c_24p0", fb$hdd_indicator)
  ssp <- fb$ssp %||% "SSP2"
  root <- getwd()

  cat("RIME maps (", paste(indicators, collapse = ", "), ", ", ssp, ") in WSL...\n", sep = "")
  runPython(root, python, toLinuxPath("scripts/tools/rimeMaps.py"), c(
    "--gsat", toLinuxPath(gsatFile), "--indicators", indicators, "--ssp", ssp,
    "--impact-dir", toLinuxPath(dataDir), "--out-dir", toLinuxPath(outputDir)), "RIME map step")

  args <- c("--maps-dir", toLinuxPath(outputDir),
            "--regionmapping", toLinuxPath(findRegionMapping(fb)),
            "--natural-earth", toLinuxPath(dataDir),
            "--out", toLinuxPath(file.path(outputDir, "iClimDegDays.csv")),
            "--cdd-ind", indicators[1])
  if (!is.null(fb$hdd_indicator)) args <- c(args, "--hdd-ind", fb$hdd_indicator)
  if (!is.null(fb$pop_grid))      args <- c(args, "--pop-grid", toLinuxPath(fb$pop_grid))
  for (k in c("floor_cdd", "floor_hdd", "cap")) {
    if (!is.null(fb[[k]])) args <- c(args, paste0("--", gsub("_", "-", k)), fb[[k]])
  }
  cat("Degree-day ratios per OPEN-PROM region...\n")
  runPython(root, python, toLinuxPath("scripts/tools/climDegreeDays.py"), args, "Degree-day step")
  cat("To use it: copy", file.path(outputDir, "iClimDegDays.csv"),
      "to data/ and run OPEN-PROM with --climFeedback=on\n")
}

# ------------------- Plot median GSAT vs reference ----------------------

readMagpie <- function(file) as.magpie(as.quitte(read_excel(file)))

gsatVar <- function(x) {
  v <- grep("\\|Surface Temperature \\(GSAT\\).*50", getItems(x, dim = 3), value = TRUE)
  if (!length(v)) stop("No median GSAT variable found.")
  v
}

# One data frame (Year, Value, Scenario) per GSAT series of x.
gsatSeries <- function(x) {
  vars <- gsatVar(x)
  scen <- getItems(x, dim = "scenario")
  lapply(seq_along(vars), function(i) {
    df <- as.data.frame(x["World", , vars[i]])
    names(df)[names(df) == "period"] <- "Year"
    data.frame(Year = as.numeric(gsub("y", "", df$Year)), Value = df$Value,
               Scenario = scen[min(i, length(scen))])
  })
}

plotTemperature <- function(outputFile, expectedFile, outputDir, refModel = "REMIND-MAgPIE 3_2-4_6") {
  dfs <- gsatSeries(readMagpie(outputFile))[1]

  if (file.exists(expectedFile)) {
    expected <- readMagpie(expectedFile)
    keep <- grep(refModel, getItems(expected, dim = 3), value = TRUE, fixed = TRUE)
    if (length(keep)) dfs <- c(dfs, gsatSeries(expected[, , keep]))
  } else {
    cat("Reference output not found, plotting this run only:", expectedFile, "\n")
  }

  df <- bind_rows(dfs)

  p <- ggplot(df, aes(x = Year, y = Value, color = Scenario, linetype = Scenario)) +
    geom_line(linewidth = 1.2) +
    labs(title = "Global warming above the 1850-1900 mean", y = "°C", x = "Year") +
    theme_bw()
  plotOut <- file.path(outputDir, "Global_Mean_Temperature.png")
  ggsave(filename = plotOut, plot = p, width = 10, height = 6, dpi = 300)
  cat("Plot saved to", plotOut, "\n")
}

# ------------------- Main ----------------------

opt <- parse_args(OptionParser(option_list = list(
  make_option("--model", type = "character", default = "magicc",
              help = "Climate emulator: magicc (default) or ciceroscm"),
  make_option("--runFolder", type = "character", default = NULL,
              help = "Run folder under runs/ (default: latest one with emissions.csv)"),
  make_option("--emissions", type = "character", default = NULL,
              help = "Custom emissions CSV (overrides --runFolder)"),
  make_option("--output", type = "character", default = NULL,
              help = "Custom output directory"),
  make_option("--steps", type = "character", default = "all",
              help = paste("all = MAGICC, then RIME degree days; emulator = MAGICC only;",
                           "rime = RIME degree days from an existing MAGICC output"))
)))
if (!opt$steps %in% c("all", "emulator", "rime")) stop("--steps must be all, emulator or rime")

cfg <- if (file.exists("config.json")) fromJSON("config.json") else list()
caDir <- findClimateAssessment(cfg)

if (is.null(opt$emissions)) {
  runFolder <- opt$runFolder %||% "latest"
  if (runFolder == "latest") runFolder <- latestRunWithEmissions()
  runDir <- file.path("runs", runFolder)
  emissions <- file.path(runDir, "emissions.csv")
} else {
  emissions <- opt$emissions
  runDir <- dirname(emissions)
}
emissions <- normalizePath(emissions, winslash = "/", mustWork = TRUE)
output <- normalizePath(opt$output %||% file.path(runDir, paste0("EmissionsOutput-", opt$model)),
                        winslash = "/", mustWork = FALSE)
dir.create(output, recursive = TRUE, showWarnings = FALSE)

cat("Model:    ", opt$model, "\nEmissions:", emissions, "\nOutput:   ", output,
    "\nclimate-assessment:", caDir, "\n")

outputFile <- file.path(output, paste0(tools::file_path_sans_ext(basename(emissions)), "_alloutput.xlsx"))

if (opt$steps != "rime") {
  runAssessment(opt$model, caDir, emissions, output)
  if (!file.exists(outputFile)) stop("Workflow finished but output is missing: ", outputFile)
  plotTemperature(outputFile, getModelConfig(opt$model, caDir)$expectedFile, output)
}

if (opt$steps %in% c("all", "rime")) {
  if (!file.exists(outputFile)) stop("No emulator output to read GSAT from: ", outputFile, ". Run --steps emulator first.")
  runRime(cfg, outputFile, output)
}
