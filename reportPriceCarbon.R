reportPriceCarbon <- function(regs) {
  
  VCarVal <- readGDX('./blabla.gdx', "VCarVal", field = "l")[regs, , ][,,"TRADE"]
  
  # complete names
  getItems(VCarVal, 3) <- "Price|Carbon"
  
  # write data in mif file
  write.report(VCarVal[,,],file="reporting.mif",model="OPEN-PROM",unit="US$2015/tn CO2",append=TRUE,scenario=scenario_name)
  
}