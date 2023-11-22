library(dplyr)
library(gdx)
library(quitte)
library(iamc)
library(tidyr)
library(utils)
library(mrprom)

openprom_p_variables <- gdxInfo("openprom_p.gdx",returnList=T,dump=F)
blabla_variables <- list() 
for (i in openprom_p_variables[["variables"]]) {
  if (i %in% c("VTechCostIntrm", "VConsEachTechTransp", "vDummyObj")) next
  blabla_variables[[i]] <- read.gdx('./blabla.gdx', i, field = 'l')
}
mena_prom_mapping <- read.csv("MENA-PROM mapping - mena_prom_mapping.csv")

z <- c("TUN", "EGY", "ISR", "MAR")
zm <- sub("MAR", "MOR", z)
years <- c(2017:2021)

x <- NULL
variable <- NULL
for (j in names(blabla_variables)) {
  l <- blabla_variables[[j]]
  if (nrow(l) == 0) next
  l <- as.quitte(l)
  l["model"] <- "OPEN-PROM"
  l["variable"] <- factor(j)
  l["period"] <- l["ytime"]
  l["region"] <- l["allcy"]
  cols1 <- names(l)[!names(l) %in% c("ytime", "allcy")]
  cols2 <- names(l)[!names(l) %in% c("model", "scenario", "region", "unit", "period", "value", "ytime", "allcy")]
  l <- select(l, all_of(cols1)) %>% unite(col = "variable", sep = " ", all_of(cols2))
  l <- l[which(l$region %in% z), ]
  l <- l[which(l$period %in% years), ]
  
  index <- match(j, mena_prom_mapping$OPEN.PROM)
  MENA_EDS_variables <- mena_prom_mapping[index, 2]
  a <- readSource("MENA_EDS", subtype = MENA_EDS_variables)
  
  if (!is.null(getRegions(a))) {
    a <- as.quitte(a[zm, years, ])
    a["model"] <- "MENA_EDS"
    a["variable"] <- MENA_EDS_variables
    if("data" %in% colnames(a)) {
      a <- subset(a, select=-c(data))
    }
    cols1 <- names(a)[!names(a) %in% c("ytime", "allcy")]
    cols2 <- names(a)[!names(a) %in% c("model", "scenario", "region", "unit", "period", "value", "ytime", "allcy")]
    a <- select(a, all_of(cols1)) %>% unite(col = "variable", sep = " ", all_of(cols2))
    a$region <- sub("MOR", "MAR", a$region)
    a$variable <- sub(MENA_EDS_variables, j, a$variable)
    x <- rbind(x, l, a)
  }
}

write.report(as.magpie(x), "bothmodels.mif") 



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