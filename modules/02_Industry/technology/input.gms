*' @title Industry Inputs
*' @code

*---
table i02ElastNonSubElecData(DSBS,ETYPES,YTIME)             "Elasticities of Non Substitutable Electricity (1)"
$ondelim
$include "./iElastNonSubElecData.csv"
$offdelim
;
*---
table i02ElaSub(allCy,DSBS)                                "Elasticities by subsector for all countries (1)" ;
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
$IFTHEN.calib %Calibration% == off
parameter i02ScaleEndogScrap(allCy,DSBS,ITECH,YTIME)       "Scale parameter for endogenous scrapping applied to the sum of full costs (1)";
parameter i02CalibUsefulEnergy(allCy,DSBS,YTIME);

i02ScaleEndogScrap(runCy,DSBS,ITECH,YTIME) = 1;
i02CalibUsefulEnergy(runCy,DSBS,YTIME) = 0;
$ELSE.calib
variable i02ScaleEndogScrap(allCy,DSBS,ITECH,YTIME)        "Scale parameter for endogenous scrapping applied to the sum of full costs (1)";
variable i02CalibUsefulEnergy(allCy,DSBS,YTIME)        ;

i02ScaleEndogScrap.LO(runCy,DSBS,ITECH,YTIME) = 0;                                      
i02ScaleEndogScrap.UP(runCy,DSBS,ITECH,YTIME) = 100;
i02ScaleEndogScrap.L(runCy,DSBS,ITECH,YTIME) = 1;
i02ScaleEndogScrap.FX(runCy,DSBS,ITECH,YTIME)$DATAY(YTIME) = 0;
i02ScaleEndogScrap.FX(runCy,DSBS,ITECH,YTIME)$(not sameas("HOU",DSBS)) = 1;

i02CalibUsefulEnergy.LO(runCy,DSBS,YTIME) = -1;  
i02CalibUsefulEnergy.UP(runCy,DSBS,YTIME) = 1;  
i02CalibUsefulEnergy.FX(runCy,DSBS,YTIME)$DATAY(YTIME) = 0;
i02CalibUsefulEnergy.FX(runCy,DSBS,YTIME)$(not sameas("HOU",DSBS)) = 0;
$ENDIF.calib
i02ElastNonSubElec(runCy,DSBS,ETYPES,YTIME) = i02ElastNonSubElecData(DSBS,ETYPES,YTIME);
*---
i02ElaSub(runCy,DSBS) = imElaSubData(DSBS);
i02ElaSub(runCy,DSBS) = 2; !!
*---
imCO2CaptRateIndustry(runCy,CCSTECH,YTIME) = 0.9;
*---
alias(ITECH,ITECH2);
i02numtechnologiesUsingEF(DSBS,EF)=sum(ITECH2$(ITECHtoEF(ITECH2,EF)$SECTTECH(DSBS,ITECH2)),1);
*---
i02ShareBlend(runCy,DSBS,ITECH,EF,YTIME)$(DATAY(YTIME) and SECTTECH(DSBS,ITECH) and ITECHtoEF(ITECH,EF)) =
  (
    imFuelConsPerFueSub(runCy,DSBS,EF,YTIME) /
    SUM(EFS2$ITECHtoEF(ITECH,EFS2), imFuelConsPerFueSub(runCy,DSBS,EFS2,YTIME))
  )$SUM(EFS2$ITECHtoEF(ITECH,EFS2), imFuelConsPerFueSub(runCy,DSBS,EFS2,YTIME)) +
  1$(not SUM(EFS2$ITECHtoEF(ITECH,EFS2), imFuelConsPerFueSub(runCy,DSBS,EFS2,YTIME)) and not BIOFUELS(EF));
  
i02ShareBlend(runCy,DSBS,ITECH,EF,YTIME)$AN(YTIME) = i02ShareBlend(runCy,DSBS,ITECH,EF,"%fBaseY%");
i02ShareBlend(runCy,"BU","TKRS","KRS",YTIME)$AN(YTIME) = i02ShareBlend(runCy,"BU","TKRS","KRS","%fBaseY%") - 0.006 * (ord(YTIME)-14);
i02ShareBlend(runCy,"BU","TKRS","BKRS",YTIME)$AN(YTIME) = i02ShareBlend(runCy,"BU","TKRS","BKRS","%fBaseY%") + 0.006 * (ord(YTIME)-14);
i02ShareBlend(runCy,"BU","TGDO","GDO",YTIME)$AN(YTIME) = i02ShareBlend(runCy,"BU","TGDO","GDO","%fBaseY%") - 0.004 * (ord(YTIME)-14);
i02ShareBlend(runCy,"BU","TGDO","BGDO",YTIME)$AN(YTIME) = i02ShareBlend(runCy,"BU","TGDO","BGDO","%fBaseY%") + 0.004 * (ord(YTIME)-14);

i02ShareElcHP(runCy,"HOU",YTIME) = 0.1;
i02ShareElcHP(runCy,"SE",YTIME) = 0.1;
*---
$IFTHEN.calib %Calibration% == MatCalibration
table t02SharesFuelBuildings(allCy,DSBS,EFS,YTIME)    "Targets for share of new passenger cars"
$ondelim
$include "../targets/tSharesFuelBuildings.csv"
$offdelim
;
$ENDIF.calib