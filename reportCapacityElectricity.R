reportCapacityElecrticity <- function(regs) {
  
  # add model OPEN-PROM data electricity production
  VCapElec2 <- readGDX('./blabla.gdx', "VCapElec2", field = 'l')[regs, , ]
  VCapElec2 <-as.quitte(VCapElec2) %>% as.magpie()
  
  # map of enerdata, OPEN-PROM, elec prod
  map_reporting <- toolGetMapping(name = "enerdata-elec-prod.csv",
                                  type = "sectoral",
                                  where = "mrprom")
  
  # aggregate from ENERDATA fuels to reporting fuel categories
  VCapElec2 <- toolAggregate(VCapElec2[,,map_reporting[["OPEN.PROM"]]], dim = 3,rel = map_reporting,from = "OPEN.PROM",to = "REPORTING")
  
  getItems(VCapElec2, 3) <- paste0("Capacity|Electricity|", getItems(VCapElec2, 3))
  
  # write data in mif file
  write.report(VCapElec2[,,],file="reporting.mif",model="OPEN-PROM",append=TRUE,unit="TWh",scenario=scenario_name)
  
  # electricity production
  VCapElec2_total <- dimSums(VCapElec2, dim = 3, na.rm = TRUE)
  
  getItems(VCapElec2_total, 3) <- "Capacity|Electricity"
  
  # write data in mif file
  write.report(VCapElec2_total[,,],file="reporting.mif",append=TRUE,model="OPEN-PROM",unit="TWh",scenario=scenario_name)
  
}
