# This script generates a mif file for comparison of OPEN-PROM data with MENA-EDS and ENERDATA
library(dplyr)
library(gdx)
library(quitte)
library(tidyr)
library(utils)
library(mrprom)
library(stringr)

# read MENA-PROM mapping, will use it to choose the correct variables from MENA
map <- read.csv("MENA-PROM mapping - mena_prom_mapping.csv")

# read GAMS set used for reporting of Final Energy
sets <- readSets("sets.gms", "BALEF2EFS")
sets[, 1] <- gsub("\"","",sets[, 1])
sets <- separate_wider_delim(sets,cols = 1, delim = ".", names = c("BAL","EF"))
sets[["EF"]] <- sub("\\(","",sets[["EF"]])
sets[["EF"]] <- sub("\\)","",sets[["EF"]])
sets <- separate_rows(sets,EF)
sets$BAL <- gsub("Gas fuels", "Gases", sets$BAL)

#add model OPEN-PROM data
VFeCons <- readGDX('./blabla.gdx', "VFeCons", field = 'l')
# aggregate from PROM fuels to reporting fuel categories
VFeCons<-toolAggregate(VFeCons[,,unique(sets$EF)],dim=3,rel=sets,from="EF",to="BAL")
getItems(VFeCons, 3) <- paste0("Final Energy ", getItems(VFeCons, 3))


#add model MENA_EDS data (choosing the correct variable from MENA by use of the MENA-PROM mapping)
a <- readSource("MENA_EDS", subtype =  map[map[["OPEN.PROM"]] == "VFeCons", "MENA.EDS"])
getRegions(a) <- sub("MOR", "MAR", getRegions(a)) # fix wrong region names in MENA
# choose years and regions that both models have
years <- intersect(getYears(a,as.integer=TRUE),getYears(VFeCons,as.integer=TRUE))
regs <- intersect(getRegions(a),getRegions(VFeCons))
# aggregate from MENA fuels to reporting fuel categories
a <- toolAggregate(a[,years,unique(sets$EF)],dim=3,rel=sets,from="EF",to="BAL")
# complete names
getItems(a, 3) <- paste0("Final Energy ", getItems(a, 3))

# write data in mif file
write.report(VFeCons[,years,],file="reporting.mif",model="OPEN-PROM",unit="Mtoe",scenario="BASE")
write.report(a[regs,years,],file="reporting.mif",model="MENA-EDS",unit="Mtoe",append=TRUE,scenario="BASE")


#filter ENERDATA by consumption
b <- readSource("ENERDATA", subtype =  "consumption", convert = TRUE)
# map of enerdata and balance fuel
map_enerdata <- toolGetMapping(name = "enerdata-by-fuel.csv",
                               type = "sectoral",
                               where = "mrprom")

year <- Reduce(intersect, list(getYears(a,as.integer=TRUE),getYears(b,as.integer=TRUE),getYears(VFeCons,as.integer=TRUE)))
#keep the variables from the map
b2 <- b[, year, map_enerdata[, 1]]
b2 <- as.quitte(b2)
names(map_enerdata) <- sub("ENERDATA", "variable", names(map_enerdata))
#remove units
map_enerdata[,1] <- sub("\\..*", "", map_enerdata[,1])
#add a column with the fuels that match each variable of enerdata
v <- left_join(b2, map_enerdata, by = "variable")
v["variable"] <- paste0("Final Energy ", v$fuel)
v <- filter(v, period %in% years)
v <- select(v , -c("fuel"))
v <- as.quitte(v)
v <- as.magpie(v)
# write data in mif file
write.report(v,file="reporting.mif",model="ENERDATA",unit="Mtoe",append=TRUE,scenario="BASE")


#add model OPEN-PROM data Electricity prices
VElecPriInduResConsu <- readGDX('./blabla.gdx', "VElecPriInduResConsu", field = 'l')
#choose Industrial consumer /i/
sets1 <- readSets("sets.gms", "iSet")
elec_prices_Industry <- VElecPriInduResConsu[,,sets1[1,1]]
getNames(elec_prices_Industry) <- "Electricity prices Industrial"
#choose Residential consumer /r/
sets2 <- readSets("sets.gms", "rSet")
elec_prices_Residential <- VElecPriInduResConsu[,,sets2[1,1]]
getNames(elec_prices_Residential) <- "Electricity prices Residential"
elec_prices <- mbind(elec_prices_Industry, elec_prices_Residential)

#add model MENA_EDS data (choosing the correct variable from MENA by use of the MENA-PROM mapping)
z <- readSource("MENA_EDS", subtype =  map[map[["OPEN.PROM"]] == "VElecPriInduResConsu", "MENA.EDS"])

getRegions(z) <- sub("MOR", "MAR", getRegions(z)) # fix wrong region names in MENA
# choose years and regions that both models have
years <- intersect(getYears(z,as.integer=TRUE),getYears(VElecPriInduResConsu,as.integer=TRUE))
regs <- intersect(getRegions(z),getRegions(VElecPriInduResConsu))
#choose Industrial consumer /i/
MENA_Industrial <- z[,years,sets1[1,1]]
getNames(MENA_Industrial) <- "Electricity prices Industrial"
#choose Residential consumer /r/
MENA_Residential <- z[,years,sets2[1,1]]
# complete names
getNames(MENA_Residential) <- "Electricity prices Residential"
z <- mbind(MENA_Industrial, MENA_Residential)

