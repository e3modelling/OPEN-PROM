reportGDP <- function(regs) {
  
  iGDP <- readGDX('./blabla.gdx', "iGDP")[regs,,]
  getItems(iGDP, 3) <- "GDP|PPP"
  
  magpie_object <- NULL
  iGDP <- add_dimension(iGDP, dim = 3.2, add = "unit", nm = "billion US$2015/yr")
  magpie_object <- mbind(magpie_object, iGDP)
  
  return(magpie_object)
}