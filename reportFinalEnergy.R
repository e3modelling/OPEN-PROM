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
  consumption_ENERDATA <- readSource("ENERDATA", subtype =  "consumption", convert = TRUE)
  
  # map of enerdata and balance fuel
  map_enerdata <- toolGetMapping(name = "enerdata-by-fuel.csv",
                                 type = "sectoral",
                                 where = "mrprom")
  
  # choose years that both models have
  year <- Reduce(intersect, list(getYears(MENA_EDS_VFeCons,as.integer=TRUE),getYears(consumption_ENERDATA,as.integer=TRUE),getYears(VFeCons,as.integer=TRUE)))
  #keep the variables from the map
  consumption_ENERDATA_variables <- consumption_ENERDATA[, year, map_enerdata[, 1]]
  consumption_ENERDATA_variables <- as.quitte(consumption_ENERDATA_variables)
  names(map_enerdata) <- sub("ENERDATA", "variable", names(map_enerdata))
  #remove units
  map_enerdata[,1] <- sub("\\..*", "", map_enerdata[,1])
  #add a column with the fuels that match each variable of enerdata
  v <- left_join(consumption_ENERDATA_variables, map_enerdata, by = "variable")
  v["variable"] <- paste0("Final Energy ", v$fuel)
  v <- filter(v, period %in% years)
  v <- select(v , -c("fuel"))
  v <- as.quitte(v)
  v <- as.magpie(v)
  v[is.na(v)] <- 0
  v <- toolAggregate(v, rel = rmap)
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
    FCONS_by_sector_and_EF_open <- var_gdx[,,sets6[, 1]]
    
    map_subsectors <- sets4 %>% filter(SBS %in% as.character(sets6[, 1]))
    
    if (sector[y] == "DOMSE") {
      sets13 <- filter(sets4, EF != "")
      sets13 <- sets13 %>% filter(EF %in% getItems(var_gdx[,,sets6[, 1]],3.2))
      map_subsectors <- sets13 %>% filter(SBS %in% as.character(sets6[, 1]))
    }
    
    map_subsectors$EF = paste(map_subsectors$SBS, map_subsectors$EF, sep=".")
    
    FCONS_by_sector_open <- toolAggregate(FCONS_by_sector_and_EF_open[,,unique(map_subsectors$EF)],dim=3,rel=map_subsectors,from="EF",to="SBS")
    getItems(FCONS_by_sector_open, 3) <- paste0("Final Energy ", sector[y]," ", getItems(FCONS_by_sector_open, 3))
    
    #add model MENA_EDS data (choosing the correct variable from MENA by use of the MENA-PROM mapping)
    FCONS_by_sector_and_EF_MENA_EDS <- readSource("MENA_EDS", subtype =  map[map[["OPEN.PROM"]] == blabla_var[y], "MENA.EDS"])
    getRegions(FCONS_by_sector_and_EF_MENA_EDS) <- sub("MOR", "MAR", getRegions(FCONS_by_sector_and_EF_MENA_EDS)) # fix wrong region names in MENA
    # choose years and regions that both models have
    years <- intersect(getYears(FCONS_by_sector_and_EF_MENA_EDS,as.integer=TRUE),getYears(FCONS_by_sector_open,as.integer=TRUE))
    
    FCONS_by_sector_MENA <- toolAggregate(FCONS_by_sector_and_EF_MENA_EDS[,,unique(map_subsectors$EF)],dim=3,rel=map_subsectors,from="EF",to="SBS")
    getItems(FCONS_by_sector_MENA, 3) <- paste0("Final Energy ", sector[y]," ", getItems(FCONS_by_sector_MENA, 3))
    
    # write data in mif file
    write.report(FCONS_by_sector_open[,,],file="reporting.mif",model="OPEN-PROM",unit="Mtoe",append=TRUE,scenario=scenario_name)
    write.report(FCONS_by_sector_MENA[menaregs,years,],file="reporting.mif",model="MENA-EDS",unit="Mtoe",append=TRUE,scenario=scenario_name)
    
    #Final Energy by sector 
    sector_open <- dimSums(FCONS_by_sector_open, dim = 3, na.rm = TRUE)
    getItems(sector_open, 3) <- paste0("Final Energy ", sector[y])
    sector_mena <- dimSums(FCONS_by_sector_MENA, dim = 3, na.rm = TRUE)
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
    by_energy_form_and_by_subsector_open <- toolAggregate(FCONS_by_sector_and_EF_open[,,as.character(unique(sets10$EF))],dim=3.2,rel=sets10,from="EF",to="EFA")
    
    #Aggregate model MENA_EDS by subsector and by energy form
    by_energy_form_and_by_subsector_mena <- toolAggregate(FCONS_by_sector_and_EF_MENA_EDS[,,sets6[, 1]][,,as.character(unique(sets10$EF))],dim=3.2,rel=sets10,from="EF",to="EFA")
    
    #sector by subsector and by energy form form OPEN-PROM
    open_by_subsector_by_energy_form <- by_energy_form_and_by_subsector_open
    getItems(open_by_subsector_by_energy_form, 3.1) <- paste0("Final Energy ", sector[y]," ", getItems(open_by_subsector_by_energy_form, 3.1))
    
    #sector by subsector and by energy form MENA_EDS
    mena_by_subsector_by_energy_form <- by_energy_form_and_by_subsector_mena
    getItems(mena_by_subsector_by_energy_form, 3.1) <- paste0("Final Energy ", sector[y]," ", getItems(mena_by_subsector_by_energy_form, 3.1))
    
    # write data in mif file
    write.report(open_by_subsector_by_energy_form[,,],file="reporting.mif",model="OPEN-PROM",unit="Mtoe",append=TRUE,scenario=scenario_name)
    write.report(mena_by_subsector_by_energy_form[menaregs,years,],file="reporting.mif",model="MENA-EDS",unit="Mtoe",append=TRUE,scenario=scenario_name)
    
    #sector_by_energy_form
    by_energy_form_open <- dimSums(by_energy_form_and_by_subsector_open, 3.1, na.rm = TRUE)
    getItems(by_energy_form_open,3.1) <- paste0("Final Energy ", sector[y]," ", getItems(by_energy_form_open, 3.1))
    by_energy_form_mena <- dimSums(by_energy_form_and_by_subsector_mena,3.1, na.rm = TRUE)
    getItems(by_energy_form_mena, 3.1) <- paste0("Final Energy ", sector[y]," ", getItems(by_energy_form_mena, 3.1))
    
    # write data in mif file
    write.report(by_energy_form_open[,,],file="reporting.mif",model="OPEN-PROM",unit="Mtoe",append=TRUE,scenario=scenario_name)
    write.report(by_energy_form_mena[menaregs,years,],file="reporting.mif",model="MENA-EDS",unit="Mtoe",append=TRUE,scenario=scenario_name)
    
    #filter IFuelCons by subtype enerdata
    FuelCons_enerdata <- calcOutput(type = "IFuelCons", subtype = sector[y], aggregate = TRUE)
    
    year <- Reduce(intersect, list(getYears(FCONS_by_sector_MENA,as.integer=TRUE),getYears(FCONS_by_sector_open,as.integer=TRUE),getYears(FuelCons_enerdata,as.integer=TRUE)))
    FuelCons_enerdata <- FuelCons_enerdata[,year,]
    
    map_subsectors_ener <- sets4 %>% filter(SBS %in% as.character(sets6[,1]))
    
    map_subsectors_ener$EF = paste(map_subsectors_ener$SBS, "Mtoe",map_subsectors_ener$EF, sep=".")
    #filter to have only the variables which are in enerdata
    map_subsectors_ener <- map_subsectors_ener %>% filter(EF %in% getItems(FuelCons_enerdata,3))
    
    # aggregate from enerdata fuels to subsectors
    enerdata_by_sector <- toolAggregate(FuelCons_enerdata[,,as.character(unique(map_subsectors_ener$EF))],dim=3,rel=map_subsectors_ener,from="EF",to="SBS")
    getItems(enerdata_by_sector, 3) <- paste0("Final Energy ", sector[y]," ", getItems(enerdata_by_sector, 3))
    
    # write data in mif file
    write.report(enerdata_by_sector[intersect(getRegions(enerdata_by_sector),regs),year,],file="reporting.mif",model="ENERDATA",unit="Mtoe",append=TRUE,scenario=scenario_name)
    
    #Final Energy enerdata
    FE_ener <- dimSums(FuelCons_enerdata, dim = 3, na.rm = TRUE)
    getItems(FE_ener, 3) <- paste0("Final Energy ", sector[y])
    
    # write data in mif file
    write.report(FE_ener[intersect(getRegions(FE_ener),regs),year,],file="reporting.mif",model="ENERDATA",unit="Mtoe",append=TRUE,scenario=scenario_name)
    
    map_subsectors_ener2 <- sets10
    #filter to have only the variables which are in enerdata
    map_subsectors_ener2 <- map_subsectors_ener2 %>% filter(EF %in% getItems(FuelCons_enerdata,3.3))
    
    #Aggregate model enerdata by subsector and by energy form
    enerdata_by_EF_and_sector <- toolAggregate(FuelCons_enerdata[,year,as.character(unique(map_subsectors_ener2$EF))],dim=3.3,rel=map_subsectors_ener2,from="EF",to="EFA")
    
    #enerdata by subsector and by energy form
    enerdata_by_subsector_by_energy_form <- enerdata_by_EF_and_sector
    enerdata_by_subsector_by_energy_form <- dimSums(enerdata_by_subsector_by_energy_form, 3.2, na.rm = TRUE)
    getItems(enerdata_by_subsector_by_energy_form, 3.1) <- paste0("Final Energy ", sector[y]," ", getItems(enerdata_by_subsector_by_energy_form, 3.1))
    
    # write data in mif file
    write.report(enerdata_by_subsector_by_energy_form[intersect(getRegions(enerdata_by_subsector_by_energy_form),regs),year,],file="reporting.mif",model="ENERDATA",unit="Mtoe",append=TRUE,scenario=scenario_name)
    
    #Aggregate model enerdata by energy form
    enerdata_by_energy_form <- dimSums(enerdata_by_EF_and_sector, 3.1, na.rm = TRUE)
    getItems(enerdata_by_energy_form,3) <- paste0("Final Energy ", sector[y]," ", getItems(enerdata_by_energy_form, 3.2))
    
    # write data in mif file
    write.report(enerdata_by_energy_form[intersect(getRegions(enerdata_by_energy_form),regs),year,],file="reporting.mif",model="ENERDATA",unit="Mtoe",append=TRUE,scenario=scenario_name)
    
  }
}
