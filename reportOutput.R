# This script generates a mif file for comparison of OPEN-PROM data with MENA-EDS and ENERDATA
library(dplyr)
library(gdx)
library(quitte)
library(tidyr)
library(utils)
library(mrprom)
library(stringr)

mapping <- "regionmappingOP5.csv" # region mapping used for aggregating validation data (e.g. ENERDATA)
# this will be read in from a configuration file 

reportPrice <- function(regs) {
  
  #add model OPEN-PROM data Electricity prices
  VElecPriInduResConsu <- readGDX('./blabla.gdx', "VElecPriInduResConsu", field = 'l')[runCY, , ]
  #choose Industrial consumer /i/
  sets_i <- toolreadSets("sets.gms", "iSet")
  elec_prices_Industry <- VElecPriInduResConsu[,,sets_i[1,1]]
    # complete names
  getNames(elec_prices_Industry) <- "Electricity prices Industrial"
  #choose Residential consumer /r/
  sets_r <- toolreadSets("sets.gms", "rSet")
  elec_prices_Residential <- VElecPriInduResConsu[,,sets_r[1,1]]
    # complete names
  getNames(elec_prices_Residential) <- "Electricity prices Residential"
    #Combine Industrial and Residential OPEN-PROM
  elec_prices <- mbind(elec_prices_Industry, elec_prices_Residential)
  
  #add model MENA_EDS data (choosing the correct variable from MENA by use of the MENA-PROM mapping)
  elec_prices_MENA <- readSource("MENA_EDS", subtype =  map[map[["OPEN.PROM"]] == "VElecPriInduResConsu", "MENA.EDS"])
      # fix wrong region names in MENA
  getRegions(elec_prices_MENA) <- sub("MOR", "MAR", getRegions(elec_prices_MENA))
  # choose years and regions that both models have
  years <- intersect(getYears(elec_prices_MENA,as.integer=TRUE),getYears(VElecPriInduResConsu,as.integer=TRUE))
  menaregs <- intersect(getRegions(elec_prices_MENA),getRegions(VElecPriInduResConsu))
  #choose Industrial consumer /i/
  MENA_Industrial <- elec_prices_MENA[,years,sets_i[1,1]]
    # complete names
  getNames(MENA_Industrial) <- "Electricity prices Industrial"
  #choose Residential consumer /r/
  MENA_Residential <- elec_prices_MENA[,years,sets_r[1,1]]
  # complete names
  getNames(MENA_Residential) <- "Electricity prices Residential"
  #combine Industrial and Residential MENA
    elec_prices_MENA <- mbind(MENA_Industrial, MENA_Residential)
  
  # write data in mif file
  write.report(elec_prices[,,],file="reporting.mif",model="OPEN-PROM",unit="Euro2005/KWh",append=TRUE,scenario=scenario_name)
  write.report(elec_prices_MENA[menaregs,years,],file="reporting.mif",model="MENA-EDS",unit="Euro2005/KWh",append=TRUE,scenario=scenario_name)
  
  #filter ENERDATA by electricity
  ENERDATA_electricity <- readSource("ENERDATA", subtype =  "lectricity", convert = TRUE)
    #choose Industrial consumer /i/
  ENERDATA_Industrial <- ENERDATA_electricity[,,"Constant price per toe in US$ of electricity in industry (taxes incl).$15/toe"]
    #choose Residential consumer /r/
  ENERDATA_Residential<- ENERDATA_electricity[,,"Constant price per toe in US$ of electricity for households (taxes incl).$15/toe"]
  #fix units from toe to kwh
  ENERDATA_Industrial <- ENERDATA_Industrial / 11630
  ENERDATA_Residential <- ENERDATA_Residential / 11630
  #fix units from $15 to $05
  ENERDATA_Industrial <- ENERDATA_Industrial * 1.2136
  ENERDATA_Residential <- ENERDATA_Residential * 1.2136
  #fix units from $2005 to Euro2005
  ENERDATA_Industrial <- ENERDATA_Industrial / 1.24
  ENERDATA_Residential <- ENERDATA_Residential / 1.24
  
    # complete names
  getItems(ENERDATA_Industrial, 3) <- "Electricity prices Industrial"
  getItems(ENERDATA_Residential, 3) <- "Electricity prices Residential"
  #combine Industrial and Residential MENA
    elec_prices_ENERDATA <- mbind(ENERDATA_Industrial, ENERDATA_Residential)
    # choose years and regions that both models have
  year <- Reduce(intersect, list(getYears(elec_prices_MENA,as.integer=TRUE),getYears(elec_prices_ENERDATA,as.integer=TRUE),getYears(VElecPriInduResConsu,as.integer=TRUE)))
  #filter ENERDATA by years that both models have
    elec_prices_ENERDATA <- elec_prices_ENERDATA[, year,]
  # write data in mif file
  write.report(elec_prices_ENERDATA[intersect(getRegions(elec_prices_ENERDATA),regs),,],file="reporting.mif",model="ENERDATA",unit="Euro2005/KWh",append=TRUE,scenario=scenario_name)
  
  #add model OPEN-PROM data iFuelPrice
    FuelPrice_OPEN_PROM <- readGDX('./blabla.gdx', "iFuelPrice")
  PRICE_by_sector_and_EF <- FuelPrice_OPEN_PROM
    # complete names
  getItems(PRICE_by_sector_and_EF, 3.1) <- paste0("Fuel Price ", getItems(PRICE_by_sector_and_EF, 3.1))
  
  #add model MENA_EDS data (choosing the correct variable from MENA by use of the MENA-PROM mapping)
  #fix units from $2015/toe to k$2015/toe
  FuelPrice_MENA <- readSource("MENA_EDS", subtype =  map[map[["OPEN.PROM"]] == "iFuelPrice", "MENA.EDS"]) / 1000
  PRICE_by_sector_and_EF_MENA <- FuelPrice_MENA
    # fix wrong region names in MENA
  getRegions(PRICE_by_sector_and_EF_MENA) <- sub("MOR", "MAR", getRegions(PRICE_by_sector_and_EF_MENA)) # fix wrong region names in MENA
  # choose years and regions that both models have
  years <- intersect(getYears(PRICE_by_sector_and_EF_MENA,as.integer=TRUE),getYears(PRICE_by_sector_and_EF,as.integer=TRUE))
  menaregs <- intersect(getRegions(PRICE_by_sector_and_EF_MENA),getRegions(PRICE_by_sector_and_EF))
    # complete names
  getItems(PRICE_by_sector_and_EF_MENA, 3.1) <- paste0("Fuel Price ", getItems(PRICE_by_sector_and_EF_MENA, 3.1))
  
  #FuelPrice enerdata
  #fix units from $2015/toe to k$2015/toe
  FuelPrice_ENERDATA <- calcOutput(type = "IFuelPrice", aggregate = TRUE) / 1000
  PRICE_by_sector_and_EF_ENERDATA <- FuelPrice_ENERDATA
    # complete names
  getItems(PRICE_by_sector_and_EF_ENERDATA, 3.1) <- paste0("Fuel Price ", getItems(PRICE_by_sector_and_EF_ENERDATA, 3.1))
    # choose years that both models have
  year <- Reduce(intersect, list(getYears(PRICE_by_sector_and_EF_MENA,as.integer=TRUE),getYears(PRICE_by_sector_and_EF,as.integer=TRUE),getYears(PRICE_by_sector_and_EF_ENERDATA,as.integer=TRUE)))
  
  # write data in mif file
  write.report(PRICE_by_sector_and_EF[,,],file="reporting.mif",model="OPEN-PROM",unit="various",append=TRUE,scenario=scenario_name)
  write.report(PRICE_by_sector_and_EF_MENA[menaregs,years,],file="reporting.mif",model="MENA-EDS",unit="various",append=TRUE,scenario=scenario_name)
  write.report(PRICE_by_sector_and_EF_ENERDATA[intersect(regs,getRegions(PRICE_by_sector_and_EF_ENERDATA)),year,],file="reporting.mif",model="ENERDATA",unit="various",append=TRUE,scenario=scenario_name)
  
  #aggregation by SECTOR and EF
    PRICE_by_EF_OPEN_PROM <- dimSums(FuelPrice_OPEN_PROM, 3.1, na.rm = TRUE)
  PRICE_by_sector_OPEN_PROM <- dimSums(FuelPrice_OPEN_PROM, 3.2, na.rm = TRUE)
  PRICE_by_EF_MENA <- dimSums(FuelPrice_MENA, 3.1, na.rm = TRUE)
  PRICE_by_sector_MENA <- dimSums(FuelPrice_MENA, 3.2, na.rm = TRUE)
  PRICE_by_EF_ENERDATA <- dimSums(FuelPrice_ENERDATA, 3.1, na.rm = TRUE)
  PRICE_by_sector_ENERDATA <- dimSums(FuelPrice_ENERDATA, 3.2, na.rm = TRUE)
  PRICE_total_OPEN_PROM <- dimSums(FuelPrice_OPEN_PROM, na.rm = TRUE)
  PRICE_total_MENA <- dimSums(FuelPrice_MENA, na.rm = TRUE)
  PRICE_total_ENERDATA <- dimSums(FuelPrice_ENERDATA,3, na.rm = TRUE)
      
    # fix wrong region names in MENA
  getRegions(PRICE_by_EF_MENA) <- sub("MOR", "MAR", getRegions(PRICE_by_EF_MENA))
  getRegions(PRICE_by_sector_MENA) <- sub("MOR", "MAR", getRegions(PRICE_by_sector_MENA))
  getRegions(PRICE_total_MENA) <- sub("MOR", "MAR", getRegions(PRICE_total_MENA))
      
    # complete names
  getItems(PRICE_by_EF_OPEN_PROM, 3) <- paste0("Fuel Price ", getItems(PRICE_by_EF_OPEN_PROM, 3))
  getItems(PRICE_by_sector_OPEN_PROM, 3) <- paste0("Fuel Price ", getItems(PRICE_by_sector_OPEN_PROM, 3))
  getItems(PRICE_by_EF_MENA, 3) <- paste0("Fuel Price ", getItems(PRICE_by_EF_MENA, 3))
  getItems(PRICE_by_sector_MENA, 3) <- paste0("Fuel Price ", getItems(PRICE_by_sector_MENA, 3))
  getItems(PRICE_by_EF_ENERDATA, 3) <- paste0("Fuel Price ", getItems(PRICE_by_EF_ENERDATA, 3))
  getItems(PRICE_by_sector_ENERDATA, 3) <- paste0("Fuel Price ", getItems(PRICE_by_sector_ENERDATA, 3))
  getItems(PRICE_total_OPEN_PROM, 3) <- paste0("Fuel Price", getItems(PRICE_total_OPEN_PROM, 3))
  getItems(PRICE_total_MENA, 3) <- paste0("Fuel Price", getItems(PRICE_total_MENA, 3))
  getItems(PRICE_total_ENERDATA, 3) <- paste0("Fuel Price", getItems(PRICE_total_ENERDATA, 3))
  
  # write data in mif file
  write.report(PRICE_by_EF_OPEN_PROM[,,],file="reporting.mif",model="OPEN-PROM",unit="various",append=TRUE,scenario=scenario_name)
  write.report(PRICE_by_EF_MENA[,years,],file="reporting.mif",model="MENA-EDS",unit="various",append=TRUE,scenario=scenario_name)
  write.report(PRICE_by_EF_ENERDATA[,year,],file="reporting.mif",model="ENERDATA",unit="various",append=TRUE,scenario=scenario_name)
  
  write.report(PRICE_by_sector_OPEN_PROM[,,],file="reporting.mif",model="OPEN-PROM",unit="various",append=TRUE,scenario=scenario_name)
  write.report(PRICE_by_sector_MENA[,years,],file="reporting.mif",model="MENA-EDS",unit="various",append=TRUE,scenario=scenario_name)
  write.report(PRICE_by_sector_ENERDATA[,year,],file="reporting.mif",model="ENERDATA",unit="various",append=TRUE,scenario=scenario_name)
  
  write.report(PRICE_total_OPEN_PROM[,,],file="reporting.mif",model="OPEN-PROM",unit="various",append=TRUE,scenario=scenario_name)
  write.report(PRICE_total_MENA[,years,],file="reporting.mif",model="MENA-EDS",unit="various",append=TRUE,scenario=scenario_name)
  write.report(PRICE_total_ENERDATA[,year,],file="reporting.mif",model="ENERDATA",unit="various",append=TRUE,scenario=scenario_name)
}
reportEmissions <- function(regs) {
  iCo2EmiFac <- readGDX('./blabla.gdx', "iCo2EmiFac")[regs, , ]
  VConsFuel <- readGDX('./blabla.gdx', "VConsFuel", field = 'l')[regs, , ]
  VTransfInThermPowPls <- readGDX('./blabla.gdx', "VTransfInThermPowPls", field = 'l')[regs, , ]
  VTransfInputDHPlants <- readGDX('./blabla.gdx', "VTransfInputDHPlants", field = 'l')[regs, , ]
  VEnCons <- readGDX('./blabla.gdx', "VEnCons", field = 'l')[regs, , ]
  VDemTr <- readGDX('./blabla.gdx', "VDemTr", field = 'l')[regs, , ]
  VElecProd <- readGDX('./blabla.gdx', "VElecProd", field = 'l')[regs, , ]
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
  
  sum2 <- VTransfInThermPowPls[,,PGEF[,1]]*iCo2EmiFac[,,"PG"][,,PGEF[,1]]
  sum2 <- dimSums(sum2, 3, na.rm = TRUE)
  
  sum3 <- VTransfInputDHPlants * iCo2EmiFac[,,"PG"][,,getItems(VTransfInputDHPlants,3)]
  sum3 <- dimSums(sum3, 3, na.rm = TRUE)
  
  sum4 <- VEnCons * iCo2EmiFac[,,"PG"][,,getItems(VEnCons,3)]
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
  
  sum5 <- VDemTr[,,map_TRANSECTOR[, 1]] * iCo2EmiFac[,,map_TRANSECTOR[, 1]]
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
  
  var_16 <- VElecProd[,,CCS[,1]] * 0.086 / iPlantEffByType[,,CCS[,1]] * iCo2EmiFac[,,"PG"][,,CCS[,2]] * iCO2CaptRate[,,CCS[,1]]
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
  #total_CO2 <- sum1 + sum2 + sum3 + sum4 - sum6
  
  getItems(total_CO2, 3) <- paste0("Emissions")
  
  #add model MENA_EDS data (choosing the correct variable from MENA by use of the MENA-PROM mapping)
  MENA_iCo2EmiFac <- readSource("MENA_EDS", subtype =  map[map[["OPEN.PROM"]] == "iCo2EmiFac", "MENA.EDS"])
  MENA_VConsFuel <- readSource("MENA_EDS", subtype =  map[map[["OPEN.PROM"]] == "VConsFuel", "MENA.EDS"])
  MENA_VTransfInThermPowPls <- readSource("MENA_EDS", subtype =  map[map[["OPEN.PROM"]] == "VTransfInThermPowPls", "MENA.EDS"])
  MENA_VTransfInputDHPlants <- readSource("MENA_EDS", subtype =  map[map[["OPEN.PROM"]] == "VTransfInputDHPlants", "MENA.EDS"])
  MENA_VEnCons <- readSource("MENA_EDS", subtype =  map[map[["OPEN.PROM"]] == "VEnCons", "MENA.EDS"])
  MENA_VDemTr <- readSource("MENA_EDS", subtype =  map[map[["OPEN.PROM"]] == "VDemTr", "MENA.EDS"])
  MENA_VElecProd <- readSource("MENA_EDS", subtype =  map[map[["OPEN.PROM"]] == "VElecProd", "MENA.EDS"])
  MENA_iPlantEffByType <- readSource("MENA_EDS", subtype =  map[map[["OPEN.PROM"]] == "iPlantEffByType", "MENA.EDS"])
  MENA_iCO2CaptRate <- readSource("MENA_EDS", subtype =  map[map[["OPEN.PROM"]] == "iCO2CaptRate", "MENA.EDS"])
  
  MENA_sum1 <- MENA_iCo2EmiFac[,,INDDOM[, 1]] * MENA_VConsFuel[,,INDDOM[, 1]]
  MENA_sum1 <- dimSums(MENA_sum1, 3, na.rm = TRUE)
  
  MENA_sum2 <- MENA_VTransfInThermPowPls[,,PGEF[,1]]*MENA_iCo2EmiFac[,,"PG"][,,PGEF[,1]]
  MENA_sum2 <- dimSums(MENA_sum2, 3, na.rm = TRUE)
  
  MENA_sum3 <- MENA_VTransfInputDHPlants[,,] * MENA_iCo2EmiFac[,,"PG"][,,getItems(MENA_VTransfInputDHPlants,3)]
  MENA_sum3 <- dimSums(MENA_sum3, 3, na.rm = TRUE)
  
  MENA_sum4 <- MENA_VEnCons * MENA_iCo2EmiFac[,,"PG"][,,getItems(MENA_VEnCons,3)]
  MENA_sum4 <- dimSums(MENA_sum4, 3, na.rm = TRUE)
  
  MENA_sum5 <- MENA_VDemTr[,,map_TRANSECTOR[, 1]] * MENA_iCo2EmiFac[,,map_TRANSECTOR[, 1]]
  MENA_sum5 <- dimSums(MENA_sum5, 3, na.rm = TRUE)
  
  MENA_var_16 <- MENA_VElecProd[,,CCS[,1]] * 0.086 / MENA_iPlantEffByType[,,CCS[,1]] * MENA_iCo2EmiFac[,,"PG"][,,CCS[,2]] * MENA_iCO2CaptRate[,,CCS[,1]]
  MENA_sum6 <- dimSums(MENA_var_16,dim=3, na.rm = TRUE)
  
  MENA_sum7 <- MENA_iCo2EmiFac[,,SECTTECH2[,1]] * MENA_VConsFuel[,,SECTTECH2[,1]]
  MENA_sum7 <- dimSums(MENA_sum7,dim=3, na.rm = TRUE)
  
  MENA_SUM <- MENA_sum1 + MENA_sum2 + MENA_sum3 + MENA_sum4 + MENA_sum5 - MENA_sum6 + MENA_sum7
  #MENA_SUM <- MENA_sum1 + MENA_sum2 + MENA_sum3 + MENA_sum4 - MENA_sum6
  
  getItems(MENA_SUM, 3) <- paste0("Emissions")
  
  getRegions(MENA_SUM) <- sub("MOR", "MAR", getRegions(MENA_SUM))
  # choose years and regions that both models have
  years <- intersect(getYears(MENA_SUM,as.integer=TRUE),getYears(total_CO2,as.integer=TRUE))
  mregs <- intersect(getRegions(MENA_SUM),regs)
  getItems(MENA_SUM, 3.1) <- paste0("Emissions")
  
  # write data in mif file
  write.report(total_CO2[,,],file="reporting.mif",model="OPEN-PROM",unit="Mt CO2",append=TRUE,scenario=scenario_name)
  write.report(MENA_SUM[mregs,years,],file="reporting.mif",model="MENA-EDS",unit="Mt CO2",append=TRUE,scenario=scenario_name)
  #c("MAR","IND","USA","EGY","RWO")
      
  #filter ENERDATA by number 2
    number_2 <- readSource("ENERDATA", "2", convert = TRUE)
  CO2_emissions_ENERDATA <- number_2[,,"CO2 emissions from fuel combustion (sectoral approach).MtCO2"]
  
  year <- Reduce(intersect, list(getYears(MENA_SUM,as.integer=TRUE),getYears(total_CO2,as.integer=TRUE),getYears(CO2_emissions_ENERDATA,as.integer=TRUE)))
  
  getItems(CO2_emissions_ENERDATA, 3) <- paste0("Emissions")
  # write data in mif file
  write.report(CO2_emissions_ENERDATA[intersect(getRegions(CO2_emissions_ENERDATA),regs),year,],file="reporting.mif",model="ENERDATA",unit="Mt CO2",append=TRUE,scenario=scenario_name)
  
  a <- calcOutput(type = "CO2_emissions", aggregate = TRUE)
  getItems(a, 3) <- paste0("Emissions")
  write.report(a[intersect(getRegions(a),regs),c(year, 2022),],file="reporting.mif",model="EDGAR",unit="Mt CO2",append=TRUE,scenario=scenario_name)
  
  pik <- readSource("PIK", convert = TRUE)
  pik <- pik[,,"Energy.MtCO2.CO2"]
  getItems(pik, 3) <- paste0("Emissions")
  write.report(pik[intersect(getRegions(pik),regs),c(year, 2022),],file="reporting.mif",model="PIK",unit="Mt CO2",append=TRUE,scenario=scenario_name)
}
reportACTV <- function(regs) {
  iActv <- readGDX('./blabla.gdx', "iActv")[regs, , ]
  getItems(iActv, 3) <- paste0("Actv", getItems(iActv, 3))
  # write data in mif file
  write.report(iActv[ , , ], file = "reporting.mif", model="OPEN-PROM", unit = "various", append = TRUE, scenario = scenario_name)
}
reportGDP <- function(regs) {
  
  iGDP <- readGDX('./blabla.gdx', "iGDP")[regs,,]
  getItems(iGDP, 3) <- "GDP"
  
  # write data in mif file
  write.report(iGDP[,,],file="reporting.mif",model="OPEN-PROM",unit="billion US$2015",append=TRUE,scenario=scenario_name)
  return(iGDP)
}
reportFinalEnergy <- function(regs) {
  # read GAMS set used for reporting of Final Energy
  sets <- toolreadSets("sets.gms", "BALEF2EFS")
  sets[, 1] <- gsub("\"","",sets[, 1])
  sets <- separate_wider_delim(sets,cols = 1, delim = ".", names = c("BAL","EF"))
  sets[["EF"]] <- sub("\\(","",sets[["EF"]])
  sets[["EF"]] <- sub("\\)","",sets[["EF"]])
  sets <- separate_rows(sets,EF)
  sets$BAL <- gsub("Gas fuels", "Gases", sets$BAL)
  
  # add model OPEN-PROM data Total final energy consumnption (Mtoe)
  VFeCons <- readGDX('./blabla.gdx', "VFeCons", field = 'l')[regs, , ]
  # aggregate from PROM fuels to reporting fuel categories
  VFeCons <- toolAggregate(VFeCons[ , , unique(sets$EF)], dim = 3, rel = sets, from = "EF", to = "BAL")
  getItems(VFeCons, 3) <- paste0("Final Energy ", getItems(VFeCons, 3))
    
  #add model MENA_EDS data (choosing the correct variable from MENA by use of the MENA-PROM mapping)
  #Total final energy consumnption (Mtoe)
    MENA_EDS_VFeCons <- readSource("MENA_EDS", subtype =  map[map[["OPEN.PROM"]] == "VFeCons", "MENA.EDS"])
  getRegions(MENA_EDS_VFeCons) <- sub("MOR", "MAR", getRegions(MENA_EDS_VFeCons)) # fix wrong region names in MENA
  # choose years and regions that both models have
  years <- intersect(getYears(MENA_EDS_VFeCons,as.integer=TRUE),getYears(VFeCons,as.integer=TRUE))
  menaregs <- intersect(getRegions(MENA_EDS_VFeCons),regs)
  # aggregate from MENA fuels to reporting fuel categories
  MENA_EDS_VFeCons <- toolAggregate(MENA_EDS_VFeCons[,years,unique(sets$EF)],dim=3,rel=sets,from="EF",to="BAL")
  # complete names
  getItems(MENA_EDS_VFeCons, 3) <- paste0("Final Energy ", getItems(MENA_EDS_VFeCons, 3))
  
  # write data in mif file
  write.report(VFeCons[,,],file="reporting.mif",model="OPEN-PROM",unit="Mtoe",scenario=scenario_name)
  write.report(MENA_EDS_VFeCons[menaregs,years,],file="reporting.mif",model="MENA-EDS",unit="Mtoe",append=TRUE,scenario=scenario_name)
    
  #filter ENERDATA by consumption
  consumption_ENERDATA <- readSource("ENERDATA", subtype =  "consumption", convert = TRUE)[intersect(regs, getISOlist()), ,]
    
  # map of enerdata and balance fuel
  map_enerdata <- toolGetMapping(name = "enerdata-by-fuel.csv",
                                 type = "sectoral",
                                 where = "mrprom")
      
    # choose years that both models have
  year <- Reduce(intersect, list(getYears(MENA_EDS_VFeCons,as.integer=TRUE),getYears(consumption_ENERDATA,as.integer=TRUE),getYears(VFeCons,as.integer=TRUE)))
  #keep the variables from the map
  consumption_ENERDATA_map <- consumption_ENERDATA[, year, map_enerdata[, 1]]
  consumption_ENERDATA_map <- as.quitte(consumption_ENERDATA_map)
  names(map_enerdata) <- sub("ENERDATA", "variable", names(map_enerdata))
  #remove units
  map_enerdata[,1] <- sub("\\..*", "", map_enerdata[,1])
  #add a column with the fuels that match each variable of enerdata
  v <- left_join(consumption_ENERDATA_map, map_enerdata, by = "variable")
  v["variable"] <- paste0("Final Energy ", v$fuel)
  v <- filter(v, period %in% years)
  v <- select(v , -c("fuel"))
  v <- as.quitte(v)
  v <- as.magpie(v)
  # write data in mif file
  write.report(v[intersect(getRegions(v),regs),,],file="reporting.mif",model="ENERDATA",unit="Mtoe",append=TRUE,scenario=scenario_name)
  
  
  
  # Final Energy | "TRANSE" | "INDSE" | "DOMSE" | "NENSE"
  
  #Link between Model Subsectors and Fuels
  sets4 <- toolreadSets("sets.gms", "SECTTECH")
  sets4[6,] <- paste0(sets4[6,] , sets4[7,])
  sets4 <- sets4[ - c(7),,drop = FALSE]
  sets4[8,] <- paste0(sets4[8,] , sets4[9,], sets4[10,])
  sets4 <- sets4[ - c(8, 9),,drop = FALSE]
  sets4 <- separate_wider_delim(sets4,cols = 1, delim = ".", names = c("SBS","EF"))
  sets4[["EF"]] <- sub("\\(","",sets4[["EF"]])
  sets4[["EF"]] <- sub("\\)","",sets4[["EF"]])
  sets4[["SBS"]] <- sub("\\(","",sets4[["SBS"]])
  sets4[["SBS"]] <- sub("\\)","",sets4[["SBS"]])
  sets4 <- separate_rows(sets4,EF)
  sets4 <- separate_rows(sets4,SBS)
  
  sector <- c("TRANSE", "INDSE", "DOMSE", "NENSE")
  blabla_var <- c("VDemTr", "VConsFuel", "VConsFuel", "VConsFuel")
  for (y in 1 : length(sector)) {
    
    sets6 <- toolreadSets("sets.gms", sector[y])
    sets6 <- separate_rows(sets6, paste0(sector[y],"(DSBS)"))
    sets6 <- as.data.frame(sets6)
    var_gdx <- readGDX('./blabla.gdx', blabla_var[y], field = 'l')[regs, , ]
    var <- var_gdx[,,sets6[, 1]]
    
    map_subsectors <- sets4 %>% filter(SBS %in% as.character(sets6[, 1]))
    
    if (sector[y] == "DOMSE") {
      sets13 <- filter(sets4, EF != "")
      sets13 <- sets13 %>% filter(EF %in% getItems(var_gdx[,,sets6[, 1]],3.2))
      map_subsectors <- sets13 %>% filter(SBS %in% as.character(sets6[, 1]))
    }
    
    map_subsectors$EF = paste(map_subsectors$SBS, map_subsectors$EF, sep=".")
    
    var <- toolAggregate(var[,,unique(map_subsectors$EF)],dim=3,rel=map_subsectors,from="EF",to="SBS")
    getItems(var, 3) <- paste0("Final Energy ", sector[y]," ", getItems(var, 3))
    
    #add model MENA_EDS data (choosing the correct variable from MENA by use of the MENA-PROM mapping)
    MENA_EDS <- readSource("MENA_EDS", subtype =  map[map[["OPEN.PROM"]] == blabla_var[y], "MENA.EDS"])
    getRegions(MENA_EDS) <- sub("MOR", "MAR", getRegions(MENA_EDS)) # fix wrong region names in MENA
    # choose years and regions that both models have
    years <- intersect(getYears(MENA_EDS,as.integer=TRUE),getYears(var,as.integer=TRUE))
    
    a <- toolAggregate(MENA_EDS[,,unique(map_subsectors$EF)],dim=3,rel=map_subsectors,from="EF",to="SBS")
    getItems(a, 3) <- paste0("Final Energy ", sector[y]," ", getItems(a, 3))
    
    # write data in mif file
    write.report(var[,,],file="reporting.mif",model="OPEN-PROM",unit="Mtoe",append=TRUE,scenario=scenario_name)
    write.report(a[menaregs,years,],file="reporting.mif",model="MENA-EDS",unit="Mtoe",append=TRUE,scenario=scenario_name)
    
    #Final Energy by sector 
    sector_open <- dimSums(var, dim = 3, na.rm = TRUE)
    getItems(sector_open, 3) <- paste0("Final Energy ", sector[y])
    sector_mena <- dimSums(a, dim = 3, na.rm = TRUE)
    getItems(sector_mena, 3) <- paste0("Final Energy ", sector[y])
    
    # write data in mif file
    write.report(sector_open[,,],file="reporting.mif",model="OPEN-PROM",unit="Mtoe",append=TRUE,scenario=scenario_name)
    write.report(sector_mena[menaregs,years,],file="reporting.mif",model="MENA-EDS",unit="Mtoe",append=TRUE,scenario=scenario_name)
    
    #Energy Forms Aggregations
    sets5 <- toolreadSets("sets.gms", "EFtoEFA")
    sets5[5,] <- paste0(sets5[5,] , sets5[6,])
    sets5 <- sets5[ - 6,]
    sets5 <- as.data.frame(sets5)
    sets5 <- separate_wider_delim(sets5,cols = 1, delim = ".", names = c("EF","EFA"))
    sets5[["EF"]] <- sub("\\(","",sets5[["EF"]])
    sets5[["EF"]] <- sub("\\)","",sets5[["EF"]])
    sets5 <- separate_rows(sets5,EF)
    
    ELC <- toolreadSets("sets.gms", "ELCEF")
    #Add electricity, Hydrogen, Biomass and Waste
    sets5[nrow(sets5) + 1, ] <- ELC[1,1]
    sets5[nrow(sets5) + 1, ] <- "H2F"
    sets5[nrow(sets5) + 1, ] <- "BMSWAS"
    
    sets10 <- sets5 %>% filter(EF %in% getItems(var_gdx[,,sets6[, 1]],3.2))
    
    #Aggregate model OPEN-PROM by subsector and by energy form 
    var_by_energy_form <- toolAggregate(var_gdx[,,sets6[, 1]][,,as.character(unique(sets10$EF))],dim=3.2,rel=sets10,from="EF",to="EFA")
    
    #Aggregate model MENA_EDS by subsector and by energy form
    mena_by_energy_form <- toolAggregate(MENA_EDS[,,sets6[, 1]][,,as.character(unique(sets10$EF))],dim=3.2,rel=sets10,from="EF",to="EFA")
    
    #sector by subsector and by energy form
    var_by_subsector_by_energy_form <- var_by_energy_form
    getItems(var_by_subsector_by_energy_form, 3.1) <- paste0("Final Energy ", sector[y]," ", getItems(var_by_subsector_by_energy_form, 3.1))
    
    #sector by subsector and by energy form MENA_EDS
    mena_by_subsector_by_energy_form <- mena_by_energy_form
    getItems(mena_by_subsector_by_energy_form, 3.1) <- paste0("Final Energy ", sector[y]," ", getItems(mena_by_subsector_by_energy_form, 3.1))
    
    # write data in mif file
    write.report(var_by_subsector_by_energy_form[,,],file="reporting.mif",model="OPEN-PROM",unit="Mtoe",append=TRUE,scenario=scenario_name)
    write.report(mena_by_subsector_by_energy_form[menaregs,years,],file="reporting.mif",model="MENA-EDS",unit="Mtoe",append=TRUE,scenario=scenario_name)
    
    #sector_by_energy_form
    by_energy_form <- dimSums(var_by_energy_form, 3.1, na.rm = TRUE)
    getItems(by_energy_form,3.1) <- paste0("Final Energy ", sector[y]," ", getItems(by_energy_form, 3.1))
    var_mena_by_energy_form <- dimSums(mena_by_energy_form,3.1, na.rm = TRUE)
    getItems(var_mena_by_energy_form, 3.1) <- paste0("Final Energy ", sector[y]," ", getItems(var_mena_by_energy_form, 3.1))
    
    # write data in mif file
    write.report(by_energy_form[,,],file="reporting.mif",model="OPEN-PROM",unit="Mtoe",append=TRUE,scenario=scenario_name)
    write.report(var_mena_by_energy_form[menaregs,years,],file="reporting.mif",model="MENA-EDS",unit="Mtoe",append=TRUE,scenario=scenario_name)
    
    #filter IFuelCons by subtype enerdata
    b3 <- calcOutput(type = "IFuelCons", subtype = sector[y], aggregate = TRUE)
    
    year <- Reduce(intersect, list(getYears(a,as.integer=TRUE),getYears(var,as.integer=TRUE),getYears(b3,as.integer=TRUE)))
    b3 <- b3[,year,]
    
    map_subsectors_ener <- sets4 %>% filter(SBS %in% as.character(sets6[,1]))
    
    map_subsectors_ener$EF = paste(map_subsectors_ener$SBS, "Mtoe",map_subsectors_ener$EF, sep=".")
    #filter to have only the variables which are in enerdata
    map_subsectors_ener <- map_subsectors_ener %>% filter(EF %in% getItems(b3,3))
    
    # aggregate from enerdata fuels to subsectors
    b3_subsector <- toolAggregate(b3[,,as.character(unique(map_subsectors_ener$EF))],dim=3,rel=map_subsectors_ener,from="EF",to="SBS")
    getItems(b3_subsector, 3) <- paste0("Final Energy ", sector[y]," ", getItems(b3_subsector, 3))
    
    # write data in mif file
    write.report(b3_subsector[intersect(getRegions(b3_subsector),regs),year,],file="reporting.mif",model="ENERDATA",unit="Mtoe",append=TRUE,scenario=scenario_name)
    
    #Final Energy enerdata
    FE_ener <- dimSums(b3, dim = 3, na.rm = TRUE)
    getItems(FE_ener, 3) <- paste0("Final Energy ", sector[y])
    
    # write data in mif file
    write.report(FE_ener[intersect(getRegions(FE_ener),regs),year,],file="reporting.mif",model="ENERDATA",unit="Mtoe",append=TRUE,scenario=scenario_name)
    
    map_subsectors_ener2 <- sets10
    #filter to have only the variables which are in enerdata
    map_subsectors_ener2 <- map_subsectors_ener2 %>% filter(EF %in% getItems(b3,3.3))
    
    #Aggregate model enerdata by subsector and by energy form
    b3_by_energy_form <- toolAggregate(b3[,year,as.character(unique(map_subsectors_ener2$EF))],dim=3.3,rel=map_subsectors_ener2,from="EF",to="EFA")
    
    #enerdata by subsector and by energy form
    enerdata_by_subsector_by_energy_form <- b3_by_energy_form
    enerdata_by_subsector_by_energy_form <- dimSums(enerdata_by_subsector_by_energy_form, 3.2, na.rm = TRUE)
    getItems(enerdata_by_subsector_by_energy_form, 3.1) <- paste0("Final Energy ", sector[y]," ", getItems(enerdata_by_subsector_by_energy_form, 3.1))
    
    # write data in mif file
    write.report(enerdata_by_subsector_by_energy_form[intersect(getRegions(enerdata_by_subsector_by_energy_form),regs),year,],file="reporting.mif",model="ENERDATA",unit="Mtoe",append=TRUE,scenario=scenario_name)
    
    #Aggregate model enerdata by energy form
    b3_agg_by_energy_form <- dimSums(b3_by_energy_form, 3.1, na.rm = TRUE)
    getItems(b3_agg_by_energy_form,3) <- paste0("Final Energy ", sector[y]," ", getItems(b3_agg_by_energy_form, 3.2))
    
    # write data in mif file
    write.report(b3_agg_by_energy_form[intersect(getRegions(b3_agg_by_energy_form),regs),year,],file="reporting.mif",model="ENERDATA",unit="Mtoe",append=TRUE,scenario=scenario_name)
    
  }
}

runCY <- readGDX('./blabla.gdx', "runCYL") # read model regions, model reporting should contain only these
rmap <- toolGetMapping(mapping, "regional", where = "mrprom")
setConfig(regionmapping = mapping)

# read MENA-PROM mapping, will use it to choose the correct variables from MENA
map <- read.csv("MENA-PROM mapping - mena_prom_mapping.csv")

scenario_name <- basename(getwd())
scenario_name <- str_match(scenario_name, "\\s*(.*?)\\s*_")[,1]
scenario_name <- str_sub(scenario_name, 1, - 2)
if (is.na(scenario_name)) scenario_name <- "default"

#output <- NULL
#output <- mbind(output, reportGDP(runCY))
reportFinalEnergy(runCY)
#reportGDP(runCY)
#reportACTV(runCY)
reportEmissions(runCY)
#reportPrice()