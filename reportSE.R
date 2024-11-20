reportSE <- function(regs) {
  
  # add model OPEN-PROM data electricity production
  VProdElec <- readGDX('./blabla.gdx', "VProdElec", field = 'l')[regs, , ]
  VProdElec <-as.quitte(VProdElec) %>% as.magpie()
  
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
  
  # aggregateto reporting fuel categories
  VProdElec <- toolAggregate(VProdElec[,,PGALLtoEF[["PGALL"]]], dim = 3,rel = PGALLtoEF,from = "PGALL", to = "EF")
  
  getItems(VProdElec, 3) <- paste0("Secondary Energy|Electricity|", getItems(VProdElec, 3))
  
  # write data in mif file
  write.report(VProdElec[,,],file="reporting.mif",model="OPEN-PROM",append=TRUE,unit="TWh",scenario=scenario_name)
  
  # electricity production
  VProdElec_total <- dimSums(VProdElec, dim = 3, na.rm = TRUE)
  
  getItems(VProdElec_total, 3) <- "Secondary Energy|Electricity"
  
  # write data in mif file
  write.report(VProdElec_total[,,],file="reporting.mif",append=TRUE,model="OPEN-PROM",unit="TWh",scenario=scenario_name)
  
  }
