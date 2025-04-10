*' @title Industry Inputs
*' @code

*---
table iElastNonSubElecData(SBS,ETYPES,YTIME)               "Elasticities of Non Substitutable Electricity (1)"
$ondelim
$include "./iElastNonSubElecData.csv"
$offdelim
;
*---
table iElaSub(allCy,DSBS)                                  "Elasticities by subsector for all countries (1)" ;
*---
Parameters
iTotFinEneDemSubBaseYr(allCy,SBS,YTIME)	                   "Total Final Energy Demand per subsector in Base year (Mtoe)"
iExogDemOfBiomass(allCy,SBS,YTIME)	                       "Demand of tranditional biomass defined exogenously ()"
iLifChpPla(allCy,DSBS,CHP)                                 "Technical Lifetime for CHP plants (years)"
iElastNonSubElec(allCy,SBS,ETYPES,YTIME)                   "Elasticities of Non Substitutable Electricity (1)"
iInvCostChp(allCy,DSBS,CHP,YTIME)                          "Capital Cost per CHP plant type (kUS$2015/KW)"
iFixOMCostPerChp(allCy,DSBS,CHP,YTIME)                     "Fixed O&M cost per CHP plant type (US$2015/KW)"
iAvailRateChp(allCy,DSBS,CHP)                              "Availability rate of CHP Plants ()"
iVarCostChp(allCy,DSBS,CHP,YTIME)                          "Variable (other than fuel) cost per CHP Type (Gross US$2015/KW)"
iBoiEffChp(allCy,CHP,YTIME)                                "Boiler efficiency (typical) used in adjusting CHP efficiency ()"
;
*---
iTotFinEneDemSubBaseYr(runCy,TRANSE,YTIME) = sum(EF$(SECTTECH(TRANSE,EF) $(not plugin(EF))), iFuelConsPerFueSub(runCy,TRANSE,EF,YTIME));
iTotFinEneDemSubBaseYr(runCy,INDSE,YTIME)   = SUM(EF$(SECTTECH(INDSE,EF)),iFuelConsPerFueSub(runCy,INDSE,EF,YTIME));
iTotFinEneDemSubBaseYr(runCy,DOMSE,YTIME)   = SUM(EF$(SECTTECH(DOMSE,EF)),iFuelConsPerFueSub(runCy,DOMSE,EF,YTIME));
iTotFinEneDemSubBaseYr(runCy,NENSE,YTIME)   = SUM(EF$(SECTTECH(NENSE,EF)),iFuelConsPerFueSub(runCy,NENSE,EF,YTIME));
*---
iExogDemOfBiomass(runCy,DOMSE,YTIME) = 0;
*---
iLifChpPla(runCy,DSBS,CHP) = iDataChpPowGen(CHP,"2010","LFT");
*---
iElastNonSubElec(runCy,SBS,ETYPES,YTIME) = iElastNonSubElecData(SBS,ETYPES,YTIME);
*---
iInvCostChp(runCy,DSBS,CHP,YTIME) = iDataChpPowGen(CHP,"2010","IC");
*---
iFixOMCostPerChp(runCy,DSBS,CHP,YTIME) = iDataChpPowGen(CHP,"2010","FC");
*---
iAvailRateChp(runCy,DSBS,CHP) = iDataChpPowGen(CHP,"2010","AVAIL");
*---
iVarCostChp(runCy,DSBS,CHP,YTIME) = iDataChpPowGen(CHP,"2010","VOM");
*---
iBoiEffChp(runCy,CHP,YTIME) = iDataChpPowGen(CHP,"2010","BOILEFF");
*---
iElaSub(runCy,DSBS) = iElaSubData(DSBS);
*---