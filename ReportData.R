library(dplyr)
library(gdx)
library(quitte)
library(iamc)

# Reading data from the GDX file
var_pop <- readGDX('./blabla.gdx', 'iPop')
var_pop <- as.quitte(var_pop)
var_pop$model <- "OPEN-PROM"
var_pop$variable <- "Population"
var_pop$unit <- "million"
var_pop <- select(var_pop, -data)

var_gdp <- readGDX('./blabla.gdx', 'iGDP')
var_gdp <- as.quitte(var_gdp)
var_gdp$model <- "OPEN-PROM"
var_gdp$variable <- "GDP|PPP"
var_gdp$unit <- "billion US$2005/yr"
var_gdp <- select(var_gdp, -data)

# Merging the datasets
gdx_data <- bind_rows(var_pop, var_gdp)

# Create the data_report folder if it doesn't exist
if (!file.exists("./data_report"))
{
  dir.create("./data_report")
} 

report <- iamCheck(gdx_data, pdf = "./data_report/report.pdf",
          refData = "./GDP_POP.mif",
          verbose = TRUE)
