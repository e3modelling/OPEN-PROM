library(dplyr)
library(gdx)
library(quitte)
library(iamc)
library(tidyr)

# Reading data from the GDX file
var_pop <- readGDX('./blabla.gdx', 'iPop')
var_pop <- as.quitte(var_pop)
var_pop$model <- "OPEN-PROM"
var_pop$variable <- "Population"
var_pop$unit <- "billion"
var_pop <- select(var_pop, -data)

var_gdp <- readGDX('./blabla.gdx', 'iGDP')
var_gdp <- as.quitte(var_gdp)
var_gdp$model <- "OPEN-PROM"
var_gdp$variable <- "GDP|PPP"
var_gdp$unit <- "billion US$2015/yr"
var_gdp <- select(var_gdp, -data)

var_demtr <- readGDX('./blabla.gdx', 'VDemTr', field = 'l')
var_demtr <- as.quitte(var_demtr)
var_demtr$model <- "OPEN-PROM"
var_demtr$unit <- "Mtoe"
var_demtr$variable <- paste(var_demtr$TRANSE, var_demtr$EF, sep = " ")
var_demtr <- select(var_demtr, -TRANSE, -EF)
var_demtr$variable <- paste(var_demtr$variable, "TRANSE", sep = " ")

var_NENSE <- readGDX('./blabla.gdx', 'iFuelConsNENSE', field = 'l')
var_NENSE <- as.quitte(var_NENSE)
var_NENSE$model <- "OPEN-PROM"
var_NENSE$unit <- "Mtoe"
var_NENSE$variable <- paste(var_NENSE$NENSE, var_NENSE$EF, sep = " ")
var_NENSE <- select(var_NENSE, -NENSE, -EF)
var_NENSE$variable <- paste(var_NENSE$variable, "NENSE", sep = " ")

var_DOMSE <- readGDX('./blabla.gdx', 'iFuelConsDOMSE', field = 'l')
var_DOMSE <- as.quitte(var_DOMSE)
var_DOMSE$model <- "OPEN-PROM"
var_DOMSE$unit <- "Mtoe"
var_DOMSE$variable <- paste(var_DOMSE$DOMSE, var_DOMSE$EF, sep = " ")
var_DOMSE <- select(var_DOMSE, -DOMSE, -EF)
var_DOMSE$variable <- paste(var_DOMSE$variable, "DOMSE", sep = " ")

var_INDSE <- readGDX('./blabla.gdx', 'iFuelConsINDSE', field = 'l')
var_INDSE <- as.quitte(var_INDSE)
var_INDSE$model <- "OPEN-PROM"
var_INDSE$unit <- "Mtoe"
var_INDSE$variable <- paste(var_INDSE$INDSE, var_INDSE$EF, sep = " ")
var_INDSE <- select(var_INDSE, -INDSE, -EF)
var_INDSE$variable <- paste(var_INDSE$variable, "INDSE", sep = " ")

iDataElecSteamGen <- readGDX('./blabla.gdx', 'iDataElecSteamGen', field = 'l')
iDataElecSteamGen <- as.quitte(iDataElecSteamGen)
iDataElecSteamGen$model <- "OPEN-PROM"
iDataElecSteamGen$unit <- "GW"
iDataElecSteamGen["variable"] <- iDataElecSteamGen["PGOTH"]
iDataElecSteamGen <- select(iDataElecSteamGen, -PGOTH)
iDataElecSteamGen$variable <- paste(iDataElecSteamGen$variable, "iDataElecSteamGen", sep = " ")

iDataPassCars <- readGDX('./blabla.gdx', 'iDataPassCars', field = 'l')
iDataPassCars <- as.quitte(iDataPassCars)
iDataPassCars$model <- "OPEN-PROM"
iDataPassCars$unit <- "reuse_pc"
iDataPassCars["variable"] <- paste(iDataPassCars$Gompset1, iDataPassCars$Gompset2)
iDataPassCars <- select((iDataPassCars), -c(Gompset1, Gompset2))
iDataPassCars$variable <- paste(iDataPassCars$variable, "iDataPassCars", sep = " ")

iFuelPrice <- readGDX('./blabla.gdx', 'iFuelPrice', field = 'l')
iFuelPrice <- as.quitte(iFuelPrice)
iFuelPrice$model <- "OPEN-PROM"
iFuelPrice$unit <- "$2015/toe"
iFuelPrice["variable"] <- paste(iFuelPrice$SBS, iFuelPrice$EF)
iFuelPrice <- select((iFuelPrice), -c(SBS, EF))
iFuelPrice$variable <- paste(iFuelPrice$variable, "iFuelPrice", sep = " ")

VNewReg <- readGDX('./blabla.gdx', 'VNewReg', field = 'l')
VNewReg <- as.quitte(VNewReg)
VNewReg["model"] <- "OPEN-PROM"
VNewReg["variable"] <- "passenger-car-first-registrations"
VNewReg <- select((VNewReg), -c(data))
VNewReg["unit"] <- "million vehicles"
VNewReg$variable <- paste(VNewReg$variable, "VNewReg", sep = " ")

iTransChar <- readGDX('./blabla.gdx', 'iTransChar', field = 'l')
iTransChar <- as.quitte(iTransChar)
iTransChar["model"] <- "OPEN-PROM"
iTransChar["variable"] <- iTransChar["TRANSPCHAR"]
iTransChar <- select((iTransChar), -c(TRANSPCHAR))
iTransChar["unit"] <- "Thousands km/veh"
iTransChar$variable <- paste(iTransChar$variable, "iTransChar", sep = " ")

iActv <- readGDX('./blabla.gdx', 'iActv', field = 'l')
iActv <- as.quitte(iActv)
iActv["model"] <- "OPEN-PROM"
iActv["variable"] <- iActv["SBS"]
iActv <- select((iActv), -c(SBS))
iActv["unit"] <- "various"
iActv$variable <- paste(iActv$variable, "iActv", sep = " ")

#all_variables <- readGDX('./blabla.gdx', types = "variables", field = 'l')

# Merging the datasets
iDataPassCars["period"] <- 2010
iDataPassCars <- as.quitte(iDataPassCars)
iDataPassCars <- interpolate_missing_periods(iDataPassCars, period = 2010:2100, expand.values = TRUE)

gdx_data <- bind_rows(var_pop, var_gdp, var_demtr, var_NENSE, var_DOMSE,
                      var_INDSE, iDataElecSteamGen, iFuelPrice,
                      VNewReg, iTransChar, iActv, iDataPassCars)

# Keeping rows from Egypt only
gdx_data <- filter(gdx_data, gdx_data$region == "EGY")

write.mif(gdx_data, "blabla.mif", append = FALSE)

# Creating a custom configuration dataframe for the iamCheck() function
custom_cfg <- filter(iamProjectConfig(), variable %in% c("GDP|PPP", "Population"))

vdemtr_cfg <- tibble(variable = unique(var_demtr$variable),
              unit = "Mtoe", min = 0, max = NA,
              definition = "fuel consumption")

custom_cfg <- bind_rows(custom_cfg, vdemtr_cfg)

# Create the data_report folder if it doesn't exist
if (!file.exists("./data_report"))
{
  dir.create("./data_report")
}

# Creating the reference dataframe
ref_data <- read.quitte( c("MENA_EDS.mif") )

# Generating the report PDF file 
report <- iamCheck(gdx_data, pdf = "./data_report/report.pdf",
          refData = ref_data,
          cfg = custom_cfg, verbose = TRUE)
