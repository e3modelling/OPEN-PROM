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

option iPop:2:0:6;
display iPop;
display imDisc;
display TF;
display TFIRST;
display runCy;
display iWgtSecAvgPriFueCons;
display imVarCostTech;

*'                *VARIABLE INITIALISATION*
*---
* Load common shared data
*execute_loadpoint 'common_data.gdx';
*---
imTransChar(runCy,"RES_MEXTF",YTIME) = 0.04;
imTransChar(runCy,"RES_MEXTV",YTIME) = 0.04;
*---
iDataPassCars(runCy,"PC","MEXTV") = 0.01;
*---
iFinEneConsPrevYear(runCy,EFS,YTIME)$(not An(YTIME)) = imFinEneCons(runCy,EFS,YTIME);

*'                **Interdependent Variables**

*---
VmRenValue.L(YTIME) = 1;
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
