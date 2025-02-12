*' @title Preloop
*' @code
*' * Calculation of polynomial distribution lags coefficients
iNPDL(DSBS) = 6;
loop DSBS do
   loop KPDL$(ord(KPDL) le iNPDL(DSBS)) do
         iFPDL(DSBS,KPDL) = 6 * (iNPDL(DSBS)+1-ord(KPDL)) * ord(KPDL)
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
display iVarCostTech;

*'                *VARIABLE INITIALISATION*
*---
* Load common shared data
*execute_loadpoint 'common_data.gdx';
*---
iPassCarsMarkSat(runCy) = 0.7; 
*---
iTransChar(runCy,"RES_MEXTF",YTIME) = 0.04;
iTransChar(runCy,"RES_MEXTV",YTIME) = 0.04;
*---
iDataPassCars(runCy,"PC","MEXTV") = 0.01;
*---
iFinEneConsPrevYear(runCy,EFS,YTIME)$(not An(YTIME)) = iFinEneCons(runCy,EFS,YTIME);

*'                **Interdependent Variables**

*---
VRenValue.l(YTIME)=1;
VRenValue.FX(YTIME) = 0 ;
*---
VCarVal.FX(runCy,"TRADE",YTIME) = sExogCarbValue*iCarbValYrExog(runCy,YTIME);
VCarVal.FX(runCy,"NOTRADE",YTIME) =sExogCarbValue*iCarbValYrExog(runCy,YTIME);
*---
openprom.optfile=1;
*---
openprom.scaleopt=1;
*---
