*' @title Power Generation Declarations
*' @code

Equations
*' *** Power Generation
Q04CapElecNominal(allCy,PGALL,YTIME)	                   "Compute nominal electricity generation capacity"
Q04ShareTechPG(allCy,PGALL,YTIME)                          "Share of all technologies in the electricity mixture"
Q04CostHourProdInvDec(allCy,PGALL,YTIME)                    "Compute production cost used in investment decisions"
Q04CostVarTech(allCy,PGALL,YTIME)	                       "Compute variable cost of technology" 	
Q04IndxEndogScrap(allCy,PGALL,YTIME)	                   "Compute endogenous scrapping index" 	
Q04CapElecNonCHP(allCy,YTIME)	                           "Compute total electricity generation capacity excluding CHP plants"
Q04GapGenCapPowerDiff(allCy,YTIME)	                       "Compute the gap in power generation capacity"		
*q04PotRenMinAllow(allCy,PGRENEF,YTIME)	                   "Compute minimum allowed renewable potential" 
Q04ShareSatPG(allCy,PGALL,YTIME)	                       "Saturation mechanism for electricity mixture penetration of RES technologies"		 	
Q04SharePowPlaNewEq(allCy,PGALL,YTIME)	                   "Compute the power plant share in new equipment"	
Q04NewCapElec(allCy,PGALL,YTIME)	                       "Compute the new capacity added every year"
Q04NetNewCapElec(allCy,PGALL,YTIME)	                       "Compute the yearly difference in installed capacity"		
Q04CFAvgRen(allCy,PGALL,YTIME)	                           "Compute the average capacity factor of RES"	
Q04CapOverall(allCy,PGALL,YTIME)	                       "Compute overall capacity"
*q04SecContrTotCHPProd(allCy,SBS,CHP,YTIME)                "Compute sector contribution to total CHP production"		
*q04CostPowGenLonMin(allCy,PGALL,YTIME)	                   "Long-term minimum power generation cost"	
*q04CostPowGenLongIntPri(allCy,PGALL,ESET,YTIME)           "Compute long term power generation cost of technologies including international Prices of main fuels"
*q04CostPowGenShortIntPri(allCy,PGALL,ESET,YTIME)          "Compute short term power generation cost of technologies including international Prices of main fuels"
*q04CostPowGenAvgShrt(allCy,ESET,YTIME)	                   "Compute short term power generation cost"
Q04LoadFacDom(allCy,YTIME)                                 "Compute electricity load factor for entire domestic system"	
$ifthen.calib %Calibration% == off
Q04DemElecTot(allCy,YTIME)                                 "Compute total electricity demand (TWh)"
$endif.calib
Q04CapElecCHP(allCy,CHP,YTIME)                             "Compute CHP electric capacity"	
Q04ProdElecEstCHP(allCy,CHP,YTIME)	                       "Estimate the electricity of CHP Plants"	
Q04CapexFixCostPG(allCy,PGALL,YTIME)                       "Computes the capex and fixed costs of any power generation technology"
Q04ShareMixWndSol(allCy,YTIME)                             "Computes the participation of solar and wind in the energy mixture (%)"
Q04CapexRESRate(allCy,PGALL,YTIME)                         "Estimates a multiplying factor expressing the extra grid and storage costs for RES implementation according to the RES penetration in the mixture"
Q04CO2CaptRate(allCy,PGALL,YTIME)
Q04CostCapTech(allCy,PGALL,YTIME)
Q04CCSRetroFit(allCy,PGALL,YTIME)
Q04ScrpRate(allCy,PGALL,YTIME)
*'                **Interdependent Equations**
Q04ProdElec(allCy,PGALL,YTIME)                             "Compute electricity production from power generation plants"
Q04CostPowGenAvgLng(allCy,YTIME)	                   "Compute long term power generation cost"
Q04CapElecTotEst(allCy,YTIME)                              "Compute Estimated total electricity generation capacity"
Q04PeakLoad(allCy,YTIME)	                               "Compute elerctricity peak load"	
Q04CapElec(allCy,PGALL,YTIME)	                           "Compute electricity generation capacity"
;

