reportFinalEnergy <- function(regs,rmap) {
  # read GAMS set used for reporting of Final Energy
  sets <- toolreadSets("sets.gms", "BALEF2EFS")
  sets[, 1] <- gsub("\"","",sets[, 1])
  sets <- separate_wider_delim(sets,cols = 1, delim = ".", names = c("BAL","EF"))
  sets[["EF"]] <- sub("\\(","",sets[["EF"]])
  sets[["EF"]] <- sub("\\)","",sets[["EF"]])
  sets <- separate_rows(sets,EF)
  sets$BAL <- gsub("Gas fuels", "Gases", sets$BAL)
  
  # add model OPEN-PROM data Total final energy consumnption (Mtoe)
  VConsFinEneCountry <- readGDX('./blabla.gdx', "VConsFinEneCountry", field = 'l')[regs, , ]
  
  # aggregate from PROM fuels to reporting fuel categories
  VConsFinEneCountry <- toolAggregate(VConsFinEneCountry[ , , unique(sets$EF)], dim = 3, rel = sets, from = "EF", to = "BAL")
  getItems(VConsFinEneCountry, 3) <- paste0("Final Energy|", getItems(VConsFinEneCountry, 3))
  
  # add model MENA_EDS data (choosing the correct variable from MENA by use of the MENA-PROM mapping)
  # Total final energy consumnption (Mtoe)
  MENA_EDS_VFeCons <- readSource("MENA_EDS", subtype =  map[map[["OPEN.PROM"]] == "VConsFinEneCountry", "MENA.EDS"])
  getRegions(MENA_EDS_VFeCons) <- sub("MOR", "MAR", getRegions(MENA_EDS_VFeCons)) # fix wrong region names in MENA
  
  # choose years and regions that both models have
  years <- intersect(getYears(MENA_EDS_VFeCons,as.integer=TRUE),getYears(VConsFinEneCountry,as.integer=TRUE))
  menaregs <- intersect(getRegions(MENA_EDS_VFeCons),regs)
  
  # aggregate from MENA fuels to reporting fuel categories
  MENA_EDS_VFeCons <- toolAggregate(MENA_EDS_VFeCons[,years,unique(sets$EF)],dim=3,rel=sets,from="EF",to="BAL")
  
  # complete names
  getItems(MENA_EDS_VFeCons, 3) <- paste0("Final Energy|", getItems(MENA_EDS_VFeCons, 3))
  
  # write data in mif file
  write.report(VConsFinEneCountry[,,],file="reporting.mif",model="OPEN-PROM",unit="Mtoe",scenario=scenario_name)
  write.report(MENA_EDS_VFeCons[menaregs,years,],file="reporting.mif",model="MENA-EDS",unit="Mtoe",append=TRUE,scenario=scenario_name)
  
  # filter ENERDATA by consumption
  consumption_ENERDATA <- readSource("ENERDATA", subtype =  "consumption", convert = TRUE)
  own_use_enerdata <- readSource("ENERDATA", subtype =  "own", convert = TRUE)
  own_use_enerdata <- own_use_enerdata[,,"Electricity own use of energy industries.Mtoe"]
  
  # map of enerdata and balance fuel
  map_enerdata <- toolGetMapping(name = "enerdata-by-fuel.csv",
                                 type = "sectoral",
                                 where = "mrprom")
  
  # choose years that both models have
  year <- Reduce(intersect, list(getYears(MENA_EDS_VFeCons,as.integer=TRUE),getYears(consumption_ENERDATA,as.integer=TRUE),getYears(VConsFinEneCountry,as.integer=TRUE)))
  
  # keep the variables from the map
  consumption_ENERDATA_variables <- consumption_ENERDATA[, year, map_enerdata[, 1]]
  
  # from Mt to Mtoe
  l <- getNames(consumption_ENERDATA_variables) == "Jet fuel final consumption.Mt"
  getNames(consumption_ENERDATA_variables)[l] <- "Jet fuel final consumption.Mtoe"
  consumption_ENERDATA_variables[,,"Jet fuel final consumption.Mtoe"] <- consumption_ENERDATA_variables[,,"Jet fuel final consumption.Mtoe"] / 1.027
  
  # remove Electricity own use of energy industries
  consumption_ENERDATA_variables[,,"Electricity final consumption.Mtoe"] <- consumption_ENERDATA_variables[,,"Electricity final consumption.Mtoe"] - ifelse(is.na(own_use_enerdata[,year,]), 0, own_use_enerdata[,year,])
  consumption_ENERDATA_variables <- as.quitte(consumption_ENERDATA_variables)
  names(map_enerdata) <- sub("ENERDATA", "variable", names(map_enerdata))
  
  # remove units
  map_enerdata[,1] <- sub("\\..*", "", map_enerdata[,1])
  
  # add a column with the fuels that match each variable of enerdata
  v <- left_join(consumption_ENERDATA_variables, map_enerdata, by = "variable")
  v["variable"] <- paste0("Final Energy|", v$fuel)
  v <- filter(v, period %in% years)
  v <- select(v , -c("fuel"))
  v <- as.quitte(v)
  v <- as.magpie(v)
  v[is.na(v)] <- 0
  v <- toolAggregate(v, rel = rmap)
  
  # write data in mif file
  write.report(v[intersect(getRegions(v),regs),,],file="reporting.mif",model="ENERDATA",unit="Mtoe",append=TRUE,scenario=scenario_name)
  
  # map of IEA and balance fuel
  map_IEA <- toolGetMapping(name = "IEA_projections.csv",
                                 type = "sectoral",
                                 where = "mrprom")
  
  IEA_all_dataset <- readSource("IEA_Energy_Projections_Balances", subtype = "all")
  year_IEA <- Reduce(intersect, list(getYears(MENA_EDS_VFeCons,as.integer=TRUE),getYears(IEA_all_dataset,as.integer=TRUE),getYears(VConsFinEneCountry,as.integer=TRUE)))
  IEA_Balances <- IEA_all_dataset[,year_IEA,"STEPS"][,,map_IEA[!is.na(map_IEA[,2]),2]][,,map_IEA[!is.na(map_IEA[,2]),3]]
  IEA_Balances <- as.quitte(IEA_Balances)
  
  # add a column with the fuels that match each variable of IEA
  names(map_IEA) <- sub("PRODUCT", "product", names(map_IEA))
  IEA_FC <- left_join(IEA_Balances, map_IEA, by = "product")
  IEA_FC["variable"] <- IEA_FC["OPEN.PROM"]
  IEA_FC <- filter(IEA_FC, period %in% year_IEA)
  IEA_FC <- select(IEA_FC , -c("OPEN.PROM","FLOW","product","flow"))
  IEA_FC <- as.quitte(IEA_FC)
  IEA_FC <- unique(IEA_FC)
  IEA_FC <- as.magpie(IEA_FC)
  IEA_FC[is.na(IEA_FC)] <- 0
  IEA_FC <- toolAggregate(IEA_FC, rel = rmap)
  
  # write data in mif file
  write.report(IEA_FC[intersect(getRegions(IEA_FC),regs),,],file="reporting.mif",model="IEA_projections",unit="Mtoe",append=TRUE,scenario=scenario_name)
  
  # Final Energy | "TRANSE" | "INDSE" | "DOMSE" | "NENSE"
  
  # Link between Model Subsectors and Fuels
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
  
  # OPEN-PROM sectors
  sector <- c("TRANSE", "INDSE", "DOMSE", "NENSE")
  sector_name <- c("Transportation", "Industry", "Tertiary", "Non Energy and Bunkers")
  
  # variables of OPEN-PROM related to sectors
  blabla_var <- c("VDemFinEneTranspPerFuel", "VConsFuel", "VConsFuel", "VConsFuel")
  
  for (y in 1 : length(sector)) {
    # read GAMS set used for reporting of Final Energy different for each sector
    sets6 <- toolreadSets("sets.gms", sector[y])
    sets6 <- separate_rows(sets6, paste0(sector[y],"(DSBS)"))
    sets6 <- as.data.frame(sets6)
    var_gdx <- readGDX('./blabla.gdx', blabla_var[y], field = 'l')[regs, , ]
    FCONS_by_sector_and_EF_open <- var_gdx[,,sets6[, 1]]
    
    map_subsectors <- sets4 %>% filter(SBS %in% as.character(sets6[, 1]))
    map_subsectors_IEA_by_sector <- map_subsectors
    
    if (sector[y] == "DOMSE") {
      sets13 <- filter(sets4, EF != "")
      #sets13 <- sets13 %>% filter(EF %in% getItems(var_gdx[,,sets6[, 1]],3.2))
      map_subsectors <- sets13 %>% filter(SBS %in% as.character(sets6[, 1]))
    }
    
    map_subsectors$EF = paste(map_subsectors$SBS, map_subsectors$EF, sep=".")
    
    # aggregate from PROM fuels to subsectors
    FCONS_by_sector_open <- toolAggregate(FCONS_by_sector_and_EF_open[,,unique(map_subsectors$EF)],dim=3,rel=map_subsectors,from="EF",to="SBS")
    getItems(FCONS_by_sector_open, 3) <- paste0("Final Energy|", sector_name[y],"|", getItems(FCONS_by_sector_open, 3))
    
    # add model MENA_EDS data (choosing the correct variable from MENA by use of the MENA-PROM mapping)
    FCONS_by_sector_and_EF_MENA_EDS <- readSource("MENA_EDS", subtype =  map[map[["OPEN.PROM"]] == blabla_var[y], "MENA.EDS"])
    getRegions(FCONS_by_sector_and_EF_MENA_EDS) <- sub("MOR", "MAR", getRegions(FCONS_by_sector_and_EF_MENA_EDS)) # fix wrong region names in MENA
    
    # choose years and regions that both models have
    years <- intersect(getYears(FCONS_by_sector_and_EF_MENA_EDS,as.integer=TRUE),getYears(FCONS_by_sector_open,as.integer=TRUE))
    
    # aggregate from PROM fuels to subsectors
    FCONS_by_sector_MENA <- toolAggregate(FCONS_by_sector_and_EF_MENA_EDS[,,unique(map_subsectors$EF)],dim=3,rel=map_subsectors,from="EF",to="SBS")
    getItems(FCONS_by_sector_MENA, 3) <- paste0("Final Energy|", sector_name[y],"|", getItems(FCONS_by_sector_MENA, 3))
    
    # write data in mif file
    write.report(FCONS_by_sector_open[,,],file="reporting.mif",model="OPEN-PROM",unit="Mtoe",append=TRUE,scenario=scenario_name)
    write.report(FCONS_by_sector_MENA[menaregs,years,],file="reporting.mif",model="MENA-EDS",unit="Mtoe",append=TRUE,scenario=scenario_name)
    
    # Final Energy by sector 
    sector_open <- dimSums(FCONS_by_sector_open, dim = 3, na.rm = TRUE)
    getItems(sector_open, 3) <- paste0("Final Energy|", sector_name[y])
    sector_mena <- dimSums(FCONS_by_sector_MENA, dim = 3, na.rm = TRUE)
    getItems(sector_mena, 3) <- paste0("Final Energy|", sector_name[y])
    
    # write data in mif file
    write.report(sector_open[,,],file="reporting.mif",model="OPEN-PROM",unit="Mtoe",append=TRUE,scenario=scenario_name)
    write.report(sector_mena[menaregs,years,],file="reporting.mif",model="MENA-EDS",unit="Mtoe",append=TRUE,scenario=scenario_name)
    
    # Energy Forms Aggregations
    sets5 <- toolreadSets("sets.gms", "EFtoEFA")
    sets5[5,] <- paste0(sets5[5,] , sets5[6,])
    sets5 <- sets5[ - 6,]
    sets5 <- as.data.frame(sets5)
    sets5 <- separate_wider_delim(sets5,cols = 1, delim = ".", names = c("EF","EFA"))
    sets5[["EF"]] <- sub("\\(","",sets5[["EF"]])
    sets5[["EF"]] <- sub("\\)","",sets5[["EF"]])
    sets5 <- separate_rows(sets5,EF)
    
    # Add electricity, Hydrogen, Biomass and Waste
    ELC <- toolreadSets("sets.gms", "ELCEF")
    sets5[nrow(sets5) + 1, ] <- ELC[1,1]
    sets5[nrow(sets5) + 1, ] <- "H2F"
    sets5[nrow(sets5) + 1, ] <- "BMSWAS"
    
    sets10 <- sets5 %>% filter(EF %in% getItems(var_gdx[,,sets6[, 1]],3.2))
    
    # Aggregate model OPEN-PROM by subsector and by energy form 
    by_energy_form_and_by_subsector_open <- toolAggregate(FCONS_by_sector_and_EF_open[,,as.character(unique(sets10$EF))],dim=3.2,rel=sets10,from="EF",to="EFA")
    
    # Aggregate model MENA_EDS by subsector and by energy form
    by_energy_form_and_by_subsector_mena <- toolAggregate(FCONS_by_sector_and_EF_MENA_EDS[,,sets6[, 1]][,,as.character(unique(sets10$EF))],dim=3.2,rel=sets10,from="EF",to="EFA")
    
    # sector by subsector and by energy form form OPEN-PROM
    open_by_subsector_by_energy_form <- by_energy_form_and_by_subsector_open
    getItems(open_by_subsector_by_energy_form, 3.1) <- paste0("Final Energy|", sector_name[y],"|", getItems(open_by_subsector_by_energy_form, 3.1))
    
    # sector by subsector and by energy form MENA_EDS
    mena_by_subsector_by_energy_form <- by_energy_form_and_by_subsector_mena
    getItems(mena_by_subsector_by_energy_form, 3.1) <- paste0("Final Energy|", sector_name[y],"|", getItems(mena_by_subsector_by_energy_form, 3.1))
    
    # write data in mif file
    write.report(open_by_subsector_by_energy_form[,,],file="reporting.mif",model="OPEN-PROM",unit="Mtoe",append=TRUE,scenario=scenario_name)
    write.report(mena_by_subsector_by_energy_form[menaregs,years,],file="reporting.mif",model="MENA-EDS",unit="Mtoe",append=TRUE,scenario=scenario_name)
    
    # sector_by_energy_form
    by_energy_form_open <- dimSums(by_energy_form_and_by_subsector_open, 3.1, na.rm = TRUE)
    getItems(by_energy_form_open,3.1) <- paste0("Final Energy|", sector_name[y],"|", getItems(by_energy_form_open, 3.1))
    by_energy_form_mena <- dimSums(by_energy_form_and_by_subsector_mena,3.1, na.rm = TRUE)
    getItems(by_energy_form_mena, 3.1) <- paste0("Final Energy|", sector_name[y],"|", getItems(by_energy_form_mena, 3.1))
    
    # write data in mif file
    write.report(by_energy_form_open[,,],file="reporting.mif",model="OPEN-PROM",unit="Mtoe",append=TRUE,scenario=scenario_name)
    write.report(by_energy_form_mena[menaregs,years,],file="reporting.mif",model="MENA-EDS",unit="Mtoe",append=TRUE,scenario=scenario_name)
    
    ###  USE READSOURCE INSTEAD CALCOUTPUT
    # load data source (ENERDATA)
    subtp <- sector[y]
    x <- readSource("ENERDATA", "consumption", convert = TRUE)
    
    # filter years
    fStartHorizon <- readEvalGlobal(system.file(file.path("extdata", "main.gms"), package = "mrprom"))["fStartHorizon"]
    lastYear <- sub("y", "", tail(sort(getYears(x)), 1))
    x <- x[, c(fStartHorizon:lastYear), ]
    
    # load current OPENPROM set configuration
    sets <- toolreadSets(system.file(file.path("extdata", "sets.gms"), package = "mrprom"), subtp)
    sets <- unlist(strsplit(sets[, 1], ","))
    
    # use enerdata-openprom mapping to extract correct data from source
    map_fc <- toolGetMapping(name = "prom-enerdata-fucon-mapping.csv",
                          type = "sectoral",
                          where = "mrprom")
    maps <- map_fc
    
    ## filter mapping to keep only XXX sectors
    map_fc <- filter(map_fc, map_fc[, "SBS"] %in% sets)
    
    ## ..and only items that have an enerdata-prom mapping
    enernames <- unique(map_fc[!is.na(map_fc[, "ENERDATA"]), "ENERDATA"])
    map_fc <- map_fc[map_fc[, "ENERDATA"] %in% enernames, ]
    
    ## filter data to keep only XXX data
    enernames <- unique(map_fc[!is.na(map_fc[, "ENERDATA"]), "ENERDATA"])
    x <- x[, , enernames]
    
    ## for oil, rename unit from Mt to Mtoe
    if (any(grepl("oil", getItems(x, 3.1)) & grepl("Mt$", getNames(x)))) {
      tmp <- x[, , "Mt"]
      getItems(tmp, 3.2) <- "Mtoe"
      x <- mbind(x[, , "Mtoe"], tmp)
      map_fc[["ENERDATA"]] <-  sub(".Mt$", ".Mtoe", map_fc[["ENERDATA"]])
    }
    
    ## rename variables to openprom names
    out <- NULL
    
    ## rename variables from ENERDATA to openprom names
    ff <- paste(map_fc[, 2], map_fc[, 3], sep = ".")
    iii <- 0
    
    ### add a dummy dimension to data because mapping has 3 dimensions, and data only 2
    for (ii in map_fc[, "ENERDATA"]) {
      iii <- iii + 1
      out <- mbind(out, setNames(add_dimension(x[, , ii], dim = 3.2), paste0(ff[iii], ".", sub("^.*.\\.", "", getNames(x[, , ii])))))
    }
    x <- out
    
    if (subtp == "TRANSE") {
      
      a6 <- readSource("IRF", subtype = "inland-surface-passenger-transport-by-rail")
      #million pKm/yr
      a7 <- readSource("IRF", subtype = "inland-surface-freight-transport-by-rail")
      #million tKm/yr
      a6 <- a6[, Reduce(intersect, list(getYears(a6), getYears(a7), getYears(x))), ]
      a7 <- a7[, Reduce(intersect, list(getYears(a6), getYears(a7), getYears(x))), ]
      x <- x[, Reduce(intersect, list(getYears(a6), getYears(a7), getYears(x))), ]
      
      #inland-surface-passenger-transport-by-rail / total inland-surface transport-by-rail
      x[, , "PT.GDO.Mtoe"] <- x[, , "PT.GDO.Mtoe"] * (a6 / (a6 + a7))
      #inland-surface-freight-transport-by-rail / total inland-surface
      x[, , "GT.GDO.Mtoe"] <- x[, , "GT.GDO.Mtoe"] * (a7 / (a6 + a7))
      
      x[, , "PT.ELC.Mtoe"] <- x[, , "PT.ELC.Mtoe"] * (a6 / (a6 + a7))
      x[, , "GT.ELC.Mtoe"] <- x[, , "GT.ELC.Mtoe"] * (a7 / (a6 + a7))
      
      a8 <- readSource("IRF", subtype = "passenger-car-traffic")
      #million pKm/yr
      a9 <- readSource("IRF", subtype = "inland-surface-freight-transport-by-road")
      #million tKm/yr
      a8 <- a8[, Reduce(intersect, list(getYears(a8), getYears(a9), getYears(x))), ]
      a9 <- a9[, Reduce(intersect, list(getYears(a8), getYears(a9), getYears(x))), ]
      x <- x[, Reduce(intersect, list(getYears(a8), getYears(a9), getYears(x))), ]
      
      #passenger-car-traffic / total inland-surface-transport-by-road
      out1 <- (a8 / (a8 + a9))
      #inland-surface-freight-transport-by-road / total inland-surface-transport-by-road
      out2 <- (a9 / (a8 + a9))
      #out1 + out2 have 40 countries and data for 6 years
      out1 <- dimSums(out1, dim = c(1, 2, 3), na.rm = TRUE) / (40 * 6)
      out2 <- dimSums(out2, dim = c(1, 2, 3), na.rm = TRUE) / (40 * 6)

      x[, , "PC.GDO.Mtoe"] <- x[, , "PC.GDO.Mtoe"] * out1
      x[, , "GU.GDO.Mtoe"] <- x[, , "GU.GDO.Mtoe"] * out2
      
      l <- getNames(x) == "PA.KRS.Mt"
      getNames(x)[l] <- "PA.KRS.Mtoe"
      #from Mt to Mtoe
      x[,,"PA.KRS.Mtoe"] <- x[,,"PA.KRS.Mtoe"] / 1.027
    }
    
    x[is.na(x)] <- 10^-6
    
    FuelCons_enerdata <- x
    
    year <- Reduce(intersect, list(getYears(FCONS_by_sector_MENA,as.integer=TRUE),getYears(FCONS_by_sector_open,as.integer=TRUE),getYears(FuelCons_enerdata,as.integer=TRUE)))
    FuelCons_enerdata <- FuelCons_enerdata[,year,]
    
    map_subsectors_ener <- sets4 %>% filter(SBS %in% as.character(sets6[,1]))
    
    map_subsectors_ener$EF = paste(map_subsectors_ener$SBS, "Mtoe",map_subsectors_ener$EF, sep=".")
    
    # filter to have only the variables which are in enerdata
    FuelCons_enerdata <- as.quitte(FuelCons_enerdata)
    FuelCons_enerdata <- as.magpie(FuelCons_enerdata)
    map_subsectors_ener <- map_subsectors_ener %>% filter(EF %in% getItems(FuelCons_enerdata,3))
    
    # aggregate from enerdata fuels to subsectors
    enerdata_by_sector <- toolAggregate(FuelCons_enerdata[,,as.character(unique(map_subsectors_ener$EF))],dim=3,rel=map_subsectors_ener,from="EF",to="SBS")
    getItems(enerdata_by_sector, 3) <- paste0("Final Energy|", sector_name[y],"|", getItems(enerdata_by_sector, 3))
    
    # country aggregation
    enerdata_by_sector <- toolAggregate(enerdata_by_sector, rel = rmap)
    
    # write data in mif file
    write.report(enerdata_by_sector[intersect(getRegions(enerdata_by_sector),regs),year,],file="reporting.mif",model="ENERDATA",unit="Mtoe",append=TRUE,scenario=scenario_name)
    
    # Final Energy enerdata
    FE_ener <- dimSums(enerdata_by_sector, dim = 3, na.rm = TRUE)
    getItems(FE_ener, 3) <- paste0("Final Energy|", sector_name[y])
    
    # write data in mif file
    write.report(FE_ener[intersect(getRegions(FE_ener),regs),year,],file="reporting.mif",model="ENERDATA",unit="Mtoe",append=TRUE,scenario=scenario_name)
    
    map_subsectors_ener2 <- sets10
    # filter to have only the variables which are in enerdata
    map_subsectors_ener2 <- map_subsectors_ener2 %>% filter(EF %in% getItems(FuelCons_enerdata,3.3))
    
    # Aggregate model enerdata by subsector and by energy form
    enerdata_by_EF_and_sector <- toolAggregate(FuelCons_enerdata[,year,as.character(unique(map_subsectors_ener2$EF))],dim=3.3,rel=map_subsectors_ener2,from="EF",to="EFA")
    
    # enerdata by subsector and by energy form
    enerdata_by_subsector_by_energy_form <- enerdata_by_EF_and_sector
    enerdata_by_subsector_by_energy_form <- dimSums(enerdata_by_subsector_by_energy_form, 3.2, na.rm = TRUE)
    getItems(enerdata_by_subsector_by_energy_form, 3.1) <- paste0("Final Energy|", sector_name[y],"|", getItems(enerdata_by_subsector_by_energy_form, 3.1))
    
    # country aggregation
    enerdata_by_subsector_by_energy_form <- toolAggregate(enerdata_by_subsector_by_energy_form, rel = rmap)
    
    # write data in mif file
    write.report(enerdata_by_subsector_by_energy_form[intersect(getRegions(enerdata_by_subsector_by_energy_form),regs),year,],file="reporting.mif",model="ENERDATA",unit="Mtoe",append=TRUE,scenario=scenario_name)
    
    # Aggregate model enerdata by energy form
    enerdata_by_energy_form <- dimSums(enerdata_by_EF_and_sector, 3.1, na.rm = TRUE)
    getItems(enerdata_by_energy_form,3) <- paste0("Final Energy|", sector_name[y],"|", getItems(enerdata_by_energy_form, 3.2))
   
    # country aggregation
    enerdata_by_energy_form <- toolAggregate(enerdata_by_energy_form, rel = rmap)
    
    # write data in mif file
    write.report(enerdata_by_energy_form[intersect(getRegions(enerdata_by_energy_form),regs),year,],file="reporting.mif",model="ENERDATA",unit="Mtoe",append=TRUE,scenario=scenario_name)
    
    # Add IEA data from world balances
    IEA <- NULL
    map_IEA <- maps %>% drop_na(IEA)
    IEA_WB <- NULL
    map_IEA <- map_IEA %>% filter(SBS %in% map_subsectors_IEA_by_sector$SBS)
    
    # the map has a column SBS which corresponds to flow of IEA
    for (ii in unique(map_IEA[, "flow"])) {
      d <- readSource("IEA", subtype = as.character(ii))
      d <- d / 1000 #ktoe to mtoe
      d <- as.quitte(d)
      # each flow has some products as it is the EF column of map
      m <- filter(map_IEA, map_IEA[["flow"]] == ii)
      # for each product of IEA data
      region <- NULL
      period <- NULL
      
      qb <- filter(d, product %in% m[, 4])
      qb <- select((qb), c(region, period, value, product, flow))
      
      if (ii == "MARBUNK") {
        qb["value"] <- - qb["value"]
      }
      
      qb <- filter(qb, qb[["period"]] %in% fStartHorizon : tail(qb[["period"]]))
      IEA_WB <- rbind(IEA_WB, qb)
    }
    
    IEA_WB["unit"] <- "Mtoe"
    
    
    names(map_IEA) <- gsub("IEA", "product", names(map_IEA))
    IEA_change_names <- left_join(IEA_WB, map_IEA, by = c("product", "flow"))
    
    IEA_data_WB <- select((IEA_change_names), c(region, period, value, SBS, EF, unit))
    
    names(IEA_data_WB) <- gsub("SBS", "variable", names(IEA_data_WB))
    names(IEA_data_WB) <- gsub("EF", "new", names(IEA_data_WB))
    
    IEA_data_WB <- as.quitte(IEA_data_WB)
    IEA_data_WB <- as.magpie(IEA_data_WB)
    
    map_subsectors_IEA2 <- sets10
    
    # filter to have only the variables which are in enerdata
    map_subsectors_IEA2 <- map_subsectors_IEA2 %>% filter(EF %in% getItems(IEA_data_WB,3.3))
    
    map_subsectors_IEA <- map_subsectors_IEA_by_sector
    
    map_subsectors_IEA$EF = paste(map_subsectors_IEA$SBS, "Mtoe",map_subsectors_IEA$EF, sep=".")
    map_subsectors_IEA <- map_subsectors_IEA %>% filter(EF %in% getItems(IEA_data_WB,3))
    
    year <- Reduce(intersect, list(getYears(FCONS_by_sector_MENA,as.integer=TRUE),getYears(FCONS_by_sector_open,as.integer=TRUE),getYears(IEA_data_WB,as.integer=TRUE)))
    IEA_data_WB <- IEA_data_WB[,year,]
    
    # aggregate from IEA fuels to subsectors
    IEA_by_sector <- toolAggregate(IEA_data_WB[,,as.character(unique(map_subsectors_IEA$EF))],dim=3,rel=map_subsectors_IEA,from="EF",to="SBS")
    getItems(IEA_by_sector, 3) <- paste0("Final Energy|", sector_name[y],"|", getItems(IEA_by_sector, 3))
    
    # country aggregation
    IEA_by_sector <- toolAggregate(IEA_by_sector, rel = rmap)
    
    # write data in mif file
    write.report(IEA_by_sector[intersect(getRegions(IEA_by_sector),regs),year,],file="reporting.mif",model="IEA_WB",unit="Mtoe",append=TRUE,scenario=scenario_name)
    
    #Final Energy IEA
    FE_IEA <- dimSums(IEA_by_sector, dim = 3, na.rm = TRUE)
    getItems(FE_IEA, 3) <- paste0("Final Energy|", sector_name[y])
    
    # write data in mif file
    write.report(FE_IEA[intersect(getRegions(FE_IEA),regs),year,],file="reporting.mif",model="IEA_WB",unit="Mtoe",append=TRUE,scenario=scenario_name)
    
    # Aggregate model IEA by subsector and by energy form
    IEA_by_EF_and_sector <- toolAggregate(IEA_data_WB[,year,as.character(unique(map_subsectors_IEA2$EF))],dim=3.3,rel=map_subsectors_IEA2,from="EF",to="EFA")
    
    # IEA by subsector and by energy form
    IEA_by_subsector_by_energy_form <- IEA_by_EF_and_sector
    IEA_by_subsector_by_energy_form <- dimSums(IEA_by_subsector_by_energy_form, 3.2, na.rm = TRUE)
    getItems(IEA_by_subsector_by_energy_form, 3.1) <- paste0("Final Energy|", sector_name[y],"|", getItems(IEA_by_subsector_by_energy_form, 3.1))
    
    # country aggregation
    IEA_by_subsector_by_energy_form <- toolAggregate(IEA_by_subsector_by_energy_form, rel = rmap)
    
    # write data in mif file
    write.report(IEA_by_subsector_by_energy_form[intersect(getRegions(IEA_by_subsector_by_energy_form),regs),year,],file="reporting.mif",model="IEA_WB",unit="Mtoe",append=TRUE,scenario=scenario_name)
    
    # Aggregate model IEA by energy form
    IEA_by_energy_form <- dimSums(IEA_by_EF_and_sector, 3.1, na.rm = TRUE)
    getItems(IEA_by_energy_form,3) <- paste0("Final Energy|", sector_name[y],"|", getItems(IEA_by_energy_form, 3.2))
    
    # country aggregation
    IEA_by_energy_form <- toolAggregate(IEA_by_energy_form, rel = rmap)
    
    # write data in mif file
    write.report(IEA_by_energy_form[intersect(getRegions(IEA_by_energy_form),regs),year,],file="reporting.mif",model="IEA_WB",unit="Mtoe",append=TRUE,scenario=scenario_name)
    
    #############    Final Energy consumption from Navigate
    # load current OPENPROM set configuration
    sets_Navigate <- toolreadSets(system.file(file.path("extdata", "sets.gms"), package = "mrprom"), sector[y])
    sets_Navigate <- unlist(strsplit(sets_Navigate[, 1], ","))
    
    # use navigate-openprom mapping to extract correct data from source
    map_Navigate <- toolGetMapping(name = "prom-navigate-fucon-mapping.csv",
                                   type = "sectoral",
                                   where = "mrprom")
    maps <- map_Navigate
     
    # filter mapping to keep only XXX sectors
    map_Navigate <- filter(map_Navigate, map_Navigate[, "SBS"] %in% sets_Navigate)
    
    # ..and only items that have an Navigate-prom mapping
    Navigate <- map_Navigate[!is.na(map_Navigate[, "Navigate"]), "Navigate"]
    map_Navigate <- map_Navigate[map_Navigate[, "Navigate"] %in% Navigate, ]
    
    # remove the empty cells from mapping
    map_Navigate <- map_Navigate[!(map_Navigate[, "Navigate"] == ""), ]
    
    # filter navigate data by scenario different for each sector
    if (sector[y] %in% c("DOMSE", "NENSE")) {
      x1 <- readSource("Navigate", subtype = "SUP_NPi_Default", convert = TRUE)
      x2 <- readSource("Navigate", subtype = "NAV_Dem-NPi-ref", convert = TRUE)
      
      #keep common years that exist in the scenarios
      years <- intersect(getYears(x1,as.integer=TRUE),getYears(x2,as.integer=TRUE))
      x <- mbind(x1[, years,], x2[, years,])
    }
    
    # for TRANSE use of NAV_Ind_NPi because it has truck data
    if (sector[y] %in% c("INDSE", "TRANSE")) {
      x1 <- readSource("Navigate", subtype = "SUP_NPi_Default", convert = TRUE)
      x2 <- readSource("Navigate", subtype = "NAV_Ind_NPi", convert = TRUE)
      
      # keep common years that exist in the scenarios
      years <- intersect(getYears(x1,as.integer=TRUE),getYears(x2,as.integer=TRUE))
      x <- mbind(x1[, years,], x2[, years,])
    }
    
    # filter data to keep only Navigate variables
    x <- x[, , map_Navigate[, "Navigate"]]
    
    # EJ to Mtoe
    x <- x * 23.8846
    getItems(x, 3.4) <- "Mtoe"
    x <- as.quitte(x)
    value.x <- NULL
    value.y <- NULL
    value <- NULL
    
    # if SUP_NPi_Default has NA take the value of the second scenario
    x <- full_join(x[which(x[,2] == "SUP_NPi_Default"),], x[which(x[,2] != "SUP_NPi_Default"),], by = c("model", "scenario", "region", "period", "variable", "unit")) %>%
      mutate(value = ifelse(is.na(value.x), value.y, value.x)) %>%
      select(-c("value.x", "value.y"))
    
    
    # rename variables from Navigate to openprom names
    names(map_Navigate) <- gsub("Navigate", "variable", names(map_Navigate))
    x <- left_join(x, map_Navigate[,  c(2,3,6)], by = "variable")
    
    # drop variable names of navigate
    x <- select(x, -c("variable"))
    
    # rename columns of data
    names(x) <- gsub("SBS", "variable", names(x))
    names(x) <- gsub("EF", "new", names(x))
    
    x <- as.quitte(x) %>% as.magpie()
    # set NA to 0
    x[is.na(x)] <- 10^-6
    
    map_subsectors_Navigate2 <- sets10
    
    # filter to have only the variables which are in enerdata
    map_subsectors_Navigate2 <- map_subsectors_Navigate2 %>% filter(EF %in% getItems(x,3.5))
    x <- as.quitte(x)
    x <- as.magpie(x)
    
    year <- Reduce(intersect, list(getYears(FCONS_by_sector_open,as.integer=TRUE),getYears(x,as.integer=TRUE)))
    x <- x[,year,]
    
    Navigate_by_sector <- dimSums(x, dim = 3.5)

    getItems(Navigate_by_sector, 3.3) <- paste0("Final Energy|", sector_name[y],"|", getItems(Navigate_by_sector, 3.3))
    
    # country aggregation
    Navigate_by_sector <- toolAggregate(Navigate_by_sector, rel = rmap)
    
    # write data in mif file, sector INDSE, works without aggregation in the next step
    if (!(sector[y] %in% c("INDSE"))) {
      write.report(Navigate_by_sector[intersect(getRegions(Navigate_by_sector),regs),year,],file="reporting.mif",append=TRUE)
    }
    
    # Aggregate model Navigate by subsector and by energy form
    Navigate_by_EF_and_sector <- toolAggregate(x[,,as.character(unique(map_subsectors_Navigate2$EF))],dim=c(3.5),rel=map_subsectors_Navigate2,from="EF",to="EFA")
    
    # Navigate by subsector and by energy form
    Navigate_by_subsector_by_energy_form <- Navigate_by_EF_and_sector
    Navigate_by_subsector_by_energy_form <- dimSums(Navigate_by_subsector_by_energy_form, 3.2, na.rm = TRUE)
    Navigate_by_subsector_by_energy_form <- collapseDim(Navigate_by_subsector_by_energy_form,3.2)
    
    getItems(Navigate_by_subsector_by_energy_form, 3.2) <- paste0("Final Energy|", sector_name[y],"|", getItems(Navigate_by_subsector_by_energy_form, 3.2))

    # country aggregation
    Navigate_by_subsector_by_energy_form <- toolAggregate(Navigate_by_subsector_by_energy_form, rel = rmap)
    
    # write data in mif file
    #the energy forms are calculated by variable in the next step and by aggegation
    #write.report(Navigate_by_subsector_by_energy_form[intersect(getRegions(Navigate_by_subsector_by_energy_form),regs),year,],file="reporting.mif",model="Navigate",unit="Mtoe",append=TRUE,scenario=scenario_name)
    
    # Aggregate model Navigate by energy form
    Navigate_by_energy_form6 <- Navigate_by_EF_and_sector
    
    getItems(Navigate_by_energy_form6,3.3) <- paste0("Final Energy|", sector_name[y],"|", getItems(Navigate_by_energy_form6, 3.3))
    
    # country aggregation
    Navigate_by_energy_form6 <- toolAggregate(Navigate_by_energy_form6, rel = rmap)
    
    # write data in mif file
    write.report(Navigate_by_energy_form6[intersect(getRegions(Navigate_by_energy_form6),regs),year,],file="reporting.mif",append=TRUE)
    
  }
  
  # Add IEA Total
  
  map_IEA_Total <- toolGetMapping(name = "IEA-by-fuel.csv",
                                 type = "sectoral",
                                 where = "mrprom")
  map_IEA_Total <- map_IEA_Total %>% drop_na("product")
  map_IEA_Total <- map_IEA_Total %>% select(-"X")
  IEA_Total <- NULL
  for (ii in unique(map_IEA_Total[, "flow"])) {
    d <- readSource("IEA", subtype = as.character(ii))
    d <- d / 1000 #ktoe to mtoe
    d <- as.quitte(d)
    
    # each flow has some products as it is the EF column of map
    m <- filter(map_IEA_Total, map_IEA_Total[["flow"]] == ii)
    
    # for each product of IEA data
    region <- NULL
    period <- NULL
    
    qb <- filter(d, product %in% m[["product"]])
    qb <- select((qb), c(region, period, value, product, flow))
    
    qb <- filter(qb, qb[["period"]] %in% fStartHorizon : max(qb[["period"]]))
    IEA_Total <- rbind(IEA_Total, qb)
  }
  
  magpie_IEA_Total <- as.quitte(IEA_Total) %>% as.magpie()
  
  # choose years that both models have
  year <- Reduce(intersect, list(getYears(MENA_EDS_VFeCons,as.integer=TRUE),getYears(magpie_IEA_Total,as.integer=TRUE),getYears(VConsFinEneCountry,as.integer=TRUE)))
  
  consumption_IEA_variables <- as.quitte(IEA_Total)

  # add a column with the fuels that match each variable of enerdata
  IEA_Balances_Total <- left_join(consumption_IEA_variables, map_IEA_Total, by = c("product", "flow"))
  IEA_Balances_Total["variable"] <- paste0("Final Energy|", IEA_Balances_Total$fuel)
  IEA_Balances_Total["unit"] <- "Mtoe"
  IEA_Balances_Total <- IEA_Balances_Total[, c(1, 2, 3, 4, 5, 6, 9)]
  IEA_Balances_Total <- filter(IEA_Balances_Total, period %in% year)
  IEA_Balances_Total <- as.quitte(IEA_Balances_Total)
  IEA_Balances_Total <- as.magpie(IEA_Balances_Total)
  IEA_Balances_Total[is.na(IEA_Balances_Total)] <- 0
  IEA_Balances_Total <- toolAggregate(IEA_Balances_Total, rel = rmap)
  
  # write data in mif file
  write.report(IEA_Balances_Total[intersect(getRegions(IEA_Balances_Total),regs),,],file="reporting.mif",model="IEA_Total",unit="Mtoe",append=TRUE,scenario=scenario_name)
  
  ########## Add Final Energy total to reporting Navigate
  
  # Map Final Energy Navigate
  map_Navigate_Total <- toolGetMapping(name = "Navigate-by-fuel.csv",
                                  type = "sectoral",
                                  where = "mrprom")
  
  map_Navigate_Total <- map_Navigate_Total %>% drop_na("Navigate")
  
  # filter Navigate by scenarios
  x1 <- readSource("Navigate", subtype = "SUP_NPi_Default", convert = TRUE)
  x2 <- readSource("Navigate", subtype = "NAV_Dem-NPi-ref", convert = TRUE)
  x3 <- readSource("Navigate", subtype = "NAV_Ind_NPi", convert = TRUE)
  
  # keep common years that exist in the scenarios
  x1 <- x1[, Reduce(intersect, list(getYears(x1), getYears(x2), getYears(x3))), ]
  x2 <- x2[, Reduce(intersect, list(getYears(x1), getYears(x2), getYears(x3))), ]
  x3 <- x3[, Reduce(intersect, list(getYears(x1), getYears(x2), getYears(x3))), ]
 
  x <- mbind(x1, x2, x3)
  
  # EJ to Mtoe
  x <- x * 23.8846
  
  # filter data to keep only Navigate map variables
  navigate_total <- x[,,map_Navigate_Total[,"Navigate"]]
  
  # choose years that both models have
  year <- Reduce(intersect, list(getYears(navigate_total,as.integer=TRUE),getYears(VConsFinEneCountry,as.integer=TRUE)))
  
  Navigate_Balances_Total <- as.quitte(navigate_total)
  names(map_Navigate_Total) <- sub("Navigate", "variable", names(map_Navigate_Total))
  
  # add a column with the fuels that match each variable of Navigate
  Navigate_Balances_Total <- left_join(Navigate_Balances_Total, map_Navigate_Total, by = c("variable"))
  
  # drop column variable and rename column fuel
  Navigate_Balances_Total <- select(Navigate_Balances_Total, -"variable")
  names(Navigate_Balances_Total) <- sub("fuel", "variable", names(Navigate_Balances_Total))
  
  # EJ to Mtoe
  Navigate_Balances_Total["unit"] <- "Mtoe"
  
  # choose common years that navigate and OPEN-PROM models have
  Navigate_Balances_Total <- filter(Navigate_Balances_Total, period %in% year)
  
  qNavigate_Balances_Total <- as.quitte(Navigate_Balances_Total)
  
  # take the sum of each subsector(for DOMSE and NENSE)
  qNavigate_Balances_Total <- mutate(qNavigate_Balances_Total, value = sum(value, na.rm = TRUE), .by = c("model", "scenario", "region", "variable", "unit", "period"))
  
  # remove duplicates
  qNavigate_Balances_Total <- distinct(qNavigate_Balances_Total)
  
  Navigate_Balances_Total <- as.quitte(qNavigate_Balances_Total) %>% as.magpie()
  
  #country aggregation
  Navigate_Balances_Total <- toolAggregate(Navigate_Balances_Total, rel = rmap)
  
  Navigate_Balances_Total[is.na(Navigate_Balances_Total)] <- 0
  
  # write data in mif file
  write.report(Navigate_Balances_Total[intersect(getRegions(Navigate_Balances_Total),regs),,],file="reporting.mif",append=TRUE)
  
}
