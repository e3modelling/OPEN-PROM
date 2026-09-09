#!/usr/bin/env Rscript
# OPEN-PROM entry point. Two modes:
#
#   Single  :  Rscript start.R task_id=N
#              Runs one scenario, taken from config.json:scenario.
#
#   Batch   :  Rscript start.R <path-to-csv>          (e.g. scenarios.csv)
#              Reads the CSV at the given path. Each row defines one scenario
#              by overriding (via deep merge with dotted column names) the
#              config.json:scenario block. task_id is restricted to {2, 7} in
#              batch mode. The VS Code "RUN BATCH" button passes "scenarios.csv".
#              Optional `start` column gates each row: 1 = run, 0 = skip,
#              anything else (incl. NA) = abort with row diagnostics. If the
#              column is absent, every row runs (backwards compatible).

library(jsonlite)
# Always (re)install the local mrprom/postprom so every run uses the root copies.
if (dir.exists("./mrprom"))  devtools::install_local("./mrprom")
if (dir.exists("./postprom")) devtools::install_local("./postprom")
`%||%` <- function(a, b) if (is.null(a)) b else a

# ---- Read config.json (or the OPENPROM_CONFIG env var override (rarely used)) -----
config_path <- Sys.getenv("OPENPROM_CONFIG", unset = "config.json")
config <- if (file.exists(config_path))
            fromJSON(config_path, simplifyVector = FALSE) else list()

behavior      <- config$behavior %||% list()
withRunFolder <- isTRUE(behavior$withRunFolder %||% TRUE)
withSync      <- isTRUE(behavior$withSync      %||% FALSE)
withReport    <- isTRUE(behavior$withReport    %||% TRUE)
uploadGDX     <- isTRUE(behavior$uploadGDX     %||% FALSE)

# ---- GAMS executable path ---------------------------------------------
gams_path <- config$paths$gams_path
if (!is.null(gams_path) && file.exists(gams_path) && file.info(gams_path)$isdir) {
  gams <- paste0(gams_path, "gams")
} else {
  if (!is.null(gams_path)) cat("Custom GAMS path is not valid, falling back to `gams` from PATH.\n")
  gams <- "gams"
}

# ---- Shared helpers ---------------------------------------------------
saveMetadata <- function(DevMode) {
  commit_author  <- system("git log -1 --format=%an",         intern = TRUE)
  commit_hash    <- system("git log -1 --format=%H",          intern = TRUE)
  commit_comment <- system("git log -1 --format=%B",          intern = TRUE)
  commit_date    <- system("git log -1 --format=%ad",         intern = TRUE)
  branch_name    <- system("git rev-parse --abbrev-ref HEAD", intern = TRUE)
  git_status     <- system("git status -s",                   intern = TRUE)
  system("git diff --output=git_diff.txt")
  if (length(git_status) == 0) git_status <- "There are no changes made."

  git_info <- list(
    "Author"         = commit_author,
    "Branch Name"    = branch_name,
    "Commit Comment" = commit_comment,
    "Git Status"     = git_status,
    "Commit Hash"    = commit_hash,
    "Date"           = commit_date
  )

  mapping <- if (DevMode == 0) "regionmappingOPDEV5.csv" else "regionmappingOPDEV4.csv"

  desc <- Sys.getenv("OPENPROM_SCENARIO_DESCRIPTION", unset = NA_character_)
  if (is.na(desc) || !nzchar(trimws(desc))) desc <- "Default model run description."

  model_info <- list(
    "Region Mapping"  = mapping,
    "Run Description" = desc
  )

  data_to_save <- list("Git Information" = git_info, "Model Information" = model_info)
  write(toJSON(data_to_save, pretty = TRUE), file = "metadata.json")
  cat("Metadata has been saved to metadata.json\n")
}

