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