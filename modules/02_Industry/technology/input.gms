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
imTotFinEneDemSubBaseYr(runCy,TRANSE,YTIME)  = sum(EF$SECtoEF(TRANSE,EF),imFuelConsPerFueSub(runCy,TRANSE,EF,YTIME));
imTotFinEneDemSubBaseYr(runCy,INDSE,YTIME)   = SUM(EF$SECtoEF(INDSE,EF),imFuelConsPerFueSub(runCy,INDSE,EF,YTIME));
imTotFinEneDemSubBaseYr(runCy,DOMSE,YTIME)   = SUM(EF$SECtoEF(DOMSE,EF),imFuelConsPerFueSub(runCy,DOMSE,EF,YTIME));
imTotFinEneDemSubBaseYr(runCy,NENSE,YTIME)   = SUM(EF$SECtoEF(NENSE,EF),imFuelConsPerFueSub(runCy,NENSE,EF,YTIME));
*---
i02ExogDemOfBiomass(runCy,DOMSE,YTIME) = 0;
*---
i02util(runCy,DSBS,ITECH,YTIME) = 1;
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
i02CalibUsefulEnergy(allCy,"HOU",YTIME) = 0;
i02CalibUsefulEnergy(allCy,"SE",YTIME) = 0;

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
* i02ScaleEndogScrap(DSBS)$(not TRANSE(DSBS) and not CDR(DSBS)) = 3./SUM(ITECH$SECTTECH(DSBS,ITECH),1);
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

*POLICY MEASURES PRISMA
i02SensCarbon(allCy,YTIME,DSBS) = 0;

* *--- USA
* i02SensCarbon("USA",YTIME,DSBS)$(ord(YTIME)>34) = 1;
* *--- LAM
* i02SensCarbon("LAM",YTIME,DSBS)$(ord(YTIME)>34) = 1;

* *--- REF
* i02SensCarbon("REF",YTIME,DSBS)$(ord(YTIME)>34) = 2;

* *--- IND
* i02SensCarbon("IND",YTIME,DSBS)$(ord(YTIME)>34) = 2.5;

* *--- OAS
* i02SensCarbon("OAS",YTIME,DSBS)$(ord(YTIME)>34) = 1;


* *--- CHA
* i02SensCarbon("CHA",YTIME,DSBS)$(ord(YTIME)>34) = 4;

* *--- CAZ
* i02SensCarbon("CAZ",YTIME,DSBS) = 1;
* i02SensCarbon("CAZ",YTIME,"HOU") = 2;
* i02SensCarbon("CAZ",YTIME,"SE") = 2;


* *--- EU + UK
* i02SensCarbon(EU28,YTIME,DSBS) = 1;
* i02SensCarbon(EU28,YTIME,"HOU") = 2;
* i02SensCarbon(EU28,YTIME,"SE") = 2;

* i02SensCarbon(EU27,YTIME,DSBS)$(ord(YTIME)>34) = 1.5;
* i02SensCarbon(EU27,YTIME,"HOU")$(ord(YTIME)>34) = 2.5;
* i02SensCarbon(EU27,YTIME,"SE")$(ord(YTIME)>34) = 2.5;
*---

* i02ShareBlend(runCy,"BU","TKRS","KRS",YTIME)$(AN(YTIME) and ord(YTIME)<55) = i02ShareBlend(runCy,"BU","TKRS","KRS","%fBaseY%") - 0.022 * (ord(YTIME)-14);
* i02ShareBlend(runCy,"BU","TKRS","BKRS",YTIME)$(AN(YTIME) and ord(YTIME)<55) = i02ShareBlend(runCy,"BU","TKRS","BKRS","%fBaseY%") + 0.022 * (ord(YTIME)-14);
* i02ShareBlend(runCy,"BU","TGDO","GDO",YTIME)$(AN(YTIME) and ord(YTIME)<55) = i02ShareBlend(runCy,"BU","TGDO","GDO","%fBaseY%") - 0.0195 * (ord(YTIME)-14);
* i02ShareBlend(runCy,"BU","TGDO","BGDO",YTIME)$(AN(YTIME) and ord(YTIME)<55) = i02ShareBlend(runCy,"BU","TGDO","BGDO","%fBaseY%") + 0.0195 * (ord(YTIME)-14);

* i02ShareBlend(runCy,"BU","TKRS","KRS",YTIME)$(AN(YTIME) and ord(YTIME)>=55) = i02ShareBlend(runCy,"BU","TKRS","KRS","%fBaseY%") - 0.022 * 41;
* i02ShareBlend(runCy,"BU","TKRS","BKRS",YTIME)$(AN(YTIME) and ord(YTIME)>=55) = i02ShareBlend(runCy,"BU","TKRS","BKRS","%fBaseY%") + 0.022 * 41;
* i02ShareBlend(runCy,"BU","TGDO","GDO",YTIME)$(AN(YTIME) and ord(YTIME)>=55) = i02ShareBlend(runCy,"BU","TGDO","GDO","%fBaseY%") - 0.0195 * 41;
* i02ShareBlend(runCy,"BU","TGDO","BGDO",YTIME)$(AN(YTIME) and ord(YTIME)>=55) = i02ShareBlend(runCy,"BU","TGDO","BGDO","%fBaseY%") + 0.0195 * 41;


i02ShareElcHP(runCy,"HOU",YTIME) = 0.1;
i02ShareElcHP(runCy,"SE",YTIME) = 0.1;
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

* imUsfEneConvSubTech(runCy,"HOU","TELC",YTIME)$(ord(YTIME)>20)  = imDataDomTech("HOU","TELC","USC") + 0.0525 * (ord(YTIME)-21);
imUsfEneConvSubTech(runCy,"HOU","THEATPUMP",YTIME)$AN(YTIME)  = 3.5;
* imUsfEneConvSubTech(runCy,"SE","TELC",YTIME)$(ord(YTIME)>20)  = imDataDomTech("SE","TELC","USC") + 0.0525 * (ord(YTIME)-21);
imUsfEneConvSubTech(runCy,"SE","THEATPUMP",YTIME)$AN(YTIME)  = 3.5;