Variables
*' *** Power Generation Variables
V04CapElecNominal(allCy,PGALL,YTIME)	                   "Nominal electricity generation plants capacity (GW)"
V04ShareTechPG(allCy,PGALL,YTIME)                          "Share of all technologies in the electricity mixture"
V04CapElecCHP(allCy,CHP,YTIME)	                           "Capacity of CHP Plants (GW)"
V04CostHourProdInvDec(allCy,PGALL,YTIME)                    "Production cost of technology (US$2015/KWh)"
V04CostVarTech(allCy,PGALL,YTIME)	                       "Variable cost of technology (US$2015/KWh)"	
V04IndxEndogScrap(allCy,PGALL,YTIME)	                   "Index used for endogenous power plants scrapping (1)"			
V04CapElecNonCHP(allCy,YTIME)	                           "Total electricity generation capacity excluding CHP (GW)"	
V04GapGenCapPowerDiff(allCy,YTIME)	                       "Gap in total generation capacity to be filled by new equipment (GW)"		
*v04PotRenMinAllow(allCy,PGRENEF,YTIME)	                   "Minimum allowed renewable potential (GW)"		
V04ShareSatPG(allCy,PGALL,YTIME)	                           "Saturation for electricity mixture penetration of RES technologies"	
V04SharePowPlaNewEq(allCy,PGALL,YTIME)	                   "Power plant share in new equipment (1)"			
V04SortPlantDispatch(allCy,PGALL,YTIME)	                   "Power plants sorting according to variable cost to decide the plant dispatching (1)"
V04NewCapElec(allCy,PGALL,YTIME)	                       "The new capacity added every year (MW)"	
V04NetNewCapElec(allCy,PGALL,YTIME)	                       "Yearly difference in installed capacity (MW)"	
V04CFAvgRen(allCy,PGALL,YTIME)	                           "The average capacity factor of RES (1)"
V04CapOverall(allCy,PGALL,YTIME)	                       "Overall Capacity (MW)"	
*v04SecContrTotCHPProd(allCy,SBS,CHP,YTIME)                "Contribution of each sector in total CHP production (1)"	
*v04CostPowGenLonMin(allCy,PGALL,YTIME)	                   "Long-term minimum power generation cost (US$2015/kWh)"		
*v04CostPowGenLongIntPri(allCy,PGALL,ESET,YTIME)           "Long term power generation cost of technologies including international prices of main fuels (kUS$2015/toe)"
*v04CostPowGenShortIntPri(allCy,PGALL,ESET,YTIME)          "Short term power generation cost of technologies including international Prices of main fuels (kUS$2015/toe)"
*v04CostPowGenAvgShrt(allCy,ESET,YTIME)                    "Short-term average power generation cost (US$2015/kWh)"
V04LoadFacDom(allCy,YTIME)                                 "Electricity load factor for entire domestic system"	
V04DemElecTot(allCy,YTIME)                                 "Total electricity demand (TWh)"
V04ProdElecEstCHP(allCy,CHP,YTIME)	                       "Estimate the electricity of CHP Plants (1)"	
V04CapexFixCostPG(allCy,PGALL,YTIME)                       "CAPEX and fixed costs of any power generation technology (US$2015/kW)"
V04ShareMixWndSol(allCy,YTIME)                             "The participation of solar and wind in the energy mixture(%)"
V04CapexRESRate(allCy,PGALL,YTIME)                         "Multiplying factor expressing the extra grid and storage costs for RES implementation according to the RES penetration in the mixture"
V04CO2CaptRate(allCy,PGALL,YTIME)
V04CostCapTech(allCy,PGALL,YTIME)
V04CCSRetroFit(allCy,PGALL,YTIME)
V04ScrpRate(allCy,PGALL,YTIME)
*'                **Interdependent Variables**	
VmProdElec(allCy,PGALL,YTIME)                              "Electricity production (TWh)"	
VmCostPowGenAvgLng(allCy,YTIME)	                   "Long-term average power generation cost (US$2015/kWh)"
VmCapElecTotEst(allCy,YTIME)	                           "Estimated Total electricity generation capacity (GW)"
VmPeakLoad(allCy,YTIME)	                                   "Electricity peak load (GW)"	
VmCapElec(allCy,PGALL,YTIME)	                           "Electricity generation plants capacity (GW)"
;

Scalars
S04CapexBessRate                                            "The power expressing the rate of the increase in the solar & wind CAPEX because of storage need and grid upgrade" /1.3/