# write data in mif file
write.report(elec_prices[,years,],file="reporting.mif",model="OPEN-PROM",unit="Euro2005/KWh",append=TRUE,scenario="BASE")
write.report(z[regs,years,],file="reporting.mif",model="MENA-EDS",unit="Euro2005/KWh",append=TRUE,scenario="BASE")

#filter ENERDATA by lectricity
k <- readSource("ENERDATA", subtype =  "lectricity", convert = TRUE)
ENERDATA_Industrial <- k[,,"Constant price per toe in US$ of electricity in industry (taxes incl).$15/toe"]
ENERDATA_Residential<- k[,,"Constant price per toe in US$ of electricity for households (taxes incl).$15/toe"]
#fix units from toe to kwh
ENERDATA_Industrial <- ENERDATA_Industrial / 11630
ENERDATA_Residential <- ENERDATA_Residential / 11630
#fix units from $15 to $05
ENERDATA_Industrial <- ENERDATA_Industrial * 1.2136
ENERDATA_Residential <- ENERDATA_Residential * 1.2136
#fix units from $2005 to Euro2005
ENERDATA_Industrial <- ENERDATA_Industrial / 1.24
ENERDATA_Residential <- ENERDATA_Residential / 1.24

getItems(ENERDATA_Industrial, 3) <- "Electricity prices Industrial"
getItems(ENERDATA_Residential, 3) <- "Electricity prices Residential"
x <- mbind(ENERDATA_Industrial, ENERDATA_Residential)
year <- Reduce(intersect, list(getYears(z,as.integer=TRUE),getYears(x,as.integer=TRUE),getYears(VElecPriInduResConsu,as.integer=TRUE)))
x <- x[, year,]
# write data in mif file
write.report(x,file="reporting.mif",model="ENERDATA",unit="Euro2005/KWh",append=TRUE,scenario="BASE")
          
               # Final Energy | "TRANSE" | "INDSE" | "DOMSE" | "NENSE"

