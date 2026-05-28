# Task 7: OPEN-PROM <-> MAgPIE soft-link, iterated to convergence with
# per-phase checkpointing.
#
# ============================================================================
# 1. Round model
# ============================================================================
#
# Round 0    cold OPEN-PROM (--link2MAgPIE=off)            -> blabla_round0.gdx
# Round k>=1 four sequential phases, each persists its completion to
#            coupling_state.json before the next starts:
#
#   forward       postprom::couplePromToMagpie(gdx_{k-1})
#                   -> openprom_coupling.mif  (+ capture h12_quant from it)
#   magpie        snapshot magpie/output/ listing, set OPENPROM_COUPLING_*
#                 env vars, run `Rscript e3m_start.R` from magpie_path, then
#                 diff the listing (must yield exactly 1 new dir)
#   backward      postprom::coupleMagpieToProm(report.mif)
#                   -> iPrices_magpie.csv + iEmissions_magpie.mif
#                   (+ capture h12_price from report.mif; uses round-0 gdx
#                    purely to read the invariant SBS set)
#   openprom_hot  OPEN-PROM (--link2MAgPIE=on); reads the just-written
#                 iPrices_magpie.csv and FX-es BMSWAS price
#                   -> blabla_round{k}.gdx
#
# After each k >= 2, convergence is checked vs round k-1 (§2). The loop
# exits at the first converged round, otherwise when k reaches max_iter.
# Finalization copies blabla_round{final_k}.gdx -> blabla.gdx, writes
# coupling_summary.json, and (per behavior flags) runs reportOutput.R + syncRun.
#
# ============================================================================
# 2. Convergence
# ============================================================================
#
# Two H12-region x year series are captured per round (cells indexed (r, t)):
#
#   h12_quant   bioenergy demand sent in to MAgPIE  (EJ/yr)
#               from openprom_coupling.mif, IAMC variable
#               'Primary Energy Production|Biomass|Energy Crops'
#   h12_price   bioenergy price returned by MAgPIE  (US$2017/GJ)
#               from report.mif, IAMC variable 'Prices|Bioenergy'
#
# For round k >= 2 and x in {price, quant}, restrict to t >= .CONVERGE_YEAR_START
# and compute per-cell relative change:
#
#   rel(r,t) = |x_k(r,t) - x_{k-1}(r,t)| / max(|x_{k-1}(r,t)|, floor)
#
# then reduce to:
#
#   delta_x_max = max(rel)            -- the convergence judge
#   delta_x_l2  = sqrt(mean(rel^2))   -- diagnostic only
#
# floor protection (denominator floor = .PRICE_FLOOR for price, .QUANT_FLOOR
# for quant) prevents spurious 100% spikes from near-zero prev values on
# regions/years that do not physically matter (e.g. price flicker
# 0.001 -> 0.002 US$/GJ).
#
# Convergence rule:
#   converged iff  delta_price_max < price_tol  AND  delta_quant_max < quant_tol
# Both must hold. NA on either side is treated as "not converged" so the loop
# never declares victory on an empty (region, year) grid.
#
# Why h12 (not resCy / not subsector): h12 is the natural shared-boundary
# granularity of the two models. The 39-country resCy and 34-subsector
# broadcasts inside OPEN-PROM are deterministic expansions of h12 values --
# measuring there adds noise without information.
#
# Why max judges (not L2): L2 averages cells, so a single bad cell can be
# washed out. BMSWAS price is .FX-ed into OPEN-PROM per (region, year), so
# even one bad cell distorts the next round's solve. L2 stays as a parallel
# diagnostic for interpreting whether the max reflects broad disagreement
# (max ~ L2) or a few outliers (max >> L2); see §5.
#
# No damping (Picard relaxation): the coupling channel is narrow (single
# fuel, .FX-ed) and MAgPIE has built-in inertia from land constraints +
# 5-year timesteps. If real runs show delta_k > delta_{k-1} for >= 2 rounds,
# revisit.
#
# Defaults:
#   price_tol             0.05      5% relative (scenario.magpie.price_tol)
#   quant_tol             0.05      5% relative (scenario.magpie.quant_tol)
#   .PRICE_FLOOR          1.0       US$2017/GJ
#   .QUANT_FLOOR          0.01      EJ/yr
#   .CONVERGE_YEAR_START  2024      matches main.gms $evalGlobal fStartY
#
# ============================================================================
# 3. State, checkpointing, resume
# ============================================================================
#
# coupling_state.json holds the full run state, written atomically (tmp file
# + file.rename) after every phase completion. Schema:
#
#   schema_version, scenario_name, started, status, last_failure,
#   config_snapshot { max_iter, price_tol, quant_tol, sce_name },
#   rounds { "0": {phase, ...}, "1": {...}, ... }
#
# Per-round phase order, with what each persists into rounds[k]:
#
#   not_started     nothing yet
#   forward_done    coupling_mif_written, h12_quant
#   magpie_done     magpie_output_dir
#   backward_done   backward_outputs_ok, h12_price
#   openprom_done   gdx_path; for k >= 2 also delta_price_max, delta_quant_max
#
# status semantics:
#
#   iterating  in progress (between phases / between rounds), OR frozen by
#              external interruption (kill -9, power loss, SIGTERM, SSH
#              drop). Relaunch with existing_prom_run pointing at the run
#              folder -> auto-resumes from the highest round's last
#              completed phase.
#   failed     a helper caught a model-self error (OPEN-PROM modelstat
#              not 2/5, MAgPIE exit != 0, couple* raised, magpie output
#              dir count != 1) via tryCatch and wrote last_failure
#              {round, phase, timestamp, message}. Not resumable -- same
#              config will fail again. User must start fresh.
#   converged  loop exited via the convergence test.
#   max_iter   loop exited because k == max_iter without converging.
#
# config_snapshot pins the four user-facing knobs at first write. Resume
# requires bit-identical config_snapshot; any mismatch rejects with the
# differing field shown. To change a knob, start fresh.
#
# ============================================================================
# 4. Pre-flight (runs before any GAMS or MAgPIE work)
# ============================================================================
#
#   Required fields    paths.magpie_path, scenario.magpie.project,
#                      scenario.scenario_name, scenario.magpie.max_iter >= 1.
#   Filesystem         magpie_path/, magpie_path/e3m_projects/<project>/,
#                      magpie_path/e3m_projects/<project>/scenarios.csv.
#   Subscenario        scenario_name matches exactly one row in the
#                      scenarios.csv `title` column via exact-or-prefix
#                      match (same semantics as MAgPIE's own e3m_start.R).
#                      Zero matches lists all titles; multiple lists
#                      candidates.
#   Resume mode only   existing_prom_run dir exists; coupling_state.json
#                      exists in it; status not in {failed, converged,
#                      max_iter}; config_snapshot bit-identical to cfg.
#
# ============================================================================
# 5. Outputs and how to read them
# ============================================================================
#
# In the openPromRun folder after each run:
#
#   blabla_round{k}.gdx        per-round OPEN-PROM solutions (k = 0..final)
#   blabla.gdx                 copy of blabla_round{final_k}.gdx for
#                              reportOutput.R
#   openprom_coupling.mif      last round's forward output (overwritten)
#   iPrices_magpie.csv         last round's backward price output (overwritten)
#   iEmissions_magpie.mif      last round's backward emissions output
#                              (overwritten)
#   coupling_state.json        full state machine snapshot (see §3)
#   convergence_log.csv        per-round convergence trajectory (see below)
#   coupling_summary.json      finalize-time summary: status, thresholds,
#                              final_deltas, magpie_output_dirs, timestamps
#
# convergence_log.csv columns (one row appended per round k >= 2 once
# openprom_done completes):
#
#   round            k (>= 2; rounds 0 and 1 have no comparable baseline)
#   delta_price_max  judge: compare to price_tol
#   delta_price_l2   diagnostic L2 for price
#   delta_quant_max  judge: compare to quant_tol
#   delta_quant_l2   diagnostic L2 for quant
#   status           'iterating' or 'converged' (never 'failed' or
#                    'max_iter' -- those exit before this row is written)
#
# Reading the max-vs-L2 pair (always max >= L2):
#
#   max much larger than L2   a few cells still moving, bulk has settled
#                             -- localized issue
#   max close to L2           broad disagreement, system not settled
#   max ~= tol, L2 << tol     usually safe to stop iterating; the average
#                             state is converged, only outliers cling to
#                             tol
#
# ============================================================================
# 6. Dependencies
# ============================================================================
#
# Stateless single-direction couplers (untouched, in their package):
#   postprom::couplePromToMagpie    forward,  PROM gdx -> MAgPIE mif
#   postprom::coupleMagpieToProm    backward, MAgPIE mif -> PROM csv + mif
#
# Globals from start.R (sourced into the same R session):
#   gams, withRunFolder, withSync, withReport, config,
#   isRunSuccessful(), createRunFolder(), saveMetadata(), syncRun()
#
# Design background and rejected alternatives: see task7-refactor-plan.md
# at the repo root.


