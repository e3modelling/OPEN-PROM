reportPrice <- function(regs) {
  
  #add model OPEN-PROM data Electricity prices
  VPriceElecIndResConsu <- readGDX('./blabla.gdx', "VPriceElecIndResConsu", field = 'l')[regs, , ]
  #choose Industrial consumer /i/
  sets_i <- toolreadSets("sets.gms", "iSet")
  elec_prices_Industry <- VPriceElecIndResConsu[,,sets_i[1,1]]
  # complete names
  getNames(elec_prices_Industry) <- "Electricity prices Industrial"
  #choose Residential consumer /r/
  sets_r <- toolreadSets("sets.gms", "rSet")
  elec_prices_Residential <- VPriceElecIndResConsu[,,sets_r[1,1]]
  # complete names
  getNames(elec_prices_Residential) <- "Electricity prices Residential"
  #Combine Industrial and Residential OPEN-PROM
  elec_prices <- mbind(elec_prices_Industry, elec_prices_Residential)
  
  #add model MENA_EDS data (choosing the correct variable from MENA by use of the MENA-PROM mapping)
  elec_prices_MENA <- readSource("MENA_EDS", subtype =  map[map[["OPEN.PROM"]] == "VPriceElecIndResConsu", "MENA.EDS"])
  # fix wrong region names in MENA
  getRegions(elec_prices_MENA) <- sub("MOR", "MAR", getRegions(elec_prices_MENA))
  # choose years and regions that both models have
  years <- intersect(getYears(elec_prices_MENA,as.integer=TRUE),getYears(VPriceElecIndResConsu,as.integer=TRUE))
  menaregs <- intersect(getRegions(elec_prices_MENA),getRegions(VPriceElecIndResConsu))
  #choose Industrial consumer /i/
  MENA_Industrial <- elec_prices_MENA[,years,sets_i[1,1]]
  # complete names
  getNames(MENA_Industrial) <- "Electricity prices Industrial"
  #choose Residential consumer /r/
  MENA_Residential <- elec_prices_MENA[,years,sets_r[1,1]]
  # complete names
  getNames(MENA_Residential) <- "Electricity prices Residential"
  #combine Industrial and Residential MENA
  elec_prices_MENA <- mbind(MENA_Industrial, MENA_Residential)
  
  # write data in mif file
  write.report(elec_prices[,,],file="reporting.mif",model="OPEN-PROM",unit="Euro2005/KWh",append=TRUE,scenario=scenario_name)
  write.report(elec_prices_MENA[menaregs,years,],file="reporting.mif",model="MENA-EDS",unit="Euro2005/KWh",append=TRUE,scenario=scenario_name)
  
  #filter ENERDATA by electricity
  ENERDATA_electricity <- readSource("ENERDATA", subtype =  "lectricity", convert = TRUE)
  #choose Industrial consumer /i/
  ENERDATA_Industrial <- ENERDATA_electricity[,,"Constant price per toe in US$ of electricity in industry (taxes incl).$15/toe"]
  #choose Residential consumer /r/
  ENERDATA_Residential<- ENERDATA_electricity[,,"Constant price per toe in US$ of electricity for households (taxes incl).$15/toe"]
  #fix units from toe to kwh
  ENERDATA_Industrial <- ENERDATA_Industrial / 11630
  ENERDATA_Residential <- ENERDATA_Residential / 11630
  #fix units from $15 to $05
  ENERDATA_Industrial <- ENERDATA_Industrial * 1.2136
  ENERDATA_Residential <- ENERDATA_Residential * 1.2136
  #fix units from $2005 to Euro2005
  ENERDATA_Industrial <- ENERDATA_Industrial / 1.24
  ENERDATA_Residential <- ENERDATA_Residential / 1.24
  
  # complete names
  getItems(ENERDATA_Industrial, 3) <- "Electricity prices Industrial"
  getItems(ENERDATA_Residential, 3) <- "Electricity prices Residential"
  #combine Industrial and Residential MENA
  elec_prices_ENERDATA <- mbind(ENERDATA_Industrial, ENERDATA_Residential)
  # choose years and regions that both models have
  year <- Reduce(intersect, list(getYears(elec_prices_MENA,as.integer=TRUE),getYears(elec_prices_ENERDATA,as.integer=TRUE),getYears(VPriceElecIndResConsu,as.integer=TRUE)))
  #filter ENERDATA by years that both models have
  elec_prices_ENERDATA <- elec_prices_ENERDATA[, year,]
  # write data in mif file
  write.report(elec_prices_ENERDATA[intersect(getRegions(elec_prices_ENERDATA),regs),,],file="reporting.mif",model="ENERDATA",unit="Euro2005/KWh",append=TRUE,scenario=scenario_name)
  
  #add model OPEN-PROM data iFuelPrice
  FuelPrice_OPEN_PROM <- readGDX('./blabla.gdx', "iFuelPrice")[regs, , ]
  PRICE_by_sector_and_EF <- FuelPrice_OPEN_PROM
  # complete names
  getItems(PRICE_by_sector_and_EF, 3.1) <- paste0("Fuel Price ", getItems(PRICE_by_sector_and_EF, 3.1))
  
  #add model MENA_EDS data (choosing the correct variable from MENA by use of the MENA-PROM mapping)
  #fix units from $2015/toe to k$2015/toe
  FuelPrice_MENA <- readSource("MENA_EDS", subtype =  map[map[["OPEN.PROM"]] == "iFuelPrice", "MENA.EDS"]) / 1000
  PRICE_by_sector_and_EF_MENA <- FuelPrice_MENA
  # fix wrong region names in MENA
  getRegions(PRICE_by_sector_and_EF_MENA) <- sub("MOR", "MAR", getRegions(PRICE_by_sector_and_EF_MENA)) # fix wrong region names in MENA
  # choose years and regions that both models have
  years <- intersect(getYears(PRICE_by_sector_and_EF_MENA,as.integer=TRUE),getYears(PRICE_by_sector_and_EF,as.integer=TRUE))
  menaregs <- intersect(getRegions(PRICE_by_sector_and_EF_MENA),getRegions(PRICE_by_sector_and_EF))
  # complete names
  getItems(PRICE_by_sector_and_EF_MENA, 3.1) <- paste0("Fuel Price ", getItems(PRICE_by_sector_and_EF_MENA, 3.1))
  
  #FuelPrice enerdata
  #fix units from $2015/toe to k$2015/toe
  FuelPrice_ENERDATA <- calcOutput(type = "IFuelPrice", aggregate = TRUE) / 1000
  PRICE_by_sector_and_EF_ENERDATA <- FuelPrice_ENERDATA
  # complete names
  getItems(PRICE_by_sector_and_EF_ENERDATA, 3.1) <- paste0("Fuel Price ", getItems(PRICE_by_sector_and_EF_ENERDATA, 3.1))
  # choose years that both models have
  year <- Reduce(intersect, list(getYears(PRICE_by_sector_and_EF_MENA,as.integer=TRUE),getYears(PRICE_by_sector_and_EF,as.integer=TRUE),getYears(PRICE_by_sector_and_EF_ENERDATA,as.integer=TRUE)))
  
  # write data in mif file
  write.report(PRICE_by_sector_and_EF[,,],file="reporting.mif",model="OPEN-PROM",unit="various",append=TRUE,scenario=scenario_name)
  write.report(PRICE_by_sector_and_EF_MENA[menaregs,years,],file="reporting.mif",model="MENA-EDS",unit="various",append=TRUE,scenario=scenario_name)
  write.report(PRICE_by_sector_and_EF_ENERDATA[intersect(regs,getRegions(PRICE_by_sector_and_EF_ENERDATA)),year,],file="reporting.mif",model="ENERDATA",unit="various",append=TRUE,scenario=scenario_name)
  
  #aggregation by SECTOR and EF
  PRICE_by_EF_OPEN_PROM <- dimSums(FuelPrice_OPEN_PROM, 3.1, na.rm = TRUE)
  PRICE_by_sector_OPEN_PROM <- dimSums(FuelPrice_OPEN_PROM, 3.2, na.rm = TRUE)
  PRICE_by_EF_MENA <- dimSums(FuelPrice_MENA, 3.1, na.rm = TRUE)
  PRICE_by_sector_MENA <- dimSums(FuelPrice_MENA, 3.2, na.rm = TRUE)
  PRICE_by_EF_ENERDATA <- dimSums(FuelPrice_ENERDATA, 3.1, na.rm = TRUE)
  PRICE_by_sector_ENERDATA <- dimSums(FuelPrice_ENERDATA, 3.2, na.rm = TRUE)
  PRICE_total_OPEN_PROM <- dimSums(FuelPrice_OPEN_PROM, na.rm = TRUE)
  PRICE_total_MENA <- dimSums(FuelPrice_MENA, na.rm = TRUE)
  PRICE_total_ENERDATA <- dimSums(FuelPrice_ENERDATA,3, na.rm = TRUE)
  
  # fix wrong region names in MENA
  getRegions(PRICE_by_EF_MENA) <- sub("MOR", "MAR", getRegions(PRICE_by_EF_MENA))
  getRegions(PRICE_by_sector_MENA) <- sub("MOR", "MAR", getRegions(PRICE_by_sector_MENA))
  getRegions(PRICE_total_MENA) <- sub("MOR", "MAR", getRegions(PRICE_total_MENA))
  
  # complete names
  getItems(PRICE_by_EF_OPEN_PROM, 3) <- paste0("Fuel Price ", getItems(PRICE_by_EF_OPEN_PROM, 3))
  getItems(PRICE_by_sector_OPEN_PROM, 3) <- paste0("Fuel Price ", getItems(PRICE_by_sector_OPEN_PROM, 3))
  getItems(PRICE_by_EF_MENA, 3) <- paste0("Fuel Price ", getItems(PRICE_by_EF_MENA, 3))
  getItems(PRICE_by_sector_MENA, 3) <- paste0("Fuel Price ", getItems(PRICE_by_sector_MENA, 3))
  getItems(PRICE_by_EF_ENERDATA, 3) <- paste0("Fuel Price ", getItems(PRICE_by_EF_ENERDATA, 3))
  getItems(PRICE_by_sector_ENERDATA, 3) <- paste0("Fuel Price ", getItems(PRICE_by_sector_ENERDATA, 3))
  getItems(PRICE_total_OPEN_PROM, 3) <- paste0("Fuel Price", getItems(PRICE_total_OPEN_PROM, 3))
  getItems(PRICE_total_MENA, 3) <- paste0("Fuel Price", getItems(PRICE_total_MENA, 3))
  getItems(PRICE_total_ENERDATA, 3) <- paste0("Fuel Price", getItems(PRICE_total_ENERDATA, 3))
  
  # write data in mif file
  write.report(PRICE_by_EF_OPEN_PROM[,,],file="reporting.mif",model="OPEN-PROM",unit="various",append=TRUE,scenario=scenario_name)
  write.report(PRICE_by_EF_MENA[menaregs,years,],file="reporting.mif",model="MENA-EDS",unit="various",append=TRUE,scenario=scenario_name)
  write.report(PRICE_by_EF_ENERDATA[intersect(regs,getRegions(PRICE_by_EF_ENERDATA)),year,],file="reporting.mif",model="ENERDATA",unit="various",append=TRUE,scenario=scenario_name)
  
  write.report(PRICE_by_sector_OPEN_PROM[,,],file="reporting.mif",model="OPEN-PROM",unit="various",append=TRUE,scenario=scenario_name)
  write.report(PRICE_by_sector_MENA[menaregs,years,],file="reporting.mif",model="MENA-EDS",unit="various",append=TRUE,scenario=scenario_name)
  write.report(PRICE_by_sector_ENERDATA[intersect(regs,getRegions(PRICE_by_sector_ENERDATA)),year,],file="reporting.mif",model="ENERDATA",unit="various",append=TRUE,scenario=scenario_name)
  
  write.report(PRICE_total_OPEN_PROM[,,],file="reporting.mif",model="OPEN-PROM",unit="various",append=TRUE,scenario=scenario_name)
  write.report(PRICE_total_MENA[menaregs,years,],file="reporting.mif",model="MENA-EDS",unit="various",append=TRUE,scenario=scenario_name)
  write.report(PRICE_total_ENERDATA[intersect(regs,getRegions(PRICE_total_ENERDATA)),year,],file="reporting.mif",model="ENERDATA",unit="various",append=TRUE,scenario=scenario_name)
}