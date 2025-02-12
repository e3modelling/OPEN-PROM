reportSE <- function(regs) {
  
  # add model OPEN-PROM data electricity production
  VProdElec <- readGDX('./blabla.gdx', "VProdElec", field = 'l')[regs, , ]
  VProdElec <-as.quitte(VProdElec) %>% as.magpie()
  
  PGALLtoEF <- readGDX('./blabla.gdx', "PGALLtoEF")
  names(PGALLtoEF) <- c("PGALL", "EF")
  
  add_LGN <- as.data.frame(PGALLtoEF[which(PGALLtoEF[, 2] == "LGN"), 1])
  add_LGN["EF"] <- "Lignite"
  names(add_LGN) <- c("PGALL","EF")
    
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
  
  VProdElec_without_aggr <- VProdElec
  getItems(VProdElec_without_aggr, 3) <- paste0("Secondary Energy|Electricity|", getItems(VProdElec_without_aggr, 3))
  
  magpie_object <- NULL
  VProdElec_without_aggr <- add_dimension(VProdElec_without_aggr, dim = 3.2, add = "unit", nm = "TWh")
  magpie_object <- mbind(magpie_object, VProdElec_without_aggr)
  
  VProdElec_LGN <- VProdElec
  # aggregate to reporting fuel categories
  VProdElec <- toolAggregate(VProdElec[,,PGALLtoEF[["PGALL"]]], dim = 3,rel = PGALLtoEF,from = "PGALL", to = "EF")
  VProdElec_LGN <- toolAggregate(VProdElec_LGN[,,add_LGN[["PGALL"]]], dim = 3,rel = add_LGN,from = "PGALL", to = "EF")
  
  getItems(VProdElec_LGN, 3) <- paste0("Secondary Energy|Electricity|", getItems(VProdElec_LGN, 3))
  
  VProdElec_LGN <- add_dimension(VProdElec_LGN, dim = 3.2, add = "unit", nm = "TWh")
  magpie_object <- mbind(magpie_object, VProdElec_LGN)
  
  getItems(VProdElec, 3) <- paste0("Secondary Energy|Electricity|", getItems(VProdElec, 3))
  
  VProdElec <- add_dimension(VProdElec, dim = 3.2, add = "unit", nm = "TWh")
  magpie_object <- mbind(magpie_object, VProdElec)
  
  # electricity production
  VProdElec_total <- dimSums(VProdElec, dim = 3, na.rm = TRUE)
  
  getItems(VProdElec_total, 3) <- "Secondary Energy|Electricity"
  
  VProdElec_total <- add_dimension(VProdElec_total, dim = 3.2, add = "unit", nm = "TWh")
  magpie_object <- mbind(magpie_object, VProdElec_total)
  
  library(ggplot2)
  pq <- as.quitte(magpie_object)
  pq <- select(pq, -c("variable"))
  names(pq) <- sub("PGALL", "variable", names(pq))
  vars <- c(
    "Secondary Energy|Electricity|Solar" ,
    "Secondary Energy|Electricity|Oil" ,
    "Secondary Energy|Electricity|Wind",
    "Secondary Energy|Electricity|Coal",
    "Secondary Energy|Electricity|Gas",
    "Secondary Energy|Electricity|Nuclear",
    "Secondary Energy|Electricity|Biomass",
    "Secondary Energy|Electricity|Geothermal",
    NULL)
  vars_wind <- c(
    "Secondary Energy|Electricity|PGAWND",
    "Secondary Energy|Electricity|PGAWNO",
    "Secondary Energy|Electricity|PGWND",
    NULL)
  vars_sol <- c(
    "Secondary Energy|Electricity|PGADPV",
    "Secondary Energy|Electricity|PGASOL",
    "Secondary Energy|Electricity|PGSOL",
    NULL)
  
  #Read csv
  colors <- read.csv(system.file(package="mip",file.path("extdata","plotstyle.csv")))
  
  #Split by semicolon
  split_text <- strsplit(as.character(colors$X.legend.color.marker.linestyle), split = ";")
  
  #Convert the list into a data frame
  colors <- do.call(bind_rows, lapply(split_text, function(x) as.data.frame(t(x))))
  
  colors_vars <- filter(colors,V1%in%vars)
  var_miss <- as.data.frame(vars)
  
  V1 <- as.character(filter(var_miss,!(vars%in%colors[,"V1"]))[["vars"]])
  V2 <- c("Coal","Gas","Biomass")
  V3 <- c("#0c0c0c","#999959","#005900")
  V4 <- rep(NA, 3)
  V5 <- rep(NA, 3)
  
  miss_vars <- data.frame(V1, V2, V3, V4, V5)
  
  colors_vars <- rbind(colors_vars, miss_vars)
  
  colors_vars <- colors_vars[order(colors_vars[["V1"]]), ]
  
  data <- filter(pq,variable%in%colors_vars[,1],period<2051)
  data <- data %>% arrange(as.character(variable))
  
  ggplot(data,aes(y=value,x=period, color=variable)) +
    scale_fill_manual(values = as.character(colors_vars[,3]), limits = as.character(colors_vars[,1])) + scale_color_manual(values = as.character(colors_vars[,3]), limits = as.character(colors_vars[,1])) + geom_bar(stat = "identity",aes(fill=variable)) + facet_wrap("region",scales = "free_y") +theme_bw()+theme(text = element_text(size = 2),
                                                                                                                                                                                                                                       axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1),
                                                                                                                                                                                                                                       aspect.ratio = 1.5/2,plot.title = element_text(size = 2))
  ggsave("1.png", units="in", width=5.5, height=4, dpi=1200)
  
  V1 <- vars_sol
  V2 <- c("PGADPV","PGASOL","PGSOL")
  V3 <- c("#d4ff00","#ffb400","#ffe600")
  
  miss_vars_sol <- data.frame(V1, V2, V3)
  
  miss_vars_sol <- miss_vars_sol[order(miss_vars_sol[["V1"]]), ]
  
  data2 <- filter(pq,variable%in%miss_vars_sol[,1],period<2051)
  data2 <- data2 %>% arrange(as.character(variable))
  
  ggplot(data2,aes(y=value,x=period, color=variable)) +
    scale_fill_manual(values = as.character(miss_vars_sol[,3]), limits = as.character(miss_vars_sol[,1])) + scale_color_manual(values = as.character(miss_vars_sol[,3]), limits = as.character(miss_vars_sol[,1])) + geom_bar(stat = "identity",aes(fill=variable)) + facet_wrap("region",scales = "free_y") +theme_bw()+theme(text = element_text(size = 2),
                                                                                                                                                                                                                                           axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1),
                                                                                                                                                                                                                                           aspect.ratio = 1.5/2,plot.title = element_text(size = 2))
  ggsave("2.png", units="in", width=5.5, height=4, dpi=1200)
  
  V1 <- vars_wind
  V2 <- c("PGAWND","PGAWNO","PGWND")
  V3 <- c("#8800ff","#334cff","#337fff")
  
  miss_vars_wind <- data.frame(V1, V2, V3)
  
  miss_vars_wind <- miss_vars_wind[order(miss_vars_wind[["V1"]]), ]
  
  data3 <- filter(pq,variable%in%miss_vars_wind[,1],period<2051)
  data3 <- data3 %>% arrange(as.character(variable))
  
  ggplot(data3,aes(y=value,x=period, color=variable)) +
    scale_fill_manual(values = as.character(miss_vars_wind[,3]), limits = as.character(miss_vars_wind[,1])) + scale_color_manual(values = as.character(miss_vars_wind[,3]), limits = as.character(miss_vars_wind[,1])) + geom_bar(stat = "identity",aes(fill=variable)) + facet_wrap("region",scales = "free_y") +theme_bw()+theme(text = element_text(size = 2),
                                                                                                                                                                                                                                             axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1),
                                                                                                                                                                                                                                             aspect.ratio = 1.5/2,plot.title = element_text(size = 2))
  ggsave("3.png", units="in", width=5.5, height=4, dpi=1200)
  
  return(magpie_object)
  }
