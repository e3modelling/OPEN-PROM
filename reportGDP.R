reportGDP <- function(regs) {
  
  iGDP <- readGDX('./blabla.gdx', "iGDP")[regs,,]
  getItems(iGDP, 3) <- "GDP|PPP"
  
  # write data in mif file
  write.report(iGDP[,, ], file = "reporting.mif", model = "OPEN-PROM", unit = "billion US$2015/yr", append = TRUE, scenario = scenario_name)

}