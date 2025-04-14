reportPrice <- function(regs) {
  
  #add model OPEN-PROM data Electricity prices
  VPriceElecIndResConsu <- readGDX('./blabla.gdx', "VPriceElecIndResConsu", field = 'l')[regs, , ]
  #choose Industrial consumer /i/
  sets_i <- readGDX('./blabla.gdx', "iSet")
  sets_i <- as.data.frame(sets_i)
  names(sets_i) <- "iSet"
  elec_prices_Industry <- VPriceElecIndResConsu[,,sets_i[1,1]]
  # complete names
  getNames(elec_prices_Industry) <- "Price|Final Energy|Industry|Electricity"
  #choose Residential consumer /r/
  sets_r <- readGDX('./blabla.gdx', "rSet")
  sets_r <- as.data.frame(sets_r)
  names(sets_r) <- "rSet"
  elec_prices_Residential <- VPriceElecIndResConsu[,,sets_r[1,1]]
  # complete names
  getNames(elec_prices_Residential) <- "Price|Final Energy|Residential|Electricity"
  #Combine Industrial and Residential OPEN-PROM
  elec_prices <- mbind(elec_prices_Industry, elec_prices_Residential)
  
  magpie_object <- NULL
  elec_prices <- add_dimension(elec_prices, dim = 3.2, add = "unit", nm = "US$2015/KWh")
  magpie_object <- mbind(magpie_object, elec_prices)
  
  # Link between Model Subsectors and Fuels
  sets4 <- readGDX('./blabla.gdx', "SECTTECH")
  
  # OPEN-PROM sectors
  sector <- c("TRANSE", "INDSE", "DOMSE", "NENSE", "PG")
  sector_name <- c("Transportation", "Industry", "Residential and Commercial", "Non Energy and Bunkers",
                   "Power and Steam Generation")
  
  
  # read GAMS set used for reporting of Final Energy
  sets <- readGDX('./blabla.gdx', "BALEF2EFS")
  names(sets) <- c("BAL", "EF")
  sets[["BAL"]] <- gsub("Gas fuels", "Gases", sets[["BAL"]])
  sets[["BAL"]] <- gsub("Steam", "Heat", sets[["BAL"]])
  
  z <- NULL
  for (y in 1 : length(sector)) {
    # read GAMS set used for reporting of Final Energy different for each sector
    sets6 <- NULL
    # load current OPENPROM set configuration for each sector
    sets6 <- readGDX('./blabla.gdx', sector[y])
    if (length(sets6) == 0) sets6 <- sector[y]
    if (sector[y] == "TRANSE") {
      sets6 <- c(sets6, "PB", "PN")
    }
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
    
    PRICE_by_sector_and_EF <- add_dimension(PRICE_by_sector_and_EF, dim = 3.2, add = "unit", nm = "KUS$2015/toe")
    magpie_object <- mbind(magpie_object, PRICE_by_sector_and_EF)
    
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
    
    PRICE_by_EF_OPEN_PROM <- add_dimension(PRICE_by_EF_OPEN_PROM, dim = 3.2, add = "unit", nm = "KUS$2015/toe")
    magpie_object <- mbind(magpie_object, PRICE_by_EF_OPEN_PROM)
    
    #fuel categories

    # aggregate from fuels to reporting fuel categories
    sum_open_prom <- iFuelPrice
    sum_open_prom <- as.quitte(sum_open_prom)
    
    # Energy Forms Aggregations
    EFtoEFA <- readGDX('./blabla.gdx', "EFtoEFA")
    EFtoEFA <- EFtoEFA[grep("^STE", EFtoEFA[,1]),]
    EFtoEFA[,2] <- "Heat"
    names(EFtoEFA) <- sub("EFA", "BAL", names(EFtoEFA))
    sets <- rbind(sets, EFtoEFA)
    
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
    
    sum_open_prom <- add_dimension(sum_open_prom, dim = 3.2, add = "unit", nm = "KUS$2015/toe")
    magpie_object <- mbind(magpie_object, sum_open_prom)
  }
  return(magpie_object)
}