createRunFolder <- function(scenario = "default") {
  folderName <- paste(scenario, format(Sys.time(), "%Y-%m-%d_%H-%M-%S"), sep = "_")
  if (!file.exists("runs")) dir.create("runs")
  runfolder <- paste0("runs/", folderName)
  dir.create(runfolder)

  # Copy run-time inputs + source tree snapshot into the run folder so every
  # run is self-contained (and so main.gms can $call scripts/tasks/* under cwd).
  file.copy(grep(".gms$",   dir(), value = TRUE), to = runfolder)
  file.copy(grep(".csv$",   dir(), value = TRUE), to = runfolder)
  file.copy(grep("*.json$", dir(), value = TRUE), to = runfolder)
  file.copy("conopt.opt",   to = runfolder)
  file.copy("data",       to = runfolder, recursive = TRUE)
  file.copy("targets",    to = runfolder, recursive = TRUE)
  file.copy("core",       to = runfolder, recursive = TRUE)
  file.copy("modules",    to = runfolder, recursive = TRUE)
  file.copy("scripts",    to = runfolder, recursive = TRUE)

  setwd(runfolder)
}

syncRun <- function() {
  folder_path  <- getwd()
  archive_name <- paste0(basename(folder_path), ".tgz")
  all_files <- list.files(folder_path, recursive = TRUE, all.files = TRUE)
  itemsToExclude <- c("mainCalib.lst", "main.lst")

  if (isRunSuccessful("modelstat.txt")) {
    message("Run Successful. Excluding temporary files from archive...")
    for (item in itemsToExclude) {
      pattern <- paste0("^", item, "($|/)")
      all_files <- all_files[!grepl(pattern, all_files)]
    }
  } else {
    message("Run had errors. Archiving ALL files for debugging.")
  }

  files_to_archive <- if (uploadGDX) all_files
                      else all_files[!grepl("\\.gdx$", all_files, ignore.case = TRUE)]

  model_runs_path <- config$paths$model_runs_path
  if (!is.null(model_runs_path) && file.exists(model_runs_path) &&
      file.info(model_runs_path)$isdir) {
    tar(tarfile = archive_name, files = files_to_archive,
        compression = "gzip", tar = "internal")
    destination_path <- file.path(model_runs_path, basename(archive_name))
    if (file.copy(archive_name, destination_path, overwrite = TRUE)) {
      cat("File copied successfully to", destination_path, "\n")
    }
  } else {
    cat("config.json:paths.model_runs_path is not valid, skipping sync.\n")
  }

  if (file.exists(archive_name)) file.remove(archive_name)
}

isRunSuccessful <- function(statusFilePath) {
  if (!file.exists(statusFilePath)) return(FALSE)
  lines <- readLines(statusFilePath)
  modelStatus <- as.numeric(sub(".*Model Status:([0-9.]+).*", "\\1", lines))
  all(modelStatus %in% c(2.0, 5.0))
}

# ---- Maturity factor switches ------------------------------------------
matFacYears     <- 2010:2100                     # must match ytime in core/sets.gms
matFacSpecKeys  <- c("level", "value", "from", "to")
matFacReserved  <- c("levels", "regions")

matFacLevel <- function(name, levels, label) {
  i <- match(as.character(name %||% ""), names(levels))
  if (is.na(i))
    stop("maturity_factors.", label, ": unknown level '", name %||% "", "'. Levels defined in config.json: ",
         paste(names(levels), collapse = ", "), ". Use one of those, a number, or { level | value, from, to }.")
  as.numeric(levels[[i]])
}

# An unnamed list is a sequence of windows rather than a single spec.
matFacIsWindowList <- function(x) is.list(x) && !length(names(x))

# One config entry -> multiplier, first year, last year.
matFacSpec <- function(spec, levels, label) {
  from <- min(matFacYears)
  to   <- max(matFacYears)
  if (is.list(spec)) {
    mult <- if (!is.null(spec$value)) as.numeric(spec$value)
            else                      matFacLevel(spec$level, levels, label)
    from <- as.integer(spec$from %||% from)
    to   <- as.integer(spec$to   %||% to)
  } else if (is.numeric(spec)) {
    mult <- as.numeric(spec)
  } else {
    mult <- matFacLevel(spec, levels, label)
  }
  list(mult = mult, from = from, to = to)
}

# One config entry -> one multiplier per year of the model horizon. A list of
# windows is applied in order, so a later window wins where they overlap.
matFacRow <- function(spec, levels, label) {
  specs <- if (matFacIsWindowList(spec)) spec else list(spec)
  vals  <- rep(1, length(matFacYears))
  for (s in specs) {
    w <- matFacSpec(s, levels, label)
    vals[matFacYears >= w$from & matFacYears <= w$to] <- w$mult
  }
  vals
}

