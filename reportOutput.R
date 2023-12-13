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
write.report(VFeCons[regs,years,],file="reporting.mif",model="OPEN-PROM",unit="Mtoe",scenario="BASE")
write.report(a[regs,,],file="reporting.mif",model="MENA-EDS",unit="Mtoe",append=TRUE,scenario="BASE")


#filter ENERDATA by onsumption
b <- readSource("ENERDATA", subtype =  "onsumption", convert = TRUE)
# map of enerdata and balance fuel
map_enerdata <- toolGetMapping(name = "enerdata-by-fuel.csv",
                               type = "sectoral",
                               where = "mappingfolder")
#keep the variables from the map
b <- b[regs, , map_enerdata[, 1]]
b <- as.quitte(b)
names(map_enerdata) <- sub("ENERDATA", "variable", names(map_enerdata))
#remove units
map_enerdata[,1] <- sub("\\..*", "", map_enerdata[,1])
#add a column with the fuels that match each variable of enerdata
v <- left_join(b, map_enerdata, by = "variable")
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
write.report(elec_prices[regs,years,],file="reporting.mif",model="OPEN-PROM",unit="Euro2005/KWh",append=TRUE,scenario="BASE")
write.report(z[regs,,],file="reporting.mif",model="MENA-EDS",unit="Euro2005/KWh",append=TRUE,scenario="BASE")

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
x <- x[regs, ,]
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
getItems(VDemTr_subsectors, 3) <- paste0("Final Energy demand in transport subsectors ", getItems(VDemTr_subsectors, 3))

#add model MENA_EDS data (choosing the correct variable from MENA by use of the MENA-PROM mapping)
a <- readSource("MENA_EDS", subtype =  map[map[["OPEN.PROM"]] == "VDemTr", "MENA.EDS"])
getRegions(a) <- sub("MOR", "MAR", getRegions(a)) # fix wrong region names in MENA
# choose years and regions that both models have
years <- intersect(getYears(a,as.integer=TRUE),getYears(VDemTr_subsectors,as.integer=TRUE))
regs <- intersect(getRegions(a),getRegions(VDemTr_subsectors))
mena_subsectors <- toolAggregate(a[,,unique(map_subsectors$EF)],dim=3,rel=map_subsectors,from="EF",to="SBS")
getItems(mena_subsectors, 3) <- paste0("Final Energy demand in transport subsectors ", getItems(mena_subsectors, 3))

# write data in mif file
write.report(VDemTr_subsectors[regs,years,],file="reporting.mif",model="OPEN-PROM",unit="Mtoe",append=TRUE,scenario="BASE")
write.report(mena_subsectors[regs,,],file="reporting.mif",model="MENA-EDS",unit="Mtoe",append=TRUE,scenario="BASE")

#Final Energy transportation 
transportation <- dimSums(VDemTr_subsectors, dim = 3)
getItems(transportation, 3) <- "Final Energy transportation"
transportation_mena <- dimSums(mena_subsectors, dim = 3)
getItems(transportation_mena, 3) <- "Final Energy transportation"

# write data in mif file
write.report(transportation[regs,years,],file="reporting.mif",model="OPEN-PROM",unit="Mtoe",append=TRUE,scenario="BASE")
write.report(transportation_mena[regs,,],file="reporting.mif",model="MENA-EDS",unit="Mtoe",append=TRUE,scenario="BASE")

#Energy Forms Aggregations
sets5 <- readSets("sets.gms", "EFtoEFA")
sets5[5,] <- paste0(sets5[5,] , sets5[6,])
sets5 <- sets5[ - 6,]
sets5 <- as.data.frame(sets5)
sets5 <- separate_wider_delim(sets5,cols = 1, delim = ".", names = c("EF","EFA"))
sets5[["EF"]] <- sub("\\(","",sets5[["EF"]])
sets5[["EF"]] <- sub("\\)","",sets5[["EF"]])
sets5 <- separate_rows(sets5,EF)

sets5 <- sets5 %>% filter(EF %in% getItems(VDemTr,3.2))

#Aggregate model OPEN-PROM by energy form
VDemTr_by_energy_form <- toolAggregate(VDemTr[,,as.character(unique(sets5$EF))],dim=3.2,rel=sets5,from="EF",to="EFA")

#Aggregate model MENA_EDS by energy form
mena_by_energy_form <- toolAggregate(a[,,as.character(unique(sets5$EF))],dim=3.2,rel=sets5,from="EF",to="EFA")

transportation_by_energy_form <- dimSums(VDemTr_by_energy_form, 3.1)
getItems(transportation_by_energy_form,3.1) <- paste0("Final Energy demand in transport by energy form ", getItems(transportation_by_energy_form, 3.1))
transportation_mena_by_energy_form <- dimSums(mena_by_energy_form,3.1)
getItems(transportation_mena_by_energy_form, 3.1) <- paste0("Final Energy demand in transport by energy form ", getItems(transportation_mena_by_energy_form, 3.1))

# write data in mif file
write.report(transportation_by_energy_form[regs,years,],file="reporting.mif",model="OPEN-PROM",unit="Mtoe",append=TRUE,scenario="BASE")
write.report(transportation_mena_by_energy_form[regs,,],file="reporting.mif",model="MENA-EDS",unit="Mtoe",append=TRUE,scenario="BASE")

#missing fuels
v <- getItems(VDemTr,3.2)
v <- as.data.frame(v)
l <- v %>% filter(!v %in% as.character(unique(sets5$EF)))

VDemTr_missing <- VDemTr[,,as.character(unique(l$v))]
x <- as.quitte(VDemTr_missing)
z <- x %>% filter(value > 0)
u <- unique(z["EF"])

