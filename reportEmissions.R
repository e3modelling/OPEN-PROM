reportEmissions <- function(regs) {
  
  Navigate_Emissions <- read.csv("data/NavigateEmissions.csv")
  
  fscenario <- readGDX('./blabla.gdx', "fscenario")
  
  Navigate_Emissions <- as.magpie(Navigate_Emissions)
  
  if (fscenario == 2) {
    Navigate_Emissions <- Navigate_Emissions[,,"SUP_2C_Default"]
  } else if (fscenario == 1) {
    Navigate_Emissions <- Navigate_Emissions[,,"SUP_1p5C_Default"]
  } else if (fscenario == 0) {
    Navigate_Emissions <- Navigate_Emissions[,,"SUP_NPi_Default"]
  }
  
  Navigate_Emissions <- collapseDim(Navigate_Emissions,3.1)
  Navigate_Emissions <- collapseDim(Navigate_Emissions,3.1)
  
  remind_AFOLU_Industrial_Processes <- Navigate_Emissions[,,c("Emissions|CO2|AFOLU","Emissions|CO2|Industrial Processes")]
  remind <- dimSums(remind_AFOLU_Industrial_Processes, 3, na.rm = TRUE)
  
  iCo2EmiFac <- readGDX('./blabla.gdx', "iCo2EmiFac")[regs, , ]
  VConsFuel <- readGDX('./blabla.gdx', "VConsFuel", field = 'l')[regs, , ]
  VInpTransfTherm <- readGDX('./blabla.gdx', "VInpTransfTherm", field = 'l')[regs, , ]
  VTransfInputDHPlants <- readGDX('./blabla.gdx', "VTransfInputDHPlants", field = 'l')[regs, , ]
  VConsFiEneSec <- readGDX('./blabla.gdx', "VConsFiEneSec", field = 'l')[regs, , ]
  VDemFinEneTranspPerFuel <- readGDX('./blabla.gdx', "VDemFinEneTranspPerFuel", field = 'l')[regs, , ]
  VProdElec <- readGDX('./blabla.gdx', "VProdElec", field = 'l')[regs, , ]
  iPlantEffByType <- readGDX('./blabla.gdx', "iPlantEffByType")[regs, , ]
  iCO2CaptRate <- readGDX('./blabla.gdx', "iCO2CaptRate")[regs, , ]
  
  # Link between Model Subsectors and Fuels
  
  sets4 <- readGDX('./blabla.gdx', "SECTTECH")
  
  EFtoEFS <- readGDX('./blabla.gdx', "EFtoEFS")
  
  IND <- readGDX('./blabla.gdx', "INDDOM")
  IND <- as.data.frame(IND)
  
  map_INDDOM <- sets4 %>% filter(SBS %in% IND[,1])
  
  map_INDDOM <- filter(map_INDDOM, EF != "")
  
  qINDDOM <- left_join(map_INDDOM, EFtoEFS, by = "EF")
  qINDDOM <- select((qINDDOM), -c(EF))
  
  qINDDOM <- unique(qINDDOM)
  names(qINDDOM) <- sub("EFS", "SECTTECH", names(qINDDOM))
  
  qINDDOM <- paste0(qINDDOM[["SBS"]], ".", qINDDOM[["SECTTECH"]])
  INDDOM <- as.data.frame(qINDDOM)
  
  PGEF <- readGDX('./blabla.gdx', "PGEF")
  PGEF <- as.data.frame(PGEF)
  
  # final consumption
  sum1 <- iCo2EmiFac[,,INDDOM[, 1]] * VConsFuel[,,INDDOM[, 1]]
  sum1 <- dimSums(sum1, 3, na.rm = TRUE)
  # input to power generation sector
  sum2 <- VInpTransfTherm[,,PGEF[,1]]*iCo2EmiFac[,,"PG"][,,PGEF[,1]]
  sum2 <- dimSums(sum2, 3, na.rm = TRUE)
  # input to district heating plants
  sum3 <- VTransfInputDHPlants * iCo2EmiFac[,,"PG"][,,getItems(VTransfInputDHPlants,3)]
  sum3 <- dimSums(sum3, 3, na.rm = TRUE)
  # consumption of energy branch
  sum4 <- VConsFiEneSec * iCo2EmiFac[,,"PG"][,,getItems(VConsFiEneSec,3)]
  sum4 <- dimSums(sum4, 3, na.rm = TRUE)
  
  TRANSE <- readGDX('./blabla.gdx', "TRANSE")
  TRANSE <- as.data.frame(TRANSE)
  
  map_TRANSECTOR <- sets4 %>% filter(SBS %in% TRANSE[,1])
  map_TRANSECTOR <- paste0(map_TRANSECTOR[["SBS"]], ".", map_TRANSECTOR[["EF"]])
  map_TRANSECTOR <- as.data.frame(map_TRANSECTOR)
  
  sum5 <- VDemFinEneTranspPerFuel[,,map_TRANSECTOR[, 1]] * iCo2EmiFac[,,map_TRANSECTOR[, 1]]
  # transport
  sum5 <- dimSums(sum5, 3, na.rm = TRUE)
  
  PGALLtoEF <- readGDX('./blabla.gdx', "PGALLtoEF")
  PGALLtoEF <- as.data.frame(PGALLtoEF)
  names(PGALLtoEF) <- c("PGALL", "EF")
  
  CCS <- readGDX('./blabla.gdx', "CCS")
  CCS <- as.data.frame(CCS)
  
  CCS <- PGALLtoEF[PGALLtoEF$PGALL %in% CCS$CCS, ]
  
  var_16 <- VProdElec[,,CCS[,1]] * 0.086 / iPlantEffByType[,,CCS[,1]] * iCo2EmiFac[,,"PG"][,,CCS[,2]] * iCO2CaptRate[,,CCS[,1]]
  # CO2 captured by CCS plants in power generation
  sum6 <- dimSums(var_16,dim=3, na.rm = TRUE) 
  
  SECTTECH2 <- sets4 %>% filter(SBS %in% c("BU"))
  SECTTECH2 <- paste0(SECTTECH2[["SBS"]], ".", SECTTECH2[["EF"]])
  SECTTECH2 <- as.data.frame(SECTTECH2)
  # Bunkers
  sum7 <- iCo2EmiFac[,,SECTTECH2[,1]] * VConsFuel[,,SECTTECH2[,1]]
  sum7 <- dimSums(sum7,dim=3, na.rm = TRUE)
  
  total_CO2 <- sum1 + sum2 + sum3 + sum4 + sum5 - sum6 + sum7 + remind
  
  getItems(total_CO2, 3) <- "Emissions|CO2"
  
  magpie_object <- NULL
  total_CO2 <- add_dimension(total_CO2, dim = 3.2, add = "unit", nm = "Mt CO2/yr")
  magpie_object <- mbind(magpie_object, total_CO2, Navigate_Emissions)
  
  # Extra Emissions
  # Emissions|CO2|Energy|Demand|Industry
  
  INDSE <- readGDX('./blabla.gdx', "INDSE")
  INDSE <- as.data.frame(INDSE)
  
  map_INDSE <- sets4 %>% filter(SBS %in% INDSE[,1])
  
  map_INDSE <- filter(map_INDSE, EF != "")
  
  qINDSE <- left_join(map_INDSE, EFtoEFS, by = "EF")
  qINDSE <- select((qINDSE), -c(EF))
  
  qINDSE <- unique(qINDSE)
  names(qINDSE) <- sub("EFS", "SECTTECH", names(qINDSE))
  
  qINDSE <- paste0(qINDSE[["SBS"]], ".", qINDSE[["SECTTECH"]])
  INDSE <- as.data.frame(qINDSE)
  
  # final consumption
  sum_INDSE <- iCo2EmiFac[,,INDSE[, 1]] * VConsFuel[,,INDSE[, 1]]
  sum_INDSE <- dimSums(sum_INDSE, 3, na.rm = TRUE)
  
  getItems(sum_INDSE, 3) <- "Emissions|CO2|Energy|Demand|Industry"
  
  sum_INDSE <- add_dimension(sum_INDSE, dim = 3.2, add = "unit", nm = "Mt CO2/yr")
  magpie_object <- mbind(magpie_object, sum_INDSE)
  
  # Emissions|CO2|Energy|Demand|Residential and Commercial
  
  DOMSE <- readGDX('./blabla.gdx', "DOMSE")
  DOMSE <- as.data.frame(DOMSE)
  
  map_DOMSE <- sets4 %>% filter(SBS %in% DOMSE[,1])
  
  map_DOMSE <- filter(map_DOMSE, EF != "")
  
  qDOMSE <- left_join(map_DOMSE, EFtoEFS, by = "EF")
  qDOMSE <- select((qDOMSE), -c(EF))
  
  qDOMSE <- unique(qDOMSE)
  names(qDOMSE) <- sub("EFS", "SECTTECH", names(qDOMSE))
  
  qDOMSE <- paste0(qDOMSE[["SBS"]], ".", qDOMSE[["SECTTECH"]])
  DOMSE <- as.data.frame(qDOMSE)
  
  # final consumption
  sum_DOMSE <- iCo2EmiFac[,,DOMSE[, 1]] * VConsFuel[,,DOMSE[, 1]]
  sum_DOMSE <- dimSums(sum_DOMSE, 3, na.rm = TRUE)
  
  getItems(sum_DOMSE, 3) <- "Emissions|CO2|Energy|Demand|Residential and Commercial"
  
  sum_DOMSE <- add_dimension(sum_DOMSE, dim = 3.2, add = "unit", nm = "Mt CO2/yr")
  magpie_object <- mbind(magpie_object, sum_DOMSE)
  
   # Emissions|CO2|Energy|Demand|Transportation
  sum_TRANSE <- sum5 # transport
  
  getItems(sum_TRANSE, 3) <- "Emissions|CO2|Energy|Demand|Transportation"
  
  sum_TRANSE <- add_dimension(sum_TRANSE, dim = 3.2, add = "unit", nm = "Mt CO2/yr")
  magpie_object <- mbind(magpie_object, sum_TRANSE)
  
  # Emissions|CO2|Energy|Demand|Bunkers
  sum_Bunkers <- sum7 # Bunkers
  
  getItems(sum_Bunkers, 3) <- "Emissions|CO2|Energy|Demand|Bunkers"
  
  sum_Bunkers <- add_dimension(sum_Bunkers, dim = 3.2, add = "unit", nm = "Mt CO2/yr")
  magpie_object <- mbind(magpie_object, sum_Bunkers)
  
  # Emissions|CO2|Energy|Demand
  # Emissions|CO2|Energy|Demand|Bunkers, sum_Bunkers
  # Emissions|CO2|Energy|Demand|Transportation, sum_TRANSE
  # Emissions|CO2|Energy|Demand|Residential and Commercial, sum_DOMSE
  # Emissions|CO2|Energy|Demand|Industry, sum_INDSE
  sum_Demand <- sum_Bunkers + sum_TRANSE + sum_DOMSE + sum_INDSE
  
  getItems(sum_Demand, 3) <- "Emissions|CO2|Energy|Demand"
  
  sum_Demand <- add_dimension(sum_Demand, dim = 3.2, add = "unit", nm = "Mt CO2/yr")
  magpie_object <- mbind(magpie_object, sum_Demand)
  
  # Emissions|CO2|Energy|Supply
  # input to power generation sector, sum2
  # input to district heating plants, sum3
  # consumption of energy branch, sum4
  # CO2 captured by CCS plants in power generation, sum6
  sum_Supply <- sum2 + sum3 + sum4 - sum6
  
  getItems(sum_Supply, 3) <- "Emissions|CO2|Energy|Supply"

  sum_Supply <- add_dimension(sum_Supply, dim = 3.2, add = "unit", nm = "Mt CO2/yr")
  magpie_object <- mbind(magpie_object, sum_Supply)
  
  # Emissions|CO2|Energy
  # Emissions|CO2|Energy|Demand, sum_Demand
  # Emissions|CO2|Energy|Supply, sum_Supply
  
  sum_Energy <- sum_Demand + sum_Supply
  
  getItems(sum_Energy, 3) <- "Emissions|CO2|Energy"
  
  sum_Energy <- add_dimension(sum_Energy, dim = 3.2, add = "unit", nm = "Mt CO2/yr")
  magpie_object <- mbind(magpie_object, sum_Energy)
  
  # Emissions|CO2|Cumulated
  
  Cumulated <- as.quitte(total_CO2)
  
  Cumulated <- Cumulated %>% group_by(region) %>% mutate(value = cumsum(value))
  
  Cumulated <- as.data.frame(Cumulated)
  
  Cumulated <- as.quitte(Cumulated) %>% as.magpie()
  
  getItems(Cumulated, 3) <- "Emissions|CO2|Cumulated"
  
  Cumulated <- Cumulated /1000
  
  Cumulated <- add_dimension(Cumulated, dim = 3.2, add = "unit", nm = "Gt CO2")
  magpie_object <- mbind(magpie_object, Cumulated)
  
  #graph emissions
  library(ggplot2)
  
  #filter period by last year of the model
  an <- readGDX('./blabla.gdx', "an", field = 'l')
  
  .toolgeom_area <- function(data, colors_vars) {
    return(ggplot(data,aes(y=value,x=period, color=variable)) +
             scale_fill_manual(values = as.character(colors_vars[,3]), limits = as.character(colors_vars[,1])) + 
             scale_color_manual(values = as.character(colors_vars[,3]), limits = as.character(colors_vars[,1])) + 
             geom_area(stat = "identity",aes(fill=variable) ) + 
             facet_wrap("region",scales = "free_y") +
             labs(x="period", y=paste0("Emissions|CO2"," ",unique(data[["unit"]]))) +
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
  names(pq) <- sub("d3", "variable", names(pq))
  
  #Read csv to map variables with colors
  colors <- read.csv(system.file(package="mip",file.path("extdata","plotstyle.csv")))
  
  #Split by semicolon
  split_text <- strsplit(as.character(colors$X.legend.color.marker.linestyle), split = ";")
  
  #Convert the list into a data frame
  colors <- do.call(bind_rows, lapply(split_text, function(x) as.data.frame(t(x))))
  
  #map variables with colors
  colors_vars <- filter(colors,V1%in%getItems(magpie_object,3.1))
 
  #add missing colors
  V1 <- c("Emissions|CO2|Energy|Demand|Bunkers","Emissions|CO2|Energy|Supply","Emissions|CO2|Cumulated")
  V2 <- c("Bunkers","Supply","Cumulated")
  V3 <- c("#FDBF6F","#bcbc6d","#661a00")
  V4 <- rep(NA, 3)
  V5 <- rep(NA, 3)
  
  miss_vars <- data.frame(V1, V2, V3, V4, V5)
  
  #add missing colors to dataset
  colors_vars <- rbind(colors_vars, miss_vars)
  
  #order colors to match variables
  colors_vars <- colors_vars[order(colors_vars[["V1"]]), ]
  
  #filter data by variables and max period
  data <- filter(pq,variable%in%colors_vars[,1],period<=max(an))
  
  #order variables to match colors
  data <- data %>% arrange(as.character(variable))
  
  #Demand_Supply graph
  emi_co2 <- filter(data,variable %in% c("Emissions|CO2|Energy|Demand|Bunkers","Emissions|CO2|Energy|Demand|Industry",
                                         "Emissions|CO2|Energy|Demand|Residential and Commercial","Emissions|CO2|Energy|Demand|Transportation",
                                         "Emissions|CO2|Energy|Supply"))
  filter_colors <- filter(colors_vars,V1 %in%c("Emissions|CO2|Energy|Demand|Bunkers","Emissions|CO2|Energy|Demand|Industry",
                                               "Emissions|CO2|Energy|Demand|Residential and Commercial","Emissions|CO2|Energy|Demand|Transportation",
                                               "Emissions|CO2|Energy|Supply"))
  #create geom_bar
  .toolgeom_area(emi_co2, filter_colors)
  ggsave("Demand_Supply_CO2.png", units="in", width=5.5, height=4, dpi=1200)
  
  
  #Cumulated graph
  Cumulated_CO2 <- filter(data,variable %in% c("Emissions|CO2|Cumulated"))
  filter_colors <- filter(colors_vars,V1 %in% c("Emissions|CO2|Cumulated"))
  #create geom_bar
  .toolgeom_area(Cumulated_CO2, filter_colors)
  ggsave("Cumulated_CO2.png", units="in", width=5.5, height=4, dpi=1200)
  
  return(magpie_object)
   }