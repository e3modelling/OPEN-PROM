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
$IF NOT %Calibration% == Calibration i02ElastNonSubElec(allCy,SBS,ETYPES,YTIME)                   "Elasticities of Non Substitutable Electricity (1)"
i02util(allCy,DSBS,ITECH,YTIME)                            "Utilization rate of technology"
i02numtechnologiesUsingEF(DSBS,EF)                         "Number of technologues using an energy form"     
i02Share(allCy,DSBS,ITECH,EF,YTIME)                        "Share of each energy form in a technology"
imCO2CaptRateIndustry(allCy,ITECH,YTIME)	               "Industry CO2 capture rate (1)"
i02ScaleEndogScrap(DSBS)                            "Scale parameter for endogenous scrapping applied to the sum of full costs (1)"
;
*---
imTotFinEneDemSubBaseYr(runCy,TRANSE,YTIME)  = sum(EF$SECtoEF(TRANSE,EF), imFuelConsPerFueSub(runCy,TRANSE,EF,YTIME));
imTotFinEneDemSubBaseYr(runCy,INDSE,YTIME)   = SUM(EF$SECtoEF(INDSE,EF),imFuelConsPerFueSub(runCy,INDSE,EF,YTIME));
imTotFinEneDemSubBaseYr(runCy,DOMSE,YTIME)   = SUM(EF$SECtoEF(DOMSE,EF),imFuelConsPerFueSub(runCy,DOMSE,EF,YTIME));
imTotFinEneDemSubBaseYr(runCy,NENSE,YTIME)   = SUM(EF$SECtoEF(NENSE,EF),imFuelConsPerFueSub(runCy,NENSE,EF,YTIME));
*---
i02ExogDemOfBiomass(runCy,DOMSE,YTIME) = 0;
*---
i02util(runCy,DSBS,ITECH,YTIME) = 1;
*---
i02Share(runCy,DSBS,ITECH,EF,YTIME) = 1; !! (To be included in mrprom when mix of fuels for technologies)
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
i02ElaSub(runCy,DSBS) = imElaSubData(DSBS);
i02ElaSub(runCy,DSBS) = 2; !!
*---
i02ScaleEndogScrap(DSBS)$(not TRANSE(DSBS) and not sameas("DAC",DSBS)) = 6./SUM(ITECH$SECTTECH(DSBS,ITECH),1);
*---
imCO2CaptRateIndustry(runCy,CCSTECH,YTIME) = 0.9;

alias(ITECH,ITECH2);
i02numtechnologiesUsingEF(DSBS,EF)=sum(ITECH2$(ITECHtoEF(ITECH2,EF)$SECTTECH(DSBS,ITECH2)),1);