#Link between Model Subsectors and Fuels
sets4 <- readSets("sets.gms", "SECTTECH")
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
  
  sets6 <- readSets("sets.gms", sector[y])
  sets6 <- separate_rows(sets6, paste0(sector[y],"(DSBS)"))
  sets6 <- as.data.frame(sets6)
  var_gdx <- readGDX('./blabla.gdx', blabla_var[y], field = 'l')
  var <- var_gdx[,,sets6[, 1]]
  
  map_subsectors <- sets4 %>% filter(SBS %in% as.character(sets6[, 1]))
  
  if (sector[y] == "DOMSE") {
    sets13 <- filter(sets4, EF != "")
    sets13 <- sets13 %>% filter(EF %in% getItems(var_gdx[,,sets6[, 1]],3.2))
    map_subsectors <- sets13 %>% filter(SBS %in% as.character(sets6[, 1]))
  }

  map_subsectors$EF = paste(map_subsectors$SBS, map_subsectors$EF, sep=".")
  
  var <- toolAggregate(var[,,unique(map_subsectors$EF)],dim=3,rel=map_subsectors,from="EF",to="SBS")
  getItems(var, 3) <- paste0("Final Energy ", sector[y]," ", getItems(var, 3))
  
  #add model MENA_EDS data (choosing the correct variable from MENA by use of the MENA-PROM mapping)
  MENA_EDS <- readSource("MENA_EDS", subtype =  map[map[["OPEN.PROM"]] == blabla_var[y], "MENA.EDS"])
  getRegions(MENA_EDS) <- sub("MOR", "MAR", getRegions(MENA_EDS)) # fix wrong region names in MENA
  # choose years and regions that both models have
  years <- intersect(getYears(MENA_EDS,as.integer=TRUE),getYears(var,as.integer=TRUE))
  regs <- intersect(getRegions(MENA_EDS),getRegions(var))
  a <- toolAggregate(MENA_EDS[,,unique(map_subsectors$EF)],dim=3,rel=map_subsectors,from="EF",to="SBS")
  getItems(a, 3) <- paste0("Final Energy ", sector[y]," ", getItems(a, 3))
  
  # write data in mif file
  write.report(var[,years,],file="reporting.mif",model="OPEN-PROM",unit="Mtoe",append=TRUE,scenario="BASE")
  write.report(a[regs,years,],file="reporting.mif",model="MENA-EDS",unit="Mtoe",append=TRUE,scenario="BASE")
  
  #Final Energy by sector 
  sector_open <- dimSums(var, dim = 3)
  getItems(sector_open, 3) <- paste0("Final Energy ", sector[y])
  sector_mena <- dimSums(a, dim = 3)
  getItems(sector_mena, 3) <- paste0("Final Energy ", sector[y])
  
  # write data in mif file
  write.report(sector_open[,years,],file="reporting.mif",model="OPEN-PROM",unit="Mtoe",append=TRUE,scenario="BASE")
  write.report(sector_mena[regs,years,],file="reporting.mif",model="MENA-EDS",unit="Mtoe",append=TRUE,scenario="BASE")
  
  #Energy Forms Aggregations
  sets5 <- readSets("sets.gms", "EFtoEFA")
  sets5[5,] <- paste0(sets5[5,] , sets5[6,])
  sets5 <- sets5[ - 6,]
  sets5 <- as.data.frame(sets5)
  sets5 <- separate_wider_delim(sets5,cols = 1, delim = ".", names = c("EF","EFA"))
  sets5[["EF"]] <- sub("\\(","",sets5[["EF"]])
  sets5[["EF"]] <- sub("\\)","",sets5[["EF"]])
  sets5 <- separate_rows(sets5,EF)
  
  ELC <- readSets("sets.gms", "ELCEF")
  #Add electricity, Hydrogen, Biomass and Waste
  sets5[nrow(sets5) + 1, ] <- ELC[1,1]
  sets5[nrow(sets5) + 1, ] <- "H2F"
  sets5[nrow(sets5) + 1, ] <- "BMSWAS"
  
  sets10 <- sets5 %>% filter(EF %in% getItems(var_gdx,3.2))
  
  #Aggregate model OPEN-PROM by subsector and by energy form 
  var_by_energy_form <- toolAggregate(var_gdx[,,as.character(unique(sets10$EF))],dim=3.2,rel=sets10,from="EF",to="EFA")
  
  #Aggregate model MENA_EDS by subsector and by energy form
  mena_by_energy_form <- toolAggregate(MENA_EDS[,,as.character(unique(sets10$EF))],dim=3.2,rel=sets10,from="EF",to="EFA")
  
  #sector by subsector and by energy form
  var_by_subsector_by_energy_form <- var_by_energy_form
  getItems(var_by_subsector_by_energy_form, 3.1) <- paste0("Final Energy ", sector[y]," ", getItems(var_by_subsector_by_energy_form, 3.1))
  
  #sector by subsector and by energy form MENA_EDS
  mena_by_subsector_by_energy_form <- mena_by_energy_form
  getItems(mena_by_subsector_by_energy_form, 3.1) <- paste0("Final Energy ", sector[y]," ", getItems(mena_by_subsector_by_energy_form, 3.1))
  
  # write data in mif file
  write.report(var_by_subsector_by_energy_form[,years,],file="reporting.mif",model="OPEN-PROM",unit="Mtoe",append=TRUE,scenario="BASE")
  write.report(mena_by_subsector_by_energy_form[regs,years,],file="reporting.mif",model="MENA-EDS",unit="Mtoe",append=TRUE,scenario="BASE")
  
  #sector_by_energy_form
  by_energy_form <- dimSums(var_by_energy_form, 3.1)
  getItems(by_energy_form,3.1) <- paste0("Final Energy ", sector[y]," ", getItems(by_energy_form, 3.1))
  var_mena_by_energy_form <- dimSums(mena_by_energy_form,3.1)
  getItems(var_mena_by_energy_form, 3.1) <- paste0("Final Energy ", sector[y]," ", getItems(var_mena_by_energy_form, 3.1))
  
  # write data in mif file
  write.report(by_energy_form[,years,],file="reporting.mif",model="OPEN-PROM",unit="Mtoe",append=TRUE,scenario="BASE")
  write.report(var_mena_by_energy_form[regs,years,],file="reporting.mif",model="MENA-EDS",unit="Mtoe",append=TRUE,scenario="BASE")
  
  #filter IFuelCons by subtype enerdata
  b3 <- calcOutput(type = "IFuelCons", subtype = sector[y], aggregate = FALSE)
  
  year <- Reduce(intersect, list(getYears(a,as.integer=TRUE),getYears(var,as.integer=TRUE),getYears(b3,as.integer=TRUE)))
  b3 <- b3[,year,]
  
  map_subsectors_ener <- sets4 %>% filter(SBS %in% as.character(sets6[,1]))
  
  map_subsectors_ener$EF = paste(map_subsectors_ener$SBS, "Mtoe",map_subsectors_ener$EF, sep=".")
  #filter to have only the variables which are in enerdata
  map_subsectors_ener <- map_subsectors_ener %>% filter(EF %in% getItems(b3,3))
  
  # aggregate from enerdata fuels to subsectors
  b3_subsector <- toolAggregate(b3[,,as.character(unique(map_subsectors_ener$EF))],dim=3,rel=map_subsectors_ener,from="EF",to="SBS")
  getItems(b3_subsector, 3) <- paste0("Final Energy ", sector[y]," ", getItems(b3_subsector, 3))
  
  # write data in mif file
  write.report(b3_subsector[,year,],file="reporting.mif",model="ENERDATA",unit="Mtoe",append=TRUE,scenario="BASE")
  
  #Final Energy enerdata
  FE_ener <- dimSums(b3, dim = 3)
  getItems(FE_ener, 3) <- paste0("Final Energy ", sector[y])
  
  # write data in mif file
  write.report(FE_ener[,year,],file="reporting.mif",model="ENERDATA",unit="Mtoe",append=TRUE,scenario="BASE")
  
  map_subsectors_ener2 <- sets10
  #filter to have only the variables which are in enerdata
  map_subsectors_ener2 <- map_subsectors_ener2 %>% filter(EF %in% getItems(b3,3.3))
  
  #Aggregate model enerdata by subsector and by energy form
  b3_by_energy_form <- toolAggregate(b3[,year,as.character(unique(map_subsectors_ener2$EF))],dim=3.3,rel=map_subsectors_ener2,from="EF",to="EFA")
  
  #enerdata by subsector and by energy form
  enerdata_by_subsector_by_energy_form <- b3_by_energy_form
  enerdata_by_subsector_by_energy_form <- dimSums(enerdata_by_subsector_by_energy_form, 3.2)
  getItems(enerdata_by_subsector_by_energy_form, 3.1) <- paste0("Final Energy ", sector[y]," ", getItems(enerdata_by_subsector_by_energy_form, 3.1))
  
  # write data in mif file
  write.report(enerdata_by_subsector_by_energy_form[,year,],file="reporting.mif",model="ENERDATA",unit="Mtoe",append=TRUE,scenario="BASE")
  
  #Aggregate model enerdata by energy form
  b3_agg_by_energy_form <- dimSums(b3_by_energy_form, 3.1)
  getItems(b3_agg_by_energy_form,3) <- paste0("Final Energy ", sector[y]," ", getItems(b3_agg_by_energy_form, 3.2))
  
  # write data in mif file
  write.report(b3_agg_by_energy_form[,year,],file="reporting.mif",model="ENERDATA",unit="Mtoe",append=TRUE,scenario="BASE")

}                          

                           # FuelPrice