# JSON keeps duplicate keys but lookup returns only the first, so reject them.
matFacCheckDup <- function(nms, where) {
  d <- unique(nms[duplicated(nms)])
  if (length(d))
    stop("maturity_factors", where, ": duplicate keys (", paste(d, collapse = ", "),
         "). Give each technology one entry, using a list of windows for several periods.")
}

matFacWriteCsv <- function(path, keyNames, rows) {
  header <- paste(sprintf('"%s"', c(keyNames, matFacYears)), collapse = ",")
  body   <- vapply(rows, function(r)
                     paste(c(sprintf('"%s"', r$keys), as.character(r$vals)), collapse = ","),
                   character(1))
  writeLines(c(header, body), path)
}

# Always rewritten, so dropping the block from config.json clears the last run's switches.
# One block of entries - the global ones, or the contents of one region.
# cyKey is prepended to every row key, so the same parser serves both files.
matFacEntries <- function(mf, levels, where, cyKey) {
  matFacCheckDup(names(mf), where)
  supply <- list()
  demand <- list()
  for (key in setdiff(names(mf), matFacReserved)) {
    spec <- mf[[key]]
    # a named map with no spec keys is a demand subsector, anything else a technology
    if (is.list(spec) && length(names(spec)) && !any(names(spec) %in% matFacSpecKeys)) {
      matFacCheckDup(names(spec), paste0(where, ".", key))
      for (tech in names(spec))
        demand[[length(demand) + 1L]] <-
          list(keys = c(cyKey, key, tech),
               vals = matFacRow(spec[[tech]], levels, paste0(where, ".", key, ".", tech)))
    } else {
      supply[[length(supply) + 1L]] <-
        list(keys = c(cyKey, key), vals = matFacRow(spec, levels, paste0(where, ".", key)))
    }
  }
  list(supply = supply, demand = demand)
}

