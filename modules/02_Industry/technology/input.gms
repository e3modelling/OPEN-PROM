*' @title Industry Inputs
*' @code

*---
table i02ElastNonSubElecData(DSBS,ETYPES,YTIME)             "Elasticities of Non Substitutable Electricity (1)"
$ondelim
$include "./parameters/iElastNonSubElecData.csv"
$offdelim
;
*---
table i02ElaSub(allCy,DSBS)                                "Elasticities by subsector for all countries (1)" ;
*---
imTotFinEneDemSubBaseYr(runCy,TRANSE,YTIME)  = sum(EF$SECtoEF(TRANSE,EF),imFuelCons(runCy,TRANSE,EF,YTIME));
imTotFinEneDemSubBaseYr(runCy,INDSE,YTIME)   = SUM(EF$SECtoEF(INDSE,EF),imFuelCons(runCy,INDSE,EF,YTIME));
imTotFinEneDemSubBaseYr(runCy,DOMSE,YTIME)   = SUM(EF$SECtoEF(DOMSE,EF),imFuelCons(runCy,DOMSE,EF,YTIME));
imTotFinEneDemSubBaseYr(runCy,NENSE,YTIME)   = SUM(EF$SECtoEF(NENSE,EF),imFuelCons(runCy,NENSE,EF,YTIME));
*---
i02ExogDemOfBiomass(runCy,DOMSE,YTIME) = 0;
*---
i02util(runCy,DSBS,ITECH,YTIME)$SECTTECH(DSBS,ITECH) = 1;
*---
$IFTHEN.calib %Calibration% == off
table i02ScaleEndogScrap(allCy,DSBS,ITECH,YTIME)       "Scale parameter for endogenous scrapping applied to the sum of full costs (1)"
$ondelim
$include"./iScaleEndogScrap.csv"
$offdelim
;
*---
table i02CalibUsefulEnergy(allCy,DSBS,YTIME)      "Calibration parameter for useful energy (1)"
$ondelim
$include"./iCalibUsefulEnergy.csv"
$offdelim
;
*---
$ELSE.calib
variable i02ScaleEndogScrap(allCy,DSBS,ITECH,YTIME)        "Scale parameter for endogenous scrapping applied to the sum of full costs (1)";
variable i02CalibUsefulEnergy(allCy,DSBS,YTIME);

i02ScaleEndogScrap.LO(runCy,DSBS,ITECH,YTIME) = 0;                                      
i02ScaleEndogScrap.UP(runCy,DSBS,ITECH,YTIME) = 100;
i02ScaleEndogScrap.L(runCy,DSBS,ITECH,YTIME) = 1;
i02ScaleEndogScrap.FX(runCy,DSBS,ITECH,YTIME)$(DATAY(YTIME) or not SECTTECH(DSBS,ITECH)) = 0;
i02ScaleEndogScrap.FX(runCy,DSBS,ITECH,YTIME)$(SECTTECH(DSBS,ITECH) and not (INDDOM(DSBS) or sameas("NEN",DSBS) or sameas("PCH",DSBS))) = 1;
i02ScaleEndogScrap.FX(runCy,DSBS,ITECH,YTIME)$(sameas("AG",DSBS) and not EU28(runCy)) = 1;

i02CalibUsefulEnergy.LO(runCy,DSBS,YTIME) = -0.5;  
i02CalibUsefulEnergy.UP(runCy,DSBS,YTIME) = 1;  
i02CalibUsefulEnergy.FX(runCy,DSBS,YTIME)$DATAY(YTIME) = 0;
i02CalibUsefulEnergy.FX(runCy,DSBS,YTIME)$(not (INDDOM(DSBS) or sameas("NEN",DSBS) or sameas("PCH",DSBS))) = 0;
i02CalibUsefulEnergy.FX(runCy,DSBS,YTIME)$(sameas("AG",DSBS) and not EU28(runCy)) = 0;
$ENDIF.calib
i02ElastNonSubElec(runCy,DSBS,ETYPES,YTIME) = i02ElastNonSubElecData(DSBS,ETYPES,YTIME);
*---
i02ElaSub(runCy,DSBS) = imElaSubData(DSBS);
i02ElaSub(runCy,DSBS) = 2;
*---
imCO2CaptRateIndustry(runCy,CCSTECH,YTIME) = 0.9;
*---
alias(ITECH,ITECH2);
i02numtechnologiesUsingEF(DSBS,EF)=sum(ITECH2$(ITECHtoEF(ITECH2,EF)$SECTTECH(DSBS,ITECH2)),1);
*---
i02ShareBlend(runCy,DSBS,ITECH,EF,YTIME)$(DATAY(YTIME) and SECTTECH(DSBS,ITECH) and ITECHtoEF(ITECH,EF)) =
  (
    imFuelCons(runCy,DSBS,EF,YTIME) /
    SUM(EFS2$ITECHtoEF(ITECH,EFS2), imFuelCons(runCy,DSBS,EFS2,YTIME))
  )$SUM(EFS2$ITECHtoEF(ITECH,EFS2), imFuelCons(runCy,DSBS,EFS2,YTIME)) +
  1$(not SUM(EFS2$ITECHtoEF(ITECH,EFS2), imFuelCons(runCy,DSBS,EFS2,YTIME)) and not BIOFUELS(EF));
  
