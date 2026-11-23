# ============================================================
# Climate assessment in the cloud (MAGICC + RIME degree days)
# ============================================================
# Sends runs/<runFolder>/emissions.csv to the climate_assessment workflow of the
# single private climate-assets repo (shared by all users), waits for it, downloads
# the outputs into runs/<runFolder>/EmissionsOutput-magicc/ and deletes the
# GitHub run (logs, inputs and outputs). Nothing is committed anywhere.
#
# Needs only the GitHub CLI: install from https://cli.github.com, then `gh auth login`
# once. The user needs write access to the private repo. No WSL, Python or MAGICC.
#
# Usage (OPEN-PROM root, or VS Code task "RUN CLIMATE EMULATOR (CLOUD)"):
#   Rscript scripts/tools/runClimateCloud.R --runFolder <name|latest> [--numCfgs 600|50]
#            [--degreeDays true|false] [--ssp SSP2] [--keepRun]
# Private repo: config.json -> paths.climate_cloud_repo (e.g. "e3modelling/climate-assets").

suppressPackageStartupMessages({
  library(optparse)
  library(jsonlite)
})

`%||%` <- function(a, b) if (is.null(a) || !nzchar(a)) b else a

gh <- function(args, stdin = "", quiet = FALSE) {
  out <- suppressWarnings(system2("gh", args, stdout = TRUE, stderr = TRUE, stdin = stdin))
  status <- attr(out, "status") %||% 0L
  if (status != 0L) stop("gh ", args[1], " ", args[2], " failed:\n", paste(out, collapse = "\n"))
  if (!quiet) invisible(out) else out
}

latestRunWithEmissions <- function() {
  dirs <- list.dirs("runs", recursive = FALSE)
  dirs <- dirs[file.exists(file.path(dirs, "emissions.csv"))]
  if (!length(dirs)) stop("No runs/* folder with an emissions.csv found.")
  basename(dirs[which.max(file.mtime(dirs))])
}

opt <- parse_args(OptionParser(option_list = list(
  make_option("--runFolder", default = "latest", help = "Run folder under runs/ (default: latest with emissions.csv)"),
  make_option("--numCfgs", default = "600", help = "MAGICC configurations: 600 (full) or 50 (quick test)"),
  make_option("--degreeDays", default = "true", help = "Also compute RIME degree days (true/false)"),
  make_option("--ssp", default = "SSP2", help = "SSP for the RIME lookup"),
  make_option("--openpromRef", default = "main", help = "OPEN-PROM branch providing the helper scripts"),
  make_option("--keepRun", action = "store_true", default = FALSE,
              help = "Do not delete the GitHub run after downloading")
)))

cfg <- if (file.exists("config.json")) fromJSON("config.json") else list()
repo <- cfg$paths$climate_cloud_repo %||% stop("Set paths.climate_cloud_repo in config.json (e.g. e3modelling/climate-assets).")
if (Sys.which("gh") == "") stop("GitHub CLI not found. Install it from https://cli.github.com and run `gh auth login`.")

runFolder <- if (opt$runFolder %in% c("", "latest")) latestRunWithEmissions() else opt$runFolder
emissions <- file.path("runs", runFolder, "emissions.csv")
if (!file.exists(emissions)) stop("Not found: ", emissions)
outDir <- file.path("runs", runFolder, "EmissionsOutput-magicc")

# Compress + base64 so the file fits in a workflow input (GitHub limit: 65,535 characters).
raw <- readBin(emissions, "raw", file.info(emissions)$size)
payload <- base64_enc(memCompress(raw, type = "gzip"))
if (nchar(payload) > 60000) stop("emissions.csv is too large to send as a workflow input (",
                                 nchar(payload), " characters after compression).")

requestId <- paste(sample(c(letters, 0:9), 12, replace = TRUE), collapse = "")
inputs <- list(emissions_b64 = payload, request_id = requestId, num_cfgs = opt$numCfgs,
               degree_days = tolower(opt$degreeDays), ssp = opt$ssp, openprom_ref = opt$openpromRef)
inputsFile <- tempfile(fileext = ".json")
writeLines(toJSON(inputs, auto_unbox = TRUE), inputsFile)

cat("Sending", emissions, "to", repo, "(request", requestId, ")\n")
gh(c("workflow", "run", "climate_assessment.yml", "-R", repo, "--json"), stdin = inputsFile)
unlink(inputsFile)

# Find our run by its run-name ("climate <request_id>").
runId <- NULL
for (i in 1:30) {
  Sys.sleep(5)
  runs <- fromJSON(paste(gh(c("run", "list", "-R", repo, "--workflow", "climate_assessment.yml",
                               "--limit", "20", "--json", "databaseId,displayTitle"), quiet = TRUE),
                         collapse = ""))
  hit <- runs$databaseId[runs$displayTitle == paste("climate", requestId)]
  if (length(hit)) { runId <- as.character(hit[1]); break }
}
if (is.null(runId)) stop("Workflow run did not appear in ", repo, ". Check the Actions tab there.")
cat("Run", runId, "started. Waiting (MAGICC takes a while)...\n")

# --exit-status makes watch fail if the run fails; download whatever exists either way.
ok <- tryCatch({ gh(c("run", "watch", runId, "-R", repo, "--exit-status", "--interval", "30")); TRUE },
               error = function(e) { message(conditionMessage(e)); FALSE })

dir.create(outDir, recursive = TRUE, showWarnings = FALSE)
got <- tryCatch({ gh(c("run", "download", runId, "-R", repo, "-n", "climate-assessment", "-D", outDir)); TRUE },
                error = function(e) { message("No outputs downloaded: ", conditionMessage(e)); FALSE })

if (opt$keepRun) {
  cat("Run kept: https://github.com/", repo, "/actions/runs/", runId, "\n", sep = "")
} else {
  tryCatch({ gh(c("run", "delete", runId, "-R", repo)); cat("Deleted the GitHub run (logs, inputs, outputs).\n") },
           error = function(e) message("Could not delete run ", runId, ": ", conditionMessage(e)))
}

if (!ok) stop("The cloud run failed", if (opt$keepRun) "." else ". Rerun with --keepRun to inspect the logs on GitHub.")
cat("Outputs in", outDir, "\n")
if (got && file.exists(file.path(outDir, "iClimDegDays.csv"))) {
  cat("To use the degree days: copy", file.path(outDir, "iClimDegDays.csv"),
      "to data/ and run OPEN-PROM with --climFeedback=on\n")
}
