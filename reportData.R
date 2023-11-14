library(dplyr)
library(gdx)
library(quitte)
library(iamc)
library(tidyr)

all_variables <- readGDX('./openprom_p.gdx', types = "variables", field = 'l')
z <- c("ALG", "MOR", "TUN", "EGY", "LIB", "ISR", "LEB", "SYR", "JOR", "TUR", "GLO")

x <- NULL
for (j in 1:length(all_variables)) {
  l <- all_variables[j]
  name <- names(l)
  l <- as.quitte(l[[1]])
  l["model"] <- "OPEN-PROM"
  d <- names(l)
  l["variable"] <- name
  for (i in 8:length(l)) {
    if (l[1, i] != "NA"){
      l = unite(l, variable, c(variable, d[i]), sep = " ", remove = FALSE)
    }
  }
  l <- select((l), -c(d[8:length(l)]))
  l <- l[which(l$region %in% z), ]
  x <- rbind(x, l)
}

x[which(is.na(x["period"])), 6] <- "2020"
x["period"] <- as.numeric(unlist(x["period"]))
x <- interpolate_missing_periods(x, period = 2019:2020, expand.values = TRUE)
x <- as.quitte(x)

write.mif(x, "openprom_p.mif", append = FALSE)

a <- readSource("MENA_EDS")
q <- as.quitte(a)
y <- rbind(x, q)

write.mif(y, "both_models.mif", append = FALSE)







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

# Merging the datasets
gdx_data <- bind_rows(var_pop, var_gdp, var_demtr)

# Keeping rows from Egypt only
gdx_data <- filter(gdx_data, gdx_data$region == "EGY")

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
ref_data <- read.quitte( c("mrprom.mif", "MENA_EDS.mif") )

# Generating the report PDF file 
report <- iamCheck(gdx_data, pdf = "./data_report/report.pdf",
                   refData = ref_data,
                   cfg = custom_cfg, verbose = TRUE)