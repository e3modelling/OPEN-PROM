*' @title Power Generation Declarations
*' @code

Equations
*' *** Power Generation
QCapElec2(allCy,PGALL,YTIME)	                           "Compute electricity generation capacity"
QCapElecNominal(allCy,PGALL,YTIME)	                     "Compute nominal electricity generation capacity"
*qScalFacPlantDispatchExpr(allCy,PGALL,HOUR,YTIME)		   "Scaling factor for plant dispatching"		
QRenTechMatMultExpr(allCy,PGALL,YTIME)                     "Renewable power capacity over potential (1)"
QPotRenCurr(allCy,PGRENEF,YTIME)	                       "Compute current renewable potential"
QCapElecCHP(allCy,CHP,YTIME)                               "Compute CHP electric capacity"	
QLambda(allCy,YTIME)	                                   "Compute Lambda parameter"
QBsldEst(allCy,YTIME)	                                   "Compute estimated base load"
QBaseLoadMax(allCy,YTIME) 	                               "Compute baseload corresponding to maximum load"
QBaseLoad(allCy,YTIME)	                                   "Compute electricity base load"
QCapElecTotEst(allCy,YTIME)                                "Compute Estimated total electricity generation capacity"	
QCostHourProdInvDec(allCy,PGALL,HOUR,YTIME)                "Compute hourly production cost used in investment decisions"
QCostHourProdInvDecNoCCS(allCy,PGALL,HOUR,YTIME)           "Compute hourly production cost used in investment decisions"
QSensCCS(allCy,YTIME)	                                   "Compute gamma parameter used in CCS/No CCS decision tree"
*qCostHourProdInvCCS(allCy,PGALL,HOUR,YTIME)	           "Compute hourly production cost used in investment decisions taking into account CCS acceptance"
QCostProdSpecTech(allCy,PGALL,YTIME)	                   "Compute production cost used in investment decisions"
QShareNewTechCCS(allCy,PGALL,YTIME)	                       "Compute SHRCAP"
QShareNewTechNoCCS(allCy,PGALL,YTIME)	                   "Compute SHRCAP excluding CCs"
QCostVarTech(allCy,PGALL,YTIME)	                           "Compute variable cost of technology" 	
QCostVarTechNotPGSCRN(allCy,PGALL,YTIME)                   "Compute variable cost of technology excluding PGSCRN"	
QCostProdTeCHPreReplac(allCy,PGALL,YTIME)	               "Compute production cost of technology  used in premature replacement"	
QCostProdTeCHPreReplacAvail(allCy,PGALL,PGALL2,YTIME)	   "Compute production cost of technology  used in premature replacement including plant availability rate"	
QIndxEndogScrap(allCy,PGALL,YTIME)	                       "Compute endogenous scrapping index" 	
QCapElecNonCHP(allCy,YTIME)	                               "Compute total electricity generation capacity excluding CHP plants"
QGapGenCapPowerDiff(allCy,YTIME)	                       "Compute the gap in power generation capacity"		
*qScalWeibull(allCy,PGALL,HOUR,YTIME)                      "Compute temporary variable facilitating the scaling in Weibull equation"	
QPotRenSuppCurve(allCy,PGRENEF,YTIME)	                   "Compute renewable potential supply curve"		
QPotRenMaxAllow(allCy,PGRENEF,YTIME)                       "Compute maximum allowed renewable potential"
*qPotRenMinAllow(allCy,PGRENEF,YTIME)	                   "Compute minimum allowed renewable potential" 
QRenTechMatMult(allCy,PGALL,YTIME)	                       "Compute renewable technologies maturity multiplier"		 	
QScalWeibullSum(allCy,PGALL,YTIME)	                       "Compute sum (over hours) of temporary variable facilitating the scaling in Weibull equation"
QNewInvElec(allCy,YTIME)	                               "Compute for Power Plant new investment decision"		
QSharePowPlaNewEq(allCy,PGALL,YTIME)	                   "Compute the power plant share in new equipment"	
QCapElec(allCy,PGALL,YTIME)	                               "Compute electricity generation capacity"	
QCostVarTechElec(allCy,PGALL,YTIME)	                       "Compute variable cost of technology" 
QCostVarTechElecTot(allCy,YTIME)	                       "Compute Electricity peak loads"	
QSortPlantDispatch(allCy,PGALL,YTIME)	                   "Compute Power plants sorting according to variable cost to decide the plant dispatching" 	
QNewCapElec(allCy,PGALL,YTIME)	                           "Compute the new capacity added every year"
QNetNewCapElec(allCy,PGALL,YTIME)	                        "Compute the yearly difference in installed capacity"		
QCFAvgRen(allCy,PGALL,YTIME)	                           "Compute the average capacity factor of RES"	
QCapOverall(allCy,PGALL,YTIME)	                           "Compute overall capacity"
QScalFacPlantDispatch(allCy,HOUR,YTIME)                    "Compute the scaling factor for plant dispatching"
QProdElecEstCHP(allCy,YTIME)	                           "Estimate the electricity of CHP Plants"	
QProdElecNonCHP(allCy,YTIME)	                           "Compute non CHP electricity production" 	
QProdElecReqCHP(allCy,YTIME)	                           "Compute total estimated CHP electricity production" 	
*qSecContrTotCHPProd(allCy,SBS,CHP,YTIME)                  "Compute sector contribution to total CHP production"		
QCostPowGenLngTechNoCp(allCy,PGALL,ESET,YTIME)	           "Compute long term power generation cost of technologies excluding climate policies"	
*qCostPowGenLonMin(allCy,PGALL,YTIME)	                   "Long-term minimum power generation cost"	
*qCostPowGenLongIntPri(allCy,PGALL,ESET,YTIME)             "Compute long term power generation cost of technologies including international Prices of main fuels"
*qCostPowGenShortIntPri(allCy,PGALL,ESET,YTIME)            "Compute short term power generation cost of technologies including international Prices of main fuels"
QCostAvgPowGenLonNoClimPol(allCy,PGALL,ESET,YTIME)	       "Compute long term average power generation cost excluding climate policies"		
QCostPowGenLonNoClimPol(allCy,ESET,YTIME)                  "Compute long term power generation cost excluding climate policies"	
*qCostPowGenAvgShrt(allCy,ESET,YTIME)	                   "Compute short term power generation cost"
QConsElec(allCy,DSBS,YTIME)                                "Compute electricity consumption per final demand sector"

