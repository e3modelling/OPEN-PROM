*' @title Industry Inputs
*' @code

*---
table i02ElastNonSubElecData(SBS,ETYPES,YTIME)             "Elasticities of Non Substitutable Electricity (1)"
$ondelim
$include "./iElastNonSubElecData.csv"
$offdelim
;
*---
table i02ElaSub(allCy,DSBS)                                "Elasticities by subsector for all countries (1)" ;
*---
Parameters
i02ExogDemOfBiomass(allCy,SBS,YTIME)	                   "Demand of tranditional biomass defined exogenously ()"
i02LifChpPla(allCy,DSBS,CHP)                               "Technical Lifetime for CHP plants (years)"
$IF NOT %Calibration% == Calibration i02ElastNonSubElec(allCy,SBS,ETYPES,YTIME)                   "Elasticities of Non Substitutable Electricity (1)"
i02InvCostChp(allCy,DSBS,CHP,YTIME)                        "Capital Cost per CHP plant type (US$2015/KW)"
i02FixOMCostPerChp(allCy,DSBS,CHP,YTIME)                   "Fixed O&M cost per CHP plant type (US$2015/KW)"
i02AvailRateChp(allCy,DSBS,CHP)                            "Availability rate of CHP Plants ()"
i02VarCostChp(allCy,DSBS,CHP,YTIME)                        "Variable (other than fuel) cost per CHP Type (Gross US$2015/KW)"
i02BoiEffChp(allCy,CHP,YTIME)                              "Boiler efficiency (typical) used in adjusting CHP efficiency ()"
;
*---
imTotFinEneDemSubBaseYr(runCy,TRANSE,YTIME)  = sum(EF$(SECTTECH(TRANSE,EF) $(not plugin(EF))), imFuelConsPerFueSub(runCy,TRANSE,EF,YTIME));
imTotFinEneDemSubBaseYr(runCy,INDSE,YTIME)   = SUM(EF$(SECTTECH(INDSE,EF)),imFuelConsPerFueSub(runCy,INDSE,EF,YTIME));
imTotFinEneDemSubBaseYr(runCy,DOMSE,YTIME)   = SUM(EF$(SECTTECH(DOMSE,EF)),imFuelConsPerFueSub(runCy,DOMSE,EF,YTIME));
imTotFinEneDemSubBaseYr(runCy,NENSE,YTIME)   = SUM(EF$(SECTTECH(NENSE,EF)),imFuelConsPerFueSub(runCy,NENSE,EF,YTIME));
*---
i02ExogDemOfBiomass(runCy,DOMSE,YTIME) = 0;
*---
i02LifChpPla(runCy,DSBS,CHP) = imDataChpPowGen(CHP,"LFT","2010");
*---
$IFTHEN.calib %Calibration% == Calibration
variable i02ElastNonSubElec(allCy,SBS,ETYPES,YTIME)        "Elasticities of Non Substitutable Electricity (1)";
i02ElastNonSubElec.L(runCy,SBS,ETYPES,YTIME) = i02ElastNonSubElecData(SBS,ETYPES,YTIME);
i02ElastNonSubElec.LO(runCy,SBS,"a",YTIME)   = 0.001;
i02ElastNonSubElec.UP(runCy,SBS,"a",YTIME)   = 10;
i02ElastNonSubElec.LO(runCy,SBS,"b1",YTIME)  = -10;
i02ElastNonSubElec.UP(runCy,SBS,"b1",YTIME)  = -0.001;
i02ElastNonSubElec.LO(runCy,SBS,"b2",YTIME)  = -10;
i02ElastNonSubElec.UP(runCy,SBS,"b2",YTIME)  = -0.001;
i02ElastNonSubElec.LO(runCy,SBS,"c",YTIME)   = -10;
i02ElastNonSubElec.UP(runCy,SBS,"c",YTIME)   = -0.001;
$ELSE.calib
i02ElastNonSubElec(runCy,SBS,ETYPES,YTIME) = i02ElastNonSubElecData(SBS,ETYPES,YTIME);
$ENDIF.calib
*---
i02InvCostChp(runCy,DSBS,CHP,YTIME)      = imDataChpPowGen(CHP,"IC",YTIME);
*---
i02FixOMCostPerChp(runCy,DSBS,CHP,YTIME) = imDataChpPowGen(CHP,"FC",YTIME);
*---
i02AvailRateChp(runCy,DSBS,CHP)          = imDataChpPowGen(CHP,"AVAIL","2010");
*---
i02VarCostChp(runCy,DSBS,CHP,YTIME)      = imDataChpPowGen(CHP,"VOM",YTIME);
*---
i02BoiEffChp(runCy,CHP,YTIME)            = imDataChpPowGen(CHP,"BOILEFF",YTIME);
*---
i02ElaSub(runCy,DSBS) = imElaSubData(DSBS);
*---