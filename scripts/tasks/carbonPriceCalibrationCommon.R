# Shared helpers and reporting subprocess for Tasks 7 and 8.

cpcFirstPolicyYear <- 2010L
cpcLastPolicyYear <- 2100L
cpcFirstSolveYear <- 2024L
cpcLastHistoricalYear <- cpcFirstSolveYear - 1L
cpcGdxFile <- "blabla.gdx"
cpcResearchRegionCount <- 39L

cpcOptions <- function(cfg, args, task_id) {
  if (!is.null(cfg) && !is.list(cfg)) stop("Task ", task_id, " configuration must be an object")
  keys <- sub("=.*$", "", args)
  unknown <- setdiff(keys, c("task_id", "resume_from"))
  if (length(unknown)) stop("Unsupported Task ", task_id, " option(s): ", paste(unknown, collapse = ", "))
  resume <- sub("^resume_from=", "", grep("^resume_from=", args, value = TRUE))
  if (length(resume) > 1L) stop("Supply one resume_from directory")
  path <- if (length(resume)) resume else cfg$resume_from
  if (!is.null(path) && (!is.character(path) || length(path) != 1L || is.na(path) || !nzchar(trimws(path)))) {
    stop("resume_from must be null or a nonempty campaign directory")
  }
  list(resume_from = path)
}

cpcNumber <- function(x, name, minimum = 0, integer = FALSE) {
  if (!is.numeric(x) || length(x) != 1L || !is.finite(x)) {
    stop("Invalid ", name, " (", deparse(x, nlines = 1L), "): expected a finite number")
  }
  if (x < minimum) stop("Invalid ", name, " (", x, "): must be at least ", minimum)
  if (integer && x != trunc(x)) stop("Invalid ", name, " (", x, "): must be an integer")
  invisible(x)
}

cpcIsIndex <- function(x) {
  is.numeric(x) && length(x) == 1L && is.finite(x) &&
    x >= 1L && x <= .Machine$integer.max && x == trunc(x)
}

cpcChoice <- function(x, choices, name) {
  if (!is.character(x) || length(x) != 1L || !x %in% choices) {
    stop(name, " must be one of: ", paste(choices, collapse = ", "))
  }
}

cpcRequirePackages <- function() {
  for (package in c("jsonlite", "digest", "filelock", "openxlsx", "processx", "ps")) {
    if (!requireNamespace(package, quietly = TRUE)) stop("Carbon price calibration requires the R package ", package)
  }
}

cpcOpenCampaign <- function(root, resume, prefix) {
  if (is.null(resume)) {
    campaign <- file.path(
      root, "runs",
      paste0(prefix, "-", Sys.getpid(), "_", format(Sys.time(), "%Y-%m-%d_%H-%M-%S"))
    )
    if (!dir.create(campaign, recursive = TRUE)) stop("Cannot create a fresh calibration directory")
  } else {
    campaign <- path.expand(resume)
    if (!dir.exists(campaign)) stop("resume_from must be a campaign directory: ", campaign)
  }
  campaign <- normalizePath(campaign, winslash = "/", mustWork = TRUE)
  # A lock in the campaign is shared across path aliases and temp directories.
  lock <- filelock::lock(file.path(campaign, ".calibration.lock"), timeout = 0)
  if (is.null(lock)) stop("This calibration is already running: ", campaign)
  list(path = campaign, lock = lock)
}

cpcReadPolicy <- function(path) {
  widths <- count.fields(path, sep = ",", quote = "\"", comment.char = "")
  if (!length(widths) || anyNA(widths) || any(widths != widths[1L])) stop("Malformed policy table")
  x <- read.csv(path, colClasses = "character", na.strings = NULL, check.names = FALSE,
    comment.char = "", fill = FALSE)
  years <- names(x)[grepl("^[0-9]{4}$", names(x))]
  if (anyDuplicated(years) || !all(as.character(cpcFirstPolicyYear:cpcLastPolicyYear) %in% years)) {
    stop("Expected unique annual columns ", cpcFirstPolicyYear, "..", cpcLastPolicyYear)
  }
  x
}

cpcPolicyRow <- function(x, region, policy) {
  i <- which(x[[1L]] == region & x[[2L]] == policy)
  if (length(i) != 1L) stop("Expected exactly one policy row: ", region, "/", policy)
  i
}

cpcWritePrices <- function(path, x) {
  cells <- unlist(x, use.names = FALSE)
  if (anyNA(cells) || any(grepl('[,\r\n"]', cells))) stop("Invalid value in unquoted policy CSV")
  staged <- tempfile(".prices-", tmpdir = dirname(path))
  on.exit(unlink(staged), add = TRUE)
  write.table(x, staged, sep = ",", quote = FALSE, row.names = FALSE, col.names = TRUE)
  cpcPublishOutput(staged, path)
}