i02ShareBlend(runCy,DSBS,ITECH,EF,YTIME)$AN(YTIME) = i02ShareBlend(runCy,DSBS,ITECH,EF,"%fBaseY%");
i02ShareBlend(runCy,"BU","TKRS","KRS",YTIME)$(AN(YTIME) and not EU28(runCy))= i02ShareBlend(runCy,"BU","TKRS","KRS","%fBaseY%") - 0.006 * (ord(YTIME)-14); 
i02ShareBlend(runCy,"BU","TKRS","BKRS",YTIME)$(AN(YTIME) and not EU28(runCy)) = i02ShareBlend(runCy,"BU","TKRS","BKRS","%fBaseY%") + 0.006 * (ord(YTIME)-14);
i02ShareBlend(runCy,"BU","TGDO","GDO",YTIME)$(AN(YTIME) and not EU28(runCy)) = i02ShareBlend(runCy,"BU","TGDO","GDO","%fBaseY%") - 0.004 * (ord(YTIME)-14);
i02ShareBlend(runCy,"BU","TGDO","BGDO",YTIME)$(AN(YTIME) and not EU28(runCy)) = i02ShareBlend(runCy,"BU","TGDO","BGDO","%fBaseY%") + 0.004 * (ord(YTIME)-14);

i02ShareBlend(EU28,"BU","TKRS","KRS",YTIME)$(AN(YTIME) and ord(YTIME)<55) = i02ShareBlend(EU28,"BU","TKRS","KRS","%fBaseY%") - 0.022 * (ord(YTIME)-14);
i02ShareBlend(EU28,"BU","TKRS","BKRS",YTIME)$(AN(YTIME) and ord(YTIME)<55) = i02ShareBlend(EU28,"BU","TKRS","BKRS","%fBaseY%") + 0.022 * (ord(YTIME)-14);
i02ShareBlend(EU28,"BU","TGDO","GDO",YTIME)$(AN(YTIME) and ord(YTIME)<55) = i02ShareBlend(EU28,"BU","TGDO","GDO","%fBaseY%") - 0.0195 * (ord(YTIME)-14);
i02ShareBlend(EU28,"BU","TGDO","BGDO",YTIME)$(AN(YTIME) and ord(YTIME)<55) = i02ShareBlend(EU28,"BU","TGDO","BGDO","%fBaseY%") + 0.0195 * (ord(YTIME)-14);

i02ShareBlend(EU28,"BU","TKRS","KRS",YTIME)$(AN(YTIME) and ord(YTIME)>=55) = i02ShareBlend(EU28,"BU","TKRS","KRS","%fBaseY%") - 0.022 * 41;
i02ShareBlend(EU28,"BU","TKRS","BKRS",YTIME)$(AN(YTIME) and ord(YTIME)>=55) = i02ShareBlend(EU28,"BU","TKRS","BKRS","%fBaseY%") + 0.022 * 41;
i02ShareBlend(EU28,"BU","TGDO","GDO",YTIME)$(AN(YTIME) and ord(YTIME)>=55) = i02ShareBlend(EU28,"BU","TGDO","GDO","%fBaseY%") - 0.0195 * 41;
i02ShareBlend(EU28,"BU","TGDO","BGDO",YTIME)$(AN(YTIME) and ord(YTIME)>=55) = i02ShareBlend(EU28,"BU","TGDO","BGDO","%fBaseY%") + 0.0195 * 41;

i02ShareBlend("DEU","PCH","TOLQ","OLQ",YTIME)$AN(YTIME) = 1; !! To Change exogenously

i02ShareElcHP(runCy,"HOU",YTIME) = 0.1;
i02ShareElcHP(runCy,"SE",YTIME) = 0.1;
*---
table i02FuelConsICT(allCy,ICTSCEN,SSPSCEN,YTIME)             "Electrity demand of Data centers and infrastructure (Mtoe)"
$ondelim
$include "./iFuelConsICT.csv"
$offdelim
;
*---
$IFTHEN.calib %Calibration% == MatCalibration
table t02SharesFuelBuildings(allCy,DSBS,EFS,YTIME)    "Targets for share of new passenger cars"
$ondelim
$include "../targets/tSharesFuelBuildings.csv"
$offdelim;

table t02SharesFuelINDSE(allCy,DSBS,EFS,YTIME)    "Targets for share of new passenger cars"
$ondelim
$include "../targets/tSharesINDSE.csv"
$offdelim;

table t02FinalEnergyDOMSE(allCy,DSBS,YTIME)    "Targets for share of new passenger cars"
$ondelim
$include "../targets/tProjectionsFuelBuildings.csv"
$offdelim;

table t02FinalEnergyINDSE(allCy,DSBS,YTIME)    "Targets for share of new passenger cars"
$ondelim
$include "../targets/tProjectionsINDSE.csv"
$offdelim;
$ENDIF.calib

i02SensCarbon(allCy,YTIME,DSBS) = 5;

imUsfEneConvSubTech(runCy,"HOU","THEATPUMP",YTIME)$AN(YTIME)  = 3.5;
imUsfEneConvSubTech(runCy,"SE","THEATPUMP",YTIME)$AN(YTIME)  = 3.5;

