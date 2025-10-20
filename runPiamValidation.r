library(piamValidation)
library(rmarkdown)
library(pandoc)
pandoc_activate()

reporting_file <- "C:\\Users\\at39\\2-Models\\OPEN-PROM\\runs\\1.5CnewCCSAndHydrogenCleanupNewCPrice_2025-10-14_16-32-21\\reporting.mif" 
validation_file <- "C:\\Users\\at39\\2-Models\\fullVALIDATION2_4.mif"

#df<-validateScenarios(dataPath = c(reporting_file,validation_file), config = "validationConfig_OPEN-PROM.csv",outputFile = "test_output.csv")

validationReport(dataPath = c(reporting_file,validation_file), config = "validationConfig_OPEN-PROM.csv",outputDir = "piamOutput")