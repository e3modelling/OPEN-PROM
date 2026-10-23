*' @title Industry Inputs
*' @code
*---
table i02Capacity(allCy,INDDOM,IND_SERVS,INDITECH,YTIME)	      ""	
$ondelim
$include"./iProductionIS.csv"
$offdelim
;
*---
table i02FuelConsICT(allCy,ICTSCEN,SSPSCEN,YTIME)             "Electrity demand of Data centers and infrastructure (Mtoe)"
$ondelim
$include "./iFuelConsICT.csv"
$offdelim
;
*---
table i02ISTransfOutEF(allCy,IS_TRANSF,EF,YTIME)	      ""	
$ondelim
$include"./iOutFullTransfProcess.csv"
$offdelim
;
*---
table i02FuelConsPerService(allCy,INDDOM,IND_SERVS,EF,YTIME)	      ""	
$ondelim
$include"./IDataFuelConsPerService.csv"
$offdelim
;
*---
table i02SFC(allCy,INDDOM,IND_SERVS,INDITECH,EF,YTIME)	      ""	
$ondelim
$include"./iDataIndustrySFC.csv"
$offdelim
;
*---
table i02ISTransfInEF(allCy,IS_TRANSF,EF,YTIME)	      ""	
$ondelim
$include"./iInpFullTransfProcess.csv"
$offdelim
;
*---
table i02OwnEnergyTransf(allCy,IS_TRANSF,EF,YTIME)	      ""	
$ondelim
$include"./IDataOwnEnergyTransf.csv"
$offdelim
;
*---
$IFTHEN.calib %Calibration% == off
$ontext
table i02ScaleEndogScrap(allCy,DSBS,ITECH,YTIME)       "Scale parameter for endogenous scrapping applied to the sum of full costs (1)"
$ondelim
$include"./iScaleEndogScrap.csv"
$offdelim
;
$offtext
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

$ontext
i02ScaleEndogScrap.LO(runCy,DSBS,ITECH,YTIME) = 0.01;                                      
i02ScaleEndogScrap.UP(runCy,DSBS,ITECH,YTIME) = 1;
i02ScaleEndogScrap.L(runCy,DSBS,ITECH,YTIME) = 1;
i02ScaleEndogScrap.FX(runCy,DSBS,ITECH,YTIME)$(DATAY(YTIME) or not SECTTECH(DSBS,ITECH)) = 0;
i02ScaleEndogScrap.FX(runCy,DSBS,ITECH,YTIME)$(SECTTECH(DSBS,ITECH) and not (INDDOM(DSBS) or sameas("NEN",DSBS) or sameas("PCH",DSBS))) = 1;
$offtext

