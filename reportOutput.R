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
#TRANSFINAL(TRANSE), 6 categories
sets6 <- readSets("sets.gms", "TRANSE")
sets6 <- separate_rows(sets6, `TRANSE(DSBS)`)

map_subsectors <- sets4 %>% filter(SBS %in% as.character((sets6$`TRANSE(DSBS)`)))
map_subsectors$EF = paste(map_subsectors$SBS, map_subsectors$EF, sep=".")

#add model OPEN-PROM data final energy demand by transport subsectors (Mtoe) and by fuel
VDemTr <- readGDX('./blabla.gdx', "VDemTr", field = 'l')

# aggregate from PROM fuels to subsectors
VDemTr_subsectors <- toolAggregate(VDemTr[,,unique(map_subsectors$EF)],dim=3,rel=map_subsectors,from="EF",to="SBS")
getItems(VDemTr_subsectors, 3) <- paste0("Final Energy Transport ", getItems(VDemTr_subsectors, 3))

#add model MENA_EDS data (choosing the correct variable from MENA by use of the MENA-PROM mapping)
a <- readSource("MENA_EDS", subtype =  map[map[["OPEN.PROM"]] == "VDemTr", "MENA.EDS"])
getRegions(a) <- sub("MOR", "MAR", getRegions(a)) # fix wrong region names in MENA
# choose years and regions that both models have
years <- intersect(getYears(a,as.integer=TRUE),getYears(VDemTr_subsectors,as.integer=TRUE))
regs <- intersect(getRegions(a),getRegions(VDemTr_subsectors))
mena_subsectors <- toolAggregate(a[,,unique(map_subsectors$EF)],dim=3,rel=map_subsectors,from="EF",to="SBS")
getItems(mena_subsectors, 3) <- paste0("Final Energy Transport ", getItems(mena_subsectors, 3))

# write data in mif file
write.report(VDemTr_subsectors[,years,],file="reporting.mif",model="OPEN-PROM",unit="Mtoe",append=TRUE,scenario="BASE")
write.report(mena_subsectors[regs,years,],file="reporting.mif",model="MENA-EDS",unit="Mtoe",append=TRUE,scenario="BASE")

#Final Energy transportation 
transportation <- dimSums(VDemTr, dim = 3)
getItems(transportation, 3) <- "Final Energy Transport"
transportation_mena <- dimSums(a, dim = 3)
getItems(transportation_mena, 3) <- "Final Energy Transport"

# write data in mif file
write.report(transportation[,years,],file="reporting.mif",model="OPEN-PROM",unit="Mtoe",append=TRUE,scenario="BASE")
write.report(transportation_mena[regs,years,],file="reporting.mif",model="MENA-EDS",unit="Mtoe",append=TRUE,scenario="BASE")

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

sets10 <- sets5 %>% filter(EF %in% getItems(VDemTr,3.2))

#Aggregate model OPEN-PROM by subsector and by energy form 
VDemTr_by_energy_form <- toolAggregate(VDemTr[,,as.character(unique(sets10$EF))],dim=3.2,rel=sets10,from="EF",to="EFA")

#Aggregate model MENA_EDS by subsector and by energy form
mena_by_energy_form <- toolAggregate(a[,,as.character(unique(sets10$EF))],dim=3.2,rel=sets10,from="EF",to="EFA")

#transportation by subsector and by energy form
transportation_by_subsector_by_energy_form <- VDemTr_by_energy_form
getItems(transportation_by_subsector_by_energy_form, 3.1) <- paste0("Final Energy Transport ", getItems(transportation_by_subsector_by_energy_form, 3.1))

#transportation by subsector and by energy form MENA_EDS
transportation_mena_by_subsector_by_energy_form <- mena_by_energy_form
getItems(transportation_mena_by_subsector_by_energy_form, 3.1) <- paste0("Final Energy Transport ", getItems(transportation_mena_by_subsector_by_energy_form, 3.1))

# write data in mif file
write.report(transportation_by_subsector_by_energy_form[,years,],file="reporting.mif",model="OPEN-PROM",unit="Mtoe",append=TRUE,scenario="BASE")
write.report(transportation_mena_by_subsector_by_energy_form[regs,years,],file="reporting.mif",model="MENA-EDS",unit="Mtoe",append=TRUE,scenario="BASE")