# ============================================================ constants

.PRICE_FLOOR         <- 1.0     # US$2017/GJ, denominator floor for delta_price
.QUANT_FLOOR         <- 0.01    # EJ/yr,      denominator floor for delta_quant
.CONVERGE_YEAR_START <- 2024L   # T* lower bound; aligns with main.gms fStartY

.STATE_FILENAME     <- "coupling_state.json"
.CONV_LOG_FILENAME  <- "convergence_log.csv"
.SUMMARY_FILENAME   <- "coupling_summary.json"
.SCHEMA_VERSION     <- 1L

.H12 <- c("CAZ","CHA","EUR","IND","JPN","LAM","MEA","NEU","OAS","REF","SSA","USA")

.VAR_QUANT <- "Primary Energy Production|Biomass|Energy Crops"
.VAR_PRICE <- "Prices|Bioenergy"


# ============================================================ small utilities

.isoNow <- function() format(Sys.time(), "%Y-%m-%dT%H:%M:%S")

.atomicWriteJson <- function(obj, path) {
  tmp <- paste0(path, ".tmp")
  jsonlite::write_json(obj, tmp, pretty = TRUE, auto_unbox = TRUE,
                       digits = 6, na = "null", null = "null")
  file.rename(tmp, path)
  invisible(path)
}

