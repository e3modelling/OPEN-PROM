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
VmPriceFuelSubsecCarVal.FX(runCy,SBS,EF,YTIME)$(SECtoEF(SBS,EF)$(not HEATPUMP(EF)) and DATAY(YTIME)) = imFuelPrice(runCy,SBS,EF,YTIME);
VmPriceFuelSubsecCarVal.FX(runCy,SBS,ALTEF,YTIME)$(SECtoEF(SBS,ALTEF)$(not An(YTIME))) = sum(EF$ALTMAP(SBS,ALTEF,EF),imFuelPrice(runCy,SBS,EF,YTIME));
* FIXME: VmPriceFuelSubsecCarVal (NUC/MET/ETH/BGDO) should be computed endogenously after startYear, and with mrprom before startYear
* author=giannou
VmPriceFuelSubsecCarVal.FX(runCy,"PG","NUC",YTIME) = 0.02; !! fixed price for nuclear fuel to 25Euro/toe
VmPriceFuelSubsecCarVal.FX(runCy,"H2P","NUC",YTIME) = 0.02; !! fixed price for nuclear fuel to 25Euro/toe
VmPriceFuelSubsecCarVal.FX(runCy,"STEAMP","NUC",YTIME) = 0.02; !! fixed price for nuclear fuel to 25Euro/toe
VmPriceFuelSubsecCarVal.FX(runCy,SBS,"MET",YTIME)$(not An(YTIME)) = 1; !! fixed price methanol
VmPriceFuelSubsecCarVal.FX(runCy,SBS,"ETH",YTIME)$(not An(YTIME)) = 1; !! fixed price for ethanol
VmPriceFuelSubsecCarVal.FX(runCy,SBS,"BGDO",YTIME)$DATAY(YTIME) = 0.5; !! fixed price for biodiesel
VmPriceFuelSubsecCarVal.FX(runCy,INDDOM,"HEATPUMP",YTIME)$(SECtoEF(INDDOM,"HEATPUMP")$(not An(YTIME))) = imFuelPrice(runCy,INDDOM,"ELC",YTIME);
VmPriceFuelSubsecCarVal.FX(runCy,"H2P",EF,YTIME)$(SECtoEF("H2P",EF)$DATAY(YTIME)) = imFuelPrice(runCy,"OI",EF,YTIME);
VmPriceFuelSubsecCarVal.FX(runCy,"STEAMP",EF,YTIME)$(SECtoEF("STEAMP",EF)$DATAY(YTIME)) = imFuelPrice(runCy,"PG",EF,YTIME);
VmPriceFuelSubsecCarVal.FX(runCy,"STEAMP","CRO",YTIME)$(not DATAY(YTIME)) = imFuelPrice(runCy,"PG","GDO","%fBaseY%") / 1.5;
VmPriceFuelSubsecCarVal.FX(runCy,SBS,"STE",YTIME)$(SECtoEF(SBS,"STE") and DATAY(YTIME)) = imFuelPrice(runCy,"OI","ELC",YTIME);
VmPriceFuelSubsecCarVal.FX(runCy,SBS,"GEO",YTIME) = 0;
*---
VmPriceElecInd.FX(runCy,YTIME)$DATAY(YTIME) = imPriceElecInd(runCy,YTIME);
*---
VmLft.L(runCy,DSBS,TTECH,YTIME) = 10;
VmLft.FX(runCy,"PC",TTECH,YTIME)$(DATAY(YTIME) and SECTTECH("PC",TTECH)) = i01TechLft(runCy,"PC",TTECH,YTIME);
VmLft.FX(runCy,DSBS,TECH,YTIME)$(SECTTECH(DSBS,TECH) and (not sameas(DSBS,"PC"))) = i01TechLft(runCy,DSBS,TECH,YTIME);
VmLft.FX(runCy,DSBS,TECH,YTIME)$(not SECTTECH(DSBS,TECH)) = 0;
*---
openprom.optfile=1;
*---
openprom.scaleopt=1;
*---