cpcSamePrices <- function(x, y) {
  # Compare numeric prices rather than CSV text spelling so rounding in the
  # last printed decimal does not trigger false mismatches.
  if (!identical(names(x), names(y)) || !identical(x[, 1:2], y[, 1:2])) return(FALSE)
  left <- as.vector(as.matrix(x[, -(1:2)]))
  right <- as.vector(as.matrix(y[, -(1:2)]))
  a <- suppressWarnings(as.numeric(left))
  b <- suppressWarnings(as.numeric(right))
  numeric <- is.finite(a)
  length(a) == length(b) && identical(numeric, is.finite(b)) &&
    identical(left[!numeric], right[!numeric]) && all(abs(a[numeric] - b[numeric]) <= 1e-12 * pmax(1, abs(b[numeric])))
}

cpcSelectedPrices <- function(cfg, prices) {
  rows <- vapply(cfg$regions, function(r) cpcPolicyRow(prices, r, cfg$policy), integer(1))
  x <- prices[rows, , drop = FALSE]
  names(x) <- names(prices)
  rownames(x) <- NULL
  x
}

cpcAnnualRows <- function(cfg, iteration, metric_name, unit_name, prices = NULL, report = NULL) {
  n <- length(cfg$regions)
  x <- data.frame(
    Trial = rep(iteration, 2L * n + 1L),
    Metric = c(rep("Carbon price", n), rep(metric_name, n + 1L)),
    Region = c(cfg$regions, cfg$regions, "World"),
    Unit = c(rep("USD2015/t CO2", n), rep(unit_name, n + 1L)),
    check.names = FALSE
  )
  years <- as.character(cpcFirstPolicyYear:cpcLastPolicyYear)
  for (year in years) x[[year]] <- NA_real_
  if (!is.null(prices)) {
    values <- cpcSelectedPrices(cfg, prices)
    for (year in years) {
      value <- suppressWarnings(as.numeric(values[[year]]))
      if (length(value) != n || any(!is.finite(value))) stop("Incomplete annual price record; retaining trial")
      x[seq_len(n), year] <- value
    }
  }
  if (!is.null(report)) {
    for (year in sort(unique(report$annual$year))) {
      if (year > cfg$end_year) next
      rows <- report$annual[report$annual$year == year, ]
      x[n + seq_len(n), as.character(year)] <- rows$value[match(cfg$regions, rows$region)]
      x[2L * n + 1L, as.character(year)] <- sum(rows$value)
    }
  }
  x
}

cpcHash <- function(path) digest::digest(file = path, algo = "sha256")

cpcReadCampaignConfig <- function(campaign) {
  path <- file.path(campaign, "config.json")
  list(config = jsonlite::read_json(path, simplifyVector = FALSE), hash = cpcHash(path))
}

cpcProcessEnvironment <- function(run_config, campaign) {
  scenario <- run_config$scenario
  if (is.null(scenario)) scenario <- list()
  c("current",
    OPENPROM_SCENARIO = as.character(jsonlite::toJSON(scenario, auto_unbox = TRUE, null = "null", digits = NA)),
    OPENPROM_CONFIG = file.path(campaign, "config.json"))
}

# Retain the marker if cleanup fails so a resume can identify the owned process.
cpcCleanupProcess <- function(p, marker) {
  if (p$is_alive()) {
    p$kill_tree()
    p$wait(timeout = 5000)
    if (p$is_alive()) stop("Owned process still running: ", marker)
  }
  if (unlink(marker) != 0L) stop("Cannot clear owned process marker: ", marker)
}

cpcProcessMarker <- "calibration-process.rds"

cpcRunProcess <- function(command, args, wd, log, env = NULL, marker_folder = wd,
                          process_factory = processx::process$new) {
  marker <- file.path(marker_folder, cpcProcessMarker)
  if (file.exists(marker)) stop("Retained process needs cleanup before a new launch: ", wd)
  # NULL sends output to the console. The registered handler owns cleanup.
  p <- process_factory(command, args, wd = wd,
    stdout = if (is.null(log)) "" else log,
    stderr = if (is.null(log)) "" else "2>&1", env = env,
    cleanup = FALSE, cleanup_tree = FALSE, supervise = TRUE)
  on.exit(cpcCleanupProcess(p, marker), add = TRUE)
  saveRDS(list(pid = p$get_pid(), created = as.numeric(p$get_start_time()),
    wd = normalizePath(wd, winslash = "/")), marker)
  p$wait()
  status <- p$get_exit_status()
  if (status != 0) stop("process_exit_", status, if (is.null(log)) "" else paste0(": ", log))
  invisible(list(status = status))
}

