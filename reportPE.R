reportPE <- function(regs) {
  
  # add model OPEN-PROM data Primary production
  VProdPrimary <- readGDX('./blabla.gdx', "VProdPrimary", field = 'l')[regs, , ]
  VProdPrimary <-as.quitte(VProdPrimary) %>% as.magpie()
  
  # map of Navigate, OPEN-PROM, Primary prod
  map_reporting <- toolGetMapping(name = "prom-reporting-primaryproduction-mapping.csv",
                                  type = "sectoral",
                                  where = "mrprom")
  
  # aggregate from OPEN-PROM fuels to reporting fuel categories
  VProdPrimary <- toolAggregate(VProdPrimary[,,map_reporting[2:10,2]], dim = 3.1,rel = map_reporting[2:10,],from = "OPEN.PROM",to = "Reporting")
  
  # write data in mif file
  write.report(VProdPrimary[,,],file="reporting.mif",model="OPEN-PROM",append=TRUE,unit="Mtoe",scenario=scenario_name)
  
  # Primary production
  VProdPrimary_total <- dimSums(VProdPrimary, dim = 3, na.rm = TRUE)
  
  getItems(VProdPrimary_total, 3) <- paste0("Primary Energy")
  
  # write data in mif file
  write.report(VProdPrimary_total[,,],file="reporting.mif",append=TRUE,model="OPEN-PROM",unit="Mtoe",scenario=scenario_name)
  
}
