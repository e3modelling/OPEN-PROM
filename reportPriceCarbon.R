reportPriceCarbon <- function(regs) {
  
  VCarVal <- readGDX('./blabla.gdx', "VCarVal", field = "l")[regs, , ][,,"TRADE"]
  
  # complete names
  getItems(VCarVal, 3) <- "Price|Carbon"
  
  magpie_object <- NULL
  VCarVal <- add_dimension(VCarVal, dim = 3.2, add = "unit", nm = "US$2015/tn CO2")
  magpie_object <- mbind(magpie_object, VCarVal)
  
  return(magpie_object)
}