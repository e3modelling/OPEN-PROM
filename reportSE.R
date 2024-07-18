reportSE <- function(regs) {
  
  # add model OPEN-PROM data electricity production
  VProdElec <- readGDX('./blabla.gdx', "VProdElec", field = 'l')[regs, , ] * 1000 #convert to GWh
  # map of enerdata, OPEN-PROM, elec prod
  map_reporting <- toolGetMapping(name = "enerdata-elec-prod.csv",
                                  type = "sectoral",
                                  where = "mrprom")
  
  # aggregate from ENERDATA fuels to reporting fuel categories
  VProdElec <- toolAggregate(VProdElec[ , , map_reporting$OPEN.PROM],dim = 3.1,rel = map_reporting,from = "OPEN.PROM",to = "REPORTING")
  
  getItems(VProdElec, 3.1) <- paste0("SE|Elec|", getItems(VProdElec, 3.1))
  getItems(VProdElec, 3) <- getItems(VProdElec, 3.1)
  
  # write data in mif file
  write.report(VProdElec[,,],file="reporting.mif",model="OPEN-PROM",append=TRUE,unit="GWh",scenario=scenario_name)
  
  # Installed capacity Total
  VProdElec_total <- dimSums(VProdElec, dim = 3, na.rm = TRUE)
  
  getItems(VProdElec_total, 3) <- paste0("SE|Elec")
  
  # write data in mif file
  write.report(VProdElec_total[,,],file="reporting.mif",append=TRUE,model="OPEN-PROM",unit="GWh",scenario=scenario_name)

  }