# Only a recorded calibration process with the expected launch directory can be
# stopped. Full reporting runs at the project root but keeps its marker in the
# campaign; creation time prevents killing a reused OS PID.
cpcStopRetainedProcess <- function(folder, expected_wd = folder) {
  marker <- file.path(folder, cpcProcessMarker)
  if (!file.exists(marker)) return(invisible(NULL))
  record <- readRDS(marker)
  if (!identical(record$wd, normalizePath(expected_wd, winslash = "/")) ||
    length(record$pid) != 1L || !is.finite(record$pid) || record$pid <= 0 ||
    length(record$created) != 1L || !is.finite(record$created)) stop("Invalid retained process identity; keeping work")
  handle <- ps::ps_handle(record$pid, as.POSIXct(record$created, origin = "1970-01-01", tz = "UTC"))
  if (ps::ps_is_running(handle)) {
    # Model trials must stay in their launch directory. A full report has a
    # separate campaign marker and may temporarily chdir while knitting; its
    # recorded launch directory and PID creation time still identify it.
    if (identical(normalizePath(folder, winslash = "/"), record$wd) &&
      !identical(normalizePath(ps::ps_cwd(handle), winslash = "/"), record$wd)) {
      stop("Retained process working directory changed; keeping work")
    }
    message("Stopping interrupted calibration process ", record$pid, " in ", folder)
    children <- ps::ps_children(handle, recursive = TRUE)
    for (child in rev(children)) if (ps::ps_is_running(child)) ps::ps_kill(child)
    if (ps::ps_is_running(handle)) ps::ps_kill(handle)
    for (i in seq_len(100L)) {
      if (!any(vapply(c(children, list(handle)), ps::ps_is_running, logical(1)))) break
      Sys.sleep(0.05)
    }
    if (any(vapply(c(children, list(handle)), ps::ps_is_running, logical(1)))) {
      stop("Interrupted process still running; keeping work")
    }
  }
  if (unlink(marker) != 0L || file.exists(marker)) stop("Cannot clear retained process marker")
  invisible(NULL)
}

cpcWriteRds <- function(value, path) {
  staged <- tempfile(paste0(".", basename(path), "-"), tmpdir = dirname(path))
  on.exit(unlink(staged), add = TRUE)
  saveRDS(value, staged)
  cpcPublishOutput(staged, path)
}

cpcPublishOutput <- function(staged, path) {
  if (!suppressWarnings(file.rename(staged, path))) {
    stop("Cannot publish output: ", path, ". If it is open in another program, close it and resume.")
  }
  invisible(NULL)
}

cpcWriteJson <- function(value, path) {
  staged <- tempfile(paste0(".", basename(path), "-"), tmpdir = dirname(path), fileext = ".json")
  on.exit(unlink(staged), add = TRUE)
  jsonlite::write_json(value, staged, pretty = TRUE, auto_unbox = TRUE, na = "null", null = "null", digits = NA)
  cpcPublishOutput(staged, path)
}

cpcLoadState <- function(path, task_id, config_hash = NULL, check_state = NULL) {
  previous <- paste0(path, ".previous")
  if (!file.exists(path) && !file.exists(previous)) return(NULL)
  # A readable checkpoint is authoritative. Only a failed read can select the previous write.
  used_previous <- !file.exists(path)
  record <- if (used_previous) readRDS(previous) else tryCatch(suppressWarnings(readRDS(path)), error = function(e) {
    if (!file.exists(previous)) stop("Cannot read calibration checkpoint ", path, ": ", conditionMessage(e))
    used_previous <<- TRUE
    readRDS(previous)
  })
  if (!is.list(record) || !identical(record$schema_version, 1L) ||
    !identical(record$task_id, task_id) || !is.list(record$state)) {
    stop("Unsupported calibration state format or wrong task: ", path)
  }
  if (!is.null(config_hash) && !identical(record$state$config_hash, config_hash)) {
    stop("Frozen Task ", task_id, " configuration changed: ", path)
  }
  if (!is.null(check_state)) check_state(record$state)
  if (used_previous) {
    cpcPublishOutput(previous, path)
  } else if (file.exists(previous) && unlink(previous) != 0L) {
    stop("Cannot remove previous checkpoint: ", previous)
  }
  record$state
}

cpcHistorySheets <- function(annual, summary, settings) {
  list(AnnualPaths = annual, SearchSummary = summary, Settings = settings)
}

