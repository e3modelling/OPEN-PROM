*' @title Preloop
*' @code
*' * Calculation of polynomial distribution lags coefficients
iNPDL(DSBS) = 6;
loop DSBS do
   loop KPDL$(ord(KPDL) le iNPDL(DSBS)) do
         imFPDL(DSBS,KPDL) = 6 * (iNPDL(DSBS)+1-ord(KPDL)) * ord(KPDL)
                           /
                           (iNPDL(DSBS) * (iNPDL(DSBS)+1) * (iNPDL(DSBS)+2))
   endloop;
endloop;

model openprom / all /;

option i01Pop:2:0:6;
display i01Pop;
display imDisc;
display TF;
display TFIRST;
display runCy;
display i08WgtSecAvgPriFueCons;
display imVarCostTech;

*'                *VARIABLE INITIALISATION*

*---
imTransChar(runCy,"RES_MEXTF",YTIME) = 0.04;
imTransChar(runCy,"RES_MEXTV",YTIME) = 0.04;
*---
iFinEneConsPrevYear(runCy,EFS,YTIME)$(not An(YTIME)) = imFinEneCons(runCy,EFS,YTIME);
*---

*'                **Interdependent Variables**

*---
VmRenValue.FX(YTIME) = 0 ;
*---
VmElecConsHeatPla.FX(runCy,INDDOM,YTIME)$(not An(YTIME)) = imFuelConsPerFueSub(runCy,INDDOM,"ELC",YTIME)*(1-imShrNonSubElecInTotElecDem(runCy,INDDOM))*iShrHeatPumpElecCons(runCy,INDDOM);
* Compute electricity consumed in heatpump plants, QElecConsHeatPla(runCy,INDDOM,YTIME)$time(ytime).
VmElecConsHeatPla.FX(runCy,INDDOM,YTIME) = 1E-7;
*---
VmCarVal.FX(runCy,"TRADE",YTIME) = iCarbValYrExog(runCy,YTIME);
VmCarVal.FX(runCy,"NOTRADE",YTIME) = iCarbValYrExog(runCy,YTIME);
*---
openprom.optfile=1;
*---
openprom.scaleopt=1;
*---
