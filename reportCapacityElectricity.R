reportCapacityElectricity <- function(regs) {
  
  # add model OPEN-PROM data electricity capacity
  VCapElec2 <- readGDX('./blabla.gdx', "VCapElec2", field = 'l')[regs, , ]
  
  PGALLtoEF <- readGDX('./blabla.gdx', "PGALLtoEF")
  names(PGALLtoEF) <- c("PGALL", "EF")
  
  add_LGN <- as.data.frame(PGALLtoEF[which(PGALLtoEF[, 2] == "LGN"), 1])
  add_LGN["EF"] <- "Lignite"
  names(add_LGN) <- c("PGALL", "EF")
  
  PGALLtoEF$EF <- gsub("LGN", "Coal", PGALLtoEF$EF)
  PGALLtoEF$EF <- gsub("HCL", "Coal", PGALLtoEF$EF)
  PGALLtoEF$EF <- gsub("RFO", "Residual Fuel Oil", PGALLtoEF$EF)
  PGALLtoEF$EF <- gsub("GDO", "Oil", PGALLtoEF$EF)
  PGALLtoEF$EF <- gsub("NGS", "Gas", PGALLtoEF$EF)
  PGALLtoEF$EF <- gsub("BMSWAS", "Biomass", PGALLtoEF$EF)
  PGALLtoEF$EF <- gsub("NUC", "Nuclear", PGALLtoEF$EF)
  PGALLtoEF$EF <- gsub("HYD", "Hydro", PGALLtoEF$EF)
  PGALLtoEF$EF <- gsub("WND", "Wind", PGALLtoEF$EF)
  PGALLtoEF$EF <- gsub("SOL", "Solar", PGALLtoEF$EF)
  PGALLtoEF$EF <- gsub("GEO", "Geothermal", PGALLtoEF$EF)
  
  VCapElec2_without_aggr <- VCapElec2
  getItems(VCapElec2_without_aggr, 3) <- paste0("Capacity|Electricity|", getItems(VCapElec2_without_aggr, 3))
  
  magpie_object <- NULL
  VCapElec2_without_aggr <- add_dimension(VCapElec2_without_aggr, dim = 3.2, add = "unit", nm = "GW")
  magpie_object <- mbind(magpie_object, VCapElec2_without_aggr)
  
  VCapElec2_LGN <- VCapElec2
  # aggregate to reporting fuel categories
  VCapElec2 <- toolAggregate(VCapElec2[,,PGALLtoEF[["PGALL"]]], dim = 3,rel = PGALLtoEF,from = "PGALL", to = "EF")
  VCapElec2_LGN <- toolAggregate(VCapElec2_LGN[,,add_LGN[["PGALL"]]], dim = 3,rel = add_LGN,from = "PGALL", to = "EF")
  
  getItems(VCapElec2, 3) <- paste0("Capacity|Electricity|", getItems(VCapElec2, 3))
  
  getItems(VCapElec2_LGN, 3) <- paste0("Capacity|Electricity|", getItems(VCapElec2_LGN, 3))

  VCapElec2_LGN <- add_dimension(VCapElec2_LGN, dim = 3.2, add = "unit", nm = "GW")
  magpie_object <- mbind(magpie_object, VCapElec2_LGN)
  
  VCapElec2 <- add_dimension(VCapElec2, dim = 3.2, add = "unit", nm = "GW")
  magpie_object <- mbind(magpie_object, VCapElec2)
  
  # electricity production
  VCapElec2_total <- dimSums(VCapElec2, dim = 3, na.rm = TRUE)
  
  getItems(VCapElec2_total, 3) <- "Capacity|Electricity"
  
  VCapElec2_total <- add_dimension(VCapElec2_total, dim = 3.2, add = "unit", nm = "GW")
  magpie_object <- mbind(magpie_object, VCapElec2_total)
  
  library(ggplot2)
  
  #filter period by last year of the model
  an <- readGDX('./blabla.gdx', "an", field = 'l')
  
  .toolgeom_bar <- function(data, colors_vars) {
    return(ggplot(data,aes(y=value,x=period, color=variable)) +
             scale_fill_manual(values = as.character(colors_vars[,3]), limits = as.character(colors_vars[,1])) + 
             scale_color_manual(values = as.character(colors_vars[,3]), limits = as.character(colors_vars[,1])) + 
             geom_bar(stat = "identity",aes(fill=variable) ) + 
             facet_wrap("region",scales = "free_y") +
             labs(x="period", y=paste0("Capacity|Electricity"," ",unique(data[["unit"]]))) +
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
  names(pq) <- sub("PGALL", "variable", names(pq))
  vars <- c(
    "Capacity|Electricity|Solar" ,
    "Capacity|Electricity|Oil" ,
    "Capacity|Electricity|Wind",
    "Capacity|Electricity|Coal",
    "Capacity|Electricity|Gas",
    "Capacity|Electricity|Nuclear",
    "Capacity|Electricity|Biomass",
    "Capacity|Electricity|Geothermal",
    NULL)
  vars_wind <- c(
    "Capacity|Electricity|PGAWND",
    "Capacity|Electricity|PGAWNO",
    "Capacity|Electricity|PGWND",
    NULL)
  vars_sol <- c(
    "Capacity|Electricity|PGADPV",
    "Capacity|Electricity|PGASOL",
    "Capacity|Electricity|PGSOL",
    NULL)
  
  #add missing colors
  V1 <- vars
  V2 <- c("Solar ","Oil","Wind","Coal ","Gas","Nuclear","Biomass","Geothermal")
  V3 <- c("#ffcc00","#663a00","#337fff","#0c0c0c","#999959","#ff33ff","#005900","#e51900")
  
  colors_vars <- data.frame(V1, V2, V3)
  
  #order colors to match variables
  colors_vars <- colors_vars[order(colors_vars[["V1"]]), ]
  
  #filter data by variables and max period
  data <- filter(pq,variable%in%colors_vars[,1],period<=max(an))
  
  #order variables to match colors
  data <- data %>% arrange(as.character(variable))
  
  #create geom_bar
  .toolgeom_bar(data, colors_vars)
  ggsave("1c.png", units="in", width=5.5, height=4, dpi=1200)
  
  #add missing colors
  V1 <- vars_sol
  V2 <- c("PGADPV","PGASOL","PGSOL")
  V3 <- c("#d4ff00","#ffb400","#ffe600")
  
  miss_vars_sol <- data.frame(V1, V2, V3)
  
  #order colors to match variables
  miss_vars_sol <- miss_vars_sol[order(miss_vars_sol[["V1"]]), ]
  
  #filter data by variables and max period
  data2 <- filter(pq,variable%in%miss_vars_sol[,1],period<=max(an))
  
  #order variables to match colors
  data2 <- data2 %>% arrange(as.character(variable))
  
  #create geom_bar
  .toolgeom_bar(data2, miss_vars_sol)
  ggsave("2c.png", units="in", width=5.5, height=4, dpi=1200)
  
  #add missing colors
  V1 <- vars_wind
  V2 <- c("PGAWND","PGAWNO","PGWND")
  V3 <- c("#8800ff","#334cff","#337fff")
  
  miss_vars_wind <- data.frame(V1, V2, V3)
  
  #order colors to match variables
  miss_vars_wind <- miss_vars_wind[order(miss_vars_wind[["V1"]]), ]
  
  #filter data by variables and max period
  data3 <- filter(pq,variable%in%miss_vars_wind[,1],period<=max(an))
  
  #order variables to match colors
  data3 <- data3 %>% arrange(as.character(variable))
  
  #create geom_bar
  .toolgeom_bar(data3, miss_vars_wind)
  ggsave("3c.png", units="in", width=5.5, height=4, dpi=1200)
  
  return(magpie_object)
}
