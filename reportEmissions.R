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
  
  EFtoEFS <- toolreadSets("sets.gms", "EFtoEFS")
  EFtoEFS <- as.data.frame(EFtoEFS)
  EFtoEFS <- separate_wider_delim(EFtoEFS,cols = 1, delim = ".", names = c("EF","EFS"))
  EFtoEFS[["EF"]] <- sub("\\(","",EFtoEFS[["EF"]])
  EFtoEFS[["EF"]] <- sub("\\)","",EFtoEFS[["EF"]])
  EFtoEFS <- EFtoEFS %>% separate_longer_delim(c(EF, EFS), delim = ",")
  
  SECTTECH <- toolreadSets("sets.gms", "SECTTECH")
  
  SECTTECH <- SECTTECH[c(8,9,10), 1]
  SECTTECH[1] <- gsub("\\.", ",", SECTTECH[1])
  SECTTECH <- unlist(strsplit(SECTTECH, ","))
  SECTTECH <- SECTTECH[c(4:29)]
  SECTTECH <- gsub("\\(|\\)", "", SECTTECH)
  SECTTECH <- as.data.frame(SECTTECH)
  
  SECTTECH <- SECTTECH %>% 
    mutate(across(where(is.character), str_remove_all, pattern = fixed(" ")))
  
  SECTTECH <- as.data.frame(SECTTECH)
  
  names(SECTTECH) <- sub("SECTTECH", "EF", names(SECTTECH))
  qx <- left_join(SECTTECH, EFtoEFS, by = "EF")
  qx <- select((qx), -c(EF))
  
  SECTTECH <- unique(qx)
  names(SECTTECH) <- sub("EFS", "SECTTECH", names(SECTTECH))
  
  IND <- toolreadSets("sets.gms", "INDDOM")
  IND <- unlist(strsplit(IND[, 1], ","))
  IND <- as.data.frame(IND)
  INDDOM <- NULL
  for (y in 1:nrow(IND)) {
    p <- paste(IND[y,1], ".", SECTTECH[c(1:2, 4:12), 1])
    p <- as.data.frame(p)
    p <- p %>% 
      mutate(across(where(is.character), str_remove_all, pattern = fixed(" ")))
    INDDOM <- rbind(INDDOM, p)
  }
  
  for (y in 11:nrow(IND)) {
    p <- paste(IND[y,1], ".", SECTTECH[c(3, 13), 1])
    p <- as.data.frame(p)
    p <- p %>%
      mutate(across(where(is.character), str_remove_all, pattern = fixed(" ")))
    INDDOM <- rbind(INDDOM, p)
  }
  
  INDDOM <- as.data.frame(INDDOM)
  
  PGEF <- toolreadSets("sets.gms", "PGEF")
  PGEF <- as.data.frame(PGEF)
  
  sum1 <- iCo2EmiFac[,,INDDOM[, 1]] * VConsFuel[,,INDDOM[, 1]]
  sum1 <- dimSums(sum1, 3, na.rm = TRUE)
  
  sum2 <- VInpTransfTherm[,,PGEF[,1]]*iCo2EmiFac[,,"PG"][,,PGEF[,1]]
  sum2 <- dimSums(sum2, 3, na.rm = TRUE)
  
  sum3 <- VTransfInputDHPlants * iCo2EmiFac[,,"PG"][,,getItems(VTransfInputDHPlants,3)]
  sum3 <- dimSums(sum3, 3, na.rm = TRUE)
  
  sum4 <- VConsFiEneSec * iCo2EmiFac[,,"PG"][,,getItems(VConsFiEneSec,3)]
  sum4 <- dimSums(sum4, 3, na.rm = TRUE)
  
  PC <- toolreadSets("sets.gms", "SECTTECH")
  PC <- PC[1, 1]
  PC <- regmatches(PC, gregexpr("(?<=\\().*?(?=\\))", PC, perl=T))[[1]]
  PC <- unlist(strsplit(PC, ","))
  PC <- as.data.frame(PC)
  PC <- paste("PC", ".", PC[,1])
  PC <- as.data.frame(PC)
  PC <- PC %>% 
    mutate(across(where(is.character), str_remove_all, pattern = fixed(" ")))
  GU <- toolreadSets("sets.gms", "SECTTECH")
  GU <- GU[2, 1]
  GU <- regmatches(GU, gregexpr("(?<=\\().*?(?=\\))", GU, perl=T))[[1]]
  GU <- unlist(strsplit(GU, ","))
  GU <- as.data.frame(GU)
  GU <- paste("GU", ".", GU[,1])
  GU <- as.data.frame(GU)
  GU <- GU %>% 
    mutate(across(where(is.character), str_remove_all, pattern = fixed(" ")))
  PT <- toolreadSets("sets.gms", "SECTTECH")
  PT <- PT[3, 1]
  PT <- regmatches(PT, gregexpr("(?<=\\().*?(?=\\))", PT, perl=T))[[1]]
  PT <- unlist(strsplit(PT, ","))
  PT <- as.data.frame(PT)
  PT <- as.data.frame(PT[c(3:5),1])
  PT <- paste("PT", ".", PT[,1])
  PT <- as.data.frame(PT)
  PT <- PT %>% 
    mutate(across(where(is.character), str_remove_all, pattern = fixed(" ")))
  GT <- toolreadSets("sets.gms", "SECTTECH")
  GT <- GT[3, 1]
  GT <- regmatches(GT, gregexpr("(?<=\\().*?(?=\\))", GT, perl=T))[[1]]
  GT <- unlist(strsplit(GT, ","))
  GT <- as.data.frame(GT)
  GT <- as.data.frame(GT[c(3:5),1])
  GT <- paste("GT", ".", GT[,1])
  GT <- as.data.frame(GT)
  GT <- GT %>% 
    mutate(across(where(is.character), str_remove_all, pattern = fixed(" ")))
  PA <- as.data.frame("PA.KRS")
  GN <- toolreadSets("sets.gms", "SECTTECH")
  GN <- GN[5, 1]
  GN <- regmatches(GN, gregexpr("(?<=\\().*?(?=\\))", GN, perl=T))[[1]]
  GN <- unlist(strsplit(GN, ","))
  GN <- as.data.frame(GN)
  GN <- paste("GN", ".", GN[,1])
  GN <- as.data.frame(GN)
  GN <- GN %>% 
    mutate(across(where(is.character), str_remove_all, pattern = fixed(" ")))
  names(PC) <- "name"
  names(PA) <- "name"
  names(PT) <- "name"
  names(GU) <- "name"
  names(GT) <- "name"
  names(GN) <- "name"
  
  map_TRANSECTOR <- rbind(PT,GT,PA,PC,GU,GN)
  
  sum5 <- VDemFinEneTranspPerFuel[,,map_TRANSECTOR[, 1]] * iCo2EmiFac[,,map_TRANSECTOR[, 1]]
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
  sum6 <- dimSums(var_16,dim=3, na.rm = TRUE) 
  
  SECTTECH2 <- toolreadSets("sets.gms", "SECTTECH")
  SECTTECH2 <- SECTTECH2[11, 1]
  SECTTECH2 <- regmatches(SECTTECH2, gregexpr("(?<=\\().*?(?=\\))", SECTTECH2, perl=T))[[1]]
  SECTTECH2 <- unlist(strsplit(SECTTECH2, ","))
  SECTTECH2 <- as.data.frame(SECTTECH2)
  SECTTECH2 <- paste("BU", ".", SECTTECH2[,1])
  SECTTECH2 <- as.data.frame(SECTTECH2)
  SECTTECH2 <- SECTTECH2 %>% 
    mutate(across(where(is.character), str_remove_all, pattern = fixed(" ")))
  
  sum7 <- iCo2EmiFac[,,SECTTECH2[,1]] * VConsFuel[,,SECTTECH2[,1]]
  sum7 <- dimSums(sum7,dim=3, na.rm = TRUE)
  
  total_CO2 <- sum1 + sum2 + sum3 + sum4 + sum5 - sum6 + sum7
  
  getItems(total_CO2, 3) <- paste0("Emissions")
  
  # write data in mif file
  write.report(total_CO2[,,],file="reporting.mif",model="OPEN-PROM",unit="Mt CO2",append=TRUE,scenario=scenario_name)
 
  }