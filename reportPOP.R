reportPOP <- function(regs) {
  
  iPop <- readGDX('./blabla.gdx', "iPop")[regs,,]
  getItems(iPop, 3) <- "Population"
  
  # write data in mif file
  write.report(iPop[,, ], file = "reporting.mif", model = "OPEN-PROM", unit = "billion", append = TRUE, scenario = scenario_name)
  
}