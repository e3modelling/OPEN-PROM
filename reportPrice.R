reportPrice <- function(regs) {
  
  #add model OPEN-PROM data Electricity prices
  VPriceElecIndResConsu <- readGDX('./blabla.gdx', "VPriceElecIndResConsu", field = 'l')[regs, , ]
  #choose Industrial consumer /i/
  sets_i <- toolreadSets("sets.gms", "iSet")
  elec_prices_Industry <- VPriceElecIndResConsu[,,sets_i[1,1]]
  # complete names
  getNames(elec_prices_Industry) <- "Electricity prices Industrial"
  #choose Residential consumer /r/
  sets_r <- toolreadSets("sets.gms", "rSet")
  elec_prices_Residential <- VPriceElecIndResConsu[,,sets_r[1,1]]
  # complete names
  getNames(elec_prices_Residential) <- "Electricity prices Residential"
  #Combine Industrial and Residential OPEN-PROM
  elec_prices <- mbind(elec_prices_Industry, elec_prices_Residential)
  
  # write data in mif file
  write.report(elec_prices[,,],file="reporting.mif",model="OPEN-PROM",unit="US$2015/KWh",append=TRUE,scenario=scenario_name)
  
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
  
  # OPEN-PROM sectors
  sector <- c("TRANSE", "INDSE", "DOMSE", "NENSE")
  sector_name <- c("Transportation", "Industry", "Residential and Commercial", "Non Energy and Bunkers")
  
  iFuelPrice_total <- readGDX('./blabla.gdx', "iFuelPrice")[regs, , ]
  iFuelPrice_total_sum <- dimSums(iFuelPrice_total, 3, na.rm = TRUE)
  getItems(iFuelPrice_total_sum, 3) <- "Price|Final Energy"
  # write data in mif file
  write.report(iFuelPrice_total_sum[,,],file="reporting.mif",model="OPEN-PROM",unit="k$2015/toe",scenario=scenario_name)
  
  # read GAMS set used for reporting of Final Energy
  sets <- toolreadSets("sets.gms", "BALEF2EFS")
  sets[, 1] <- gsub("\"","",sets[, 1])
  sets <- separate_wider_delim(sets,cols = 1, delim = ".", names = c("BAL","EF"))
  sets[["EF"]] <- sub("\\(","",sets[["EF"]])
  sets[["EF"]] <- sub("\\)","",sets[["EF"]])
  sets <- separate_rows(sets,EF)
  sets$BAL <- gsub("Gas fuels", "Gases", sets$BAL)
  
  for (y in 1 : length(sector)) {
    # read GAMS set used for reporting of Final Energy different for each sector
    sets6 <- toolreadSets("sets.gms", sector[y])
    sets6 <- separate_rows(sets6, paste0(sector[y],"(DSBS)"))
    sets6 <- as.data.frame(sets6)
    
    map_subsectors <- sets4 %>% filter(SBS %in% as.character(sets6[, 1]))
    map_subsectors$EF = paste(map_subsectors$SBS, map_subsectors$EF, sep=".")
    
    #add model OPEN-PROM data iFuelPrice
    iFuelPrice <- readGDX('./blabla.gdx', "iFuelPrice")[regs, , ][,,map_subsectors$EF]
    PRICE_by_sector_and_EF <- iFuelPrice
    # complete names
    getItems(PRICE_by_sector_and_EF, 3.1) <- paste0("Price|Final Energy|", sector_name[y],"|", getItems(PRICE_by_sector_and_EF, 3.1))
    
    # remove . from magpie object and replace with |
    PRICE_by_sector_and_EF <- as.quitte(PRICE_by_sector_and_EF)
    PRICE_by_sector_and_EF[["SBS"]] <- paste0(PRICE_by_sector_and_EF[["SBS"]], "|", PRICE_by_sector_and_EF[["EF"]])
    PRICE_by_sector_and_EF <- select(PRICE_by_sector_and_EF, -c("variable","EF"))
    PRICE_by_sector_and_EF <- as.quitte(PRICE_by_sector_and_EF) %>% as.magpie()
    
    # write data in mif file
    write.report(PRICE_by_sector_and_EF[,,],file="reporting.mif",model="OPEN-PROM",unit="k$2015/toe",append=TRUE,scenario=scenario_name)
    
    #aggregation by SECTOR and EF
    PRICE_by_EF_OPEN_PROM <- dimSums(iFuelPrice, 3.1, na.rm = TRUE)
    PRICE_by_sector_OPEN_PROM <- dimSums(iFuelPrice, 3.2, na.rm = TRUE)
    PRICE_total_OPEN_PROM_sector <- dimSums(iFuelPrice, na.rm = TRUE)
    
    # complete names
    getItems(PRICE_by_EF_OPEN_PROM, 3) <- paste0("Price|Final Energy|", sector_name[y],"|", getItems(PRICE_by_EF_OPEN_PROM, 3))
    getItems(PRICE_by_sector_OPEN_PROM, 3) <- paste0("Price|Final Energy|", sector_name[y],"|", getItems(PRICE_by_sector_OPEN_PROM, 3))
    getItems(PRICE_total_OPEN_PROM_sector, 3) <- paste0("Price|Final Energy|", sector_name[y])
    
    # write data in mif file
    write.report(PRICE_by_EF_OPEN_PROM[,,],file="reporting.mif",model="OPEN-PROM",unit="k$2015/toe",append=TRUE,scenario=scenario_name)
    write.report(PRICE_by_sector_OPEN_PROM[,,],file="reporting.mif",model="OPEN-PROM",unit="k$2015/toe",append=TRUE,scenario=scenario_name)
    write.report(PRICE_total_OPEN_PROM_sector[,,],file="reporting.mif",model="OPEN-PROM",unit="k$2015/toe",append=TRUE,scenario=scenario_name)
    
    fuels <- dimSums(iFuelPrice, 3.1, na.rm = TRUE)
    
    # Energy Forms Aggregations
    sets5 <- toolreadSets(system.file(file.path("extdata", "sets.gms"), package = "mrprom"), "EFtoEFA")
    sets5[5,] <- paste0(sets5[5, ] , sets5[6, ])
    sets5 <- sets5[- 6, ]
    sets5 <- as.data.frame(sets5)
    sets5 <- separate_wider_delim(sets5, cols = 1, delim = ".", names = c("EF", "EFA"))
    sets5[["EF"]] <- sub("\\(", "", sets5[["EF"]])
    sets5[["EF"]] <- sub("\\)", "", sets5[["EF"]])
    sets5 <- separate_rows(sets5, EF)
    
    # Aggregate model by subsector and by energy form
    ef_toefa_map <- sets5 %>% filter(EF %in% as.character(getItems(fuels,3)))
    fuels_EFtoEFA <- toolAggregate(fuels[, , getItems(fuels,3)[getItems(fuels,3) %in% unique(sets5$EF)]], dim = 3, rel = ef_toefa_map, from = "EF", to = "EFA")
    getItems(fuels_EFtoEFA, 3) <- paste0("Price|Final Energy|", sector_name[y],"|", getItems(fuels_EFtoEFA, 3))
    
    # write data in mif file
    write.report(fuels[,,],file="reporting.mif",model="OPEN-PROM",unit="k$2015/toe",scenario=scenario_name)
    
    fuel_map <- getItems(fuels,3)[getItems(fuels,3) %in% unique(sets$EF)]
    fuel_map <- drop_na(as.data.frame(fuel_map))
    # aggregate from PROM fuels to reporting fuel categories
    iFuelPrice_total_sector <- toolAggregate(fuels[ , , fuel_map[,1]], dim = 3, rel = sets[sets$EF %in% fuel_map[,1],], from = "EF", to = "BAL")
    getItems(iFuelPrice_total_sector, 3) <- paste0("Price|Final Energy|", sector_name[y],"|", getItems(iFuelPrice_total_sector, 3))
    
    # write data in mif file
    write.report(iFuelPrice_total_sector[,,],file="reporting.mif",model="OPEN-PROM",unit="k$2015/toe",scenario=scenario_name)
    
  }
  
  VCarVal <- readGDX('./blabla.gdx', "VCarVal")[regs, , ][,,"TRADE.l" ]
  
  # complete names
  getItems(VCarVal, 3) <- "Price|Carbon"
  
  # write data in mif file
  write.report(VCarVal[,,],file="reporting.mif",model="OPEN-PROM",unit="US$2015/tn CO2",append=TRUE,scenario=scenario_name)
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  #add model MENA_EDS data (choosing the correct variable from MENA by use of the MENA-PROM mapping)
  elec_prices_MENA <- readSource("MENA_EDS", subtype =  map[map[["OPEN.PROM"]] == "VPriceElecIndResConsu", "MENA.EDS"])
  # fix wrong region names in MENA
  getRegions(elec_prices_MENA) <- sub("MOR", "MAR", getRegions(elec_prices_MENA))
  # choose years and regions that both models have
  years <- intersect(getYears(elec_prices_MENA,as.integer=TRUE),getYears(VPriceElecIndResConsu,as.integer=TRUE))
  menaregs <- intersect(getRegions(elec_prices_MENA),getRegions(VPriceElecIndResConsu))
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

  
  # complete names
  getItems(ENERDATA_Industrial, 3) <- "Electricity prices Industrial"
  getItems(ENERDATA_Residential, 3) <- "Electricity prices Residential"
  #combine Industrial and Residential MENA
  elec_prices_ENERDATA <- mbind(ENERDATA_Industrial, ENERDATA_Residential)
  # choose years and regions that both models have
  year <- Reduce(intersect, list(getYears(elec_prices_MENA,as.integer=TRUE),getYears(elec_prices_ENERDATA,as.integer=TRUE),getYears(VPriceElecIndResConsu,as.integer=TRUE)))
  #filter ENERDATA by years that both models have
  elec_prices_ENERDATA <- elec_prices_ENERDATA[, year,]
  # write data in mif file
  write.report(elec_prices_ENERDATA[intersect(getRegions(elec_prices_ENERDATA),regs),,],file="reporting.mif",model="ENERDATA",unit="Euro2005/KWh",append=TRUE,scenario=scenario_name)
  

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
  write.report(PRICE_by_EF_MENA[menaregs,years,],file="reporting.mif",model="MENA-EDS",unit="various",append=TRUE,scenario=scenario_name)
  write.report(PRICE_by_EF_ENERDATA[intersect(regs,getRegions(PRICE_by_EF_ENERDATA)),year,],file="reporting.mif",model="ENERDATA",unit="various",append=TRUE,scenario=scenario_name)
  
  write.report(PRICE_by_sector_OPEN_PROM[,,],file="reporting.mif",model="OPEN-PROM",unit="various",append=TRUE,scenario=scenario_name)
  write.report(PRICE_by_sector_MENA[menaregs,years,],file="reporting.mif",model="MENA-EDS",unit="various",append=TRUE,scenario=scenario_name)
  write.report(PRICE_by_sector_ENERDATA[intersect(regs,getRegions(PRICE_by_sector_ENERDATA)),year,],file="reporting.mif",model="ENERDATA",unit="various",append=TRUE,scenario=scenario_name)
  
  write.report(PRICE_total_OPEN_PROM[,,],file="reporting.mif",model="OPEN-PROM",unit="various",append=TRUE,scenario=scenario_name)
  write.report(PRICE_total_MENA[menaregs,years,],file="reporting.mif",model="MENA-EDS",unit="various",append=TRUE,scenario=scenario_name)
  write.report(PRICE_total_ENERDATA[intersect(regs,getRegions(PRICE_total_ENERDATA)),year,],file="reporting.mif",model="ENERDATA",unit="various",append=TRUE,scenario=scenario_name)
}