price_gdx <- readGDX('./blabla.gdx', "iFuelPrice", field = 'l')
price <- price_gdx
getItems(price, 3.1) <- paste0("Fuel Price ", getItems(price, 3.1))

#add model MENA_EDS data (choosing the correct variable from MENA by use of the MENA-PROM mapping)
#fix units from $2015/toe to k$2015/toe
MENA_EDS_price <- readSource("MENA_EDS", subtype =  map[map[["OPEN.PROM"]] == "iFuelPrice", "MENA.EDS"]) / 1000
MENA_EDS_pric <- MENA_EDS_price
getRegions(MENA_EDS_pric) <- sub("MOR", "MAR", getRegions(MENA_EDS_pric)) # fix wrong region names in MENA
# choose years and regions that both models have
years <- intersect(getYears(MENA_EDS_pric,as.integer=TRUE),getYears(price,as.integer=TRUE))
regs <- intersect(getRegions(MENA_EDS_pric),getRegions(price))
getItems(MENA_EDS_pric, 3.1) <- paste0("Fuel Price ", getItems(MENA_EDS_pric, 3.1))

#FuelPrice enerdata
#fix units from $2015/toe to k$2015/toe
a_ener_price <- calcOutput(type = "IFuelPrice", aggregate = FALSE) / 1000
a_ener <- a_ener_price
getItems(a_ener, 3.1) <- paste0("Fuel Price ", getItems(a_ener, 3.1))
year <- Reduce(intersect, list(getYears(MENA_EDS_pric,as.integer=TRUE),getYears(price,as.integer=TRUE),getYears(a_ener,as.integer=TRUE)))

# write data in mif file
write.report(price[,years,],file="reporting.mif",model="OPEN-PROM",unit="various",append=TRUE,scenario="BASE")
write.report(MENA_EDS_pric[regs,years,],file="reporting.mif",model="MENA-EDS",unit="various",append=TRUE,scenario="BASE")
write.report(a_ener[,year,],file="reporting.mif",model="ENERDATA",unit="various",append=TRUE,scenario="BASE")

by_price_form <- dimSums(price_gdx, 3.1)
by_price_form2 <- dimSums(price_gdx, 3.2)
by_price_form_MENA_EDS <- dimSums(MENA_EDS_price, 3.1)
by_price_form2_MENA_EDS <- dimSums(MENA_EDS_price, 3.2)
by_price_form_ener <- dimSums(a_ener_price, 3.1)
by_price_form2_ener <- dimSums(a_ener_price, 3.2)
Fuel_Price <- dimSums(price_gdx)
Fuel_Price_MENA_EDS <- dimSums(MENA_EDS_price)
Fuel_Price_ener <- dimSums(a_ener_price)

getRegions(by_price_form_MENA_EDS) <- sub("MOR", "MAR", getRegions(by_price_form_MENA_EDS))
getRegions(by_price_form2_MENA_EDS) <- sub("MOR", "MAR", getRegions(by_price_form2_MENA_EDS))
getRegions(Fuel_Price_MENA_EDS) <- sub("MOR", "MAR", getRegions(Fuel_Price_MENA_EDS))

getItems(by_price_form, 3) <- paste0("Fuel Price ", getItems(by_price_form, 3))
getItems(by_price_form2, 3) <- paste0("Fuel Price ", getItems(by_price_form2, 3))
getItems(by_price_form_MENA_EDS, 3) <- paste0("Fuel Price ", getItems(by_price_form_MENA_EDS, 3))
getItems(by_price_form2_MENA_EDS, 3) <- paste0("Fuel Price ", getItems(by_price_form2_MENA_EDS, 3))
getItems(by_price_form_ener, 3) <- paste0("Fuel Price ", getItems(by_price_form_ener, 3))
getItems(by_price_form2_ener, 3) <- paste0("Fuel Price ", getItems(by_price_form2_ener, 3))
getItems(Fuel_Price, 3) <- paste0("Fuel Price", getItems(Fuel_Price, 3))
getItems(Fuel_Price_MENA_EDS, 3) <- paste0("Fuel Price", getItems(Fuel_Price_MENA_EDS, 3))
getItems(Fuel_Price_ener, 3) <- paste0("Fuel Price", getItems(Fuel_Price_ener, 3))

