library(gdx)
library(quitte)

var <- readGDX('blabla.gdx', 'VDemTr', field = 'l')
var_q <- as.quitte(var)

write.mif(var_q, 'VDemTr.mif')