# Region x year matrix <-> {regions, years, values} JSON object. NULL passes.
.matrixToJsonObj <- function(mat) {
  if (is.null(mat)) return(NULL)
  list(
    regions = rownames(mat),
    years   = as.integer(colnames(mat)),
    values  = lapply(seq_len(nrow(mat)), function(i) as.numeric(mat[i, ]))
  )
}

.jsonObjToMatrix <- function(obj) {
  if (is.null(obj)) return(NULL)
  regions <- unlist(obj$regions)
  years   <- as.integer(unlist(obj$years))
  vals <- do.call(rbind, lapply(obj$values, function(v) as.numeric(unlist(v))))
  rownames(vals) <- regions
  colnames(vals) <- as.character(years)
  vals
}


# ============================================================ state schema

.newState <- function(sceName, cfg) {
  list(
    schema_version = .SCHEMA_VERSION,
    scenario_name  = sceName,
    config_snapshot = list(
      max_iter  = cfg$max_iter,
      price_tol = cfg$price_tol,
      quant_tol = cfg$quant_tol,
      sce_name  = sceName
    ),
    rounds = setNames(list(), character(0)),
    status = "iterating",
    started = .isoNow(),
    last_failure = NULL
  )
}

.loadState <- function(path) {
  raw <- jsonlite::read_json(path, simplifyVector = FALSE)
  for (k in names(raw$rounds)) {
    r <- raw$rounds[[k]]
    if (!is.null(r$h12_price)) r$h12_price <- .jsonObjToMatrix(r$h12_price)
    if (!is.null(r$h12_quant)) r$h12_quant <- .jsonObjToMatrix(r$h12_quant)
    raw$rounds[[k]] <- r
  }
  raw
}

.saveState <- function(state, path) {
  ser <- state
  for (k in names(ser$rounds)) {
    r <- ser$rounds[[k]]
    if (!is.null(r$h12_price) && is.matrix(r$h12_price))
      r$h12_price <- .matrixToJsonObj(r$h12_price)
    if (!is.null(r$h12_quant) && is.matrix(r$h12_quant))
      r$h12_quant <- .matrixToJsonObj(r$h12_quant)
    ser$rounds[[k]] <- r
  }
  .atomicWriteJson(ser, path)
}

.validateConfigConsistency <- function(state, cfg, sceName) {
  snap <- state$config_snapshot
  curr <- list(
    max_iter  = cfg$max_iter,
    price_tol = cfg$price_tol,
    quant_tol = cfg$quant_tol,
    sce_name  = sceName
  )
  diffs <- character(0)
  for (k in names(curr)) {
    a <- snap[[k]]
    b <- curr[[k]]
    if (is.null(a) || is.null(b) || !identical(as.character(a), as.character(b))) {
      diffs <- c(diffs, sprintf("  %s: snapshot=%s, current=%s",
                                 k, format(a), format(b)))
    }
  }
  if (length(diffs)) {
    stop("[task 7] config mismatch with coupling_state.json:\n",
         paste(diffs, collapse = "\n"),
         "\nResume requires bit-identical config. To use different params, start a fresh run.")
  }
  invisible(NULL)
}

# Persist status='failed' + last_failure, then re-raise. Never silently continue.
.markFailedAndStop <- function(state, stateFile, round, phase, e) {
  state$status <- "failed"
  state$last_failure <- list(
    round     = round,
    phase     = phase,
    timestamp = .isoNow(),
    message   = conditionMessage(e)
  )
  try(.saveState(state, stateFile), silent = TRUE)
  stop(sprintf("[task 7] failed in round=%s phase=%s: %s",
               round, phase, conditionMessage(e)))
}


