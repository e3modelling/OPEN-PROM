reportCapacityElectricity <- function(regs) {
  
  # add model OPEN-PROM data electricity capacity
  VCapElec2 <- readGDX('./blabla.gdx', "VCapElec2", field = 'l')[regs, , ]
  
  PGALLtoEF <- toolreadSets("sets.gms", "PGALLtoEF")
  PGALLtoEF <- separate_wider_delim(PGALLtoEF,cols = 1, delim = ".", names = c("PGALL","EF"))
  PGALLtoEF[["EF"]] <- sub("\\(","",PGALLtoEF[["EF"]])
  PGALLtoEF[["EF"]] <- sub("\\)","",PGALLtoEF[["EF"]])
  PGALLtoEF <- separate_rows(PGALLtoEF, EF)
  PGALLtoEF <- separate_rows(PGALLtoEF, PGALL)
  PGALLtoEF <- filter(PGALLtoEF, EF != "")
  PGALLtoEF <- filter(PGALLtoEF, PGALL != "")
  PGALLtoEF$EF <- gsub("LGN", "Lignite", PGALLtoEF$EF)
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
  
  # aggregate to reporting fuel categories
  VCapElec2 <- toolAggregate(VCapElec2[,,PGALLtoEF[["PGALL"]]], dim = 3,rel = PGALLtoEF,from = "PGALL", to = "EF")
  
  getItems(VCapElec2, 3) <- paste0("Capacity|Electricity|", getItems(VCapElec2, 3))
  
  # write data in mif file
  write.report(VCapElec2[,,],file="reporting.mif",model="OPEN-PROM",append=TRUE,unit="GW",scenario=scenario_name)
  
  # electricity production
  VCapElec2_total <- dimSums(VCapElec2, dim = 3, na.rm = TRUE)
  
  getItems(VCapElec2_total, 3) <- "Capacity|Electricity"
  
  # write data in mif file
  write.report(VCapElec2_total[,,],file="reporting.mif",append=TRUE,model="OPEN-PROM",unit="GW",scenario=scenario_name)
  
}
