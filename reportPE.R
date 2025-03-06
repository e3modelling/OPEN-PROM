reportPE <- function(regs) {
  
  # add model OPEN-PROM data Primary production
  VProdPrimary <- readGDX('./blabla.gdx', "VProdPrimary", field = 'l')[regs, , ]
  
  sets <- readGDX('./blabla.gdx', "BALEF2EFS")
  names(sets) <- c("BAL", "EF")
  sets[["BAL"]] <- gsub("Gas fuels", "Gases", sets[["BAL"]])
  sets$BAL <- gsub("Solids", "Coal", sets$BAL)
  sets$BAL <- gsub("Crude oil and Feedstocks", "Oil", sets$BAL)
  sets$BAL <- gsub("Nuclear heat", "Nuclear", sets$BAL)
  sets$BAL <- gsub("Solar energy", "Solar", sets$BAL)
  sets$BAL <- gsub("Geothermal heat", "Geothermal", sets$BAL)
  sets[["BAL"]] <- gsub("Steam", "Heat", sets[["BAL"]])
  
  # aggregate from PROM fuels to reporting fuel categories
  VProdPrimary <- toolAggregate(VProdPrimary[ , , unique(sets$EF)], dim = 3, rel = sets, from = "EF", to = "BAL")
  getItems(VProdPrimary, 3) <- paste0("Primary Energy|", getItems(VProdPrimary, 3))
  
  l <- getNames(VProdPrimary) == "Primary Energy|Total"
  getNames(VProdPrimary)[l] <- "Primary Energy"
  
  magpie_object <- NULL
  VProdPrimary <- add_dimension(VProdPrimary, dim = 3.2, add = "unit", nm = "Mtoe")
  magpie_object <- mbind(magpie_object, VProdPrimary)
  
  return(magpie_object)
}