i02CalibUsefulEnergy.LO(runCy,DSBS,YTIME) = -0.5;  
i02CalibUsefulEnergy.UP(runCy,DSBS,YTIME) = 0.5;  
i02CalibUsefulEnergy.FX(runCy,DSBS,YTIME)$DATAY(YTIME) = 0;
i02CalibUsefulEnergy.FX(runCy,DSBS,YTIME)$(not (INDDOM(DSBS) or sameas("NEN",DSBS) or sameas("PCH",DSBS))) = 0;
*---
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
*---
imTotFinEneDemSubBaseYr(runCy,DSBS,YTIME)  = sum(EF$SECtoEF(DSBS,EF),imFuelCons(runCy,DSBS,EF,YTIME));
*---
imCO2CaptRateIndustry(runCy,CCSITECH,YTIME) = 0.9;
*---
i02DataEnergyService(runCy,INDDOM,IND_SERVS,YTIME)$(INDDOMtoSERVS(INDDOM,IND_SERVS)) = SUM(INDITECH,i02Capacity(runCy,INDDOM,IND_SERVS,INDITECH,YTIME));
*---
$ontext
i02SpecificFuelConsData(runCy,INDDOM,IND_SERVS,INDITECH,YTIME)$(DATAY(YTIME) and INDDOMtoSERVS(INDDOM,IND_SERVS) or SERVStoTECH(IND_SERVS,INDITECH)) = 1;
i02SpecificFuelConsData(runCy,INDDOM,IND_SERVS,INDITECH,YTIME)$(DATAY(YTIME) and INDDOMtoSERVS(INDDOM,IND_SERVS) or SERVStoTECH(IND_SERVS,INDITECH)) = 
(i02SpecificFuelConsData(runCy,INDDOM,IND_SERVS,INDITECH,YTIME) / i02DataEnergyService(runCy,INDDOM,IND_SERVS,YTIME) *
SUM((INDITECH2,EFS)$(INDDOMtoSERVS(INDDOM,IND_SERVS) and SERVStoTECH(IND_SERVS,INDITECH2) and INDITECHTOEF(INDITECH2,EFS)),
  i02FuelConsPerService(runCy,INDDOM,IND_SERVS,EFS,YTIME) / i02SpecificFuelConsData(runCy,INDDOM,IND_SERVS,INDITECH2,YTIME)
)
)$(i02DataEnergyService(runCy,INDDOM,IND_SERVS,YTIME) and SUM(EFS,i02FuelConsPerService(runCy,INDDOM,IND_SERVS,EFS,YTIME))) +
1e-6;
$offtext
*---
*i02Capacity(runCy,INDDOM,IND_SERVS,INDITECH,YTIME)$(DATAY(YTIME) and INDDOMtoSERVS(INDDOM,IND_SERVS) and SERVStoTECH(IND_SERVS,INDITECH)) = SUM(EFS$INDITECHTOEF(INDITECH,EFS), i02FuelConsPerService(runCy,INDDOM,IND_SERVS,EFS,YTIME)) / i02SpecificFuelConsData(runCy,INDDOM,IND_SERVS,INDITECH,YTIME);
*---
$ontext
i02DataShareBlend(runCy,INDDOM,IND_SERVS,INDITECH,EF,YTIME)$(DATAY(YTIME) and INDDOMtoSERVS(INDDOM,IND_SERVS) and SERVStoTECH(IND_SERVS,INDITECH) and INDITECHTOEF(INDITECH,EF)) = 
(i02FuelConsPerService(runCy,INDDOM,IND_SERVS,EF,YTIME) + 1e-6) /
SUM(EF2$(INDDOMtoSERVS(INDDOM,IND_SERVS) or SERVStoTECH(IND_SERVS,INDITECH) and INDITECHTOEF(INDITECH,EF2)),
    i02FuelConsPerService(runCy,INDDOM,IND_SERVS,EF2,YTIME) + 1e-6
);
$offtext
*---
i02ratioTransfInputIS(runCy,IS_TRANSF,EFS,YTIME)$DATAY(YTIME) =
(
  -i02ISTransfInEF(runCy,IS_TRANSF,EFS,YTIME) / 
  SUM(EFS2$IS_TRANSF_OUT(IS_TRANSF,EFS2),
    i02ISTransfOutEF(runCy,IS_TRANSF,EFS2,YTIME)
  )
)$SUM(EFS2$IS_TRANSF_OUT(IS_TRANSF,EFS2),i02ISTransfOutEF(runCy,IS_TRANSF,EFS2,YTIME));
*---
i02ratioOwnEnergyTransfIS(runCy,IS_TRANSF,EFS,YTIME)$DATAY(YTIME) = 
(
  i02OwnEnergyTransf(runCy,IS_TRANSF,EFS,YTIME) / 
  SUM(EFS2$IS_TRANSF_OUT(IS_TRANSF,EFS2),i02ISTransfOutEF(runCy,IS_TRANSF,EFS2,YTIME))
)$SUM(EFS2$IS_TRANSF_OUT(IS_TRANSF,EFS2),i02ISTransfOutEF(runCy,IS_TRANSF,EFS2,YTIME));
i02ratioOwnEnergyTransfIS("FRA",IS_TRANSF,EFS,"%fBaseY%") = i02ratioOwnEnergyTransfIS("FRA",IS_TRANSF,EFS,"2016");