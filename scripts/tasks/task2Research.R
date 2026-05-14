# Task 2: OPEN-PROM RESEARCH
# DevMode=0 (research mode). Single GAMS solve + reportOutput.
# One of the two batch-capable tasks (together with task 7).

runTask2 <- function() {
  scn <- jsonlite::fromJSON(Sys.getenv("OPENPROM_SCENARIO"))

  if (withRunFolder) createRunFolder(scn$scenario_name)
  saveMetadata(DevMode = 0)

  extra <- Sys.getenv("OPENPROM_EXTRA_FLAGS")
  base_cmd <- paste(
    gams, "main.gms --DevMode=0 --GenerateInput=off", extra,
    "-logOption 4 -AsyncSolLst 1 -Idir=./data 2>&1"
  )

  if (.Platform$OS.type == "unix") {
    system(base_cmd)
  } else {
    shell(paste0(base_cmd, " | tee full.log"))
  }

  if (withRunFolder && withReport) {
    run_path <- getwd()
    setwd("../../")
    cat("Executing the report output script\n")
    system(paste0("Rscript ./scripts/tasks/reportOutput.R ", run_path))
    setwd(run_path)
  }
  if (withRunFolder && withSync) syncRun()
}