# write data in mif file
write.report(by_price_form[,years,],file="reporting.mif",model="OPEN-PROM",unit="various",append=TRUE,scenario="BASE")
write.report(by_price_form_MENA_EDS[regs,years,],file="reporting.mif",model="MENA-EDS",unit="various",append=TRUE,scenario="BASE")
write.report(by_price_form_ener[,year,],file="reporting.mif",model="ENERDATA",unit="various",append=TRUE,scenario="BASE")

write.report(by_price_form2[,years,],file="reporting.mif",model="OPEN-PROM",unit="various",append=TRUE,scenario="BASE")
write.report(by_price_form2_MENA_EDS[regs,years,],file="reporting.mif",model="MENA-EDS",unit="various",append=TRUE,scenario="BASE")
write.report(by_price_form2_ener[,year,],file="reporting.mif",model="ENERDATA",unit="various",append=TRUE,scenario="BASE")

write.report(Fuel_Price[,years,],file="reporting.mif",model="OPEN-PROM",unit="various",append=TRUE,scenario="BASE")
write.report(Fuel_Price_MENA_EDS[regs,years,],file="reporting.mif",model="MENA-EDS",unit="various",append=TRUE,scenario="BASE")
write.report(Fuel_Price_ener[,year,],file="reporting.mif",model="ENERDATA",unit="various",append=TRUE,scenario="BASE")

                                #  emission

iCo2EmiFac <- readGDX('./blabla.gdx', "iCo2EmiFac", field = 'l')
VConsFuel <- readGDX('./blabla.gdx', "VConsFuel", field = 'l')
VTransfInThermPowPls <- readGDX('./blabla.gdx', "VTransfInThermPowPls", field = 'l')
VTransfInputDHPlants <- readGDX('./blabla.gdx', "VTransfInputDHPlants", field = 'l')
VEnCons <- readGDX('./blabla.gdx', "VEnCons", field = 'l')
VDemTr <- readGDX('./blabla.gdx', "VDemTr", field = 'l')
VElecProd <- readGDX('./blabla.gdx', "VElecProd", field = 'l')
iPlantEffByType <- readGDX('./blabla.gdx', "iPlantEffByType", field = 'l')
iCO2CaptRate <- readGDX('./blabla.gdx', "iCO2CaptRate", field = 'l')

EFtoEFS <- readSets("sets.gms", "EFtoEFS")
EFtoEFS <- as.data.frame(EFtoEFS)
EFtoEFS <- separate_wider_delim(EFtoEFS,cols = 1, delim = ".", names = c("EF","EFS"))
EFtoEFS[["EF"]] <- sub("\\(","",EFtoEFS[["EF"]])
EFtoEFS[["EF"]] <- sub("\\)","",EFtoEFS[["EF"]])
EFtoEFS <- EFtoEFS %>% separate_longer_delim(c(EF, EFS), delim = ",")

iCo2EmiFac_by_EFS <- toolAggregate(iCo2EmiFac[,,unique(EFtoEFS$EF)],dim=3.2,rel=EFtoEFS,from="EF",to="EFS")
VConsFuel_by_EFS <- toolAggregate(VConsFuel[,,unique(EFtoEFS$EF)],dim=3.2,rel=EFtoEFS,from="EF",to="EFS")

SECTTECH <- readSets("sets.gms", "SECTTECH")
SECTTECH <- SECTTECH[c(6,7), 1]
SECTTECH[1] <- gsub("\\.", ",", SECTTECH[1])
SECTTECH <- unlist(strsplit(SECTTECH, ","))
SECTTECH <- SECTTECH[c(11:26)]
SECTTECH <- gsub("\\(|\\)", "", SECTTECH)
SECTTECH <- as.data.frame(SECTTECH)

names(SECTTECH) <- sub("SECTTECH", "EF", names(SECTTECH))
qx <- left_join(SECTTECH, EFtoEFS, by = "EF")
qx <- select((qx), -c(EF))

SECTTECH <- unique(qx)
names(SECTTECH) <- sub("EFS", "SECTTECH", names(SECTTECH))

IND <- readSets("sets.gms", "INDDOM")
IND <- unlist(strsplit(IND[, 1], ","))
IND <- as.data.frame(IND)
INDSE <- NULL
for (y in 1:nrow(IND)) {
  p <- paste(IND[y,1], ".", SECTTECH[,1])
  p <- as.data.frame(p)
  p <- p %>% 
    mutate(across(where(is.character), str_remove_all, pattern = fixed(" ")))
  INDSE <- rbind(INDSE, p)
}
INDSE <- as.data.frame(INDSE)

PGEF <- readSets("sets.gms", "PGEF")
PGEF <- as.data.frame(PGEF)

CCS <- readSets("sets.gms", "CCS")
CCS <- as.data.frame(CCS)

