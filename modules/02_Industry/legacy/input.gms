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
$IF NOT %Calibration% == Calibration iElastNonSubElec(allCy,SBS,ETYPES,YTIME)                   "Elasticities of Non Substitutable Electricity (1)"
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
$IFTHEN.calib %Calibration% == Calibration
variable iElastNonSubElec(allCy,SBS,ETYPES,YTIME)        "Elasticities of Non Substitutable Electricity (1)";
iElastNonSubElec.L(runCy,SBS,ETYPES,YTIME) = iElastNonSubElecData(SBS,ETYPES,YTIME);
iElastNonSubElec.LO(runCy,SBS,"a",YTIME) = 0.001;
iElastNonSubElec.UP(runCy,SBS,"a",YTIME) = 10;
iElastNonSubElec.LO(runCy,SBS,"b1",YTIME) = -10;
iElastNonSubElec.UP(runCy,SBS,"b1",YTIME) = -0.001;
iElastNonSubElec.LO(runCy,SBS,"b2",YTIME) = -10;
iElastNonSubElec.UP(runCy,SBS,"b2",YTIME) = -0.001;
iElastNonSubElec.LO(runCy,SBS,"c",YTIME) = -10;
iElastNonSubElec.UP(runCy,SBS,"c",YTIME) = -0.001;
$ELSE.calib
iElastNonSubElec(runCy,SBS,ETYPES,YTIME) = iElastNonSubElecData(SBS,ETYPES,YTIME);
$ENDIF.calib
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