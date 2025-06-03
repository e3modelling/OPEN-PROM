*' @title Preloop
*' @code
*' * Calculation of polynomial distribution lags coefficients
iNPDL(DSBS) = 6;
loop DSBS do
   loop KPDL$(ord(KPDL) le iNPDL(DSBS)) do
         iMFPDL(DSBS,KPDL) = 6 * (iNPDL(DSBS)+1-ord(KPDL)) * ord(KPDL)
                           /
                           (iNPDL(DSBS) * (iNPDL(DSBS)+1) * (iNPDL(DSBS)+2))
   endloop;
endloop;

model openprom / all /;

option iPop:2:0:6;
display iPop;
display iDisc;
display TF;
display TFIRST;
display runCy;
display iWgtSecAvgPriFueCons;
display iMVarCostTech;

*'                *VARIABLE INITIALISATION*
*---
* Load common shared data
*execute_loadpoint 'common_data.gdx';
*---
iTransChar(runCy,"RES_MEXTF",YTIME) = 0.04;
iTransChar(runCy,"RES_MEXTV",YTIME) = 0.04;
*---
iDataPassCars(runCy,"PC","MEXTV") = 0.01;
*---
iFinEneConsPrevYear(runCy,EFS,YTIME)$(not An(YTIME)) = iMFinEneCons(runCy,EFS,YTIME);

*'                **Interdependent Variables**

*---
VMRenValue.L(YTIME) = 1;
VMRenValue.FX(YTIME) = 0 ;
*---
VMElecConsHeatPla.FX(runCy,INDDOM,YTIME)$(not An(YTIME)) = iMFuelConsPerFueSub(runCy,INDDOM,"ELC",YTIME)*(1-iMShrNonSubElecInTotElecDem(runCy,INDDOM))*iShrHeatPumpElecCons(runCy,INDDOM);
* Compute electricity consumed in heatpump plants, QElecConsHeatPla(runCy,INDDOM,YTIME)$time(ytime).
VMElecConsHeatPla.FX(runCy,INDDOM,YTIME) = 1E-7;
*---
VMCarVal.FX(runCy,"TRADE",YTIME) = iCarbValYrExog(runCy,YTIME);
VMCarVal.FX(runCy,"NOTRADE",YTIME) = iCarbValYrExog(runCy,YTIME);
*---
openprom.optfile=1;
*---
openprom.scaleopt=1;
*---