var_1 <- dimSums(iCo2EmiFac_by_EFS[,,INDSE[, 1]], 3, na.rm = TRUE)#CO2EMFAC(CYrun,DSBS,EFS,YTIME))
var_2 <- dimSums(VConsFuel_by_EFS[,,INDSE[, 1]], 3, na.rm = TRUE)#CONSEF.L(CYrun,DSBS,EFS,YTIME)
sum1 <- var_1 * var_2
var_3 <- dimSums(VTransfInThermPowPls[,,PGEF[,1]], 3, na.rm = TRUE)#(PGEF, TICT.L(CYrun,PGEF,YTIME)
var_5 <- dimSums(iCo2EmiFac[,,"PG"], 3.1, na.rm = TRUE)
var_5 <- dimSums(var_5[,,PGEF[,1]], 3, na.rm = TRUE)#CO2EMFAC(CYrun,"PG",PGEF,YTIME))
sum2 <- var_3 * var_5
var_4 <- dimSums(VTransfInputDHPlants, 3, na.rm = TRUE)#(EFS, TIDH.L(CYrun,EFS,YTIME)
var_20 <- dimSums(iCo2EmiFac_by_EFS[,,"PG"], 3, na.rm = TRUE)#CO2EMFAC(CYrun,"PG",EFS,YTIME))
sum3 <- var_4 * var_20
var_6 <- dimSums(VEnCons, 3, na.rm = TRUE)#(EFS, CEN.L(CYrun,EFS,YTIME)
var_7 <- dimSums(iCo2EmiFac_by_EFS[,,"PG"], 3, na.rm = TRUE)#CO2EMFAC(CYrun,"PG",EFS,YTIME))
sum4 <- var_6 * var_7


PC <- readSets("sets.gms", "SECTTECH")
PC <- PC[1, 1]
PC <- regmatches(PC, gregexpr("(?<=\\().*?(?=\\))", PC, perl=T))[[1]]
PC <- unlist(strsplit(PC, ","))
PC <- as.data.frame(PC)
PC <- paste("PC", ".", PC[,1])
PC <- as.data.frame(PC)
PC <- PC %>% 
  mutate(across(where(is.character), str_remove_all, pattern = fixed(" ")))
GU <- readSets("sets.gms", "SECTTECH")
GU <- GU[2, 1]
GU <- regmatches(GU, gregexpr("(?<=\\().*?(?=\\))", GU, perl=T))[[1]]
GU <- unlist(strsplit(GU, ","))
GU <- as.data.frame(GU)
GU <- paste("GU", ".", GU[,1])
GU <- as.data.frame(GU)
GU <- GU %>% 
  mutate(across(where(is.character), str_remove_all, pattern = fixed(" ")))
PT <- readSets("sets.gms", "SECTTECH")
PT <- PT[3, 1]
PT <- regmatches(PT, gregexpr("(?<=\\().*?(?=\\))", PT, perl=T))[[1]]
PT <- unlist(strsplit(PT, ","))
PT <- as.data.frame(PT)
PT <- as.data.frame(PT[c(3:5),1])
PT <- paste("PT", ".", PT[,1])
PT <- as.data.frame(PT)
PT <- PT %>% 
  mutate(across(where(is.character), str_remove_all, pattern = fixed(" ")))
GT <- readSets("sets.gms", "SECTTECH")
GT <- GT[3, 1]
GT <- regmatches(GT, gregexpr("(?<=\\().*?(?=\\))", GT, perl=T))[[1]]
GT <- unlist(strsplit(GT, ","))
GT <- as.data.frame(GT)
GT <- as.data.frame(GT[c(3:5),1])
GT <- paste("GT", ".", GT[,1])
GT <- as.data.frame(GT)
GT <- GT %>% 
  mutate(across(where(is.character), str_remove_all, pattern = fixed(" ")))
PA <- as.data.frame("PA.KRS")
GN <- readSets("sets.gms", "SECTTECH")
GN <- GN[5, 1]
GN <- regmatches(GN, gregexpr("(?<=\\().*?(?=\\))", GN, perl=T))[[1]]
GN <- unlist(strsplit(GN, ","))
GN <- as.data.frame(GN)
GN <- paste("GN", ".", GN[,1])
GN <- as.data.frame(GN)
GN <- GN %>% 
  mutate(across(where(is.character), str_remove_all, pattern = fixed(" ")))
names(PC) <- "r"
names(PA) <- "r"
names(PT) <- "r"
names(GU) <- "r"
names(GT) <- "r"
names(GN) <- "r"

map_TRANSECTOR <- rbind(PT,GT,PA,PC,GU,GN)

var_8 <- dimSums(VDemTr[,,map_TRANSECTOR[, 1]], 3, na.rm = TRUE)#DEMTR.L(CYrun,TRANSE,EF,YTIME)
var_9 <- dimSums(iCo2EmiFac[,,map_TRANSECTOR[, 1]], 3, na.rm = TRUE)#CO2EMFAC(CYrun,TRANSE,EF,YTIME))
sum5 <- var_8 * var_9

PGALLtoEF <- readSets("sets.gms", "PGALLtoEF")
PGALLtoEF <- as.data.frame(PGALLtoEF)
PGALLtoEF <- separate_wider_delim(PGALLtoEF,cols = 1, delim = ".", names = c("PGALL","EF"))
PGALLtoEF[["PGALL"]] <- sub("\\(","",PGALLtoEF[["PGALL"]])
PGALLtoEF[["PGALL"]] <- sub("\\)","",PGALLtoEF[["PGALL"]])
PGALLtoEF <- separate_rows(PGALLtoEF,PGALL)

CCS <- PGALLtoEF[PGALLtoEF$PGALL %in% CCS$CCS, ]
  