#transportation_by_energy_form
transportation_by_energy_form <- dimSums(VDemTr_by_energy_form, 3.1)
getItems(transportation_by_energy_form,3.1) <- paste0("Final Energy Transport ", getItems(transportation_by_energy_form, 3.1))
transportation_mena_by_energy_form <- dimSums(mena_by_energy_form,3.1)
getItems(transportation_mena_by_energy_form, 3.1) <- paste0("Final Energy Transport ", getItems(transportation_mena_by_energy_form, 3.1))

# write data in mif file
write.report(transportation_by_energy_form[,years,],file="reporting.mif",model="OPEN-PROM",unit="Mtoe",append=TRUE,scenario="BASE")
write.report(transportation_mena_by_energy_form[regs,years,],file="reporting.mif",model="MENA-EDS",unit="Mtoe",append=TRUE,scenario="BASE")

#missing fuels
#v <- getItems(VDemTr,3.2)
#v <- as.data.frame(v)
#l <- v %>% filter(!v %in% as.character(unique(sets10$EF)))

#VDemTr_missing <- VDemTr[,,as.character(unique(l$v))]
#x <- as.quitte(VDemTr_missing)
#z <- x %>% filter(value > 0)
#u <- unique(z["EF"])

#filter IFuelCons by transport
b3 <- calcOutput(type = "IFuelCons", subtype = "TRANSE", aggregate = FALSE)
year <- Reduce(intersect, list(getYears(a,as.integer=TRUE),getYears(VDemTr_subsectors,as.integer=TRUE),getYears(b3,as.integer=TRUE)))
b3 <- b3[,year,]

map_subsectors_ener <- sets4 %>% filter(SBS %in% as.character((sets6$`TRANSE(DSBS)`)))
map_subsectors_ener$EF = paste(map_subsectors_ener$SBS, "Mtoe",map_subsectors_ener$EF, sep=".")
#filter to have only the variables which are in enerdata
map_subsectors_ener <- map_subsectors_ener %>% filter(EF %in% getItems(b3,3))

# aggregate from enerdata fuels to subsectors
b3_subsector <- toolAggregate(b3[,,as.character(unique(map_subsectors_ener$EF))],dim=3,rel=map_subsectors_ener,from="EF",to="SBS")
getItems(b3_subsector, 3) <- paste0("Final Energy Transport ", getItems(b3_subsector, 3))

# write data in mif file
write.report(b3_subsector[,year,],file="reporting.mif",model="ENERDATA",unit="Mtoe",append=TRUE,scenario="BASE")

#Final Energy transportation enerdata
transportation_ener <- dimSums(b3, dim = 3)
getItems(transportation_ener, 3) <- "Final Energy Transport"

# write data in mif file
write.report(transportation_ener[,year,],file="reporting.mif",model="ENERDATA",unit="Mtoe",append=TRUE,scenario="BASE")

map_subsectors_ener2 <- sets10
#filter to have only the variables which are in enerdata
map_subsectors_ener2 <- map_subsectors_ener2 %>% filter(EF %in% getItems(b3,3.3))

#Aggregate model enerdata by subsector and by energy form
b3_by_energy_form <- toolAggregate(b3[,year,as.character(unique(map_subsectors_ener2$EF))],dim=3.3,rel=map_subsectors_ener2,from="EF",to="EFA")

#enerdata by subsector and by energy form
transportation_enerdata_by_subsector_by_energy_form <- b3_by_energy_form
transportation_enerdata_by_subsector_by_energy_form <- dimSums(transportation_enerdata_by_subsector_by_energy_form, 3.2)
getItems(transportation_enerdata_by_subsector_by_energy_form, 3.1) <- paste0("Final Energy Transport ", getItems(transportation_enerdata_by_subsector_by_energy_form, 3.1))

# write data in mif file
write.report(transportation_enerdata_by_subsector_by_energy_form[,year,],file="reporting.mif",model="ENERDATA",unit="Mtoe",append=TRUE,scenario="BASE")

#Aggregate model enerdata by energy form
b3_by_energy_form <- dimSums(b3_by_energy_form, 3.1)
getItems(b3_by_energy_form,3) <- paste0("Final Energy Transport ", getItems(b3_by_energy_form, 3.2))

# write data in mif file
write.report(b3_by_energy_form[,year,],file="reporting.mif",model="ENERDATA",unit="Mtoe",append=TRUE,scenario="BASE")


