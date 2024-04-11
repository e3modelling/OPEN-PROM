reportGDP <- function(regs) {
  
  iGDP <- readGDX('./blabla.gdx', "iGDP")[regs,,]
  getItems(iGDP, 3) <- "GDP"
  
  # write data in mif file
  write.report(iGDP[,,],file="reporting.mif",model="OPEN-PROM",unit="billion US$2015",append=TRUE,scenario=scenario_name)
}