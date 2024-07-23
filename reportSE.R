reportSE <- function(regs) {
  
  # add model OPEN-PROM data electricity production
  VProdElec <- readGDX('./blabla.gdx', "VProdElec", field = 'l')[regs, , ]
  VProdElec <-as.quitte(VProdElec) %>% as.magpie()
  getItems(VProdElec, 3) <- paste0("Secondary Energy|Electricity|", getItems(VProdElec, 3))
  
  # write data in mif file
  write.report(VProdElec[,,],file="reporting.mif",model="OPEN-PROM",append=TRUE,unit="TWh",scenario=scenario_name)
  
  # electricity production
  VProdElec_total <- dimSums(VProdElec, dim = 3, na.rm = TRUE)
  
  getItems(VProdElec_total, 3) <- paste0("Secondary Energy|Electricity")
  
  # write data in mif file
  write.report(VProdElec_total[,,],file="reporting.mif",append=TRUE,model="OPEN-PROM",unit="TWh",scenario=scenario_name)
  
  }
