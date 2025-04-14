reportFinalEnergy <- function(regs) {
  
  # read GAMS set used for reporting of Final Energy
  
  sets <- readGDX('./blabla.gdx', "BALEF2EFS")
  names(sets) <- c("BAL", "EF")
  sets[["BAL"]] <- gsub("Gas fuels", "Gases", sets[["BAL"]])
  sets[["BAL"]] <- gsub("Steam", "Heat", sets[["BAL"]])
  
  # add model OPEN-PROM data Total final energy consumnption (Mtoe)
  VConsFinEneCountry <- readGDX('./blabla.gdx', "VConsFinEneCountry", field = 'l')[regs, , ]
  
  # aggregate from PROM fuels to reporting fuel categories
  VConsFinEneCountry <- toolAggregate(VConsFinEneCountry[ , , unique(sets$EF)], dim = 3, rel = sets, from = "EF", to = "BAL")
  getItems(VConsFinEneCountry, 3) <- paste0("Final Energy|", getItems(VConsFinEneCountry, 3))
  
  l <- getNames(VConsFinEneCountry) == "Final Energy|Total"
  getNames(VConsFinEneCountry)[l] <- "Final Energy"
  
  VConsFinEneCountry <- add_dimension(VConsFinEneCountry, dim = 3.2, add = "unit", nm = "Mtoe")
  
  magpie_object <- NULL
  
  magpie_object <- mbind(magpie_object, VConsFinEneCountry)
  
  library(ggplot2)
  
  #filter period by last year of the model
  an <- readGDX('./blabla.gdx', "an", field = 'l')
  
  .toolgeom_bar <- function(data, colors_vars) {
    return(ggplot(data,aes(y=value,x=period, color=variable)) +
             scale_fill_manual(values = as.character(colors_vars[,3]), limits = as.character(colors_vars[,1])) + 
             scale_color_manual(values = as.character(colors_vars[,3]), limits = as.character(colors_vars[,1])) + 
             geom_bar(stat = "identity",aes(fill=variable) ) + 
             facet_wrap("region",scales = "free_y") +
             labs(x="period", y=paste0("Final Energy"," ",unique(data[["unit"]]))) +
             theme_bw()+
             theme(text = element_text(size = 4),
                   strip.text.x = element_text(margin = margin(0.05,0,0.05,0, "cm")),
                   axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1), 
                   aspect.ratio = 1.5/2,plot.title = element_text(size = 4),
                   legend.key.size = unit(0.5, "cm"),
                   legend.key.width = unit(0.5, "cm")))
  }
  
  pq <- as.quitte(magpie_object)
  pq <- select(pq, -c("variable"))
  names(pq) <- sub("EF", "variable", names(pq))
  vars <- c(
    "Final Energy|Solids" ,
    "Final Energy|Hydrogen" ,
    "Final Energy|Gases",
    "Final Energy|Electricity",
    "Final Energy|Liquids",
    "Final Energy|Heat",
    "Final Energy|Biomass",
    NULL)
  
  
  #Read csv to map variables with colors
  colors <- read.csv(system.file(package="mip",file.path("extdata","plotstyle.csv")))
  
  #Split by semicolon
  split_text <- strsplit(as.character(colors$X.legend.color.marker.linestyle), split = ";")
  
  #Convert the list into a data frame
  colors <- do.call(bind_rows, lapply(split_text, function(x) as.data.frame(t(x))))
  
  #map variables with colors
  colors_vars <- filter(colors,V1%in%vars)
  var_miss <- as.data.frame(vars)
  
  #add missing colors
  V1 <- as.character(filter(var_miss,!(vars%in%colors[,"V1"]))[["vars"]])
  V2 <- c("Biomass")
  V3 <- c("#00b219")
  V4 <- rep(NA)
  V5 <- rep(NA)
  
  miss_vars <- data.frame(V1, V2, V3, V4, V5)
  
  #add missing colors to dataset
  colors_vars <- rbind(colors_vars, miss_vars)
  
  #order colors to match variables
  colors_vars <- colors_vars[order(colors_vars[["V1"]]), ]
  
  #filter data by variables and max period
  data <- filter(pq,variable%in%colors_vars[,1],period<=max(an))
  
  #order variables to match colors
  data <- data %>% arrange(as.character(variable))
  
  #FE plots per fuel
  #create geom_bar
  .toolgeom_bar(data, colors_vars)
  ggsave("FE_fuels.png", units="in", width=5.5, height=4, dpi=1200)
  
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
    if (sector[y] == "TRANSE") {
      sets6 <- c(sets6, "PB", "PN")
    }
    sets6 <- as.data.frame(sets6)
    names(sets6) <- sector[y]
    
    var_gdx <- readGDX('./blabla.gdx', blabla_var[y], field = 'l')[regs, , ]
    FCONS_by_sector_and_EF_open <- var_gdx[,,sets6[, 1]]
    
    map_subsectors <- sets4 %>% filter(SBS %in% as.character(sets6[, 1]))
    
    map_subsectors$EF = paste(map_subsectors$SBS, map_subsectors$EF, sep=".")
    
    # aggregate from PROM fuels to subsectors
    FCONS_by_sector_open <- toolAggregate(FCONS_by_sector_and_EF_open[,,unique(map_subsectors$EF)],dim=3,rel=map_subsectors,from="EF",to="SBS")
    getItems(FCONS_by_sector_open, 3) <- paste0("Final Energy|", sector_name[y],"|", getItems(FCONS_by_sector_open, 3))
    
    FCONS_by_sector_open <- add_dimension(FCONS_by_sector_open, dim = 3.2, add = "unit", nm = "Mtoe")
    
    magpie_object <- mbind(magpie_object, FCONS_by_sector_open)
    
    # Final Energy by sector 
    sector_open <- dimSums(FCONS_by_sector_open, dim = 3, na.rm = TRUE)
    getItems(sector_open, 3) <- paste0("Final Energy|", sector_name[y])
    
    sector_open <- add_dimension(sector_open, dim = 3.2, add = "unit", nm = "Mtoe")
    magpie_object <- mbind(magpie_object, sector_open)
    
    # Energy Forms Aggregations
    sets5 <- readGDX('./blabla.gdx', "EFtoEFA")
    
    # Add electricity, Hydrogen, Biomass and Waste
    ELC <- readGDX('./blabla.gdx', "ELCEF")
    ELC <- as.data.frame(ELC)
    names(ELC) <- "ELCEF"
    
    sets5[nrow(sets5) + 1, ] <- ELC[1,1]
    
    sets5$EFA <- gsub("SLD", "Solids", sets5$EFA)
    sets5$EFA <- gsub("LQD", "Liquids", sets5$EFA)
    sets5$EFA <- gsub("OLQT", "All liquids but GDO, RFO, GSL", sets5$EFA)
    sets5$EFA <- gsub("GAS", "Gases", sets5$EFA)
    sets5$EFA <- gsub("NFF", "Non Fossil Fuels", sets5$EFA)
    sets5$EFA <- gsub("REN", "Renewables except Hydro", sets5$EFA)
    sets5$EFA <- gsub("NEF", "New energy forms", sets5$EFA)
    sets5$EFA <- gsub("STE", "Heat", sets5$EFA)
    sets5$EFA <- gsub("ELC", "Electricity", sets5$EFA)
    
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
    
    open_by_subsector_by_energy_form <- add_dimension(open_by_subsector_by_energy_form, dim = 3.2, add = "unit", nm = "Mtoe")
    magpie_object <- mbind(magpie_object, open_by_subsector_by_energy_form)
    
    # sector_by_energy_form
    by_energy_form_open <- dimSums(by_energy_form_and_by_subsector_open, 3.1, na.rm = TRUE)
    getItems(by_energy_form_open,3.1) <- paste0("Final Energy|", sector_name[y],"|", getItems(by_energy_form_open, 3.1))
    
    by_energy_form_open <- add_dimension(by_energy_form_open, dim = 3.2, add = "unit", nm = "Mtoe")
    magpie_object <- mbind(magpie_object, by_energy_form_open)
    
    # per fuel
    FCONS_per_fuel <- FCONS_by_sector_and_EF_open[,,sets6[,1]][,,!(getItems(FCONS_by_sector_and_EF_open,3.2)) %in% (getItems(by_energy_form_and_by_subsector_open,3.2))]
    
    # remove . from magpie object and replace with |
    FCONS_per_fuel <- as.quitte(FCONS_per_fuel)
    FCONS_per_fuel[[names(FCONS_per_fuel[, 8])]] <- paste0(FCONS_per_fuel[[names(FCONS_per_fuel[, 8])]], "|", FCONS_per_fuel[["EF"]])
    FCONS_per_fuel <- select(FCONS_per_fuel, -c("EF"))
    FCONS_per_fuel <- as.quitte(FCONS_per_fuel) %>% as.magpie()
    getItems(FCONS_per_fuel, 3) <- paste0("Final Energy|", sector_name[y],"|", getItems(FCONS_per_fuel, 3))
    
    FCONS_per_fuel <- add_dimension(FCONS_per_fuel, dim = 3.2, add = "unit", nm = "Mtoe")
    magpie_object <- mbind(magpie_object, FCONS_per_fuel)
  }
  
  vars_sectors <- c(
    "Final Energy|Industry" ,
    "Final Energy|Transportation" ,
    "Final Energy|Residential and Commercial",
    "Final Energy|Non Energy and Bunkers",
    NULL)
  
  pq <- as.quitte(magpie_object[,,vars_sectors])
  pq <- select(pq, -c("variable"))
  names(pq) <- sub("EF", "variable", names(pq))

  #Read csv to map variables with colors
  colors <- read.csv(system.file(package="mip",file.path("extdata","plotstyle.csv")))
  
  #Split by semicolon
  split_text <- strsplit(as.character(colors$X.legend.color.marker.linestyle), split = ";")
  
  #Convert the list into a data frame
  colors <- do.call(bind_rows, lapply(split_text, function(x) as.data.frame(t(x))))
  
  #map variables with colors
  colors_vars <- filter(colors,V1%in%vars_sectors)
  var_miss <- as.data.frame(vars_sectors)
  
  #add missing colors
  V1 <- as.character(filter(var_miss,!(vars_sectors%in%colors[,"V1"]))[["vars_sectors"]])
  V2 <- c("Non Energy and Bunkers")
  V3 <- c("yellow")
  V4 <- rep(NA)
  V5 <- rep(NA)
  
  miss_vars <- data.frame(V1, V2, V3, V4, V5)
  
  #add missing colors to dataset
  colors_vars <- rbind(colors_vars, miss_vars)
  
  #order colors to match variables
  colors_vars <- colors_vars[order(colors_vars[["V1"]]), ]
  
  #filter data by variables and max period
  data <- filter(pq,variable%in%colors_vars[,1],period<=max(an))
  
  #order variables to match colors
  data <- data %>% arrange(as.character(variable))
  
  #FE plots per sector
  #create geom_bar
  .toolgeom_bar(data, colors_vars)
  ggsave("FE_sectors.png", units="in", width=5.5, height=4, dpi=1200)
  
  return(magpie_object)
}