*'                **Interdependent Equations**
QLoadFacDom(allCy,YTIME)	                               "Compute load factor of entire domestic system"
QPeakLoad(allCy,YTIME)	                                   "Compute elerctricity peak load"	
QDemElecTot(allCy,YTIME)                                   "Compute total electricity demand"
QProdElec(allCy,PGALL,YTIME)                               "Compute electricity production from power generation plants"
QProdElecCHP(allCy,CHP,YTIME)	                           "Compute electricity production from CHP plants" 
QProdElecReqTot(allCy,YTIME)                               "Compute total required electricity production"
QCostPowGenAvgLng(allCy,ESET,YTIME)	                       "Compute long term power generation cost"
;

Variables
*' *** Power Generation Variables
VCapElec2(allCy,PGALL,YTIME)	                           "Electricity generation plants capacity (GW)"
VCapElecNominal(allCy,PGALL,YTIME)	                     "Nominal electricity generation plants capacity (GW)"
*vScalFacPlantDispatchExpr(allCy,PGALL,HOUR,YTIME)         "Scaling factor for plant dispatching"
VRenTechMatMultExpr(allCy,PGALL,YTIME)                   "Renewable power capacity over potential (1)"
VPotRenCurr(allCy,PGRENEF,YTIME)	                       "Current renewable potential (GW)"			
VCapElecCHP(allCy,CHP,YTIME)	                           "Capacity of CHP Plants (GW)"
VLambda(allCy,YTIME)	                                   "Parameter for load curve construction (1)"
VBsldEst(allCy,YTIME)	                                   "Estimated base load (GW)"
VBaseLoadMax(allCy,YTIME)	                               "Baseload corresponding to Maximum Load Factor (1)"
VBaseLoad(allCy,YTIME)	                                   "Corrected base load (GW)"
VCapElecTotEst(allCy,YTIME)	                               "Estimated Total electricity generation capacity (GW)"
VCostHourProdInvDec(allCy,PGALL,HOUR,YTIME)                "Hourly production cost of technology (US$2015/KWh)"
VCostHourProdInvDecNoCCS(allCy,PGALL,HOUR,YTIME)           "Hourly production cost of technology (US$2015/KWh)"	
VSensCCS(allCy,YTIME)	                                   "Variable that controlls the sensitivity of CCS acceptance (1)"			
*vCostHourProdInvCCS(allCy,PGALL,HOUR,YTIME)               "Hourly production cost of technology accounting for CCS acceptance (US$2015/KWh)"
VCostProdSpecTech(allCy,PGALL,YTIME)	                   "Production cost of technology (US$2015/KWh)"
VShareNewTechCCS(allCy,PGALL,YTIME)	                       "Power plant share in new equipment (1)"		
VShareNewTechNoCCS(allCy,PGALL,YTIME)	                   "Power plant share in new equipment (1)"
VCostVarTech(allCy,PGALL,YTIME)	                           "Variable cost of technology (US$2015/KWh)"	
VCostVarTechNotPGSCRN(allCy,PGALL,YTIME)                   "Variable cost of technology excluding PGSCRN (US$2015/KWh)"
VCostProdTeCHPreReplac(allCy,PGALL,YTIME)                  "Production cost of technology used in premature replacement (US$2015/KWh)"
VCostProdTeCHPreReplacAvail(allCy,PGALL,PGALL2,YTIME)	   "Production cost of technology used in premature replacement including plant availability rate (US$2015/KWh)"			
VIndxEndogScrap(allCy,PGALL,YTIME)	                       "Index used for endogenous power plants scrapping (1)"			
VCapElecNonCHP(allCy,YTIME)	                               "Total electricity generation capacity excluding CHP (GW)"	
VGapGenCapPowerDiff(allCy,YTIME)	                       "Gap in total generation capacity to be filled by new equipment (GW)"		
*vScalWeibull(allCy,PGALL,HOUR,YTIME)                      "Temporary variable facilitating the scaling in Weibull equation"	
VPotRenSuppCurve(allCy,PGRENEF,YTIME)	                   "Renewable potential supply curve	(1)"
VPotRenMaxAllow(allCy,PGRENEF,YTIME)                       "Maximum allowed renewable potential (GW)"
*vPotRenMinAllow(allCy,PGRENEF,YTIME)	                   "Minimum allowed renewable potential (GW)"		
VRenTechMatMult(allCy,PGALL,YTIME)	                       "Renewable technologies maturity multiplier (1)"	
VScalWeibullSum(allCy,PGALL,YTIME)	                       "Sum (over hours) of temporary variable facilitating the scaling in Weibull equation (1)"
VNewInvElec(allCy,YTIME)	                               "Power plant sorting for new investment decision according to total cost (1)"	
VSharePowPlaNewEq(allCy,PGALL,YTIME)	                   "Power plant share in new equipment (1)"	
VCapElec(allCy,PGALL,YTIME)	                               "Electricity generation plants capacity (GW)"	
VCostVarTechElec(allCy,PGALL,YTIME)	                       "Variable cost of technology (US$2015/KWh)"	
VCostVarTechElecTot(allCy,YTIME)	                       "Electricity peak loads (GW)"	
VSortPlantDispatch(allCy,PGALL,YTIME)	                   "Power plants sorting according to variable cost to decide the plant dispatching (1)"
VNewCapElec(allCy,PGALL,YTIME)	                         "The new capacity added every year (MW)"	
VNetNewCapElec(allCy,PGALL,YTIME)	                       "Yearly difference in installed capacity (MW)"	
VCFAvgRen(allCy,PGALL,YTIME)	                           "The average capacity factor of RES (1)"
VCapOverall(allCy,PGALL,YTIME)	                           "Overall Capacity (MW)"	
VScalFacPlaDisp(allCy,HOUR,YTIME)	                       "Scaling factor for plant dispatching	(1)"
VProdElecEstCHP(allCy,YTIME)	                           "Estimate the electricity of CHP Plants (1)"	
VProdElecNonCHP(allCy,YTIME)	                           "Non CHP total electricity production (TWh)"				
VProdElecReqCHP(allCy,YTIME)	                           "Total estimated CHP electricity production (TWh)"	
*vSecContrTotCHPProd(allCy,SBS,CHP,YTIME)                  "Contribution of each sector in total CHP production (1)"	
VCostPowGenLngTechNoCp(allCy,PGALL,ESET,YTIME)	           "Long-term average power generation cost (US$2015/kWh)"
*vCostPowGenLonMin(allCy,PGALL,YTIME)	                   "Long-term minimum power generation cost (US$2015/kWh)"		
*vCostPowGenLongIntPri(allCy,PGALL,ESET,YTIME)             "Long term power generation cost of technologies including international prices of main fuels (kUS$2015/toe)"
*vCostPowGenShortIntPri(allCy,PGALL,ESET,YTIME)            "Short term power generation cost of technologies including international Prices of main fuels (kUS$2015/toe)"
VCostAvgPowGenLonNoClimPol(allCy,PGALL,ESET,YTIME)	       "Long-term average power generation cost excluding climate policies(US$2015/kWh)" 	
VCostPowGenLonNoClimPol(allCy,ESET,YTIME)                  "Long-term average power generation cost  excluding climate policies (US$2015/kWh)"	
*vCostPowGenAvgShrt(allCy,ESET,YTIME)                      "Short-term average power generation cost (US$2015/kWh)"
VConsElec(allCy,DSBS,YTIME)                                "Electricity demand per final sector (Mtoe)"

*'                **Interdependent Variables**	
VLoadFacDom(allCy,YTIME)                                   "Electricity load factor for entire domestic system"	
VPeakLoad(allCy,YTIME)	                                   "Electricity peak load (GW)"	
VDemElecTot(allCy,YTIME)                                   "Total electricity demand (TWh)"
VProdElec(allCy,PGALL,YTIME)                               "Electricity production (TWh)"	
VProdElecCHP(allCy,CHP,YTIME)	                           "CHP electricity production (TWh)"
VProdElecReqTot(allCy,YTIME)	                           "Total required electricity production (TWh)"
VCostPowGenAvgLng(allCy,ESET,YTIME)	                       "Long-term average power generation cost (US$2015/kWh)"
;