#industry
#add model OPEN-PROM data final energy demand by industry subsectors (Mtoe) and by fuel
VConsFuel <- readGDX('./blabla.gdx', "VConsFuel", field = 'l')
q <- VConsFuel
#Industrial SubSectors
sets8 <- readSets("sets.gms", "INDSE")
sets8 <- separate_rows(sets8, `INDSE(DSBS)`)
sets8 <- as.data.frame(sets8)
VConsFuel <- VConsFuel[,,sets8$`INDSE(DSBS)`]

map_subsectors6 <- sets4 %>% filter(SBS %in% as.character((sets8$`INDSE(DSBS)`)))
map_subsectors6$EF = paste(map_subsectors6$SBS, map_subsectors6$EF, sep=".")

VConsFuel_subsectors <- toolAggregate(VConsFuel[,,unique(map_subsectors6$EF)],dim=3,rel=map_subsectors6,from="EF",to="SBS")
getItems(VConsFuel_subsectors, 3) <- paste0("Final Energy Industry ", getItems(VConsFuel_subsectors, 3))

#add model MENA_EDS data (choosing the correct variable from MENA by use of the MENA-PROM mapping)
a <- readSource("MENA_EDS", subtype =  map[map[["OPEN.PROM"]] == "VConsFuel", "MENA.EDS"])
getRegions(a) <- sub("MOR", "MAR", getRegions(a)) # fix wrong region names in MENA
q2 <- a
# choose years and regions that both models have
years <- intersect(getYears(a,as.integer=TRUE),getYears(VConsFuel_subsectors,as.integer=TRUE))
regs <- intersect(getRegions(a),getRegions(VConsFuel_subsectors))
a <- a[,,sets8$`INDSE(DSBS)`]
mena_subsectors_industry <- toolAggregate(q2[,,unique(map_subsectors6$EF)],dim=3,rel=map_subsectors6,from="EF",to="SBS")
getItems(mena_subsectors_industry, 3) <- paste0("Final Energy Industry ", getItems(mena_subsectors_industry, 3))

# write data in mif file
write.report(VConsFuel_subsectors[,years,],file="reporting.mif",model="OPEN-PROM",unit="Mtoe",append=TRUE,scenario="BASE")
write.report(mena_subsectors_industry[regs,years,],file="reporting.mif",model="MENA-EDS",unit="Mtoe",append=TRUE,scenario="BASE")

#Final Energy industry 
industry <- dimSums(VConsFuel_subsectors, dim = 3)
getItems(industry, 3) <- "Final Energy Industry"
industry_mena <- dimSums(mena_subsectors_industry, dim = 3)
getItems(industry_mena, 3) <- "Final Energy Industry"

# write data in mif file
write.report(industry[,years,],file="reporting.mif",model="OPEN-PROM",unit="Mtoe",append=TRUE,scenario="BASE")
write.report(industry_mena[regs,years,],file="reporting.mif",model="MENA-EDS",unit="Mtoe",append=TRUE,scenario="BASE")

#Energy Forms Aggregations
sets9 <- sets5 %>% filter(EF %in% getItems(VConsFuel,3.2))

#Aggregate model OPEN-PROM by subsector and by energy form 
VConsFuel_by_energy_form <- toolAggregate(VConsFuel[,,as.character(unique(sets9$EF))],dim=3.2,rel=sets9,from="EF",to="EFA")

#Aggregate model MENA_EDS by subsector and by energy form
mena_by_energy_form_industry <- toolAggregate(a[,,as.character(unique(sets9$EF))],dim=3.2,rel=sets9,from="EF",to="EFA")

#industry by subsector and by energy form
industry_by_subsector_by_energy_form <- VConsFuel_by_energy_form
getItems(industry_by_subsector_by_energy_form, 3.1) <- paste0("Final Energy Industry ", getItems(industry_by_subsector_by_energy_form, 3.1))

#industry by subsector and by energy form MENA_EDS
industry_mena_by_subsector_by_energy_form <- mena_by_energy_form_industry
getItems(industry_mena_by_subsector_by_energy_form, 3.1) <- paste0("Final Energy Industry ", getItems(industry_mena_by_subsector_by_energy_form, 3.1))

# write data in mif file
write.report(industry_by_subsector_by_energy_form[,years,],file="reporting.mif",model="OPEN-PROM",unit="Mtoe",append=TRUE,scenario="BASE")
write.report(industry_mena_by_subsector_by_energy_form[regs,years,],file="reporting.mif",model="MENA-EDS",unit="Mtoe",append=TRUE,scenario="BASE")

