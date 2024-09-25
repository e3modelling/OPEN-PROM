reportPE <- function(regs) {
  
  # add model OPEN-PROM data Primary production
  VProdPrimary <- readGDX('./blabla.gdx', "VProdPrimary", field = 'l')[regs, , ]
  
  sets <- toolreadSets("sets.gms", "BALEF2EFS")
  sets[, 1] <- gsub("\"","",sets[, 1])
  sets <- separate_wider_delim(sets,cols = 1, delim = ".", names = c("BAL","EF"))
  sets[["EF"]] <- sub("\\(","",sets[["EF"]])
  sets[["EF"]] <- sub("\\)","",sets[["EF"]])
  sets <- separate_rows(sets,EF)
  sets$BAL <- gsub("Gas fuels", "Gas", sets$BAL)
  sets$BAL <- gsub("Solids", "Coal", sets$BAL)
  sets$BAL <- gsub("Crude oil and Feedstocks", "Oil", sets$BAL)
  sets$BAL <- gsub("Nuclear heat", "Nuclear", sets$BAL)
  sets$BAL <- gsub("Solar energy", "Solar", sets$BAL)
  sets$BAL <- gsub("Geothermal heat", "Geothermal", sets$BAL)
  
  # aggregate from PROM fuels to reporting fuel categories
  VProdPrimary <- toolAggregate(VProdPrimary[ , , unique(sets$EF)], dim = 3, rel = sets, from = "EF", to = "BAL")
  getItems(VProdPrimary, 3) <- paste0("Primary Energy|", getItems(VProdPrimary, 3))
  
  l <- getNames(VProdPrimary) == "Primary Energy|Total"
  getNames(VProdPrimary)[l] <- "Primary Energy"
  
  # write data in mif file
  write.report(VProdPrimary[,,],file="reporting.mif",model="OPEN-PROM",append=TRUE,unit="Mtoe",scenario=scenario_name)
  
}
