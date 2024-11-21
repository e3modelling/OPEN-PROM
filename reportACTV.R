reportACTV <- function(regs) {
  iActv <- readGDX('./blabla.gdx', "iActv")[regs, , ]
  getItems(iActv, 3) <- paste0("Actv", getItems(iActv, 3))
  # write data in mif file
  write.report(iActv[ , , ], file = "reporting.mif", model="OPEN-PROM", unit = "various", append = TRUE, scenario = scenario_name)
}