cpcSaveHistory <- function(path, sheets) {
  if (any(vapply(sheets, nrow, integer(1)) >= 1048576L)) stop("Excel row limit exceeded")
  wb <- openxlsx::createWorkbook(creator = "OPEN-PROM")
  openxlsx::modifyBaseFont(wb, fontName = "Arial", fontSize = 10)
  header <- openxlsx::createStyle(fgFill = "#243746", fontColour = "#FFFFFF", textDecoration = "bold",
    halign = "center", valign = "center", wrapText = TRUE)
  for (i in seq_along(sheets)) {
    name <- names(sheets)[i]
    data <- sheets[[i]]
    openxlsx::addWorksheet(wb, name, gridLines = FALSE)
    if (nrow(data)) {
      openxlsx::writeDataTable(wb, name, data, tableName = c("AnnualPaths", "SearchSummary", "RunSettings")[i],
        tableStyle = "TableStyleLight9", headerStyle = header, keepNA = FALSE)
    } else {
      openxlsx::writeData(wb, name, data, headerStyle = header, keepNA = FALSE)
    }
    openxlsx::freezePane(wb, name, firstActiveRow = 2, firstActiveCol = if (i == 1L) 5 else 3)
    openxlsx::setRowHeights(wb, name, 1, if (i == 2L) 48 else 30)
    if (i == 1L) {
      openxlsx::setColWidths(wb, name, 1:4, c(12, 24, 12, 22))
      openxlsx::setColWidths(wb, name, 5:ncol(data), 14)
    } else if (i == 2L) {
      openxlsx::setColWidths(wb, name, seq_len(ncol(data)), 18)
      openxlsx::setColWidths(wb, name, which(grepl("Price|CO2|Slope", names(data))), 25)
      openxlsx::setColWidths(wb, name, match(c("FailureReason", "LogExcerpt"), names(data)), c(55, 75))
    } else {
      openxlsx::setColWidths(wb, name, 1:2, c(32, 85))
    }
    numeric_columns <- if (i == 1L) 5:ncol(data) else which(vapply(data, is.numeric, logical(1)))
    if (nrow(data) && length(numeric_columns)) {
      openxlsx::addStyle(wb, name, openxlsx::createStyle(numFmt = "#,##0.000000"),
        rows = 2:(nrow(data) + 1L), cols = numeric_columns, gridExpand = TRUE, stack = TRUE)
    }
  }
  staged <- tempfile(".history-", tmpdir = dirname(path), fileext = ".xlsx")
  on.exit(unlink(staged), add = TRUE)
  openxlsx::saveWorkbook(wb, staged, overwrite = TRUE)
  cpcPublishOutput(staged, path)
}

# Only the authoritative checkpoint needs a previous copy across an interrupted replacement.
cpcSaveState <- function(path, task_id, state) {
  previous <- paste0(path, ".previous")
  if (file.exists(previous)) stop("Unresolved previous checkpoint; resume the campaign: ", previous)
  staged <- tempfile(".checkpoint-", tmpdir = dirname(path))
  committed <- FALSE
  on.exit({
    unlink(staged)
    if (!committed && !file.exists(path) && file.exists(previous)) file.rename(previous, path)
  }, add = TRUE)
  saveRDS(list(schema_version = 1L, task_id = task_id, state = state), staged)
  if (file.exists(path) && !file.rename(path, previous)) stop("Cannot preserve checkpoint: ", path)
  cpcPublishOutput(staged, path)
  committed <- TRUE
  if (file.exists(previous) && unlink(previous) != 0L) stop("Cannot remove previous checkpoint: ", previous)
  invisible(cpcHash(path))
}

cpcSaveCheckpoint <- function(path, task_id, state, history, sheets) {
  saved <- cpcSaveState(path, task_id, state)
  cpcSaveHistory(history, sheets)
  invisible(saved)
}

cpcCheckSavedState <- function(path, saved_hash) {
  if (!file.exists(path) || !identical(cpcHash(path), saved_hash)) {
    stop("Saved calibration state changed or is missing; keeping recovery files: ", path)
  }
}

cpcCleanup <- function(path, parent, state_path, saved_hash) {
  if (!dir.exists(path)) return(invisible(NULL))
  link <- Sys.readlink(path)
  if ((!is.na(link) && nzchar(link)) ||
    !identical(normalizePath(dirname(path), winslash = "/"), normalizePath(parent, winslash = "/")) ||
    !grepl("^(\\.work|trial-[0-9]+)$", basename(path))) stop("Refusing to remove an unexpected directory")
  cpcCheckSavedState(state_path, saved_hash)
  if (any(basename(list.files(path, recursive = TRUE, all.files = TRUE)) == cpcProcessMarker)) {
    stop("Process cleanup has not completed; keeping temporary directory: ", path)
  }
  if (basename(path) == ".work" && any(grepl("^trial-", list.files(path, all.files = TRUE)))) {
    stop("Uncleared trial remains; keeping work directory: ", path)
  }
  if (unlink(path, recursive = TRUE) != 0L || dir.exists(path)) stop("Could not clean temporary directory: ", path)
}

cpcMetadataFiles <- c("metadata.json", "git_diff.txt")
cpcModelFiles <- function(folder) file.path(folder, c(cpcGdxFile, "modelstat.txt", "main.lst",
  "outputData.gdx", "main.log", cpcMetadataFiles))

cpcResearchFiles <- function(folder) {
  file.path(folder, c("reporting.mif", "emissions.csv", "plot.pdf", "Validation.pdf"))
}

cpcFilesReady <- function(paths) {
  all(file.exists(paths)) && !any(dir.exists(paths)) &&
    isTRUE(all(file.info(paths)$size > 0 | basename(paths) == "git_diff.txt"))
}

cpcFileHashes <- function(paths) setNames(vapply(paths, cpcHash, character(1), USE.NAMES = FALSE), basename(paths))

