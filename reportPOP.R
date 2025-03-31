reportPOP <- function(regs) {
  
  iPop <- readGDX('./blabla.gdx', "iPop")[regs,,]
  getItems(iPop, 3) <- "Population"
  
  magpie_object <- NULL
  iPop <- add_dimension(iPop, dim = 3.2, add = "unit", nm = "billion")
  magpie_object <- mbind(magpie_object, iPop)
  
  return(magpie_object)
}