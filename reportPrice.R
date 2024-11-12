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
  
  
  # read GAMS set used for reporting of Final Energy
  sets <- toolreadSets("sets.gms", "BALEF2EFS")
  sets[, 1] <- gsub("\"","",sets[, 1])
  sets <- separate_wider_delim(sets,cols = 1, delim = ".", names = c("BAL","EF"))
  sets[["EF"]] <- sub("\\(","",sets[["EF"]])
  sets[["EF"]] <- sub("\\)","",sets[["EF"]])
  sets <- separate_rows(sets,EF)
  sets$BAL <- gsub("Gas fuels", "Gases", sets$BAL)
  
  sets <- toolreadSets(system.file(file.path("extdata", "sets.gms"), package = "mrprom"), "BALEF2EFS")
  sets[, 1] <- gsub("\"", "", sets[, 1])
  sets <- separate_wider_delim(sets,cols = 1, delim = ".", names = c("BAL", "EF"))
  sets[["EF"]] <- sub("\\(", "", sets[["EF"]])
  sets[["EF"]] <- sub("\\)", "", sets[["EF"]])
  EF <- NULL
  sets <- separate_rows(sets, EF)
  sets[["BAL"]] <- gsub("Gas fuels", "Gases", sets[["BAL"]])
  
  z <- NULL
  for (y in 1 : length(sector)) {
    # read GAMS set used for reporting of Final Energy different for each sector
    sets6 <- NULL
    # load current OPENPROM set configuration for each sector
    try(sets6 <- toolreadSets("sets.gms", sector[y]))
    try(sets6 <- separate_rows(sets6, paste0(sector[y],"(DSBS)")))
    try(sets6 <- as.data.frame(sets6))
    if (y == 5) sets6 <- sector[y]
    sets6 <- as.data.frame(sets6)
    
    map_subsectors <- sets4 %>% filter(SBS %in% as.character(sets6[, 1]))
    map_subsectors$EF = paste(map_subsectors$SBS, map_subsectors$EF, sep=".")
    
    #add model OPEN-PROM data VPriceFuelSubsecCarVal
    iFuelPrice <- readGDX('./blabla.gdx', "VPriceFuelSubsecCarVal", field = "l")[regs, , ][,,map_subsectors$EF]
    PRICE_by_sector_and_EF <- iFuelPrice
    # complete names
    getItems(PRICE_by_sector_and_EF, 3.1) <- paste0("Price|Final Energy|", sector_name[y],"|", getItems(PRICE_by_sector_and_EF, 3.1))
    
    # remove . from magpie object and replace with |
    PRICE_by_sector_and_EF <- as.quitte(PRICE_by_sector_and_EF)
    PRICE_by_sector_and_EF[["SBS"]] <- paste0(PRICE_by_sector_and_EF[["SBS"]], "|", PRICE_by_sector_and_EF[["EF"]])
    PRICE_by_sector_and_EF <- select(PRICE_by_sector_and_EF, -c("variable","EF"))
    PRICE_by_sector_and_EF <- as.quitte(PRICE_by_sector_and_EF) %>% as.magpie()
    
    # write data in mif file
    write.report(PRICE_by_sector_and_EF[,,],file="reporting.mif",model="OPEN-PROM",unit="KUS$2015/toe",append=TRUE,scenario=scenario_name)
    
    #aggregation by SECTOR and EF
    
    iFuelPrice2 <- as.quitte(iFuelPrice)
    iFuelPrice2 <- iFuelPrice2 %>% mutate(value = mean(value, na.rm = TRUE), .by = c("model", "scenario",
                                                                                               "region", "unit",
                                                                                               "period", "variable","EF"))
    iFuelPrice2 <- select(iFuelPrice2, "EF", "model", "scenario", "region", "variable", "unit", "period", "value")
    iFuelPrice2 <- distinct(iFuelPrice2)
    PRICE_by_EF_OPEN_PROM <- as.quitte(iFuelPrice2) %>% as.magpie()
    
    # complete names
    getItems(PRICE_by_EF_OPEN_PROM, 3) <- paste0("Price|Final Energy|", sector_name[y],"|", getItems(PRICE_by_EF_OPEN_PROM, 3))
    
    # write data in mif file
    write.report(PRICE_by_EF_OPEN_PROM[,,],file="reporting.mif",model="OPEN-PROM",unit="KUS$2015/toe",append=TRUE,scenario=scenario_name)
      
    #fuel categories

    # aggregate from fuels to reporting fuel categories
    sum_open_prom <- iFuelPrice
    sum_open_prom <- as.quitte(sum_open_prom)
    ## add mapping
    sum_open_prom <- left_join(sum_open_prom, sets, by = "EF")
    # take the mean
    sum_open_prom <- mutate(sum_open_prom, value = mean(value, na.rm = TRUE), .by = c("model", "scenario", "region",
                                                                      "unit","period","BAL" ))
    sum_open_prom <- distinct(sum_open_prom)
    sum_open_prom <- sum_open_prom %>% select(c("model","scenario","region","unit",
                                "period","value","BAL")) 
    sum_open_prom <- distinct(sum_open_prom)
    sum_open_prom <- as.magpie(as.quitte(drop_na(sum_open_prom)))
    
    # complete names
    getItems(sum_open_prom, 3) <- paste0("Price|Final Energy|", sector_name[y],"|", getItems(sum_open_prom, 3))
    
    # write data in mif file
    write.report(sum_open_prom[,,],file="reporting.mif",model="OPEN-PROM",unit="KUS$2015/toe",append=TRUE,scenario=scenario_name)
    
  }
}