# A failed confirmation or full report restores the files it replaced. Leave
# the previous set in .work if a reporting child still owns the output files.
cpcReplaceOutputs <- function(paths, work, publish) {
  if (any(dir.exists(paths))) stop("An output destination is a directory: ", paths[dir.exists(paths)][1L])
  existed <- file.exists(paths)
  backup <- tempfile("previous-outputs-", tmpdir = work)
  previous <- file.path(backup, basename(paths))
  if (any(existed) && !dir.create(backup)) stop("Cannot stage previous outputs")
  committed <- FALSE
  on.exit({
    if (committed) {
      unlink(backup, recursive = TRUE)
    } else if (!file.exists(file.path(dirname(paths[1L]), cpcProcessMarker))) {
      moved <- file.exists(previous)
      # A failed move leaves its original path in place.
      if (unlink(paths[!existed | moved]) != 0L || !all(file.rename(previous[moved], paths[moved]))) {
        stop("Could not restore outputs. Previous files retained at ", backup)
      }
      unlink(backup, recursive = TRUE)
    }
  }, add = TRUE)
  if (!all(file.rename(paths[existed], previous[existed]))) stop("Cannot move previous outputs to ", backup)
  force(publish)
  committed <- TRUE
  invisible(NULL)
}

cpcPublishConfirmation <- function(files, campaign, trial, task_id, iteration) {
  hashes <- cpcFileHashes(files)
  marker <- file.path(trial, "confirmation.rds")
  cpcWriteRds(list(task_id = task_id, trial = as.integer(iteration), hashes = hashes), marker)
  targets <- file.path(campaign, basename(c(files, marker)))
  cpcReplaceOutputs(targets, dirname(trial), {
    if (!all(file.copy(files, campaign)) || !file.copy(marker, campaign)) stop("Cannot publish confirmation")
    if (!identical(cpcFileHashes(targets), c(hashes, confirmation.rds = cpcHash(marker)))) {
      stop("Published confirmation files differ from the trial")
    }
  })
}

cpcConfirmationTrialReady <- function(trial) {
  cpcFilesReady(c(cpcModelFiles(trial), file.path(trial, "data/iEnvPolicies.csv"))) &&
    !file.exists(file.path(trial, cpcProcessMarker))
}

cpcConfirmationMatches <- function(campaign, files, task_id, iteration) {
  marker <- file.path(campaign, "confirmation.rds")
  if (!file.exists(marker) || !cpcFilesReady(files)) return(FALSE)
  expected <- list(task_id = as.integer(task_id), trial = as.integer(iteration), hashes = cpcFileHashes(files))
  tryCatch(identical(suppressWarnings(readRDS(marker)), expected), error = function(e) FALSE)
}

# Recovery data are private to this calibration and removed only after complete.
cpcStateFolder <- function(campaign) {
  current <- file.path(campaign, "calibration-state")
  link <- Sys.readlink(current)
  if ((!is.na(link) && nzchar(link)) || (file.exists(current) && !dir.exists(current))) {
    stop("Invalid calibration-state directory")
  }
  current
}

cpcLogExcerpt <- function(paths) {
  parts <- lapply(paths[file.exists(paths)], function(p) {
    lines <- tail(readLines(p, warn = FALSE), 40L)
    paste(basename(p), substr(paste(lines, collapse = "\n"), 1L, 11000L), sep = "\n")
  })
  if (length(parts)) substr(paste(unlist(parts), collapse = "\n\n"), 1L, 29000L) else NA_character_
}

# ---- Campaign snapshots, model execution and reporting ----------------------
cpcPackageNames <- c("postprom", "mrprom", "gdx", "magclass", "madrat", "quitte")

cpcPackageVersions <- function() {
  setNames(lapply(cpcPackageNames, function(p) as.character(utils::packageVersion(p))), cpcPackageNames)
}

cpcValidIndustrialInput <- function(x) inherits(x, "magpie") && all(is.finite(x))

cpcCheckReportVersions <- function(folder) {
  path <- file.path(folder, "package-versions.rds")
  if (!identical(readRDS(path), cpcPackageVersions())) stop("Reporting package versions changed: ", path)
}

# Match createRunFolder(): root GAMS/CSV/JSON files, solver options and the
# data/targets/core/modules/scripts directories. Do not copy companion packages.
cpcSources <- function(root) {
  entries <- list.files(root, full.names = TRUE)
  entries[basename(entries) %in% c("data", "targets", "core", "modules", "scripts", "conopt.opt") |
    grepl("\\.(gms|csv|json)$", entries)]
}

cpcSnapshot <- function(root, campaign, run_config, write_metadata) {
  if (!all(file.copy(cpcSources(root), campaign, recursive = TRUE))) stop("Incomplete model snapshot")
  # Keep only the reporter actually sourced by the isolated reporting worker.
  state_dir <- cpcStateFolder(campaign)
  if (!dir.create(state_dir)) stop("Cannot create calibration-state directory")
  if (!file.copy(file.path(root, "postprom/R/reportEmissions.R"), state_dir)) stop("Cannot freeze emissions reporter")
  # Preserve the actual configuration, including an OPENPROM_CONFIG override.
  jsonlite::write_json(run_config, file.path(campaign, "config.json"),
                       pretty = TRUE, auto_unbox = TRUE, null = "null", digits = NA)
  previous_wd <- setwd(state_dir)
  on.exit(setwd(previous_wd), add = TRUE)
  write_metadata(DevMode = 0)
}