writeMaturityFactors <- function(mf) {
  levels  <- mf$levels  %||% list()
  regions <- mf$regions %||% list()
  entries <- setdiff(names(mf), matFacReserved)
  if ((length(entries) || length(regions)) && !length(levels))
    stop("maturity_factors needs a \"levels\" block saying what the level names mean, ",
         "e.g. \"levels\": { \"low\": 0.5, \"def\": 1, \"high\": 2 }.")

  glob <- matFacEntries(mf, levels, "", character(0))
  cy   <- list(supply = list(), demand = list())
  matFacCheckDup(names(regions), ".regions")
  for (region in names(regions)) {
    r <- matFacEntries(regions[[region]], levels, paste0(".regions.", region), region)
    cy$supply <- c(cy$supply, r$supply)
    cy$demand <- c(cy$demand, r$demand)
  }

  matFacWriteCsv("data/iMatFacMultSupply.csv",   "PGALL",                    glob$supply)
  matFacWriteCsv("data/iMatFacMultDemand.csv",   c("DSBS", "TECH"),          glob$demand)
  matFacWriteCsv("data/iMatFacMultSupplyCy.csv", c("allCy", "PGALL"),        cy$supply)
  matFacWriteCsv("data/iMatFacMultDemandCy.csv", c("allCy", "DSBS", "TECH"), cy$demand)
  if (length(glob$supply) + length(glob$demand) + length(cy$supply) + length(cy$demand))
    cat("Maturity-factor switches: global", length(glob$supply), "supply,", length(glob$demand),
        "demand; regional", length(cy$supply), "supply,", length(cy$demand), "demand
")
}

# ---- Load task bodies --------------------------------------------------
for (f in list.files("scripts/tasks", pattern = "^task\\d+[A-Z].*\\.R$",
                     full.names = TRUE)) source(f)

# ---- Parse CLI args ---------------------------------------------------
args            <- commandArgs(trailingOnly = TRUE)
cli_task_id     <- as.integer(sub("task_id=", "", grep("^task_id=", args, value = TRUE)))
cli_csv_paths   <- grep("\\.csv$", args, ignore.case = TRUE, value = TRUE)

if (length(cli_csv_paths) > 1) {
  stop("Pass at most one CSV path. Got: ", paste(cli_csv_paths, collapse = ", "))
}
batch_mode <- length(cli_csv_paths) == 1L

if (!batch_mode && !length(cli_task_id)) {
  stop("Usage:\n",
       "  Rscript start.R task_id=N        single scenario from config.json:scenario\n",
       "  Rscript start.R <path-to-csv>    batch over each row in the CSV")
}

# ---- nestDottedKeys: take a flat named list whose names may contain dots ---
# (e.g. "gams_flags.fScenario") and return a nested list rebuilding the
# hierarchy. NA / empty-string values are skipped (= do not override).
nestDottedKeys <- function(flat) {
  out <- list()
  for (key in names(flat)) {
    val <- flat[[key]]
    if (is.null(val) ||
        (length(val) == 1 && (is.na(val) || identical(as.character(val), "")))) next
    if (is.character(val)) val <- trimws(val)
    if (identical(val, "")) next
    parts <- strsplit(key, ".", fixed = TRUE)[[1]]
    leaf <- val
    for (i in rev(seq_along(parts))) leaf <- setNames(list(leaf), parts[i])
    out <- modifyList(out, leaf)
  }
  out
}

# ---- runScenario(): set env vars + dispatch to the right task body --------
runScenario <- function(scn) {
  if (is.null(scn$task_id)) stop("task_id is missing in the scenario.")

  land_use_extra <- ""
  if (length(scn$gams_flags)) {
    extra <- paste(sprintf("--%s=%s", names(scn$gams_flags),
                           unlist(scn$gams_flags)),
                   collapse = " ")
  } else {
    extra <- ""
  }
  # Land-use emulator config group -> GAMS flags (the soft_link_magpie group is
  # consumed by task7, which passes --softLinkMAgPIE itself).
  lue <- scn$land_use_emulator
  if (length(lue)) {
    emulator_source <- lue$source %||% "magpie"
    allowed_sources <- c("legacy", "globiom", "magpie")
    if (length(emulator_source) != 1L || !emulator_source %in% allowed_sources) {
      stop("land_use_emulator.source must be one of: ",
           paste(allowed_sources, collapse = ", "), ". Got: ",
           paste(emulator_source, collapse = ", "))
    }

    # Every non-legacy source requires a matching coefficient-table scenario.
    # This also applies to task 7: its round-0 solve explicitly runs with
    # softLinkMAgPIE=off before the live coupling iterations start.
    if (emulator_source != "legacy") {
      carbon_price_scenario <- lue$carbon_price_scenario
      if (is.null(carbon_price_scenario) || length(carbon_price_scenario) != 1L ||
          !nzchar(carbon_price_scenario)) {
        stop("land_use_emulator.carbon_price_scenario must contain one scenario label",
             " when source='", emulator_source, "'.")
      }
    }

    source_flag <- sprintf("--landUseEmulator=%s", emulator_source)
    extra <- paste(extra, source_flag)
    land_use_extra <- paste(land_use_extra, source_flag)
    carbon_price_scenario <- lue$carbon_price_scenario
    if (!is.null(carbon_price_scenario)) {
      scenario_flag <- sprintf("--emulatorCarbonPriceScenario=%s", carbon_price_scenario)
      extra <- paste(extra, scenario_flag)
      land_use_extra <- paste(land_use_extra, scenario_flag)
    }
  }
  # Maturity-factor switches -> the two multiplier CSVs that GAMS reads.
  writeMaturityFactors(scn$maturity_factors %||% list())
  Sys.setenv(OPENPROM_EXTRA_FLAGS          = extra)
  Sys.setenv(OPENPROM_LAND_USE_FLAGS       = trimws(land_use_extra))
  Sys.setenv(OPENPROM_SCENARIO             = toJSON(scn, auto_unbox = TRUE))
  Sys.setenv(OPENPROM_SCENARIO_DESCRIPTION = scn$description %||% "")

  switch(as.character(scn$task_id),
         "0" = runTask0(), "1" = runTask1(), "2" = runTask2(),
         "3" = runTask3(), "4" = runTask4(), "5" = runTask5(),
         "6" = runTask6(), "7" = runTask7(),
         stop("Unknown task_id: ", scn$task_id))

  message(sprintf("[%s] task_id=%d done",
                  scn$scenario_name %||% "(no name)", scn$task_id))
}

# ---- Mode dispatch ----------------------------------------------------
if (!batch_mode) {
  # ---- Single mode: use config.json:scenario, override task_id via CLI ----
  scn <- config$scenario %||% list()
  scn$task_id <- cli_task_id
  runScenario(scn)
} else {
  # ---- Batch mode: read CSV, run each row as its own scenario ----
  csv_path <- cli_csv_paths[1]
  if (!file.exists(csv_path)) {
    stop(sprintf(
      "Batch CSV not found: %s\nCreate one (see scenarios.template.csv for the format), or run single-scenario mode:\n  Rscript start.R task_id=N",
      csv_path
    ))
  }
  ALLOWED_TASK_IDS <- c(2L, 7L)

  csv <- read.csv(csv_path, stringsAsFactors = FALSE, na.strings = c("", "NA"),
                  check.names = FALSE)
  if (!"task_id" %in% colnames(csv))
    stop(csv_path, " is missing the required `task_id` column.")
  if (!"scenario_name" %in% colnames(csv))
    stop(csv_path, " is missing the required `scenario_name` column.")
  if (nrow(csv) == 0)
    stop(csv_path, " has no data rows.")

  # ---- Optional `start` column: gate each row (1 = run, 0 = skip).
  # Validate the whole column upfront (any value other than 0/1 aborts) so
  # typos surface before any scenario starts running. Missing column =
  # everything runs (backwards-compatible with pre-`start` CSVs).
  total_rows <- nrow(csv)
  skipped_idx <- integer(0)
  if ("start" %in% colnames(csv)) {
    raw_start <- csv$start
    parsed_start <- suppressWarnings(as.integer(trimws(as.character(raw_start))))
    bad <- which(is.na(parsed_start) | !(parsed_start %in% c(0L, 1L)))
    if (length(bad)) {
      details <- paste(
        sprintf("  row %d (scenario_name=%s): start=%s",
                bad, csv$scenario_name[bad],
                ifelse(is.na(raw_start[bad]), "<NA>",
                       sprintf("\"%s\"", raw_start[bad]))),
        collapse = "\n"
      )
      stop(sprintf(
        "%s: `start` column must be 1 (run) or 0 (skip); invalid value(s):\n%s",
        csv_path, details
      ))
    }
    skipped_idx <- which(parsed_start == 0L)
    if (length(skipped_idx)) {
      for (j in skipped_idx) {
        cat(sprintf("Skipping row %d (scenario_name=%s): start=0\n",
                    j, csv$scenario_name[j]))
      }
      csv <- csv[parsed_start == 1L, , drop = FALSE]
    }
    # Strip `start` itself so it isn't merged into config.json:scenario
    csv$start <- NULL
  }

  cat(sprintf("Loaded %d row(s) from %s, %d active%s\n",
              total_rows, csv_path, nrow(csv),
              if (length(skipped_idx)) sprintf(", %d skipped", length(skipped_idx)) else ""))
  if (nrow(csv) == 0)
    stop("All rows are gated off (start=0); nothing to run.")

  orig_wd <- getwd()
  for (i in seq_len(nrow(csv))) {
    setwd(orig_wd)  # createRunFolder() changes cwd; reset before each iteration.

    row     <- as.list(csv[i, , drop = FALSE])
    task_id <- as.integer(row$task_id)
    if (!task_id %in% ALLOWED_TASK_IDS) {
      stop(sprintf(
        "Row %d (scenario_name=%s): task_id=%s not allowed for batch; only {%s} are batchable.",
        i, row$scenario_name, row$task_id, paste(ALLOWED_TASK_IDS, collapse = ", ")
      ))
    }

    overlay         <- nestDottedKeys(row)
    overlay$task_id <- task_id          # ensure integer, not character from CSV
    scn             <- modifyList(config$scenario %||% list(), overlay)

    cat(sprintf("\n=== [%d/%d] %s (task_id=%d) ===\n",
                i, nrow(csv), scn$scenario_name %||% "(no name)", task_id))
    runScenario(scn)
  }

  cat("\nBatch finished.\n")
}