#industry_by_energy_form
industry_by_energy_form <- dimSums(VConsFuel_by_energy_form, 3.1)
getItems(industry_by_energy_form,3.1) <- paste0("Final Energy Industry ", getItems(industry_by_energy_form, 3.1))
industry_mena_by_energy_form <- dimSums(mena_by_energy_form_industry,3.1)
getItems(industry_mena_by_energy_form, 3.1) <- paste0("Final Energy Industry ", getItems(industry_mena_by_energy_form, 3.1))

# write data in mif file
write.report(industry_by_energy_form[,years,],file="reporting.mif",model="OPEN-PROM",unit="Mtoe",append=TRUE,scenario="BASE")
write.report(industry_mena_by_energy_form[regs,years,],file="reporting.mif",model="MENA-EDS",unit="Mtoe",append=TRUE,scenario="BASE")

#filter IFuelCons by INDSE
b4 <- calcOutput(type = "IFuelCons", subtype = "INDSE", aggregate = FALSE)
year <- Reduce(intersect, list(getYears(a,as.integer=TRUE),getYears(VConsFuel_subsectors,as.integer=TRUE),getYears(b4,as.integer=TRUE)))
b4 <- b4[,year,]
b4 <- b4[,,sets8$`INDSE(DSBS)`]

map_subsectors_ener6 <- sets4 %>% filter(SBS %in% as.character((sets8$`INDSE(DSBS)`)))
map_subsectors_ener6$EF = paste(map_subsectors_ener6$SBS, "Mtoe",map_subsectors_ener6$EF, sep=".")
#filter to have only the variables which are in enerdata
map_subsectors_ener6 <- map_subsectors_ener6 %>% filter(EF %in% getItems(b4,3))

# aggregate from enerdata fuels to subsectors
b4_by_subsector <- toolAggregate(b4[,,as.character(unique(map_subsectors_ener6$EF))],dim=3,rel=map_subsectors_ener6,from="EF",to="SBS")

getItems(b4_by_subsector, 3) <- paste0("Final Energy Industry ", getItems(b4_by_subsector, 3))

# write data in mif file
write.report(b4_by_subsector[,year,],file="reporting.mif",model="ENERDATA",unit="Mtoe",append=TRUE,scenario="BASE")

#Final Energy industry enerdata
industry_ener <- dimSums(b4_by_subsector, dim = 3)
getItems(industry_ener, 3) <- "Final Energy Industry"

# write data in mif file
write.report(industry_ener[,year,],file="reporting.mif",model="ENERDATA",unit="Mtoe",append=TRUE,scenario="BASE")

map_subsectors_ener4 <- sets9
#filter to have only the variables which are in enerdata
map_subsectors_ener4 <- map_subsectors_ener4 %>% filter(EF %in% getItems(b4,3.3))

#Aggregate model enerdata by subsector and by energy form
b4_by_energy_form <- toolAggregate(b4[,year,as.character(unique(map_subsectors_ener4$EF))],dim=3.3,rel=map_subsectors_ener4,from="EF",to="EFA")

#enerdata by subsector and by energy form
industry_enerdata_by_subsector_by_energy_form <- b4_by_energy_form
industry_enerdata_by_subsector_by_energy_form <- dimSums(industry_enerdata_by_subsector_by_energy_form, 3.2)
getItems(industry_enerdata_by_subsector_by_energy_form, 3.1) <- paste0("Final Energy Industry ", getItems(industry_enerdata_by_subsector_by_energy_form, 3.1))

# write data in mif file
write.report(industry_enerdata_by_subsector_by_energy_form[,year,],file="reporting.mif",model="ENERDATA",unit="Mtoe",append=TRUE,scenario="BASE")

#Aggregate model enerdata by energy form
industry_enerdata__by_energy_form <- dimSums(b4_by_energy_form, 3.1)
getItems(industry_enerdata__by_energy_form,3) <- paste0("Final Energy Industry ", getItems(industry_enerdata__by_energy_form, 3.2))

# write data in mif file
write.report(industry_enerdata__by_energy_form[,year,],file="reporting.mif",model="ENERDATA",unit="Mtoe",append=TRUE,scenario="BASE")