cpcPrepareTrial <- function(campaign, trial, prices, confirmation) {
  if (!all(file.copy(cpcSources(campaign), trial, recursive = TRUE))) stop("Incomplete trial snapshot")
  cpcWritePrices(file.path(trial, "data/iEnvPolicies.csv"), prices)
  if (confirmation && !all(file.copy(file.path(cpcStateFolder(campaign), cpcMetadataFiles), trial, overwrite = TRUE))) {
    stop("Cannot copy snapshot metadata to confirmation: ", trial)
  }
}

cpcFlags <- function(flags, cfg) {
  if (is.null(flags)) flags <- list()
  if (any(names(flags) %in% c("fCountries", "Calibration", "fBaseY", "fStartHorizon"))) {
    stop("Country subset, calibration or historical overrides are unsupported")
  }
  flags <- modifyList(flags, list(DevMode = 0, GenerateInput = "off", WriteGDX = "on",
    CountrySolveMode = "serial", softLinkMAgPIE = "off", fStartY = cpcFirstSolveYear, fPeriodOfYears = 1,
    fEndY = cfg$end_year, fScenario = cfg$fScenario, landUseEmulator = "magpie",
    emulatorCarbonPriceScenario = cfg$emulator))
  if (anyDuplicated(names(flags)) || any(!grepl("^[A-Za-z][A-Za-z0-9_]*$", names(flags))) ||
    any(lengths(flags) != 1L) || any(!grepl("^[A-Za-z0-9_.+-]+$", unlist(flags)))) stop("Invalid GAMS flag")
  flags
}

cpcSolveArgs <- function(flags, confirmation) {
  c("main.gms", paste0("--", names(flags), "=", unlist(flags)), if (confirmation) "lo=4" else "lo=3", "-Idir=./data")
}

cpcModelStatusFields <- function(path) {
  lines <- readLines(path, warn = FALSE)
  lines <- lines[nzchar(trimws(lines))]
  pattern <- "^\\s*Country:\\s*(\\S+)\\s+Model Status:\\s*([0-9.]+)\\s+Year:\\s*([0-9]+)\\s*$"
  regmatches(lines, regexec(pattern, lines, perl = TRUE))
}

cpcReadRegions <- function(campaign) {
  sets <- paste(readLines(file.path(campaign, "core/sets.gms"), warn = FALSE), collapse = "\n")
  block <- regmatches(sets, regexec('(?s)resCy\\s+"[^"]*"\\s*/(.*?)/', sets, perl = TRUE))[[1L]]
  if (length(block) != 2L) stop("Cannot read research regions")
  regions <- strsplit(trimws(block[2L]), "\\s+", perl = TRUE)[[1L]]
  if (length(regions) != cpcResearchRegionCount) {
    stop("This version requires all ", cpcResearchRegionCount, " research regions")
  }
  regions
}

cpcTrialFolders <- function(work) {
  folders <- list.dirs(work, recursive = FALSE, full.names = TRUE)
  folders <- folders[grepl("^trial-[0-9]+$", basename(folders))]
  folders[order(as.integer(sub("trial-", "", basename(folders))))]
}

cpcReportProcess <- function(root, campaign, run_config, metric) {
  worker <- file.path(campaign, "scripts", "tasks", "carbonPriceCalibrationCommon.R")
  if (!file.exists(worker)) stop("Missing calibration reporting worker: ", worker)
  env <- cpcProcessEnvironment(run_config, campaign)
  work <- file.path(campaign, ".work")
  function(mode, trial = NULL) {
    folder <- if (mode == "full") campaign else work
    args <- c(mode, metric, folder, trial)
    wd <- if (mode == "full") root else if (is.null(trial)) work else trial
    log <- if (mode == "full") NULL else file.path(wd, if (mode == "freeze") "freeze-reporting.log" else "report.log")
    cpcRunProcess(file.path(R.home("bin"), "Rscript"), c(worker, args), wd, log, env,
      marker_folder = if (mode == "full") campaign else wd)
  }
}

cpcFreezeReporting <- function(campaign, report_process, fresh = TRUE) {
  folder <- cpcStateFolder(campaign)
  if (!file.exists(file.path(folder, "reportEmissions.R"))) stop("Frozen emissions reporter is missing: ", folder)
  files <- file.path(folder, c("industrial-processes.rds", "package-versions.rds"))
  if (!all(file.exists(files)) && fresh) report_process("freeze")
  if (!all(file.exists(files))) stop("Missing frozen reporting inputs: ", folder)
  cpcCheckReportVersions(folder)
}

