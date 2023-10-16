library(gdx)
library(quitte)
library(iamc)

var <- readGDX('./blabla.gdx', 'VDemTr', field = 'l')
var_q <- as.quitte(var)

# write.mif(var_q, 'VDemTr.mif')

iamCheck(var_q, pdf = "./report.pdf",
         refData = "./Data_validation_mrprom.mif",
         verbose = FALSE)