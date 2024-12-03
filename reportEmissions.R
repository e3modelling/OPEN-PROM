reportEmissions <- function(regs) {
  
  iCo2EmiFac <- readGDX('./blabla.gdx', "iCo2EmiFac")[regs, , ]
  VConsFuel <- readGDX('./blabla.gdx', "VConsFuel", field = 'l')[regs, , ]
  VInpTransfTherm <- readGDX('./blabla.gdx', "VInpTransfTherm", field = 'l')[regs, , ]
  VTransfInputDHPlants <- readGDX('./blabla.gdx', "VTransfInputDHPlants", field = 'l')[regs, , ]
  VConsFiEneSec <- readGDX('./blabla.gdx', "VConsFiEneSec", field = 'l')[regs, , ]
  VDemFinEneTranspPerFuel <- readGDX('./blabla.gdx', "VDemFinEneTranspPerFuel", field = 'l')[regs, , ]
  VProdElec <- readGDX('./blabla.gdx', "VProdElec", field = 'l')[regs, , ]
  iPlantEffByType <- readGDX('./blabla.gdx', "iPlantEffByType")[regs, , ]
  iCO2CaptRate <- readGDX('./blabla.gdx', "iCO2CaptRate")[regs, , ]
  
  # Link between Model Subsectors and Fuels
  
  sets4 <- readGDX('./blabla.gdx', "SECTTECH")
  
  EFtoEFS <- readGDX('./blabla.gdx', "EFtoEFS")
  
  IND <- readGDX('./blabla.gdx', "INDDOM")
  IND <- as.data.frame(IND)
  
  map_INDDOM <- sets4 %>% filter(SBS %in% IND[,1])
  
  map_INDDOM <- filter(map_INDDOM, EF != "")
  
  qINDDOM <- left_join(map_INDDOM, EFtoEFS, by = "EF")
  qINDDOM <- select((qINDDOM), -c(EF))
  
  qINDDOM <- unique(qINDDOM)
  names(qINDDOM) <- sub("EFS", "SECTTECH", names(qINDDOM))
  
  qINDDOM <- paste0(qINDDOM[["SBS"]], ".", qINDDOM[["SECTTECH"]])
  INDDOM <- as.data.frame(qINDDOM)
  
  PGEF <- readGDX('./blabla.gdx', "PGEF")
  PGEF <- as.data.frame(PGEF)
  
  # final consumption
  sum1 <- iCo2EmiFac[,,INDDOM[, 1]] * VConsFuel[,,INDDOM[, 1]]
  sum1 <- dimSums(sum1, 3, na.rm = TRUE)
  # input to power generation sector
  sum2 <- VInpTransfTherm[,,PGEF[,1]]*iCo2EmiFac[,,"PG"][,,PGEF[,1]]
  sum2 <- dimSums(sum2, 3, na.rm = TRUE)
  # input to district heating plants
  sum3 <- VTransfInputDHPlants * iCo2EmiFac[,,"PG"][,,getItems(VTransfInputDHPlants,3)]
  sum3 <- dimSums(sum3, 3, na.rm = TRUE)
  # consumption of energy branch
  sum4 <- VConsFiEneSec * iCo2EmiFac[,,"PG"][,,getItems(VConsFiEneSec,3)]
  sum4 <- dimSums(sum4, 3, na.rm = TRUE)
  
  TRANSE <- readGDX('./blabla.gdx', "TRANSE")
  TRANSE <- as.data.frame(TRANSE)
  
  map_TRANSECTOR <- sets4 %>% filter(SBS %in% TRANSE[,1])
  map_TRANSECTOR <- paste0(map_TRANSECTOR[["SBS"]], ".", map_TRANSECTOR[["EF"]])
  map_TRANSECTOR <- as.data.frame(map_TRANSECTOR)
  
  sum5 <- VDemFinEneTranspPerFuel[,,map_TRANSECTOR[, 1]] * iCo2EmiFac[,,map_TRANSECTOR[, 1]]
  # transport
  sum5 <- dimSums(sum5, 3, na.rm = TRUE)
  
  PGALLtoEF <- readGDX('./blabla.gdx', "PGALLtoEF")
  PGALLtoEF <- as.data.frame(PGALLtoEF)
  names(PGALLtoEF) <- c("PGALL", "EF")
  
  CCS <- readGDX('./blabla.gdx', "CCS")
  CCS <- as.data.frame(CCS)
  
  CCS <- PGALLtoEF[PGALLtoEF$PGALL %in% CCS$CCS, ]
  
  var_16 <- VProdElec[,,CCS[,1]] * 0.086 / iPlantEffByType[,,CCS[,1]] * iCo2EmiFac[,,"PG"][,,CCS[,2]] * iCO2CaptRate[,,CCS[,1]]
  # CO2 captured by CCS plants in power generation
  sum6 <- dimSums(var_16,dim=3, na.rm = TRUE) 
  
  SECTTECH2 <- sets4 %>% filter(SBS %in% c("BU"))
  SECTTECH2 <- paste0(SECTTECH2[["SBS"]], ".", SECTTECH2[["EF"]])
  SECTTECH2 <- as.data.frame(SECTTECH2)
  # Bunkers
  sum7 <- iCo2EmiFac[,,SECTTECH2[,1]] * VConsFuel[,,SECTTECH2[,1]]
  sum7 <- dimSums(sum7,dim=3, na.rm = TRUE)
  
  total_CO2 <- sum1 + sum2 + sum3 + sum4 + sum5 - sum6 + sum7
  
  getItems(total_CO2, 3) <- "Emissions|CO2"
  
  # write data in mif file
  write.report(total_CO2[,,],file="reporting.mif",model="OPEN-PROM",unit = "Mt CO2/yr",append=TRUE,scenario=scenario_name)
 
  # Extra Emissions
  # Emissions|CO2|Energy|Demand|Industry
  
  INDSE <- readGDX('./blabla.gdx', "INDSE")
  INDSE <- as.data.frame(INDSE)
  
  map_INDSE <- sets4 %>% filter(SBS %in% INDSE[,1])
  
  map_INDSE <- filter(map_INDSE, EF != "")
  
  qINDSE <- left_join(map_INDSE, EFtoEFS, by = "EF")
  qINDSE <- select((qINDSE), -c(EF))
  
  qINDSE <- unique(qINDSE)
  names(qINDSE) <- sub("EFS", "SECTTECH", names(qINDSE))
  
  qINDSE <- paste0(qINDSE[["SBS"]], ".", qINDSE[["SECTTECH"]])
  INDSE <- as.data.frame(qINDSE)
  
  # final consumption
  sum_INDSE <- iCo2EmiFac[,,INDSE[, 1]] * VConsFuel[,,INDSE[, 1]]
  sum_INDSE <- dimSums(sum_INDSE, 3, na.rm = TRUE)
  
  getItems(sum_INDSE, 3) <- "Emissions|CO2|Energy|Demand|Industry"
  
  # write data in mif file
  write.report(sum_INDSE[,,],file="reporting.mif",model="OPEN-PROM",unit = "Mt CO2/yr",append=TRUE,scenario=scenario_name)
  
  # Emissions|CO2|Energy|Demand|Residential and Commercial
  
  DOMSE <- readGDX('./blabla.gdx', "DOMSE")
  DOMSE <- as.data.frame(DOMSE)
  
  map_DOMSE <- sets4 %>% filter(SBS %in% DOMSE[,1])
  
  map_DOMSE <- filter(map_DOMSE, EF != "")
  
  qDOMSE <- left_join(map_DOMSE, EFtoEFS, by = "EF")
  qDOMSE <- select((qDOMSE), -c(EF))
  
  qDOMSE <- unique(qDOMSE)
  names(qDOMSE) <- sub("EFS", "SECTTECH", names(qDOMSE))
  
  qDOMSE <- paste0(qDOMSE[["SBS"]], ".", qDOMSE[["SECTTECH"]])
  DOMSE <- as.data.frame(qDOMSE)
  
  # final consumption
  sum_DOMSE <- iCo2EmiFac[,,DOMSE[, 1]] * VConsFuel[,,DOMSE[, 1]]
  sum_DOMSE <- dimSums(sum_DOMSE, 3, na.rm = TRUE)
  
  getItems(sum_DOMSE, 3) <- "Emissions|CO2|Energy|Demand|Residential and Commercial"
  
  # write data in mif file
  write.report(sum_DOMSE[,,],file="reporting.mif",model="OPEN-PROM",unit = "Mt CO2/yr",append=TRUE,scenario=scenario_name)
  
  # Emissions|CO2|Energy|Demand|Transportation
  sum_TRANSE <- sum5 # transport
  
  getItems(sum_TRANSE, 3) <- "Emissions|CO2|Energy|Demand|Transportation"
  
  # write data in mif file
  write.report(sum_TRANSE[,,],file="reporting.mif",model="OPEN-PROM",unit = "Mt CO2/yr",append=TRUE,scenario=scenario_name)
  
  # Emissions|CO2|Energy|Demand|Bunkers
  sum_Bunkers <- sum7 # Bunkers
  
  getItems(sum_Bunkers, 3) <- "Emissions|CO2|Energy|Demand|Bunkers"
  
  # write data in mif file
  write.report(sum_Bunkers[,,],file="reporting.mif",model="OPEN-PROM",unit = "Mt CO2/yr",append=TRUE,scenario=scenario_name)
  
  # Emissions|CO2|Energy|Supply
  # input to power generation sector, sum2
  # input to district heating plants, sum3
  # consumption of energy branch, sum4
  # CO2 captured by CCS plants in power generation, sum6
  sum_Supply <- sum2 + sum3 + sum4 - sum6
  
  getItems(sum_Supply, 3) <- "Emissions|CO2|Energy|Supply"

  # write data in mif file
  write.report(sum_Supply[,,],file="reporting.mif",model="OPEN-PROM",unit = "Mt CO2/yr",append=TRUE,scenario=scenario_name)
  
  # Emissions|CO2|Cumulated
  
  Cumulated <- as.quitte(total_CO2)
  
  Cumulated <- Cumulated %>% group_by(region) %>% mutate(value = cumsum(value))
  
  Cumulated <- as.data.frame(Cumulated)
  
  Cumulated <- as.quitte(Cumulated) %>% as.magpie()
  
  getItems(Cumulated, 3) <- "Emissions|CO2|Cumulated"
  
  Cumulated <- Cumulated /1000
  
  # write data in mif file
  write.report(Cumulated,file="reporting.mif",model="OPEN-PROM",unit = "Gt CO2",append=TRUE,scenario=scenario_name)
  
   }