cpcFullReport <- function(campaign, work, report_process) {
  marker <- file.path(campaign, "confirmation.rds")
  confirmation <- cpcHash(marker)
  outputs <- cpcResearchFiles(campaign)
  stamp <- file.path(cpcStateFolder(campaign), "full-report.rds")
  signature <- function() {
    if (cpcFilesReady(outputs) && identical(cpcHash(marker), confirmation)) {
      list(confirmation = confirmation, outputs = cpcFileHashes(outputs))
    }
  }
  current <- signature()
  if (!is.null(current) && file.exists(stamp) &&
    identical(tryCatch(suppressWarnings(readRDS(stamp)), error = function(e) NULL), current)) {
    message("Reusing complete research reports for the saved confirmation")
    return(invisible(NULL))
  }

  cpcReplaceOutputs(outputs, work, {
    message("Generating full research reports for the saved confirmation")
    report_process("full")
    current <- signature()
    if (is.null(current)) stop("Full reporting did not produce MIF, emissions CSV and both PDFs for the confirmation")
    cpcWriteRds(current, stamp)
  })
}

cpcCleanupReportState <- function(campaign, state_path, saved_hash) {
  cpcCheckSavedState(state_path, saved_hash)
  if (file.exists(file.path(campaign, cpcProcessMarker))) stop("Reporting process cleanup is incomplete")
  folder <- cpcStateFolder(campaign)
  if (!dir.exists(folder)) return(invisible(NULL))
  entries <- list.files(folder, all.files = TRUE, no.. = TRUE)
  records <- c("industrial-processes.rds", "package-versions.rds", "full-report.rds")
  staged <- grepl("^\\.(industrial-processes|package-versions|full-report)\\.rds-", entries)
  if (any(!(entries %in% c("reportEmissions.R", cpcMetadataFiles, records) | staged)) ||
      any(dir.exists(file.path(folder, entries)))) {
    stop("Unexpected recovery-state contents; keeping recovery state")
  }
  if (unlink(folder, recursive = TRUE) != 0L || dir.exists(folder)) {
    stop("Cannot clean completed recovery state: ", folder)
  }
}

