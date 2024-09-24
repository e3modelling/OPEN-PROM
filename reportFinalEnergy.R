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
  VConsFinEneCountry <- readGDX('./blabla.gdx', "VConsFinEneCountry", field = 'l')[regs, , ]
  
  # aggregate from PROM fuels to reporting fuel categories
  VConsFinEneCountry <- toolAggregate(VConsFinEneCountry[ , , unique(sets$EF)], dim = 3, rel = sets, from = "EF", to = "BAL")
  getItems(VConsFinEneCountry, 3) <- paste0("Final Energy|", getItems(VConsFinEneCountry, 3))
  
  l <- getNames(VConsFinEneCountry) == "Final Energy|Total"
  getNames(VConsFinEneCountry)[l] <- "Final Energy"
  
  VConsFinEneCountry_GLO <- dimSums(VConsFinEneCountry, 1)
  getItems(VConsFinEneCountry_GLO, 1) <- "World"
  VConsFinEneCountry <- mbind(VConsFinEneCountry, VConsFinEneCountry_GLO)
  
  # write data in mif file
  write.report(VConsFinEneCountry[,,],file="reporting.mif",model="OPEN-PROM",unit="Mtoe",scenario=scenario_name)
  
  # Final Energy | "TRANSE" | "INDSE" | "DOMSE" | "NENSE"
  
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
    
    map_subsectors$EF = paste(map_subsectors$SBS, map_subsectors$EF, sep=".")
    
    # aggregate from PROM fuels to subsectors
    FCONS_by_sector_open <- toolAggregate(FCONS_by_sector_and_EF_open[,,unique(map_subsectors$EF)],dim=3,rel=map_subsectors,from="EF",to="SBS")
    getItems(FCONS_by_sector_open, 3) <- paste0("Final Energy|", sector_name[y],"|", getItems(FCONS_by_sector_open, 3))
    
    FCONS_by_sector_open_GLO <- dimSums(FCONS_by_sector_open, 1)
    getItems(FCONS_by_sector_open_GLO, 1) <- "World"
    FCONS_by_sector_open <- mbind(FCONS_by_sector_open, FCONS_by_sector_open_GLO)
    
    # write data in mif file
    write.report(FCONS_by_sector_open[,,],file="reporting.mif",model="OPEN-PROM",unit="Mtoe",append=TRUE,scenario=scenario_name)
    
    # Final Energy by sector 
    sector_open <- dimSums(FCONS_by_sector_open, dim = 3, na.rm = TRUE)
    getItems(sector_open, 3) <- paste0("Final Energy|", sector_name[y])
    
    # write data in mif file
    write.report(sector_open[,,],file="reporting.mif",model="OPEN-PROM",unit="Mtoe",append=TRUE,scenario=scenario_name)
    
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
    
    sets10 <- sets5 %>% filter(EF %in% getItems(var_gdx[,,sets6[, 1]],3.2))
    
    # Aggregate model OPEN-PROM by subsector and by energy form 
    by_energy_form_and_by_subsector_open <- toolAggregate(FCONS_by_sector_and_EF_open[,,as.character(unique(sets10$EF))],dim=3.2,rel=sets10,from="EF",to="EFA")
    
    # sector by subsector and by energy form form OPEN-PROM
    open_by_subsector_by_energy_form <- by_energy_form_and_by_subsector_open
    getItems(open_by_subsector_by_energy_form, 3.1) <- paste0("Final Energy|", sector_name[y],"|", getItems(open_by_subsector_by_energy_form, 3.1))
    
    # remove . from magpie object and replace with |
    open_by_subsector_by_energy_form <- as.quitte(open_by_subsector_by_energy_form)
    open_by_subsector_by_energy_form[[names(open_by_subsector_by_energy_form[, 8])]] <- paste0(open_by_subsector_by_energy_form[[names(open_by_subsector_by_energy_form[, 8])]], "|", open_by_subsector_by_energy_form[["EF"]])
    open_by_subsector_by_energy_form <- select(open_by_subsector_by_energy_form, -c("EF"))
    open_by_subsector_by_energy_form <- as.quitte(open_by_subsector_by_energy_form) %>% as.magpie()
    
    open_by_subsector_by_energy_form_GLO <- dimSums(open_by_subsector_by_energy_form, 1)
    getItems(open_by_subsector_by_energy_form_GLO, 1) <- "World"
    open_by_subsector_by_energy_form <- mbind(open_by_subsector_by_energy_form, open_by_subsector_by_energy_form_GLO)
    
    # write data in mif file
    write.report(open_by_subsector_by_energy_form[,,],file="reporting.mif",model="OPEN-PROM",unit="Mtoe",append=TRUE,scenario=scenario_name)
     
    # sector_by_energy_form
    by_energy_form_open <- dimSums(by_energy_form_and_by_subsector_open, 3.1, na.rm = TRUE)
    getItems(by_energy_form_open,3.1) <- paste0("Final Energy|", sector_name[y],"|", getItems(by_energy_form_open, 3.1))
    
    by_energy_form_open_GLO <- dimSums(by_energy_form_open, 1)
    getItems(by_energy_form_open_GLO, 1) <- "World"
    by_energy_form_open <- mbind(by_energy_form_open, by_energy_form_open_GLO)
    
    # write data in mif file
    write.report(by_energy_form_open[,,],file="reporting.mif",model="OPEN-PROM",unit="Mtoe",append=TRUE,scenario=scenario_name)
     
    # per fuel
    FCONS_per_fuel <- FCONS_by_sector_and_EF_open[,,sets6[,1]][,,!(getItems(FCONS_by_sector_and_EF_open,3.2)) %in% (getItems(by_energy_form_and_by_subsector_open,3.2))]
    
    # remove . from magpie object and replace with |
    FCONS_per_fuel <- as.quitte(FCONS_per_fuel)
    FCONS_per_fuel[[names(FCONS_per_fuel[, 8])]] <- paste0(FCONS_per_fuel[[names(FCONS_per_fuel[, 8])]], "|", FCONS_per_fuel[["EF"]])
    FCONS_per_fuel <- select(FCONS_per_fuel, -c("EF"))
    FCONS_per_fuel <- as.quitte(FCONS_per_fuel) %>% as.magpie()
    getItems(FCONS_per_fuel, 3) <- paste0("Final Energy|", sector_name[y],"|", getItems(FCONS_per_fuel, 3))
    
    FCONS_per_fuel_GLO <- dimSums(FCONS_per_fuel, 1)
    getItems(FCONS_per_fuel_GLO, 1) <- "World"
    FCONS_per_fuel <- mbind(FCONS_per_fuel, FCONS_per_fuel_GLO)
    
    # write data in mif file
    write.report(FCONS_per_fuel[,,],file="reporting.mif",model="OPEN-PROM",unit="Mtoe",append=TRUE,scenario=scenario_name)
  }
}
