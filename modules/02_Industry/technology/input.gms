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
$IFTHEN.calib %Calibration% == Calibration
variable i02ElastNonSubElec(allCy,DSBS,ETYPES,YTIME)        "Elasticities of Non Substitutable Electricity (1)";
i02ElastNonSubElec.L(runCy,DSBS,ETYPES,YTIME) = i02ElastNonSubElecData(DSBS,ETYPES,YTIME);
i02ElastNonSubElec.LO(runCy,DSBS,"a",YTIME)   = 0.001;
i02ElastNonSubElec.UP(runCy,DSBS,"a",YTIME)   = 10;
i02ElastNonSubElec.LO(runCy,DSBS,"b1",YTIME)  = -10;
i02ElastNonSubElec.UP(runCy,DSBS,"b1",YTIME)  = -0.001;
i02ElastNonSubElec.LO(runCy,DSBS,"b2",YTIME)  = -10;
i02ElastNonSubElec.UP(runCy,DSBS,"b2",YTIME)  = -0.001;
i02ElastNonSubElec.LO(runCy,DSBS,"c",YTIME)   = -10;
i02ElastNonSubElec.UP(runCy,DSBS,"c",YTIME)   = -0.001;
$ELSE.calib
i02ElastNonSubElec(runCy,DSBS,ETYPES,YTIME) = i02ElastNonSubElecData(DSBS,ETYPES,YTIME);
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
*---
i02ShareBlend(runCy,DSBS,ITECH,EF,YTIME)$(DATAY(YTIME) and SECTTECH(DSBS,ITECH) and ITECHtoEF(ITECH,EF)) =
(
  imFuelConsPerFueSub(runCy,DSBS,EF,YTIME) /
  SUM(EFS2$ITECHtoEF(ITECH,EFS2), imFuelConsPerFueSub(runCy,DSBS,EFS2,YTIME))
)$SUM(EFS2$ITECHtoEF(ITECH,EFS2), imFuelConsPerFueSub(runCy,DSBS,EFS2,YTIME)) +
1$(not SUM(EFS2$ITECHtoEF(ITECH,EFS2), imFuelConsPerFueSub(runCy,DSBS,EFS2,YTIME)) and not BIOFUELS(EF));
i02ShareBlend(runCy,DSBS,ITECH,EF,YTIME)$AN(YTIME) = i02ShareBlend(runCy,DSBS,ITECH,EF,"%fBaseY%");
i02ShareBlend(runCy,"BU","TKRS","KRS",YTIME)$AN(YTIME) = i02ShareBlend(runCy,"BU","TKRS","KRS","%fBaseY%") - 0.006 * (ord(YTIME)-11);
i02ShareBlend(runCy,"BU","TKRS","BKRS",YTIME)$AN(YTIME) = i02ShareBlend(runCy,"BU","TKRS","BKRS","%fBaseY%") + 0.006 * (ord(YTIME)-11);
i02ShareBlend(runCy,"BU","TGDO","GDO",YTIME)$AN(YTIME) = i02ShareBlend(runCy,"BU","TGDO","GDO","%fBaseY%") - 0.004 * (ord(YTIME)-11);
i02ShareBlend(runCy,"BU","TGDO","BGDO",YTIME)$AN(YTIME) = i02ShareBlend(runCy,"BU","TGDO","BGDO","%fBaseY%") + 0.004 * (ord(YTIME)-11);