# ============================================================ h12 capture + math

# Read an .mif and return a region x year matrix for the requested IAMC
# variable, restricted to .H12 regions. Prefix match (varNeedle may omit
# the " (unit)" suffix); magclass handles both ';' and ',' delimiters.
.captureH12Series <- function(mifPath, varNeedle) {
  if (!file.exists(mifPath))
    stop(".captureH12Series: file not found: ", mifPath)
  rep <- magclass::read.report(mifPath, as.list = FALSE)
  rep <- magclass::collapseNames(rep)
  vars <- magclass::getNames(rep)
  # Escape IAMC special chars (. | + ()) for use as a regex prefix.
  needle_re <- paste0("^", gsub("([.|+()])", "\\\\\\1", varNeedle))
  hit <- vars[grepl(needle_re, vars)]
  if (length(hit) == 0)
    stop(sprintf(".captureH12Series: var '%s' not found in %s",
                 varNeedle, mifPath))
  slc <- rep[, , hit[1]]
  h12_present <- intersect(.H12, magclass::getRegions(slc))
  if (length(h12_present) == 0)
    stop(sprintf(".captureH12Series: no .H12 regions present in %s", mifPath))
  slc <- slc[h12_present, , ]
  arr <- as.array(slc)
  if (length(dim(arr)) > 2) arr <- arr[, , 1]
  if (is.null(rownames(arr))) rownames(arr) <- h12_present
  colnames(arr) <- sub("^y", "", colnames(arr))   # strip magclass "y" prefix
  storage.mode(arr) <- "double"
  arr
}

# Convergence deltas (max, l2) between two H12-region x year matrices.
# Formula and semantics: see §2 at the top of this file. Returns NA pair
# when the (region, year >= yearStart) intersection is empty.
.computeDelta <- function(curr, prev, floor, yearStart) {
  if (is.null(curr) || is.null(prev))
    return(list(max = NA_real_, l2 = NA_real_))
  rows <- intersect(rownames(curr), rownames(prev))
  yr_c <- suppressWarnings(as.integer(colnames(curr)))
  yr_p <- suppressWarnings(as.integer(colnames(prev)))
  yrs  <- intersect(yr_c, yr_p)
  yrs  <- yrs[!is.na(yrs) & yrs >= yearStart]
  if (length(rows) == 0L || length(yrs) == 0L)
    return(list(max = NA_real_, l2 = NA_real_))
  cc <- curr[rows, as.character(yrs), drop = FALSE]
  pp <- prev[rows, as.character(yrs), drop = FALSE]
  diff  <- abs(cc - pp)
  denom <- pmax(abs(pp), floor)
  rel   <- diff / denom
  list(
    max = max(rel,   na.rm = TRUE),
    l2  = sqrt(mean(rel^2, na.rm = TRUE))
  )
}


# ============================================================ logging outputs

# Append one row to convergence_log.csv (writes header if file is new).
# Column meanings, interpretation, and write timing: see §5 at top of file.
.appendConvergenceLog <- function(openPromRun, round, dp, dq, status) {
  path <- file.path(openPromRun, .CONV_LOG_FILENAME)
  isNew <- !file.exists(path)
  con <- file(path, open = "at")
  on.exit(close(con))
  if (isNew) writeLines(
    "round,delta_price_max,delta_price_l2,delta_quant_max,delta_quant_l2,status",
    con
  )
  writeLines(sprintf("%d,%.6g,%.6g,%.6g,%.6g,%s",
                     round,
                     dp$max, dp$l2,
                     dq$max, dq$l2,
                     status),
             con)
  invisible(path)
}

.writeCouplingSummary <- function(state, openPromRun, finalGdx, cfg) {
  k_keys <- as.integer(names(state$rounds))
  final_k <- max(k_keys)
  final_round <- state$rounds[[as.character(final_k)]]
  magpie_dirs <- vapply(seq_along(k_keys), function(i) {
    r <- state$rounds[[as.character(sort(k_keys)[i])]]
    if (is.null(r$magpie_output_dir)) NA_character_ else r$magpie_output_dir
  }, character(1))
  magpie_dirs <- magpie_dirs[!is.na(magpie_dirs)]

  summary <- list(
    scenario_name   = state$scenario_name,
    status          = state$status,
    rounds_completed = final_k,
    max_iter        = cfg$max_iter,
    thresholds = list(
      price_tol           = cfg$price_tol,
      quant_tol           = cfg$quant_tol,
      price_floor         = .PRICE_FLOOR,
      quant_floor         = .QUANT_FLOOR,
      converge_year_start = .CONVERGE_YEAR_START
    ),
    final_deltas = list(
      price_max = final_round$delta_price_max,
      quant_max = final_round$delta_quant_max
    ),
    magpie_output_dirs = magpie_dirs,
    final_gdx          = finalGdx,
    started            = state$started,
    completed          = .isoNow()
  )
  .atomicWriteJson(summary, file.path(openPromRun, .SUMMARY_FILENAME))
}


