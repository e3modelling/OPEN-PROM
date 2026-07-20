# Task 1: OPEN-PROM DEV NEW DATA
# DevMode=1 + GenerateInput=on. After the solve, copy the freshly generated
# data/ and targets/ back to the repo root for use by subsequent runs.

runTask1 <- function() {
  scn <- jsonlite::fromJSON(Sys.getenv("OPENPROM_SCENARIO"))

  if (withRunFolder) createRunFolder(scn$scenario_name)
  saveMetadata(DevMode = 1)

  extra <- Sys.getenv("OPENPROM_EXTRA_FLAGS")
  base_cmd <- paste(
    gams, "main.gms --DevMode=1 --GenerateInput=on", extra,
    "-logOption 4 -AsyncSolLst 1 -Idir=./data 2>&1"
  )

  if (.Platform$OS.type == "unix") {
    system(base_cmd)
  } else {
    shell(base_cmd)
  }

  if (withRunFolder) {
    file.copy("data",    to = "../../", recursive = TRUE)  # copy generated data back to root
    file.copy("targets", to = "../../", recursive = TRUE)
    if (withSync) syncRun()
  }
}
