# Task 7: OPEN-PROM <-> MAgPIE SOFT-LINK
# Six-step pipeline:
#   Step 1: OPEN-PROM run (link2MAgPIE=off)
#   Step 2: couplePromToMagpie()   convert OPEN-PROM gdx -> coupling.mif
#   Step 3: MAgPIE run             (reads OPENPROM_COUPLING_* env vars)
#   Step 4: coupleMagpieToProm()   convert MAgPIE report.mif -> iPrices/iEmissions
#   Step 5: OPEN-PROM rerun (link2MAgPIE=on)
#   Step 6: reportOutput.R + sync
#
# scenario_name is used as the scenario label on BOTH the OPEN-PROM side and the
# MAgPIE side (the run folder name and the MAgPIE subscenario share this string).
# If the scenario carries a magpie.existing_prom_run field, Step 1 is skipped and
# the pipeline picks up from the given OPEN-PROM run folder.

runTask7 <- function() {
  scn <- jsonlite::fromJSON(Sys.getenv("OPENPROM_SCENARIO"))

  # ---- Read required fields from config + scenario ----
  config        <- if (file.exists("config.json")) jsonlite::fromJSON("config.json") else list()
  magpieRoot    <- config$paths$magpie_path
  magpieProj    <- scn$magpie$project
  sceName       <- scn$scenario_name
  existingRun   <- scn$magpie$existing_prom_run

  if (is.null(magpieRoot) || !nzchar(magpieRoot))
    stop("[task 7] config.json must define paths.magpie_path (absolute path to the magpie/ root).")
  if (is.null(magpieProj) || !nzchar(magpieProj))
    stop("[task 7] scenario must define magpie.project (subfolder name under magpie/e3m_projects/).")
  if (is.null(sceName) || !nzchar(sceName))
    stop("[task 7] scenario must define scenario_name (used as the MAgPIE subscenario name too).")

  # ---- Pre-flight: validate MAgPIE installation + project layout ----
  if (!dir.exists(magpieRoot))
    stop("[task 7] magpie_path does not exist: ", magpieRoot,
         ". Check config.json:paths.magpie_path.")
  projDir <- file.path(magpieRoot, "e3m_projects", magpieProj)
  scenCsv <- file.path(projDir, "scenarios.csv")
  if (!dir.exists(projDir))
    stop("[task 7] project folder not found: ", projDir,
         ". Check scenario.magpie.project (must be a subfolder of ",
         "<magpie_path>/e3m_projects/).")
  if (!file.exists(scenCsv))
    stop("[task 7] scenarios.csv missing at: ", scenCsv,
         ". The project folder is incomplete.")

  # NULL when omitted, NA when serialized through JSON as null, "" when blank.
  # Treat all three as "no resume requested".
  reuseExisting <- length(existingRun) > 0 && !is.na(existingRun) && nzchar(existingRun)
  if (reuseExisting) {
    if (!dir.exists(existingRun))
      stop("[task 7] magpie.existing_prom_run folder does not exist: ", existingRun)
    openPromRun <- normalizePath(existingRun, winslash = "/", mustWork = TRUE)
    setwd(openPromRun)
    cat(">>> [task 7] reusing existing run folder:", openPromRun, "\n")
  } else {
    if (withRunFolder) createRunFolder(sceName)
    openPromRun <- getwd()
  }
  saveMetadata(DevMode = 0)
  couplingMif <- file.path(openPromRun, "openprom_coupling.mif")

  # ---- Step 1: OPEN-PROM run (link2MAgPIE=off) ----
  if (!reuseExisting) {
    cat(">>> [task 7] Step 1/6: OPEN-PROM run (link2MAgPIE=off)\n")
    extra <- Sys.getenv("OPENPROM_EXTRA_FLAGS")
    cmd1 <- paste(gams, "main.gms --DevMode=0 --GenerateInput=off --link2MAgPIE=off",
                  extra, "-logOption 4 -AsyncSolLst 1 -Idir=./data 2>&1")
    if (.Platform$OS.type == "unix") {
      system(paste0("sh -c ", shQuote(cmd1)))
    } else {
      shell(cmd1)
    }
    if (!isRunSuccessful("modelstat.txt"))
      stop("[task 7] First OPEN-PROM run failed. Aborting soft-link.")
    file.copy(file.path(openPromRun, "blabla.gdx"),
              file.path(openPromRun, "blabla_round1.gdx"),
              overwrite = TRUE)
  } else {
    cat(">>> [task 7] Step 1/6: SKIPPED (reusing existing round-1 result)\n")
    if (!file.exists(file.path(openPromRun, "blabla_round1.gdx"))) {
      srcGdx <- file.path(openPromRun, "blabla.gdx")
      if (!file.exists(srcGdx))
        stop("[task 7] Existing run folder has neither blabla_round1.gdx nor blabla.gdx: ", openPromRun)
      file.copy(srcGdx, file.path(openPromRun, "blabla_round1.gdx"), overwrite = FALSE)
    }
  }
  openPromGdx <- file.path(openPromRun, "blabla_round1.gdx")

  # ---- Step 2: OPEN-PROM -> MAgPIE (couplePromToMagpie) ----
  cat(">>> [task 7] Step 2/6: couplePromToMagpie() -> ", couplingMif, "\n")
  library(postprom)
  couplePromToMagpie(
    gdxPath    = openPromGdx,
    outMifPath = couplingMif,
    scenario   = sceName
  )

  # ---- Step 3: MAgPIE run ----
  cat(">>> [task 7] Step 3/6: MAgPIE run\n")
  setwd(magpieRoot)
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
  if (magpie_exit != 0) {
    setwd(openPromRun)
    stop("[task 7] MAgPIE run failed with exit code ", magpie_exit, ".")
  }
  magpieOutDirs   <- list.dirs("output", recursive = FALSE)
  latestMagpieRun <- magpieOutDirs[which.max(file.info(magpieOutDirs)$mtime)]
  magpieReport    <- file.path(normalizePath(latestMagpieRun, winslash = "/"), "report.mif")

  # ---- Step 4: MAgPIE -> OPEN-PROM (coupleMagpieToProm) ----
  cat(">>> [task 7] Step 4/6: coupleMagpieToProm()\n")
  setwd(openPromRun)
  coupleMagpieToProm(
    reportMifPath       = magpieReport,
    outCsvPath          = file.path(openPromRun, "iPrices_magpie.csv"),
    outEmissionsMifPath = file.path(openPromRun, "iEmissions_magpie.mif"),
    gdxPath             = openPromGdx,
    scenario            = sceName
  )

  # ---- Step 5: OPEN-PROM rerun (link2MAgPIE=on) ----
  cat(">>> [task 7] Step 5/6: OPEN-PROM run (link2MAgPIE=on)\n")
  extra <- Sys.getenv("OPENPROM_EXTRA_FLAGS")
  cmd2 <- paste(gams, "main.gms --DevMode=0 --GenerateInput=off --link2MAgPIE=on",
                extra, "-logOption 4 -AsyncSolLst 1 -Idir=./data 2>&1")
  if (.Platform$OS.type == "unix") {
    system(paste0("sh -c ", shQuote(cmd2)))
  } else {
    shell(cmd2)
  }

  # ---- Step 6: reportOutput + sync ----
  if (withRunFolder && withReport) {
    cat(">>> [task 7] Step 6/6: reportOutput.R\n")
    run_path <- getwd()
    setwd("../../")
    system(paste0("Rscript ./scripts/tasks/reportOutput.R ", run_path))
    setwd(run_path)
  }
  if (withRunFolder && withSync) syncRun()
}