# ---- Reporting subprocess ------------------------------------------------
cpcReportWorker <- function(mode, metric, work, trial = NULL, scripts_dir) {
  cpcChoice(metric, c("Emissions|CO2.Mt CO2/yr", "Emissions|Kyoto Gases.Mt CO2-equiv/yr"), "Reporting metric")
  work <- normalizePath(work, mustWork = TRUE)
  folder <- cpcStateFolder(if (mode == "full") work else dirname(work))
  if (mode == "freeze") {
    old <- madrat::getConfig("packages")
    madrat::setConfig(packages = unique(c("mrprom", old)))
    frozen <- madrat::readSource("IndustrialProcessesEmissionsIEAPrimes")
    if (!cpcValidIndustrialInput(frozen)) stop("Invalid industrial reporting source")
    cpcWriteRds(frozen, file.path(folder, "industrial-processes.rds"))
    cpcWriteRds(cpcPackageVersions(), file.path(folder, "package-versions.rds"))
    return(invisible(NULL))
  }
  if (!mode %in% c("evaluate", "full") || (mode == "evaluate" && is.null(trial))) stop("Expected freeze/evaluate/full")
  cpcCheckReportVersions(folder)

  # Both lightweight and full reports use the same frozen emissions function
  # and industrial input; all other full-report calculations use normal postprom.
  env <- new.env(parent = asNamespace("postprom"))
  sys.source(file.path(folder, "reportEmissions.R"), envir = env)
  frozen <- readRDS(file.path(folder, "industrial-processes.rds"))
  if (!cpcValidIndustrialInput(frozen)) stop("Invalid frozen industrial reporting input")

  frozen_reads <- 0L
  env$readSource <- function(type, ...) {
    if (!identical(type, "IndustrialProcessesEmissionsIEAPrimes")) stop("Unexpected reporting data lookup: ", type)
    frozen_reads <<- frozen_reads + 1L
    frozen
  }
  env$interpolate_missing_periods <- quitte::interpolate_missing_periods
  report_emissions <- function(...) {
    before <- frozen_reads
    report <- env$reportEmissions(...)
    if (frozen_reads == before) stop("The emissions reporter did not use the frozen industrial process input")
    report
  }
  if (mode == "full") {
    if (!requireNamespace("tinytex", quietly = TRUE) || !tinytex::is_tinytex()) {
      stop("TinyTeX is required for plot.pdf and Validation.pdf; calibration files retained")
    }
    # postprom currently has no emissions callback. Keep the substitution in
    # this process and verify the normal report called the frozen reporter.
    original <- getFromNamespace("reportEmissions", "postprom")
    assignInNamespace("reportEmissions", report_emissions, ns = "postprom")
    on.exit(assignInNamespace("reportEmissions", original, ns = "postprom"), add = TRUE)
    report_env <- new.env(parent = globalenv())
    report_env$.report_output_args <- work
    sys.source(file.path(scripts_dir, "reportOutput.R"), envir = report_env)
    if (!frozen_reads) stop("The research report did not use the frozen emissions reporter")
    return(invisible(NULL))
  }
  cfg <- readRDS(file.path(work, "config.rds"))
  trial <- normalizePath(trial, mustWork = TRUE)
  gdx_path <- file.path(trial, cpcGdxFile)
  if (!file.exists(gdx_path) || file.info(gdx_path)$size == 0) stop("Missing GDX")
  regions <- cfg$regions
  years <- seq.int(cpcFirstSolveYear, cfg$end_year)
  report_years <- seq.int(cpcFirstPolicyYear, cfg$end_year)
  key <- function(r, y) paste(r, y, sep = ":")
  grid <- function(object, r, y) {
    if (!inherits(object, "magpie") || !all(r %in% magclass::getRegions(object)) ||
      !all(y %in% magclass::getYears(object, as.integer = TRUE))) stop("Incomplete GDX grid")
    d <- as.data.frame(object[r, paste0("y", y), ])
    if (!all(c("Region", "Year", "Value") %in% names(d))) stop("Unexpected GDX layout")
    out <- data.frame(
      region = as.character(d$Region), year = as.integer(as.character(d$Year)), value = as.numeric(d$Value)
    )
    expected <- expand.grid(region = r, year = y)
    if (anyDuplicated(key(out$region, out$year)) || any(!is.finite(out$value)) ||
      !setequal(key(out$region, out$year), key(expected$region, expected$year))) stop("Invalid or duplicate GDX grid")
    out
  }
  tag <- function(name) {
    x <- gdx::readGDX(gdx_path, name, react = "silent")
    if (is.null(x) || !length(x)) stop("Missing GDX tag: ", name)
    as.character(x)
  }
  if (!identical(tag("fscenario"), as.character(cfg$fScenario)) ||
    !identical(tag("activeMagpieScen"), cfg$emulator) ||
    !identical(tag("sLandEmiMode"), "curve") ||
    !setequal(tag("runCyL"), regions) || !setequal(tag("resCy"), regions) ||
    !setequal(as.integer(tag("an")), years)) stop("GDX scenario/region/year mismatch")

  # Verify the prices actually consumed by GAMS, not just the generated CSV.
  actual <- grid(gdx::readGDX(gdx_path, "iCarbValYrExog"), regions, years)
  input <- read.csv(file.path(trial, "data/iEnvPolicies.csv"), check.names = FALSE)
  expected <- do.call(rbind, lapply(regions, function(r) {
    row <- which(input[[1L]] == r & input[[2L]] == cfg$policy)
    if (length(row) != 1L) stop("Policy row mismatch")
    data.frame(region = r, year = years, value = as.numeric(input[row, as.character(years)]))
  }))
  wanted <- expected$value[match(key(actual$region, actual$year), key(expected$region, expected$year))]
  if (any(!is.finite(wanted)) || any(abs(actual$value - wanted) > 1e-8 * pmax(1, abs(wanted)))) {
    stop("Actual model prices differ")
  }

  # Check required CO2 inputs before the reporter can substitute a fallback.
  for (symbol in c("V07GrossEmissCO2Demand", "V06CO2CaptureCCS", "V07GrossEmissCO2Supply",
    "V06CapCDR", "imAfoluLandEmis", "imAfoluAgriEmis", "V07EmiActBySrcRegTim")) {
    x <- if (startsWith(symbol, "V")) gdx::readGDX(gdx_path, symbol, field = "l") else gdx::readGDX(gdx_path, symbol)
    if (!inherits(x, "magpie") || !all(regions %in% magclass::getRegions(x)) ||
      !all(report_years %in% magclass::getYears(x, as.integer = TRUE)) ||
      any(!is.finite(x[regions, paste0("y", report_years), ]))) stop("Missing/invalid emissions input: ", symbol)
  }
  report <- report_emissions(gdx_path, regions, paste0("y", report_years))
  if (!metric %in% magclass::getNames(report)) stop("Missing emissions metric: ", metric)
  annual <- grid(report[, , metric], regions, report_years)
  world <- aggregate(value ~ year, annual, sum)
  world <- world[order(world$year), ]
  names(world)[2L] <- if (metric == "Emissions|CO2.Mt CO2/yr") "emissions_mtco2" else "emissions_mtco2eq"
  saveRDS(list(annual = annual, world = world), file.path(trial, "report.rds"))
}

if (sys.nframe() == 0L) {
  args <- commandArgs(trailingOnly = TRUE)
  if (!((length(args) == 3L && args[1L] %in% c("freeze", "full")) ||
    (length(args) == 4L && args[1L] == "evaluate"))) {
    stop("Usage: carbonPriceCalibrationCommon.R freeze|evaluate|full <metric> <folder> [trial]")
  }
  script <- sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE)[1L])
  # Rscript escapes spaces in its own --file argument.
  if (!file.exists(script)) script <- gsub("~+~", " ", script, fixed = TRUE)
  scripts_dir <- dirname(normalizePath(script, winslash = "/", mustWork = TRUE))
  cpcReportWorker(args[1L], args[2L], args[3L], if (length(args) == 4L) args[4L] else NULL, scripts_dir)
}
