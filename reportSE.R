reportSE <- function(regs) {
  
  # add model OPEN-PROM data electricity production
  VProdElec <- readGDX('./blabla.gdx', "VProdElec", field = 'l')[regs, , ]
  VProdElec <-as.quitte(VProdElec) %>% as.magpie()
  
  # map of enerdata, OPEN-PROM, elec prod
  map_reporting <- toolGetMapping(name = "enerdata-elec-prod.csv",
                                  type = "sectoral",
                                  where = "mrprom")
  
  # aggregate from ENERDATA fuels to reporting fuel categories
  VProdElec <- toolAggregate(VProdElec[,,map_reporting[["OPEN.PROM"]]], dim = 3.1,rel = map_reporting,from = "OPEN.PROM",to = "REPORTING")
  
  getItems(VProdElec, 3) <- paste0("Secondary Energy|Electricity|", getItems(VProdElec, 3))
  
  VProdElec_GLO <- dimSums(VProdElec, 1)
  getItems(VProdElec_GLO, 1) <- "World"
  VProdElec <- mbind(VProdElec, VProdElec_GLO)
  
  # write data in mif file
  write.report(VProdElec[,,],file="reporting.mif",model="OPEN-PROM",append=TRUE,unit="TWh",scenario=scenario_name)
  
  # electricity production
  VProdElec_total <- dimSums(VProdElec, dim = 3, na.rm = TRUE)
  
  getItems(VProdElec_total, 3) <- paste0("Secondary Energy|Electricity")
  
  # write data in mif file
  write.report(VProdElec_total[,,],file="reporting.mif",append=TRUE,model="OPEN-PROM",unit="TWh",scenario=scenario_name)
  
  }