var_10 <- dimSums(iCo2EmiFac[,,"PG"],dim=3.1, na.rm = TRUE)
var_10 <- var_10[,,CCS[,2]]#CO2EMFAC(CYrun,"PG",PGEF,YTIME)
var_11 <- toolAggregate(VElecProd[,,CCS[,1]],dim=3,rel=CCS,from="PGALL",to="EF")#ELCPROD.L(CYrun,CCS,YTIME)
var_12 <- toolAggregate(iPlantEffByType[,,CCS[,1]],dim=3,rel=CCS,from="PGALL",to="EF")#PGEFF(CYrun,CCS,YTIME)
var_13 <- toolAggregate(iCO2CaptRate[,,CCS[,1]],dim=3,rel=CCS,from="PGALL",to="EF")#PGCR(CYrun,CCS,YTIME)))
var_16 <- var_11 * 0.086 / var_12 * var_10 * var_13
sum6 <- dimSums(var_16,dim=3, na.rm = TRUE)

SECTTECH2 <- readSets("sets.gms", "SECTTECH")
SECTTECH2 <- SECTTECH2[11, 1]
SECTTECH2 <- regmatches(SECTTECH2, gregexpr("(?<=\\().*?(?=\\))", SECTTECH2, perl=T))[[1]]
SECTTECH2 <- unlist(strsplit(SECTTECH2, ","))
SECTTECH2 <- as.data.frame(SECTTECH2)
SECTTECH2 <- paste("BU", ".", SECTTECH2[,1])
SECTTECH2 <- as.data.frame(SECTTECH2)
SECTTECH2 <- SECTTECH2 %>% 
  mutate(across(where(is.character), str_remove_all, pattern = fixed(" ")))

var_14 <- dimSums(iCo2EmiFac_by_EFS[,,SECTTECH2[,1]], 3, na.rm = TRUE)#co2emfac(CYrun,DSBS,EFS,YTIME))
var_15 <- dimSums(VConsFuel_by_EFS[,,SECTTECH2[,1]], 3, na.rm = TRUE)#consef.l(CYrun,DSBS,EFS,YTIME) 
sum7 <- var_14 * var_15

total_CO2 <- ifelse(is.na(sum1), 0, sum1) + ifelse(is.na(sum2), 0, sum2) + ifelse(is.na(sum3), 0, sum3) + ifelse(is.na(sum4), 0, sum4) + ifelse(is.na(sum5), 0, sum5) - ifelse(is.na(sum6), 0, sum6)  + ifelse(is.na(sum7), 0, sum7)

getItems(total_CO2, 3) <- paste0("Emission")

#add model MENA_EDS data (choosing the correct variable from MENA by use of the MENA-PROM mapping)
MENA_iCo2EmiFac <- readSource("MENA_EDS", subtype =  map[map[["OPEN.PROM"]] == "iCo2EmiFac", "MENA.EDS"])
MENA_VConsFuel <- readSource("MENA_EDS", subtype =  map[map[["OPEN.PROM"]] == "VConsFuel", "MENA.EDS"])
MENA_VTransfInThermPowPls <- readSource("MENA_EDS", subtype =  map[map[["OPEN.PROM"]] == "VTransfInThermPowPls", "MENA.EDS"])
MENA_VTransfInputDHPlants <- readSource("MENA_EDS", subtype =  map[map[["OPEN.PROM"]] == "VTransfInputDHPlants", "MENA.EDS"])
MENA_VEnCons <- readSource("MENA_EDS", subtype =  map[map[["OPEN.PROM"]] == "VEnCons", "MENA.EDS"])
MENA_VDemTr <- readSource("MENA_EDS", subtype =  map[map[["OPEN.PROM"]] == "VDemTr", "MENA.EDS"])
MENA_VElecProd <- readSource("MENA_EDS", subtype =  map[map[["OPEN.PROM"]] == "VElecProd", "MENA.EDS"])
MENA_iPlantEffByType <- readSource("MENA_EDS", subtype =  map[map[["OPEN.PROM"]] == "iPlantEffByType", "MENA.EDS"])
MENA_iCO2CaptRate <- readSource("MENA_EDS", subtype =  map[map[["OPEN.PROM"]] == "iCO2CaptRate", "MENA.EDS"])

MENA_iCo2EmiFac_by_EFS <- MENA_iCo2EmiFac[,,unique(EFtoEFS$EFS)]
MENA_VConsFuel_by_EFS <- MENA_VConsFuel[,,unique(EFtoEFS$EFS)]

MENA_iCo2EmiFac_by_EFS <- toolAggregate(MENA_iCo2EmiFac[,,unique(EFtoEFS$EF)],dim=3.2,rel=EFtoEFS,from="EF",to="EFS")
MENA_VConsFuel_by_EFS <- toolAggregate(MENA_VConsFuel[,,unique(EFtoEFS$EF)],dim=3.2,rel=EFtoEFS,from="EF",to="EFS")

