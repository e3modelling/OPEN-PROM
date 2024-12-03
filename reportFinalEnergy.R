reportFinalEnergy <- function(regs) {
  
  # read GAMS set used for reporting of Final Energy
  
  sets <- readGDX('./blabla.gdx', "BALEF2EFS")
  names(sets) <- c("BAL", "EF")
  sets[["BAL"]] <- gsub("Gas fuels", "Gases", sets[["BAL"]])
  
  # add model OPEN-PROM data Total final energy consumnption (Mtoe)
  VConsFinEneCountry <- readGDX('./blabla.gdx', "VConsFinEneCountry", field = 'l')[regs, , ]
  
  # aggregate from PROM fuels to reporting fuel categories
  VConsFinEneCountry <- toolAggregate(VConsFinEneCountry[ , , unique(sets$EF)], dim = 3, rel = sets, from = "EF", to = "BAL")
  getItems(VConsFinEneCountry, 3) <- paste0("Final Energy|", getItems(VConsFinEneCountry, 3))
  
  l <- getNames(VConsFinEneCountry) == "Final Energy|Total"
  getNames(VConsFinEneCountry)[l] <- "Final Energy"
  
  # write data in mif file
  write.report(VConsFinEneCountry[,,],file="reporting.mif",model="OPEN-PROM",unit="Mtoe",scenario=scenario_name)
  
  # Final Energy | "TRANSE" | "INDSE" | "DOMSE" | "NENSE"
  
  # Link between Model Subsectors and Fuels
  sets4 <- readGDX('./blabla.gdx', "SECTTECH")
  
  # OPEN-PROM sectors
  sector <- c("TRANSE", "INDSE", "DOMSE", "NENSE")
  sector_name <- c("Transportation", "Industry", "Residential and Commercial", "Non Energy and Bunkers")
  
  # variables of OPEN-PROM related to sectors
  blabla_var <- c("VDemFinEneTranspPerFuel", "VConsFuel", "VConsFuel", "VConsFuel")
  
  for (y in 1 : length(sector)) {
    # read GAMS set used for reporting of Final Energy different for each sector
    sets6 <- readGDX('./blabla.gdx', sector[y])
    sets6 <- as.data.frame(sets6)
    names(sets6) <- sector[y]
    
    var_gdx <- readGDX('./blabla.gdx', blabla_var[y], field = 'l')[regs, , ]
    FCONS_by_sector_and_EF_open <- var_gdx[,,sets6[, 1]]
    
    map_subsectors <- sets4 %>% filter(SBS %in% as.character(sets6[, 1]))
    
    map_subsectors$EF = paste(map_subsectors$SBS, map_subsectors$EF, sep=".")
    
    # aggregate from PROM fuels to subsectors
    FCONS_by_sector_open <- toolAggregate(FCONS_by_sector_and_EF_open[,,unique(map_subsectors$EF)],dim=3,rel=map_subsectors,from="EF",to="SBS")
    getItems(FCONS_by_sector_open, 3) <- paste0("Final Energy|", sector_name[y],"|", getItems(FCONS_by_sector_open, 3))
    
    # write data in mif file
    write.report(FCONS_by_sector_open[,,],file="reporting.mif",model="OPEN-PROM",unit="Mtoe",append=TRUE,scenario=scenario_name)
    
    # Final Energy by sector 
    sector_open <- dimSums(FCONS_by_sector_open, dim = 3, na.rm = TRUE)
    getItems(sector_open, 3) <- paste0("Final Energy|", sector_name[y])
    
    # write data in mif file
    write.report(sector_open[,,],file="reporting.mif",model="OPEN-PROM",unit="Mtoe",append=TRUE,scenario=scenario_name)
    
    # Energy Forms Aggregations
    sets5 <- readGDX('./blabla.gdx', "EFtoEFA")
    
    # Add electricity, Hydrogen, Biomass and Waste
    ELC <- readGDX('./blabla.gdx', "ELCEF")
    ELC <- as.data.frame(ELC)
    names(ELC) <- "ELCEF"
    
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
    
    # write data in mif file
    write.report(open_by_subsector_by_energy_form[,,],file="reporting.mif",model="OPEN-PROM",unit="Mtoe",append=TRUE,scenario=scenario_name)
     
    # sector_by_energy_form
    by_energy_form_open <- dimSums(by_energy_form_and_by_subsector_open, 3.1, na.rm = TRUE)
    getItems(by_energy_form_open,3.1) <- paste0("Final Energy|", sector_name[y],"|", getItems(by_energy_form_open, 3.1))
    
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
    
    # write data in mif file
    write.report(FCONS_per_fuel[,,],file="reporting.mif",model="OPEN-PROM",unit="Mtoe",append=TRUE,scenario=scenario_name)
  }
}
