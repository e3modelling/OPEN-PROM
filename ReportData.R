library(dplyr)
library(gdx)
library(quitte)
library(iamc)

var_pop <- readGDX('./blabla.gdx', 'iPop')
var_pop <- as.quitte(var_pop)
var_pop$model <- "OPEN-PROM"
var_pop$variable <- "Population"
var_pop$unit <- "billion"
var_pop <- select(var_pop, -data)

var_gdp <- readGDX('./blabla.gdx', 'iGDP')
var_gdp <- as.quitte(var_gdp)
var_gdp$model <- "OPEN-PROM"
var_gdp$variable <- "GDP"
var_gdp$unit <- "billion US$2015"
var_gdp <- select(var_gdp, -data)


#write.mif(var_pop, 'pop.mif')

# iamCheck(var_q, pdf = "./report.pdf",
#         refData = "./Data_validation_mrprom.mif",
#         verbose = FALSE)