# ============================================================ phase helpers
# Each: (state, k, ...) -> state. tryCatch wrapper; success advances
# state$rounds[[k]]$phase + saves; error routes through .markFailedAndStop.

.ensureRound <- function(state, k) {
  key <- as.character(k)
  if (is.null(state$rounds[[key]])) {
    state$rounds[[key]] <- list(phase = "not_started", started = .isoNow())
  }
  state
}

# Round 0: cold OPEN-PROM (link2MAgPIE=off) -> blabla_round0.gdx.
.runOpenPromCold <- function(state, openPromRun, stateFile) {
  k <- 0L; key <- "0"
  tryCatch({
    cat(">>> [task 7] Round 0: OPEN-PROM cold (link2MAgPIE=off)\n")
    extra <- Sys.getenv("OPENPROM_EXTRA_FLAGS")
    cmd <- paste(gams, "main.gms --DevMode=0 --GenerateInput=off --link2MAgPIE=off",
                 extra, "-logOption 4 -AsyncSolLst 1 -Idir=./data 2>&1")
    if (.Platform$OS.type == "unix") {
      system(paste0("sh -c ", shQuote(cmd)))
    } else {
      shell(paste0(cmd, " | tee full_round0.log"))
    }
    if (!isRunSuccessful("modelstat.txt"))
      stop("OPEN-PROM cold run failed (modelstat != 2 or 5)")
    gdx_path <- file.path(openPromRun, "blabla_round0.gdx")
    file.copy(file.path(openPromRun, "blabla.gdx"), gdx_path, overwrite = TRUE)
    state$rounds[[key]]$phase     <- "openprom_done"
    state$rounds[[key]]$gdx_path  <- gdx_path
    state$rounds[[key]]$completed <- .isoNow()
    .saveState(state, stateFile)
    state
  }, error = function(e) .markFailedAndStop(state, stateFile, k, "openprom_done", e))
}

# Forward: gdx_{k-1} -> openprom_coupling.mif + capture h12_quant.
.runForward <- function(state, k, openPromRun, sceName, stateFile) {
  key <- as.character(k)
  tryCatch({
    cat(sprintf(">>> [task 7] Round %d phase=forward: couplePromToMagpie()\n", k))
    prev_gdx <- state$rounds[[as.character(k - 1L)]]$gdx_path
    if (is.null(prev_gdx) || !file.exists(prev_gdx))
      stop(sprintf("previous round gdx missing: %s", prev_gdx))
    couplingMif <- file.path(openPromRun, "openprom_coupling.mif")
    postprom::couplePromToMagpie(
      gdxPath    = prev_gdx,
      outMifPath = couplingMif,
      scenario   = sceName
    )
    h12_quant <- .captureH12Series(couplingMif, .VAR_QUANT)
    state$rounds[[key]]$phase                <- "forward_done"
    state$rounds[[key]]$coupling_mif_written <- TRUE
    state$rounds[[key]]$h12_quant            <- h12_quant
    .saveState(state, stateFile)
    state
  }, error = function(e) .markFailedAndStop(state, stateFile, k, "forward_done", e))
}