MENA_var_1 <- dimSums(MENA_iCo2EmiFac_by_EFS[,,INDSE[, 1]], 3, na.rm = TRUE)
MENA_var_2 <- dimSums(MENA_VConsFuel_by_EFS[,,INDSE[, 1]], 3, na.rm = TRUE)
MENA_sum1 <- MENA_var_1 * MENA_var_2
MENA_var_3 <- dimSums(MENA_VTransfInThermPowPls[,,PGEF[,1]], 3, na.rm = TRUE)
MENA_var_5 <- dimSums(MENA_iCo2EmiFac[,,"PG"], 3.1, na.rm = TRUE)
MENA_var_5 <- dimSums(MENA_var_5[,,PGEF[,1]], 3, na.rm = TRUE)
MENA_sum2 <- MENA_var_3 * MENA_var_5
MENA_var_4 <- dimSums(MENA_VTransfInputDHPlants, 3, na.rm = TRUE)
MENA_var_20 <- dimSums(MENA_iCo2EmiFac_by_EFS[,,"PG"], 3, na.rm = TRUE)
MENA_sum3 <- MENA_var_4 * MENA_var_20
MENA_var_6 <- dimSums(MENA_VEnCons, 3, na.rm = TRUE)
MENA_var_7 <- dimSums(MENA_iCo2EmiFac_by_EFS[,,"PG"], 3, na.rm = TRUE)
MENA_sum4 <- MENA_var_6 * MENA_var_7
MENA_var_8 <- dimSums(MENA_VDemTr[,,map_TRANSECTOR[, 1]], 3, na.rm = TRUE)
MENA_var_9 <- dimSums(MENA_iCo2EmiFac[,,map_TRANSECTOR[, 1]], 3, na.rm = TRUE)
MENA_sum5 <- MENA_var_8 * MENA_var_9
MENA_var_10 <- dimSums(MENA_iCo2EmiFac[,,"PG"],dim=3.1, na.rm = TRUE)
MENA_var_10 <- MENA_var_10[,,CCS[,2]]
MENA_var_11 <- toolAggregate(MENA_VElecProd[,,CCS[,1]],dim=3,rel=CCS,from="PGALL",to="EF")
MENA_var_12 <- toolAggregate(MENA_iPlantEffByType[,,CCS[,1]],dim=3,rel=CCS,from="PGALL",to="EF")
MENA_var_13 <- toolAggregate(MENA_iCO2CaptRate[,,CCS[,1]],dim=3,rel=CCS,from="PGALL",to="EF")
MENA_var_16 <- MENA_var_11 * 0.086 / MENA_var_12 * MENA_var_10 * MENA_var_13
MENA_sum6 <- dimSums(MENA_var_16,dim=3, na.rm = TRUE)
MENA_var_14 <- dimSums(MENA_iCo2EmiFac_by_EFS[,,SECTTECH2[,1]], 3, na.rm = TRUE)
MENA_var_15 <- dimSums(MENA_VConsFuel_by_EFS[,,SECTTECH2[,1]], 3, na.rm = TRUE)
MENA_sum7 <- MENA_var_14 * MENA_var_15

MENA_SUM <- ifelse(is.na(MENA_sum1), 0, MENA_sum1) + ifelse(is.na(MENA_sum2), 0, MENA_sum2) + ifelse(is.na(MENA_sum3), 0, MENA_sum3) + ifelse(is.na(MENA_sum4), 0, MENA_sum4) + ifelse(is.na(MENA_sum5), 0, MENA_sum5) - ifelse(is.na(MENA_sum6), 0, MENA_sum6) + ifelse(is.na(MENA_sum7), 0, MENA_sum7)

getItems(MENA_SUM, 3) <- paste0("Emission")

getRegions(MENA_SUM) <- sub("MOR", "MAR", getRegions(MENA_SUM))
# choose years and regions that both models have
years <- intersect(getYears(MENA_SUM,as.integer=TRUE),getYears(total_CO2,as.integer=TRUE))
regs <- intersect(getRegions(MENA_SUM),getRegions(total_CO2))
getItems(MENA_SUM, 3.1) <- paste0("Emission")

# write data in mif file
write.report(total_CO2[,years,],file="reporting.mif",model="OPEN-PROM",unit="various",append=TRUE,scenario="BASE")
write.report(MENA_SUM[regs,years,],file="reporting.mif",model="MENA-EDS",unit="various",append=TRUE,scenario="BASE")
#c("MAR","IND","USA","EGY","RWO")
calc <- dimSums(total_CO2[c("MAR","IND","USA","EGY","RWO"),2018:2020,], 1, na.rm = TRUE)
VTotGhgEmisAllCountrNap <- readGDX('./blabla.gdx', "VTotGhgEmisAllCountrNap", field = 'l')
VTotGhgEmisAllCountrNap <- dimSums(VTotGhgEmisAllCountrNap[,2018:2020,], 3, na.rm = TRUE)
diff <- calc - VTotGhgEmisAllCountrNap
diff <- as.quitte(diff)

# calc_mena <- dimSums(MENA_SUM[regs,2018:2020,], 1, na.rm = TRUE)
# 
# l <- readSource("ENERDATA", "2", convert = TRUE)
# l1 <- l[,,"CO2 emissions from fuel combustion (sectoral approach).MtCO2"]
# l2 <- l[,,"CO2 emissions: fuel combustion (reference approach).MtCO2"]
# getItems(l1,3) <- paste0("Emission")
# getItems(l2,3) <- paste0("Emission")

# write data in mif file
# write.report(l1[,2010:2021,],file="reporting.mif",model="ENERDATA1",unit="various",append=TRUE,scenario="BASE")
# write.report(l2[,2010:2021,],file="reporting.mif",model="ENERDATA2",unit="various",append=TRUE,scenario="BASE")
# 
