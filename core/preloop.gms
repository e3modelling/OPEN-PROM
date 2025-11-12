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
file debug /debug.txt/;
put debug;
put "Number of variables: ", openprom.numvar:10:0 /;
put "Number of equations: ", openprom.numequ:10:0 /;
putclose debug;

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

*'                **Interdependent Variables**

*---
VmCstCO2SeqCsts.L(runCy,YTIME)=1;
VmCstCO2SeqCsts.FX(runCy,YTIME)$DATAY(YTIME) = i06ElastCO2Seq(runCy,"mc_b");
*---
VmPriceFuelSubsecCarVal.L(runCy,SBS,EF,YTIME)$SECtoEF(SBS,EF) = 1.5;
VmPriceFuelSubsecCarVal.L(runCy,"PG",PGEF,YTIME) = 1;
VmPriceFuelSubsecCarVal.LO(runCy,SBS,"H2F",YTIME) = 1E-6;
$IFTHEN %link2MAgPIE% == on 
VmPriceFuelSubsecCarVal.FX(runCy,SBS,"BMSWAS",YTIME)$(An(YTIME)) = iPricesMagpie(runCy,SBS,YTIME);
$ENDIF
VmPriceFuelSubsecCarVal.FX(runCy,SBS,EF,YTIME)$(SECtoEF(SBS,EF)$(not HEATPUMP(EF))$DATAY(YTIME)) = imFuelPrice(runCy,SBS,EF,YTIME);
VmPriceFuelSubsecCarVal.FX(runCy,SBS,ALTEF,YTIME)$(SECtoEF(SBS,ALTEF)$DATAY(YTIME)) = sum(EF$ALTMAP(SBS,ALTEF,EF),imFuelPrice(runCy,SBS,EF,YTIME));
* FIXME: VmPriceFuelSubsecCarVal (NUC/MET/ETH/BGDO) should be computed endogenously after startYear, and with mrprom before startYear
* author=giannou
VmPriceFuelSubsecCarVal.FX(runCy,"PG","NUC",YTIME) = 0.02; !! fixed price for nuclear fuel to 25Euro/toe
VmPriceFuelSubsecCarVal.FX(runCy,"H2P","NUC",YTIME) = 0.02; !! fixed price for nuclear fuel to 25Euro/toe
VmPriceFuelSubsecCarVal.FX(runCy,SBS,"MET",YTIME)$DATAY(YTIME) = 1; !! fixed price methanol
VmPriceFuelSubsecCarVal.FX(runCy,SBS,"ETH",YTIME)$DATAY(YTIME) = 1; !! fixed price for ethanol
VmPriceFuelSubsecCarVal.FX(runCy,SBS,"BGDO",YTIME)$DATAY(YTIME) = 0.5; !! fixed price for biodiesel
VmPriceFuelSubsecCarVal.FX(runCy,INDDOM,"HEATPUMP",YTIME)$(SECtoEF(INDDOM,"HEATPUMP")$DATAY(YTIME)) = imFuelPrice(runCy,INDDOM,"ELC",YTIME);
VmPriceFuelSubsecCarVal.FX(runCy,"H2P",EF,YTIME)$(SECtoEF("H2P",EF)$DATAY(YTIME)) = imFuelPrice(runCy,"OI",EF,YTIME);
VmPriceFuelSubsecCarVal.FX(runCy,"H2P",EF,YTIME)$(not SECtoEF("H2P",EF)) = 0;
*---
VmPriceElecInd.L(runCy,YTIME)= 0.9;
VmPriceElecInd.FX(runCy,YTIME)$TFIRST(YTIME) = i08ElecIndex(runCy,YTIME);
*---
openprom.optfile=1;
*---
openprom.scaleopt=1;
*---