# MAgPIE: run e3m_start.R; snapshot+diff output/ to robustly catch the new dir.
.runMagpieStep <- function(state, k, openPromRun, magpieRoot, magpieProj,
                           sceName, stateFile) {
  key <- as.character(k)
  tryCatch({
    cat(sprintf(">>> [task 7] Round %d phase=magpie: MAgPIE run\n", k))
    couplingMif <- file.path(openPromRun, "openprom_coupling.mif")
    old_wd <- getwd()
    on.exit(setwd(old_wd), add = TRUE)
    setwd(magpieRoot)
    snap_before <- list.dirs("output", recursive = FALSE)   # baseline for diff
    Sys.setenv(
      OPENPROM_MAGPIE_PROJECT     = magpieProj,
      OPENPROM_MAGPIE_SUBSCENARIO = sceName,
      OPENPROM_COUPLING_MIF       = couplingMif,
      OPENPROM_COUPLING_SCENARIO  = sceName,
      OPENPROM_COUPLING_GHG       = "on",
      OPENPROM_COUPLING_BIOENERGY = "on"
    )
    magpie_exit <- system("Rscript e3m_start.R")
    Sys.unsetenv(c("OPENPROM_MAGPIE_PROJECT", "OPENPROM_MAGPIE_SUBSCENARIO",
                   "OPENPROM_COUPLING_MIF", "OPENPROM_COUPLING_SCENARIO",
                   "OPENPROM_COUPLING_GHG", "OPENPROM_COUPLING_BIOENERGY"))
    if (magpie_exit != 0)
      stop("MAgPIE exit code ", magpie_exit)
    snap_after <- list.dirs("output", recursive = FALSE)
    new_dirs <- setdiff(snap_after, snap_before)
    if (length(new_dirs) != 1L)
      stop(sprintf("MAgPIE output dir detection: expected exactly 1 new dir, got %d (%s)",
                   length(new_dirs), paste(new_dirs, collapse = ", ")))
    magpie_output_dir <- normalizePath(file.path(magpieRoot, new_dirs),
                                       winslash = "/", mustWork = TRUE)
    state$rounds[[key]]$phase             <- "magpie_done"
    state$rounds[[key]]$magpie_output_dir <- magpie_output_dir
    .saveState(state, stateFile)
    state
  }, error = function(e) .markFailedAndStop(state, stateFile, k, "magpie_done", e))
}

# Backward: report.mif -> iPrices_magpie.csv + iEmissions_magpie.mif
# + capture h12_price.
.runBackward <- function(state, k, openPromRun, sceName, stateFile) {
  key <- as.character(k)
  tryCatch({
    cat(sprintf(">>> [task 7] Round %d phase=backward: coupleMagpieToProm()\n", k))
    mout <- state$rounds[[key]]$magpie_output_dir
    if (is.null(mout) || !dir.exists(mout))
      stop(sprintf("magpie output dir missing for round %d: %s", k, mout))
    reportMif <- file.path(mout, "report.mif")
    # SBS set is round-invariant; round-0 gdx keeps the read deterministic.
    sbs_gdx <- state$rounds[["0"]]$gdx_path
    postprom::coupleMagpieToProm(
      reportMifPath       = reportMif,
      outCsvPath          = file.path(openPromRun, "iPrices_magpie.csv"),
      outEmissionsMifPath = file.path(openPromRun, "iEmissions_magpie.mif"),
      gdxPath             = sbs_gdx,
      scenario            = sceName
    )
    h12_price <- .captureH12Series(reportMif, .VAR_PRICE)
    state$rounds[[key]]$phase               <- "backward_done"
    state$rounds[[key]]$backward_outputs_ok <- TRUE
    state$rounds[[key]]$h12_price           <- h12_price
    .saveState(state, stateFile)
    state
  }, error = function(e) .markFailedAndStop(state, stateFile, k, "backward_done", e))
}

# Hot OPEN-PROM (link2MAgPIE=on) -> blabla_round{k}.gdx. Reads iPrices_magpie.csv.
.runOpenPromHot <- function(state, k, openPromRun, stateFile) {
  key <- as.character(k)
  tryCatch({
    cat(sprintf(">>> [task 7] Round %d phase=openprom_hot: OPEN-PROM (link2MAgPIE=on)\n", k))
    extra <- Sys.getenv("OPENPROM_EXTRA_FLAGS")
    cmd <- paste(gams, "main.gms --DevMode=0 --GenerateInput=off --link2MAgPIE=on",
                 extra, "-logOption 4 -AsyncSolLst 1 -Idir=./data 2>&1")
    if (.Platform$OS.type == "unix") {
      system(paste0("sh -c ", shQuote(cmd)))
    } else {
      shell(paste0(cmd, " | tee full_round", k, ".log"))
    }
    if (!isRunSuccessful("modelstat.txt"))
      stop(sprintf("OPEN-PROM hot run failed in round %d (modelstat != 2 or 5)", k))
    gdx_path <- file.path(openPromRun, sprintf("blabla_round%d.gdx", k))
    file.copy(file.path(openPromRun, "blabla.gdx"), gdx_path, overwrite = TRUE)
    state$rounds[[key]]$phase     <- "openprom_done"
    state$rounds[[key]]$gdx_path  <- gdx_path
    state$rounds[[key]]$completed <- .isoNow()
    .saveState(state, stateFile)
    state
  }, error = function(e) .markFailedAndStop(state, stateFile, k, "openprom_done", e))
}


# ============================================================ resume planner

