reportPrice <- function(regs) {
  
  #add model OPEN-PROM data Electricity prices
  VPriceElecIndResConsu <- readGDX('./blabla.gdx', "VPriceElecIndResConsu", field = 'l')[regs, , ]
  #choose Industrial consumer /i/
  sets_i <- toolreadSets("sets.gms", "iSet")
  elec_prices_Industry <- VPriceElecIndResConsu[,,sets_i[1,1]]
  # complete names
  getNames(elec_prices_Industry) <- "Price|Final Energy|Industry|Electricity"
  #choose Residential consumer /r/
  sets_r <- toolreadSets("sets.gms", "rSet")
  elec_prices_Residential <- VPriceElecIndResConsu[,,sets_r[1,1]]
  # complete names
  getNames(elec_prices_Residential) <- "Price|Final Energy|Residential|Electricity"
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
  sector <- c("TRANSE", "INDSE", "DOMSE", "NENSE", "PG")
  sector_name <- c("Transportation", "Industry", "Residential and Commercial", "Non Energy and Bunkers",
                   "Power and Steam Generation")
  
  iFuelPrice_total <- readGDX('./blabla.gdx', "iFuelPrice")[regs, , ]
  iFuelPrice_total_sum <- dimSums(iFuelPrice_total, 3, na.rm = TRUE)
  getItems(iFuelPrice_total_sum, 3) <- "Price|Final Energy"
  # write data in mif file
  write.report(iFuelPrice_total_sum[,,],file="reporting.mif",append=TRUE,model="OPEN-PROM",unit="k$2015/toe",scenario=scenario_name)
  
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
    sets6 <- NULL
    # load current OPENPROM set configuration for each sector
    try(sets6 <- toolreadSets("sets.gms", sector[y]))
    try(sets6 <- separate_rows(sets6, paste0(sector[y],"(DSBS)")))
    try(sets6 <- as.data.frame(sets6))
    if (is.null(sets6[1,1])) sets6 <- sector[y]
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
    write.report(fuels_EFtoEFA[,,],file="reporting.mif",append=TRUE,model="OPEN-PROM",unit="k$2015/toe",scenario=scenario_name)
    
    fuel_map <- getItems(fuels,3)[getItems(fuels,3) %in% unique(sets$EF)]
    fuel_map <- drop_na(as.data.frame(fuel_map))
    # aggregate from PROM fuels to reporting fuel categories
    iFuelPrice_total_sector <- toolAggregate(fuels[ , , fuel_map[,1]], dim = 3, rel = sets[sets$EF %in% fuel_map[,1],], from = "EF", to = "BAL")
    getItems(iFuelPrice_total_sector, 3) <- paste0("Price|Final Energy|", sector_name[y],"|", getItems(iFuelPrice_total_sector, 3))
    
    # write data in mif file
    write.report(iFuelPrice_total_sector[,,],append=TRUE,file="reporting.mif",model="OPEN-PROM",unit="k$2015/toe",scenario=scenario_name)
    
    #add model MENA_EDS data (choosing the correct variable from MENA by use of the MENA-PROM mapping)
    #fix units from $2015/toe to k$2015/toe
    FuelPrice_MENA <- readSource("MENA_EDS", subtype =  map[map[["OPEN.PROM"]] == "iFuelPrice", "MENA.EDS"]) / 1000
    PRICE_by_sector_and_EF_MENA <- FuelPrice_MENA
    # fix wrong region names in MENA
    getRegions(PRICE_by_sector_and_EF_MENA) <- sub("MOR", "MAR", getRegions(PRICE_by_sector_and_EF_MENA)) # fix wrong region names in MENA
    # choose years and regions that both models have
    lastYear <- sub("y", "", tail(sort(getYears(PRICE_by_sector_and_EF_MENA)), 1))
    PRICE_by_sector_and_EF_MENA <- PRICE_by_sector_and_EF_MENA[, c(fStartHorizon : lastYear), ] 
    
    PRICE_by_sector_and_EF_MENA <- as.quitte(PRICE_by_sector_and_EF_MENA) %>%
      interpolate_missing_periods(period = getYears(PRICE_by_sector_and_EF_MENA,as.integer=TRUE)[1]:getYears(PRICE_by_sector_and_EF_MENA,as.integer=TRUE)[length(getYears(PRICE_by_sector_and_EF_MENA))], expand.values = TRUE)
    
    PRICE_by_sector_and_EF_MENA <- as.quitte(PRICE_by_sector_and_EF_MENA) %>% as.magpie()
    years_in_horizon <-  horizon[horizon %in% getYears(PRICE_by_sector_and_EF_MENA, as.integer = TRUE)]
    
    PRICE_by_sector_and_EF_MENA_GLO <- dimSums(PRICE_by_sector_and_EF_MENA, 1)
    getItems(PRICE_by_sector_and_EF_MENA_GLO, 1) <- "World"
    PRICE_by_sector_and_EF_MENA <- mbind(PRICE_by_sector_and_EF_MENA, PRICE_by_sector_and_EF_MENA_GLO)
    
    # complete names
    getItems(PRICE_by_sector_and_EF_MENA, 3.1) <- paste0("Price|Final Energy|", sector_name[y],"|", getItems(PRICE_by_sector_and_EF_MENA, 3.1))
    
    # remove . from magpie object and replace with |
    PRICE_by_sector_and_EF_MENA <- as.quitte(PRICE_by_sector_and_EF_MENA)
    PRICE_by_sector_and_EF_MENA[["sbs"]] <- paste0(PRICE_by_sector_and_EF_MENA[["sbs"]], "|", PRICE_by_sector_and_EF_MENA[["ef"]])
    PRICE_by_sector_and_EF_MENA <- select(PRICE_by_sector_and_EF_MENA, -c("variable","ef"))
    PRICE_by_sector_and_EF_MENA <- as.quitte(PRICE_by_sector_and_EF_MENA) %>% as.magpie()
    
    # write data in mif file
    write.report(PRICE_by_sector_and_EF_MENA[, years_in_horizon, ], file = "reporting.mif", model = "MENA-EDS", unit = "US$2015/KWh",append = TRUE, scenario = "Baseline")
    
    # fix wrong region names in MENA
    getRegions(FuelPrice_MENA) <- sub("MOR", "MAR", getRegions(FuelPrice_MENA))
    # choose years and regions that both models have
    lastYear <- sub("y", "", tail(sort(getYears(FuelPrice_MENA)), 1))
    FuelPrice_MENA <- FuelPrice_MENA[, c(fStartHorizon : lastYear), ]
    
    FuelPrice_MENA <- as.quitte(FuelPrice_MENA) %>%
      interpolate_missing_periods(period = getYears(FuelPrice_MENA,as.integer=TRUE)[1]:getYears(FuelPrice_MENA,as.integer=TRUE)[length(getYears(FuelPrice_MENA))], expand.values = TRUE)
    
    FuelPrice_MENA <- as.quitte(FuelPrice_MENA) %>% as.magpie()
    years_in_horizon <-  horizon[horizon %in% getYears(FuelPrice_MENA, as.integer = TRUE)]
    
    FuelPrice_MENA_GLO <- dimSums(FuelPrice_MENA, 1)
    getItems(FuelPrice_MENA_GLO, 1) <- "World"
    FuelPrice_MENA <- mbind(FuelPrice_MENA, FuelPrice_MENA_GLO)
    
    #aggregation by SECTOR and EF
    PRICE_by_EF_MENA_PROM <- dimSums(FuelPrice_MENA, 3.1, na.rm = TRUE)
    PRICE_by_sector_MENA_PROM <- dimSums(FuelPrice_MENA, 3.2, na.rm = TRUE)
    PRICE_total_MENA_sector <- dimSums(FuelPrice_MENA, na.rm = TRUE)
    
    # complete names
    getItems(PRICE_by_EF_MENA_PROM, 3) <- paste0("Price|Final Energy|", sector_name[y],"|", getItems(PRICE_by_EF_MENA_PROM, 3))
    getItems(PRICE_by_sector_MENA_PROM, 3) <- paste0("Price|Final Energy|", sector_name[y],"|", getItems(PRICE_by_sector_MENA_PROM, 3))
    getItems(PRICE_total_MENA_sector, 3) <- paste0("Price|Final Energy|", sector_name[y])
    
    # write data in mif file
    write.report(PRICE_by_EF_MENA_PROM[,years_in_horizon,],file="reporting.mif",model="MENA-EDS",unit="k$2015/toe",append=TRUE,scenario="Baseline")
    write.report(PRICE_by_sector_MENA_PROM[,years_in_horizon,],file="reporting.mif",model="MENA-EDS",unit="k$2015/toe",append=TRUE,scenario="Baseline")
    write.report(PRICE_total_MENA_sector[,years_in_horizon,],file="reporting.mif",model="MENA-EDS",unit="k$2015/toe",append=TRUE,scenario="Baseline")
    
    fuels_mena <- dimSums(FuelPrice_MENA, 3.1, na.rm = TRUE)
    
    # Aggregate model by subsector and by energy form
    ef_toefa_map <- sets5 %>% filter(EF %in% as.character(getItems(fuels_mena,3)))
    fuels_EFtoEFA_mena <- toolAggregate(fuels_mena[, , getItems(fuels_mena,3)[getItems(fuels_mena,3) %in% unique(sets5$EF)]], dim = 3, rel = ef_toefa_map, from = "EF", to = "EFA")
    getItems(fuels_EFtoEFA_mena, 3) <- paste0("Price|Final Energy|", sector_name[y],"|", getItems(fuels_EFtoEFA_mena, 3))
    
    # write data in mif file
    write.report(fuels_EFtoEFA_mena[,years_in_horizon,],file="reporting.mif",model="OPEN-PROM",unit="k$2015/toe",append=TRUE,scenario="Baseline")
    
    fuel_map <- getItems(fuels_mena,3)[getItems(fuels_mena,3) %in% unique(sets$EF)]
    fuel_map <- drop_na(as.data.frame(fuel_map))
    # aggregate from PROM fuels to reporting fuel categories
    iFuelPrice_total_sector_mena <- toolAggregate(fuels_mena[ , , fuel_map[,1]], dim = 3, rel = sets[sets$EF %in% fuel_map[,1],], from = "EF", to = "BAL")
    getItems(iFuelPrice_total_sector_mena, 3) <- paste0("Price|Final Energy|", sector_name[y],"|", getItems(iFuelPrice_total_sector_mena, 3))
    
    # write data in mif file
    write.report(iFuelPrice_total_sector_mena[,years_in_horizon,],file="reporting.mif",model="MENA-EDS",unit="k$2015/toe",append=TRUE,scenario="Baseline")
    
    
    #FuelPrice enerdata
    x <- readSource("ENERDATA", "constant price", convert = TRUE)
    x[x == 0] <- NA # set all zeros to NA because we deal with prices
    
    # filter years
    fStartHorizon <- readEvalGlobal(system.file(file.path("extdata", "main.gms"), package = "mrprom"))["fStartHorizon"]
    fStartY <- readEvalGlobal(system.file(file.path("extdata", "main.gms"), package = "mrprom"))["fStartY"]
    x <- x[, c(fStartHorizon : max(getYears(x, as.integer = TRUE))), ]
    
    # use enerdata-openprom mapping to extract correct data from source
    map0 <- toolGetMapping(name = "prom-enerdata-fuprice-mapping.csv",
                           type = "sectoral",
                           where = "mrprom")
    
    # filter data to choose correct (sub)sectors and fuels
    out <- NULL
      
    ## filter mapping to keep only i sectors
    map_enerdata <- filter(map0, map0[, "SBS"] %in% sets6[ ,1])
    ## ..and only items that have an enerdata-prom mapping
    enernames <- unique(map_enerdata[!is.na(map_enerdata[, "ENERDATA"]), "ENERDATA"])
    map_enerdata <- map_enerdata[map_enerdata[, "ENERDATA"] %in% enernames, ]
    ## rename variables from ENERDATA to openprom names
    ff <- paste(map_enerdata[, 2], map_enerdata[, 3], sep = ".")
    iii <- 0
    ### add a dummy dimension to data because mapping has 3 dimensions, and data only 2
    for (ii in map_enerdata[, "ENERDATA"]) {
      iii <- iii + 1
      out <- mbind(out, setNames(add_dimension(x[, , ii], dim = 3.2), paste0(ff[iii], ".", sub("^.*.\\.", "", getNames(x[, , ii])))))
    }
    
    # complete incomplete time series
    x <- as.quitte(out) %>%
      interpolate_missing_periods(period = getYears(out, as.integer = TRUE), expand.values = TRUE) %>%
      as.magpie()# %>%
    
    PRICE_by_sector_and_EF_enerdata <- x
    # complete names
    getItems(PRICE_by_sector_and_EF_enerdata, 3.1) <- paste0("Price|Final Energy|", sector_name[y],"|", getItems(PRICE_by_sector_and_EF_enerdata, 3.1))
    
    # remove . from magpie object and replace with |
    PRICE_by_sector_and_EF_enerdata <- as.quitte(PRICE_by_sector_and_EF_enerdata)
    PRICE_by_sector_and_EF_enerdata[["variable"]] <- paste0(PRICE_by_sector_and_EF_enerdata[["variable"]], "|", PRICE_by_sector_and_EF_enerdata[["new"]])
    PRICE_by_sector_and_EF_enerdata <- select(PRICE_by_sector_and_EF_enerdata, -c("new"))
    PRICE_by_sector_and_EF_enerdata <- as.quitte(PRICE_by_sector_and_EF_enerdata) %>% as.magpie()
    
    lastYear <- sub("y", "", tail(sort(getYears(PRICE_by_sector_and_EF_enerdata)), 1))
    PRICE_by_sector_and_EF_enerdata <- PRICE_by_sector_and_EF_enerdata[, c(fStartHorizon : lastYear), ]
    
    PRICE_by_sector_and_EF_enerdata <- as.quitte(PRICE_by_sector_and_EF_enerdata) %>%
      interpolate_missing_periods(period = getYears(PRICE_by_sector_and_EF_enerdata,as.integer=TRUE)[1]:getYears(PRICE_by_sector_and_EF_enerdata,as.integer=TRUE)[length(getYears(PRICE_by_sector_and_EF_enerdata))], expand.values = TRUE)
    
    PRICE_by_sector_and_EF_enerdata <- as.quitte(PRICE_by_sector_and_EF_enerdata) %>% as.magpie()
    years_in_horizon <-  horizon[horizon %in% getYears(PRICE_by_sector_and_EF_enerdata, as.integer = TRUE)]
    
    PRICE_by_sector_and_EF_enerdata_GLO <- dimSums(PRICE_by_sector_and_EF_enerdata, 1)
    getItems(PRICE_by_sector_and_EF_enerdata_GLO, 1) <- "World"
    PRICE_by_sector_and_EF_enerdata <- mbind(PRICE_by_sector_and_EF_enerdata, PRICE_by_sector_and_EF_enerdata_GLO)
    
    PRICE_by_sector_and_EF_enerdata <- PRICE_by_sector_and_EF_enerdata / 1000 # fix units to k$2015/toe
    
    # write data in mif file
    write.report(PRICE_by_sector_and_EF_enerdata[, years_in_horizon, ], file = "reporting.mif", model = "ENERDATA", unit = "k$2015/toe",append = TRUE, scenario = "Validation")
    
    #aggregation by SECTOR and EF
    PRICE_by_EF_ENERDATA_PROM <- dimSums(PRICE_by_sector_and_EF_enerdata, 3.1, na.rm = TRUE)
    PRICE_by_sector_ENERDATA_PROM <- dimSums(PRICE_by_sector_and_EF_enerdata, 3.2, na.rm = TRUE)
    PRICE_total_ENERDATA_PROM_sector <- dimSums(PRICE_by_sector_and_EF_enerdata, na.rm = TRUE)
    
    # complete names
    getItems(PRICE_by_EF_ENERDATA_PROM, 3) <- paste0("Price|Final Energy|", sector_name[y],"|", getItems(PRICE_by_EF_ENERDATA_PROM, 3))
    getItems(PRICE_by_sector_ENERDATA_PROM, 3) <- paste0("Price|Final Energy|", sector_name[y],"|", getItems(PRICE_by_sector_ENERDATA_PROM, 3))
    getItems(PRICE_total_ENERDATA_PROM_sector, 3) <- paste0("Price|Final Energy|", sector_name[y])
    
    # write data in mif PRICE_by_EF_ENERDATA_PROM
    write.report(PRICE_by_EF_OPEN_PROM[, years_in_horizon, ], file = "reporting.mif", model = "ENERDATA", unit = "k$2015/toe",append = TRUE, scenario = "Validation")
    write.report(PRICE_by_sector_ENERDATA_PROM[, years_in_horizon, ], file = "reporting.mif", model = "ENERDATA", unit = "k$2015/toe",append = TRUE, scenario = "Validation")
    write.report(PRICE_total_ENERDATA_PROM_sector[, years_in_horizon, ], file = "reporting.mif", model = "ENERDATA", unit = "k$2015/toe",append = TRUE, scenario = "Validation")
    
    fuels_enerdata <- dimSums(x, 3.1, na.rm = TRUE)
    fuels_enerdata <- dimSums(fuels_enerdata, 3.1, na.rm = TRUE)
    
    # Aggregate model by subsector and by energy form
    ef_toefa_map <- sets5 %>% filter(EF %in% as.character(getItems(fuels_enerdata,3)))
    fuels_EFtoEFA_enerdata <- toolAggregate(fuels_enerdata[, , getItems(fuels_enerdata,3)[getItems(fuels_enerdata,3) %in% unique(sets5$EF)]], dim = 3, rel = ef_toefa_map, from = "EF", to = "EFA")
    getItems(fuels_EFtoEFA_enerdata, 3) <- paste0("Price|Final Energy|", sector_name[y],"|", getItems(fuels_EFtoEFA_enerdata, 3))
    
    # write data in mif file
    write.report(fuels_EFtoEFA_enerdata[, years_in_horizon, ], file = "reporting.mif", model = "ENERDATA", unit = "k$2015/toe",append = TRUE, scenario = "Validation")
    
    fuel_map <- getItems(fuels_enerdata,3)[getItems(fuels_enerdata,3) %in% unique(sets$EF)]
    fuel_map <- drop_na(as.data.frame(fuel_map))
    # aggregate from PROM fuels to reporting fuel categories
    iFuelPrice_total_sector_enerdata <- toolAggregate(fuels_enerdata[ , , fuel_map[,1]], dim = 3, rel = sets[sets$EF %in% fuel_map[,1],], from = "EF", to = "BAL")
    getItems(iFuelPrice_total_sector_enerdata, 3) <- paste0("Price|Final Energy|", sector_name[y],"|", getItems(iFuelPrice_total_sector_enerdata, 3))
    
    # write data in mif file
    write.report(iFuelPrice_total_sector_enerdata[, years_in_horizon, ], file = "reporting.mif", model = "ENERDATA", unit = "k$2015/toe",append = TRUE, scenario = "Validation")
    
  }
  
  VCarVal <- readGDX('./blabla.gdx', "VCarVal")[regs, , ][,,"TRADE.l" ]
  
  # complete names
  getItems(VCarVal, 3) <- "Price|Carbon"
  
  # write data in mif file
  write.report(VCarVal[,,],file="reporting.mif",model="OPEN-PROM",unit="US$2015/tn CO2",append=TRUE,scenario=scenario_name)
  
  # MENA
  #add model MENA_EDS data (choosing the correct variable from MENA by use of the MENA-PROM mapping)
  elec_prices_MENA <- readSource("MENA_EDS", subtype =  map[map[["OPEN.PROM"]] == "VPriceElecIndResConsu", "MENA.EDS"])
  # fix wrong region names in MENA
  getRegions(elec_prices_MENA) <- sub("MOR", "MAR", getRegions(elec_prices_MENA))
  # choose years and regions that both models have
  lastYear <- sub("y", "", tail(sort(getYears(elec_prices_MENA)), 1))
  elec_prices_MENA <- elec_prices_MENA[, c(fStartHorizon : lastYear), ] 
  
  #choose Industrial consumer /i/
  MENA_Industrial <- elec_prices_MENA[,,sets_i[1,1]]
  # complete names
  getNames(MENA_Industrial) <- "Price|Final Energy|Industry|Electricity"
  #choose Residential consumer /r/
  MENA_Residential <- elec_prices_MENA[,,sets_r[1,1]]
  # complete names
  getNames(MENA_Residential) <- "Price|Final Energy|Residential|Electricity"
  #combine Industrial and Residential MENA
  elec_prices_MENA <- mbind(MENA_Industrial, MENA_Residential)
  
  elec_prices_MENA <- as.quitte(elec_prices_MENA) %>%
    interpolate_missing_periods(period = getYears(elec_prices_MENA,as.integer=TRUE)[1]:getYears(elec_prices_MENA,as.integer=TRUE)[length(getYears(elec_prices_MENA))], expand.values = TRUE)
  
  elec_prices_MENA <- as.quitte(elec_prices_MENA) %>% as.magpie()
  years_in_horizon <-  horizon[horizon %in% getYears(elec_prices_MENA, as.integer = TRUE)]
  
  elec_prices_MENA_GLO <- dimSums(elec_prices_MENA, 1)
  getItems(elec_prices_MENA_GLO, 1) <- "World"
  elec_prices_MENA <- mbind(elec_prices_MENA, elec_prices_MENA_GLO)
  
  elec_prices_MENA <- elec_prices_MENA * 1.231727 # Euro2005 to US$2015/KWh
  # write data in mif file
  write.report(elec_prices_MENA[, years_in_horizon, ], file = "reporting.mif", model = "MENA-EDS", unit = "US$2015/KWh",append = TRUE, scenario = "Baseline")
  
  #filter ENERDATA by electricity
  ENERDATA_electricity <- readSource("ENERDATA", subtype =  "electricity", convert = TRUE)
  #choose Industrial consumer /i/
  ENERDATA_Industrial <- ENERDATA_electricity[,,"Constant price per toe in US$ of electricity in industry (taxes incl).$15/toe"]
  #choose Residential consumer /r/
  ENERDATA_Residential<- ENERDATA_electricity[,,"Constant price per toe in US$ of electricity for households (taxes incl).$15/toe"]
  #fix units from toe to kwh
  ENERDATA_Industrial <- ENERDATA_Industrial / 11630
  ENERDATA_Residential <- ENERDATA_Residential / 11630

  # complete names
  getItems(ENERDATA_Industrial, 3) <- "Price|Final Energy|Industry|Electricity"
  getItems(ENERDATA_Residential, 3) <- "Price|Final Energy|Residential|Electricity"
  #combine Industrial and Residential MENA
  elec_prices_ENERDATA <- mbind(ENERDATA_Industrial, ENERDATA_Residential)
  elec_prices_ENERDATA <- as.quitte(elec_prices_ENERDATA) %>%
    interpolate_missing_periods(period = getYears(elec_prices_ENERDATA,as.integer=TRUE)[1]:getYears(elec_prices_ENERDATA,as.integer=TRUE)[length(getYears(elec_prices_ENERDATA))], expand.values = TRUE)
  
  elec_prices_ENERDATA <- as.quitte(elec_prices_ENERDATA) %>% as.magpie()
  years_in_horizon <-  horizon[horizon %in% getYears(elec_prices_ENERDATA, as.integer = TRUE)]
  
  elec_prices_ENERDATA_GLO <- dimSums(elec_prices_ENERDATA, 1)
  getItems(elec_prices_ENERDATA_GLO, 1) <- "World"
  elec_prices_ENERDATA <- mbind(elec_prices_ENERDATA, elec_prices_ENERDATA_GLO)
  
  # write data in mif file
  write.report(elec_prices_ENERDATA[, years_in_horizon, ], file = "reporting.mif", model = "ENERDATA", unit = "US$2015/KWh",append = TRUE, scenario = "Validation")
  
  # Navigate
  map_price_navigate <- c("Price|Final Energy|Industry|Gases", "Price|Final Energy|Industry|Liquids",
                          "Price|Final Energy|Industry|Solids", "Price|Final Energy|Transportation|Electricity")
  
  Navigate_p <- Navigate_Con_F_calc[,,map_price_navigate]
  
  Navigate_p <- as.quitte(Navigate_p) %>%
    interpolate_missing_periods(period = getYears(Navigate_p,as.integer=TRUE)[1]:getYears(Navigate_p,as.integer=TRUE)[length(getYears(Navigate_p))], expand.values = TRUE)
  
  Navigate_p <- as.quitte(Navigate_p) %>% as.magpie()
  years_in_horizon <-  horizon[horizon %in% getYears(Navigate_p, as.integer = TRUE)]
  
  getItems(Navigate_p, 3.4) <- "k$2015/toe"
  
  Navigate_p <- Navigate_p * 1.087 * 41.868 / 1000 # US$2010/GJ to k$2015/toe
  
  write.report(Navigate_p[, years_in_horizon, ], file = "reporting.mif", append = TRUE)
  
  
  # Navigate
  map_price_navigate <- c("Price|Final Energy|Industry|Electricity","Price|Final Energy|Residential|Electricity",
                          "Price|Final Energy|Residential and Commercial|Electricity")
  
  Navigate_p <- Navigate_Con_F_calc[,,map_price_navigate]
  
  Navigate_p <- as.quitte(Navigate_p) %>%
    interpolate_missing_periods(period = getYears(Navigate_p,as.integer=TRUE)[1]:getYears(Navigate_p,as.integer=TRUE)[length(getYears(Navigate_p))], expand.values = TRUE)
  
  Navigate_p <- as.quitte(Navigate_p) %>% as.magpie()
  years_in_horizon <-  horizon[horizon %in% getYears(Navigate_p, as.integer = TRUE)]
  
  getItems(Navigate_p, 3.4) <- "US$2015/KWh"
  
  Navigate_p <- Navigate_p * 1.087 / 277.778 # US$2010/GJ to US$2015/KWh
  
  write.report(Navigate_p[, years_in_horizon, ], file = "reporting.mif", append = TRUE)
  
  
  
  Navigate_p <- Navigate_Con_F_calc[,,"Price|Carbon"]
  
  Navigate_p <- as.quitte(Navigate_p) %>%
    interpolate_missing_periods(period = getYears(Navigate_p,as.integer=TRUE)[1]:getYears(Navigate_p,as.integer=TRUE)[length(getYears(Navigate_p))], expand.values = TRUE)
  
  Navigate_p <- as.quitte(Navigate_p) %>% as.magpie()
  years_in_horizon <-  horizon[horizon %in% getYears(Navigate_p, as.integer = TRUE)]
  
  getItems(Navigate_p, 3.4) <- "US$2015/tn CO2"
  
  Navigate_p <- Navigate_p * 1.087 # US$2010/t CO2 to US$2015/tn CO2
  
  write.report(Navigate_p[, years_in_horizon, ], file = "reporting.mif", append = TRUE)
  
  
  
  
}