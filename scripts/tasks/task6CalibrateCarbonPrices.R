# Task 6: OPEN-PROM CALIBRATE CARBON PRICES
# Iteratively invoke GAMS via findCarbonPrice.R to find the carbon-price scaling
# factor that hits the configured emissions targets.

runTask6 <- function() {
  scn <- jsonlite::fromJSON(Sys.getenv("OPENPROM_SCENARIO"))

  saveMetadata(DevMode = 0)
  if (withRunFolder) createRunFolder(scn$scenario_name)

  run_path <- getwd()
  print(run_path)
  system(paste0("Rscript ./scripts/tasks/findCarbonPrice.R ", run_path))

  if (withRunFolder && withReport) {
    setwd("../../")
    cat("Executing the report output script\n")
    system(paste0("Rscript ./scripts/tasks/reportOutput.R ", run_path))
    setwd(run_path)
  }
  if (withRunFolder && withSync) syncRun()
}