# Highest existing round dictates resume point: if its phase == openprom_done,
# start round k+1 fresh; otherwise pick up that round at its current phase.
.planResume <- function(state) {
  if (length(state$rounds) == 0L) {
    return(list(round = 0L, phase = "not_started"))
  }
  k_keys <- sort(as.integer(names(state$rounds)))
  last_k <- tail(k_keys, 1L)
  last_phase <- state$rounds[[as.character(last_k)]]$phase
  if (identical(last_phase, "openprom_done")) {
    return(list(round = last_k + 1L, phase = "not_started"))
  }
  list(round = last_k, phase = last_phase)
}


# ============================================================ main entry

runTask7 <- function() {
  scn <- jsonlite::fromJSON(Sys.getenv("OPENPROM_SCENARIO"))

  # ---- Read config + scenario fields
  config        <- if (file.exists("config.json")) jsonlite::fromJSON("config.json") else list()
  magpieRoot    <- config$paths$magpie_path
  magpieProj    <- scn$magpie$project
  sceName       <- scn$scenario_name
  existingRun   <- scn$magpie$existing_prom_run

  # Coupling-loop config with defaults.
  cfg <- list(
    max_iter  = as.integer(scn$magpie$max_iter  %||% 1L),
    price_tol = as.numeric(scn$magpie$price_tol %||% 0.05),
    quant_tol = as.numeric(scn$magpie$quant_tol %||% 0.05)
  )

  if (is.null(magpieRoot) || !nzchar(magpieRoot))
    stop("[task 7] config.json must define paths.magpie_path.")
  if (is.null(magpieProj) || !nzchar(magpieProj))
    stop("[task 7] scenario must define magpie.project.")
  if (is.null(sceName) || !nzchar(sceName))
    stop("[task 7] scenario must define scenario_name.")
  if (cfg$max_iter < 1L)
    stop("[task 7] magpie.max_iter must be >= 1, got ", cfg$max_iter)

  if (!dir.exists(magpieRoot))
    stop("[task 7] magpie_path does not exist: ", magpieRoot)
  projDir <- file.path(magpieRoot, "e3m_projects", magpieProj)
  scenCsv <- file.path(projDir, "scenarios.csv")
  if (!dir.exists(projDir))
    stop("[task 7] project folder not found: ", projDir,
         ". Check scenario.magpie.project.")
  if (!file.exists(scenCsv))
    stop("[task 7] scenarios.csv missing at: ", scenCsv)

  # Validate scenario_name resolves to exactly one MAgPIE subscenario before
  # spending hours on cold OPEN-PROM. MAgPIE matches by `title` column with
  # exact-or-prefix semantics (its own error reads "not found / ambiguous"),
  # so we replicate that here.
  mpTitles <- tryCatch(
    read.csv(scenCsv, stringsAsFactors = FALSE)$title,
    error = function(e) stop("[task 7] failed to read MAgPIE scenarios.csv (",
                             scenCsv, "): ", conditionMessage(e))
  )
  if (is.null(mpTitles))
    stop("[task 7] MAgPIE scenarios.csv has no 'title' column: ", scenCsv)
  hit <- mpTitles[mpTitles == sceName | startsWith(mpTitles, sceName)]
  if (length(hit) == 0L)
    stop("[task 7] scenario_name='", sceName, "' not found in MAgPIE project '",
         magpieProj, "' scenarios.csv.\nAvailable titles:\n  ",
         paste(mpTitles, collapse = "\n  "))
  if (length(hit) > 1L)
    stop("[task 7] scenario_name='", sceName, "' ambiguous in MAgPIE project '",
         magpieProj, "' — matches multiple titles via exact-or-prefix:\n  ",
         paste(hit, collapse = "\n  "))

  library(postprom)

  # ---- Decide: resume an existing run, or start fresh
  reuseExisting <- length(existingRun) > 0 &&
                   !is.na(existingRun) &&
                   nzchar(existingRun)

  if (reuseExisting) {
    if (!dir.exists(existingRun))
      stop("[task 7] magpie.existing_prom_run folder does not exist: ", existingRun)
    openPromRun <- normalizePath(existingRun, winslash = "/", mustWork = TRUE)
    setwd(openPromRun)
    stateFile <- file.path(openPromRun, .STATE_FILENAME)
    if (!file.exists(stateFile))
      stop("[task 7] existing_prom_run=", existingRun,
           " has no ", .STATE_FILENAME,
           ". task7 only accepts state files written by this version; ",
           "the bare-blabla.gdx fallback is not supported. ",
           "Start a fresh run.")
    state <- .loadState(stateFile)
    if (identical(state$status, "failed"))
      stop("[task 7] previous run failed in round=", state$last_failure$round,
           " phase=", state$last_failure$phase,
           " (", state$last_failure$message, "). ",
           "This run is considered dead and is not resumable. ",
           "Start a fresh run.")
    if (state$status %in% c("converged", "max_iter"))
      stop("[task 7] previous run already finished (status=", state$status,
           "). Start a fresh run.")
    .validateConfigConsistency(state, cfg, sceName)
    cat(sprintf(">>> [task 7] resuming run folder: %s\n", openPromRun))
  } else {
    if (withRunFolder) createRunFolder(sceName)
    openPromRun <- getwd()
    stateFile <- file.path(openPromRun, .STATE_FILENAME)
    state <- .newState(sceName, cfg)
    .saveState(state, stateFile)
    cat(sprintf(">>> [task 7] fresh run folder: %s\n", openPromRun))
  }

  saveMetadata(DevMode = 0)

  # ---- Determine resume point
  plan <- .planResume(state)
  start_k     <- plan$round
  start_phase <- plan$phase

  # ---- Round 0 (cold) if not yet done. Any non-openprom_done state at k=0
  # would have been marked failed; treat partial as not_started defensively.
  if (start_k == 0L) {
    state <- .ensureRound(state, 0L)
    state <- .runOpenPromCold(state, openPromRun, stateFile)
    start_k <- 1L; start_phase <- "not_started"
  }

  # ---- Hot rounds loop
  k <- start_k
  while (k <= cfg$max_iter) {
    state <- .ensureRound(state, k)
    phase <- state$rounds[[as.character(k)]]$phase

    if (phase == "not_started") {
      state <- .runForward(state, k, openPromRun, sceName, stateFile)
      phase <- state$rounds[[as.character(k)]]$phase
    }
    if (phase == "forward_done") {
      state <- .runMagpieStep(state, k, openPromRun, magpieRoot, magpieProj,
                              sceName, stateFile)
      phase <- state$rounds[[as.character(k)]]$phase
    }
    if (phase == "magpie_done") {
      state <- .runBackward(state, k, openPromRun, sceName, stateFile)
      phase <- state$rounds[[as.character(k)]]$phase
    }
    if (phase == "backward_done") {
      state <- .runOpenPromHot(state, k, openPromRun, stateFile)
      phase <- state$rounds[[as.character(k)]]$phase
    }
    # Convergence check (k >= 2 only; see §2 for the metric, §5 for the log).
    converged <- FALSE
    if (k >= 2L) {
      curr <- state$rounds[[as.character(k)]]
      prev <- state$rounds[[as.character(k - 1L)]]
      dp <- .computeDelta(curr$h12_price, prev$h12_price,
                          .PRICE_FLOOR, .CONVERGE_YEAR_START)
      dq <- .computeDelta(curr$h12_quant, prev$h12_quant,
                          .QUANT_FLOOR, .CONVERGE_YEAR_START)
      state$rounds[[as.character(k)]]$delta_price_max <- dp$max
      state$rounds[[as.character(k)]]$delta_quant_max <- dq$max
      converged <- !is.na(dp$max) && !is.na(dq$max) &&
                   dp$max < cfg$price_tol && dq$max < cfg$quant_tol
      log_status <- if (converged) "converged" else "iterating"
      .appendConvergenceLog(openPromRun, k, dp, dq, log_status)
      .saveState(state, stateFile)
    }

    if (converged) {
      state$status <- "converged"
      .saveState(state, stateFile)
      cat(sprintf(">>> [task 7] CONVERGED at round %d (delta_price=%.4g, delta_quant=%.4g)\n",
                  k, dp$max, dq$max))
      break
    }
    if (k >= cfg$max_iter) {
      state$status <- "max_iter"
      .saveState(state, stateFile)
      cat(sprintf(">>> [task 7] reached max_iter=%d without convergence\n", cfg$max_iter))
      break
    }
    k <- k + 1L
  }

  # ---- Finalization
  final_k     <- max(as.integer(names(state$rounds)))
  final_gdx   <- state$rounds[[as.character(final_k)]]$gdx_path
  if (!is.null(final_gdx) && file.exists(final_gdx))
    file.copy(final_gdx, file.path(openPromRun, "blabla.gdx"), overwrite = TRUE)
  .writeCouplingSummary(state, openPromRun, final_gdx, cfg)

  if (withRunFolder && withReport) {
    cat(">>> [task 7] reportOutput.R\n")
    run_path <- getwd()
    setwd("../../")
    system(paste0("Rscript ./scripts/tasks/reportOutput.R ", run_path))
    setwd(run_path)
  }
  if (withRunFolder && withSync) syncRun()

  invisible(state)
}

# `%||%` is provided by start.R; guard lets this file parse standalone.
if (!exists("%||%", mode = "function")) {
  `%||%` <- function(a, b) if (is.null(a)) b else a
}