#Residential and Commercial
#Residential and Commercial SubSectors
sets11 <- readSets("sets.gms", "DOMSE")
sets11 <- separate_rows(sets11, `DOMSE(DSBS)`)
sets11 <- as.data.frame(sets11)
q3 <- q[,,sets11$`DOMSE(DSBS)`]
VConsFuel_subsectors_DOMSE <- q[,,sets11$`DOMSE(DSBS)`]

sets13 <- filter(sets4, EF != "")
sets13 <- sets13 %>% filter(EF %in% getItems(q[,,sets11$`DOMSE(DSBS)`],3.2))

map_subsectors7 <- sets13 %>% filter(SBS %in% as.character((sets11$`DOMSE(DSBS)`)))
map_subsectors7$EF <- paste(map_subsectors7$SBS, map_subsectors7$EF, sep=".")

VConsFuel_subsectors_DOMSE <- toolAggregate(q3[,,unique(map_subsectors7$EF)],dim=3,rel=map_subsectors7,from="EF",to="SBS")
getItems(VConsFuel_subsectors_DOMSE, 3) <- paste0("Final Energy Residential and Commercial ", getItems(VConsFuel_subsectors_DOMSE, 3))

q4 <- q2[,,sets11$`DOMSE(DSBS)`]

mena_subsectors_DOMSE <- toolAggregate(q4[,,unique(map_subsectors7$EF)],dim=3,rel=map_subsectors7,from="EF",to="SBS")
getItems(mena_subsectors_DOMSE, 3) <- paste0("Final Energy Residential and Commercial ", getItems(mena_subsectors_DOMSE, 3))

years <- intersect(getYears(mena_subsectors_DOMSE,as.integer=TRUE),getYears(VConsFuel_subsectors_DOMSE,as.integer=TRUE))
regs <- intersect(getRegions(mena_subsectors_DOMSE),getRegions(VConsFuel_subsectors_DOMSE))

# write data in mif file
write.report(VConsFuel_subsectors_DOMSE[,years,],file="reporting.mif",model="OPEN-PROM",unit="Mtoe",append=TRUE,scenario="BASE")
write.report(mena_subsectors_DOMSE[regs,years,],file="reporting.mif",model="MENA-EDS",unit="Mtoe",append=TRUE,scenario="BASE")

#Final Energy Residential and Commercial 
residential <- dimSums(VConsFuel_subsectors_DOMSE, dim = 3)
getItems(residential, 3) <- "Final Energy Residential and Commercial"
residential_mena <- dimSums(mena_subsectors_DOMSE, dim = 3)
getItems(residential_mena, 3) <- "Final Energy Residential and Commercial"

# write data in mif file
write.report(residential[,years,],file="reporting.mif",model="OPEN-PROM",unit="Mtoe",append=TRUE,scenario="BASE")
write.report(residential_mena[regs,years,],file="reporting.mif",model="MENA-EDS",unit="Mtoe",append=TRUE,scenario="BASE")

#Energy Forms Aggregations
sets12 <- sets5 %>% filter(EF %in% getItems(q[,,sets11$`DOMSE(DSBS)`],3.2))

#Aggregate model OPEN-PROM by subsector and by energy form 
VConsFuel_by_energy_form_DOMSE <- toolAggregate(q3[,,as.character(unique(sets12$EF))],dim=3.2,rel=sets12,from="EF",to="EFA")

#Aggregate model MENA_EDS by subsector and by energy form
mena_by_energy_form_residential <- toolAggregate(q4[,,as.character(unique(sets12$EF))],dim=3.2,rel=sets12,from="EF",to="EFA")

#by subsector and by energy form
residential_by_subsector_by_energy_form <- VConsFuel_by_energy_form_DOMSE
getItems(residential_by_subsector_by_energy_form, 3.1) <- paste0("Final Energy Residential and Commercial ", getItems(residential_by_subsector_by_energy_form, 3.1))

#by subsector and by energy form MENA_EDS
residential_mena_by_subsector_by_energy_form <- mena_by_energy_form_residential
getItems(residential_mena_by_subsector_by_energy_form, 3.1) <- paste0("Final Energy Residential and Commercial ", getItems(residential_mena_by_subsector_by_energy_form, 3.1))

# write data in mif file
write.report(residential_by_subsector_by_energy_form[,years,],file="reporting.mif",model="OPEN-PROM",unit="Mtoe",append=TRUE,scenario="BASE")
write.report(residential_mena_by_subsector_by_energy_form[regs,years,],file="reporting.mif",model="MENA-EDS",unit="Mtoe",append=TRUE,scenario="BASE")

