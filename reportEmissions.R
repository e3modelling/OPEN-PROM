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
  sets4 <- toolreadSets("sets.gms", "SECTTECH")
  sets4[6,] <- paste0(sets4[6,] , sets4[7,])
  sets4 <- sets4[ - c(7),,drop = FALSE]
  sets4[7,] <- paste0(sets4[7,] , sets4[8,], sets4[9,])
  sets4 <- sets4[ - c(8, 9),,drop = FALSE]
  sets4 <- separate_wider_delim(sets4,cols = 1, delim = ".", names = c("SBS","EF"))
  sets4[["EF"]] <- sub("\\(","",sets4[["EF"]])
  sets4[["EF"]] <- sub("\\)","",sets4[["EF"]])
  sets4[["SBS"]] <- sub("\\(","",sets4[["SBS"]])
  sets4[["SBS"]] <- sub("\\)","",sets4[["SBS"]])
  sets4 <- separate_rows(sets4,EF)
  sets4 <- separate_rows(sets4,SBS)
  sets4 <- filter(sets4, EF != "")
  
  EFtoEFS <- toolreadSets("sets.gms", "EFtoEFS")
  EFtoEFS <- as.data.frame(EFtoEFS)
  EFtoEFS <- separate_wider_delim(EFtoEFS,cols = 1, delim = ".", names = c("EF","EFS"))
  EFtoEFS[["EF"]] <- sub("\\(","",EFtoEFS[["EF"]])
  EFtoEFS[["EF"]] <- sub("\\)","",EFtoEFS[["EF"]])
  EFtoEFS <- EFtoEFS %>% separate_longer_delim(c(EF, EFS), delim = ",")
  
  IND <- toolreadSets("sets.gms", "INDDOM")
  IND <- unlist(strsplit(IND[, 1], ","))
  IND <- as.data.frame(IND)
  
  map_INDDOM <- sets4 %>% filter(SBS %in% IND[,1])
  
  map_INDDOM <- filter(map_INDDOM, EF != "")
  
  qINDDOM <- left_join(map_INDDOM, EFtoEFS, by = "EF")
  qINDDOM <- select((qINDDOM), -c(EF))
  
  qINDDOM <- unique(qINDDOM)
  names(qINDDOM) <- sub("EFS", "SECTTECH", names(qINDDOM))
  
  qINDDOM <- paste0(qINDDOM[["SBS"]], ".", qINDDOM[["SECTTECH"]])
  INDDOM <- as.data.frame(qINDDOM)
  
  PGEF <- toolreadSets("sets.gms", "PGEF")
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
  
  TRANSE <- toolreadSets("sets.gms", "TRANSE")
  TRANSE <- unlist(strsplit(TRANSE[, 1], ","))
  TRANSE <- as.data.frame(TRANSE)
  
  map_TRANSECTOR <- sets4 %>% filter(SBS %in% TRANSE[,1])
  map_TRANSECTOR <- paste0(map_TRANSECTOR[["SBS"]], ".", map_TRANSECTOR[["EF"]])
  map_TRANSECTOR <- as.data.frame(map_TRANSECTOR)
  
  sum5 <- VDemFinEneTranspPerFuel[,,map_TRANSECTOR[, 1]] * iCo2EmiFac[,,map_TRANSECTOR[, 1]]
  # transport
  sum5 <- dimSums(sum5, 3, na.rm = TRUE)
  
  PGALLtoEF <- toolreadSets("sets.gms", "PGALLtoEF")
  PGALLtoEF <- as.data.frame(PGALLtoEF)
  PGALLtoEF <- separate_wider_delim(PGALLtoEF,cols = 1, delim = ".", names = c("PGALL","EF"))
  PGALLtoEF[["PGALL"]] <- sub("\\(","",PGALLtoEF[["PGALL"]])
  PGALLtoEF[["PGALL"]] <- sub("\\)","",PGALLtoEF[["PGALL"]])
  PGALLtoEF <- separate_rows(PGALLtoEF,PGALL)
  
  CCS <- toolreadSets("sets.gms", "CCS")
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
  
  getItems(total_CO2, 3) <- paste0("Emissions|CO2")
  
  total_CO2_GLO <- dimSums(total_CO2, 1)
  getItems(total_CO2_GLO, 1) <- "World"
  total_CO2 <- mbind(total_CO2, total_CO2_GLO)
  
  # write data in mif file
  write.report(total_CO2[,,],file="reporting.mif",model="OPEN-PROM",unit = "Mt CO2/yr",append=TRUE,scenario=scenario_name)
 
  # Emissions|CO2|Cumulated
  
  Cumulated <- as.quitte(total_CO2)
  
  Cumulated <- Cumulated %>% group_by(region) %>% mutate(value = cumsum(value))
  
  Cumulated <- as.data.frame(Cumulated)
  
  Cumulated <- as.quitte(Cumulated) %>% as.magpie()
  
  getItems(Cumulated, 3) <- paste0("Emissions|CO2|Cumulated")
  
  Cumulated <- Cumulated /1000
  
  # write data in mif file
  write.report(Cumulated,file="reporting.mif",model="OPEN-PROM",unit = "Gt CO2",append=TRUE,scenario=scenario_name)
  
   }