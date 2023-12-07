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
write.report(VFeCons[regs,years,],file="final.mif",model="OPEN-PROM",unit="Mtoe",scenario="BASE")
write.report(a[regs,,],file="final.mif",model="MENA-EDS",unit="Mtoe",append=TRUE,scenario="BASE")


#filter ENERDATA by onsumption
b <- readSource("ENERDATA", subtype =  "onsumption", convert = TRUE)
# map of enerdata and balance fuel
map <- toolGetMapping(name = "enerdata-by-fuel.csv",
                      type = "sectoral",
                      where = "mappingfolder")
#keep the variables from the map
b <- b[regs, , map[, 1]]
b <- as.quitte(b)
names(map) <- sub("ENERDATA", "variable", names(map))
#remove units
map[,1] <- sub("\\..*", "", map[,1])
#add a column with the fuels that match each variable of enerdata
v <- left_join(b, map, by = "variable")
v["variable"] <- paste0("Final Energy ", v$fuel)
v <- filter(v, period %in% years)
v <- select(v , -c("fuel"))
v <- as.quitte(v)
v <- as.magpie(v)
# write data in mif file
write.report(v,file="final.mif",model="ENERDATA",unit="Mtoe",append=TRUE,scenario="BASE")