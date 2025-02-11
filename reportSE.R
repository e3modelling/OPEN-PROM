reportSE <- function(regs) {
  
  # add model OPEN-PROM data electricity production
  VProdElec <- readGDX('./blabla.gdx', "VProdElec", field = 'l')[regs, , ]
  VProdElec <-as.quitte(VProdElec) %>% as.magpie()
  
  PGALLtoEF <- readGDX('./blabla.gdx', "PGALLtoEF")
  names(PGALLtoEF) <- c("PGALL", "EF")
  
  add_LGN <- as.data.frame(PGALLtoEF[which(PGALLtoEF[, 2] == "LGN"), 1])
  add_LGN["EF"] <- "Lignite"
  names(add_LGN) <- c("PGALL","EF")
    
  PGALLtoEF$EF <- gsub("LGN", "Coal", PGALLtoEF$EF)
  PGALLtoEF$EF <- gsub("HCL", "Coal", PGALLtoEF$EF)
  PGALLtoEF$EF <- gsub("RFO", "Residual Fuel Oil", PGALLtoEF$EF)
  PGALLtoEF$EF <- gsub("GDO", "Oil", PGALLtoEF$EF)
  PGALLtoEF$EF <- gsub("NGS", "Gas", PGALLtoEF$EF)
  PGALLtoEF$EF <- gsub("BMSWAS", "Biomass", PGALLtoEF$EF)
  PGALLtoEF$EF <- gsub("NUC", "Nuclear", PGALLtoEF$EF)
  PGALLtoEF$EF <- gsub("HYD", "Hydro", PGALLtoEF$EF)
  PGALLtoEF$EF <- gsub("WND", "Wind", PGALLtoEF$EF)
  PGALLtoEF$EF <- gsub("SOL", "Solar", PGALLtoEF$EF)
  PGALLtoEF$EF <- gsub("GEO", "Geothermal", PGALLtoEF$EF)
  
  VProdElec_without_aggr <- VProdElec
  getItems(VProdElec_without_aggr, 3) <- paste0("Secondary Energy|Electricity|", getItems(VProdElec_without_aggr, 3))
  
  magpie_object <- NULL
  VProdElec_without_aggr <- add_dimension(VProdElec_without_aggr, dim = 3.2, add = "unit", nm = "TWh")
  magpie_object <- mbind(magpie_object, VProdElec_without_aggr)
  
  VProdElec_LGN <- VProdElec
  # aggregate to reporting fuel categories
  VProdElec <- toolAggregate(VProdElec[,,PGALLtoEF[["PGALL"]]], dim = 3,rel = PGALLtoEF,from = "PGALL", to = "EF")
  VProdElec_LGN <- toolAggregate(VProdElec_LGN[,,add_LGN[["PGALL"]]], dim = 3,rel = add_LGN,from = "PGALL", to = "EF")
  
  getItems(VProdElec_LGN, 3) <- paste0("Secondary Energy|Electricity|", getItems(VProdElec_LGN, 3))
  
  VProdElec_LGN <- add_dimension(VProdElec_LGN, dim = 3.2, add = "unit", nm = "TWh")
  magpie_object <- mbind(magpie_object, VProdElec_LGN)
  
  getItems(VProdElec, 3) <- paste0("Secondary Energy|Electricity|", getItems(VProdElec, 3))
  
  VProdElec <- add_dimension(VProdElec, dim = 3.2, add = "unit", nm = "TWh")
  magpie_object <- mbind(magpie_object, VProdElec)
  
  # electricity production
  VProdElec_total <- dimSums(VProdElec, dim = 3, na.rm = TRUE)
  
  getItems(VProdElec_total, 3) <- "Secondary Energy|Electricity"
  
  VProdElec_total <- add_dimension(VProdElec_total, dim = 3.2, add = "unit", nm = "TWh")
  magpie_object <- mbind(magpie_object, VProdElec_total)
  
  return(magpie_object)
  }
