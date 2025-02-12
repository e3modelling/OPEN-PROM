reportCapacityElectricity <- function(regs) {
  
  # add model OPEN-PROM data electricity capacity
  VCapElec2 <- readGDX('./blabla.gdx', "VCapElec2", field = 'l')[regs, , ]
  
  PGALLtoEF <- readGDX('./blabla.gdx', "PGALLtoEF")
  names(PGALLtoEF) <- c("PGALL", "EF")
  
  add_LGN <- as.data.frame(PGALLtoEF[which(PGALLtoEF[, 2] == "LGN"), 1])
  add_LGN["EF"] <- "Lignite"
  names(add_LGN) <- c("PGALL", "EF")
  
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
  
  VCapElec2_LGN <- VCapElec2
  # aggregate to reporting fuel categories
  VCapElec2 <- toolAggregate(VCapElec2[,,PGALLtoEF[["PGALL"]]], dim = 3,rel = PGALLtoEF,from = "PGALL", to = "EF")
  VCapElec2_LGN <- toolAggregate(VCapElec2_LGN[,,add_LGN[["PGALL"]]], dim = 3,rel = add_LGN,from = "PGALL", to = "EF")
  
  getItems(VCapElec2, 3) <- paste0("Capacity|Electricity|", getItems(VCapElec2, 3))
  
  getItems(VCapElec2_LGN, 3) <- paste0("Capacity|Electricity|", getItems(VCapElec2_LGN, 3))
  
  magpie_object <- NULL
  VCapElec2_LGN <- add_dimension(VCapElec2_LGN, dim = 3.2, add = "unit", nm = "GW")
  magpie_object <- mbind(magpie_object, VCapElec2_LGN)
  
  VCapElec2 <- add_dimension(VCapElec2, dim = 3.2, add = "unit", nm = "GW")
  magpie_object <- mbind(magpie_object, VCapElec2)
  
  # electricity production
  VCapElec2_total <- dimSums(VCapElec2, dim = 3, na.rm = TRUE)
  
  getItems(VCapElec2_total, 3) <- "Capacity|Electricity"
  
  VCapElec2_total <- add_dimension(VCapElec2_total, dim = 3.2, add = "unit", nm = "GW")
  magpie_object <- mbind(magpie_object, VCapElec2_total)
  
  return(magpie_object)
}