#Residential and Commercial_by_energy_form
residential_by_energy_form <- dimSums(VConsFuel_by_energy_form_DOMSE, 3.1)
getItems(residential_by_energy_form,3.1) <- paste0("Final Energy Residential and Commercial ", getItems(residential_by_energy_form, 3.1))
mena_by_energy_form_residential <- dimSums(mena_by_energy_form_residential,3.1)
getItems(mena_by_energy_form_residential, 3.1) <- paste0("Final Energy Residential and Commercial ", getItems(mena_by_energy_form_residential, 3.1))

# write data in mif file
write.report(residential_by_energy_form[,years,],file="reporting.mif",model="OPEN-PROM",unit="Mtoe",append=TRUE,scenario="BASE")
write.report(mena_by_energy_form_residential[regs,years,],file="reporting.mif",model="MENA-EDS",unit="Mtoe",append=TRUE,scenario="BASE")


#filter IFuelCons by DOMSE
b5 <- calcOutput(type = "IFuelCons", subtype = "DOMSE", aggregate = FALSE)
year <- Reduce(intersect, list(getYears(q4,as.integer=TRUE),getYears(q3,as.integer=TRUE),getYears(b5,as.integer=TRUE)))
b5 <- b5[,year,]
b5 <- b5[,,sets11$`DOMSE(DSBS)`]

map_subsectors_ener8 <- sets4 %>% filter(SBS %in% as.character((sets11$`DOMSE(DSBS)`)))
map_subsectors_ener8$EF = paste(map_subsectors_ener8$SBS, "Mtoe",map_subsectors_ener8$EF, sep=".")
#filter to have only the variables which are in enerdata
map_subsectors_ener8 <- map_subsectors_ener8 %>% filter(EF %in% getItems(b5,3))

# aggregate from enerdata fuels to subsectors
b5_by_subsector <- toolAggregate(b5[,,as.character(unique(map_subsectors_ener8$EF))],dim=3,rel=map_subsectors_ener8,from="EF",to="SBS")

getItems(b5_by_subsector, 3) <- paste0("Final Energy Residential and Commercial ", getItems(b5_by_subsector, 3))

# write data in mif file
write.report(b5_by_subsector[,year,],file="reporting.mif",model="ENERDATA",unit="Mtoe",append=TRUE,scenario="BASE")

#Final Energy industry enerdata
residential_ener <- dimSums(b5_by_subsector, dim = 3)
getItems(residential_ener, 3) <- "Final Energy Residential and Commercial"

# write data in mif file
write.report(residential_ener[,year,],file="reporting.mif",model="ENERDATA",unit="Mtoe",append=TRUE,scenario="BASE")

map_subsectors_ener5 <- sets12
#filter to have only the variables which are in enerdata
map_subsectors_ener5 <- map_subsectors_ener5 %>% filter(EF %in% getItems(b5,3.3))

#Aggregate model enerdata by subsector and by energy form
b5_by_energy_form <- toolAggregate(b5[,year,as.character(unique(map_subsectors_ener5$EF))],dim=3.3,rel=map_subsectors_ener5,from="EF",to="EFA")

#enerdata by subsector and by energy form
residential_enerdata_by_subsector_by_energy_form <- b5_by_energy_form
residential_enerdata_by_subsector_by_energy_form <- dimSums(residential_enerdata_by_subsector_by_energy_form, 3.2)
getItems(residential_enerdata_by_subsector_by_energy_form, 3.1) <- paste0("Final Energy Residential and Commercial ", getItems(residential_enerdata_by_subsector_by_energy_form, 3.1))

# write data in mif file
write.report(residential_enerdata_by_subsector_by_energy_form[,year,],file="reporting.mif",model="ENERDATA",unit="Mtoe",append=TRUE,scenario="BASE")

#Aggregate model enerdata by energy form
residential_enerdata__by_energy_form <- dimSums(b5_by_energy_form, 3.1)
getItems(residential_enerdata__by_energy_form,3) <- paste0("Final Energy Residential and Commercial ", getItems(residential_enerdata__by_energy_form, 3.2))

# write data in mif file
write.report(residential_enerdata__by_energy_form[,year,],file="reporting.mif",model="ENERDATA",unit="Mtoe",append=TRUE,scenario="BASE")
