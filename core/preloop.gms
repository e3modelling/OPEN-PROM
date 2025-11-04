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

*'                **Interdependent Variables**

*---
VmRenValue.FX(YTIME)$(ord(YTIME)<20) = 0 ;
VmRenValue.FX(YTIME)$(ord(YTIME)>=20 and ord(YTIME)<50) = (ord(YTIME)-20) * 100;
VmRenValue.FX(YTIME)$(ord(YTIME)>=40) = 2000;
*VmRenValue.FX(YTIME)$(not AN(YTIME)) = 0 ;
*VmRenValue.FX(YTIME)$(AN(YTIME)) = 0 ;
*---
VmElecConsHeatPla.FX(runCy,INDDOM,YTIME)$(not An(YTIME)) = imFuelConsPerFueSub(runCy,INDDOM,"ELC",YTIME)*(1-imShrNonSubElecInTotElecDem(runCy,INDDOM))*iShrHeatPumpElecCons(runCy,INDDOM);
* Compute electricity consumed in heatpump plants, QElecConsHeatPla(runCy,INDDOM,YTIME)$time(ytime).
VmElecConsHeatPla.FX(runCy,INDDOM,YTIME) = 1E-7;
*---
VmCarVal.FX(runCy,"TRADE",YTIME) = iCarbValYrExog(runCy,YTIME);
VmCarVal.FX(runCy,"NOTRADE",YTIME) = iCarbValYrExog(runCy,YTIME);

*---
VmCstCO2SeqCsts.L(runCy,YTIME)=1;
VmCstCO2SeqCsts.FX(runCy,YTIME)$(not an(YTIME)) = i06ElastCO2Seq(runCy,"mc_b");
*---
VmPriceFuelSubsecCarVal.L(runCy,SBS,EF,YTIME)$SECtoEF(SBS,EF) = 1.5;
VmPriceFuelSubsecCarVal.L(runCy,"PG",PGEF,YTIME) = 1;
VmPriceFuelSubsecCarVal.LO(runCy,SBS,"H2F",YTIME) = 1E-6;
$IFTHEN %link2MAgPIE% == on 
VmPriceFuelSubsecCarVal.FX(runCy,SBS,"BMSWAS",YTIME)$(An(YTIME)) = iPricesMagpie(runCy,SBS,YTIME);
$ENDIF
VmPriceFuelSubsecCarVal.FX(runCy,SBS,EF,YTIME)$(SECtoEF(SBS,EF)$(not HEATPUMP(EF))$(not An(YTIME))) = imFuelPrice(runCy,SBS,EF,YTIME);
VmPriceFuelSubsecCarVal.FX(runCy,SBS,ALTEF,YTIME)$(SECtoEF(SBS,ALTEF)$(not An(YTIME))) = sum(EF$ALTMAP(SBS,ALTEF,EF),imFuelPrice(runCy,SBS,EF,YTIME));
* FIXME: VmPriceFuelSubsecCarVal (NUC/MET/ETH/BGDO) should be computed endogenously after startYear, and with mrprom before startYear
* author=giannou
VmPriceFuelSubsecCarVal.FX(runCy,"PG","NUC",YTIME) = 0.02; !! fixed price for nuclear fuel to 25Euro/toe
VmPriceFuelSubsecCarVal.FX(runCy,"H2P","NUC",YTIME) = 0.02; !! fixed price for nuclear fuel to 25Euro/toe
VmPriceFuelSubsecCarVal.FX(runCy,SBS,"MET",YTIME)$(not An(YTIME)) = 1; !! fixed price methanol
VmPriceFuelSubsecCarVal.FX(runCy,SBS,"ETH",YTIME)$(not An(YTIME)) = 1; !! fixed price for ethanol
VmPriceFuelSubsecCarVal.FX(runCy,SBS,"BGDO",YTIME)$(not An(YTIME)) = 0.5; !! fixed price for biodiesel
VmPriceFuelSubsecCarVal.FX(runCy,INDDOM,"HEATPUMP",YTIME)$(SECtoEF(INDDOM,"HEATPUMP")$(not An(YTIME))) = imFuelPrice(runCy,INDDOM,"ELC",YTIME);
VmPriceFuelSubsecCarVal.FX(runCy,"H2P",EF,YTIME)$(SECtoEF("H2P",EF)$(not An(YTIME))) = VmPriceFuelSubsecCarVal.L(runCy,"PG",EF,YTIME);
VmPriceFuelSubsecCarVal.FX(runCy,"H2P","ELC",YTIME)$(not An(YTIME))= VmPriceFuelSubsecCarVal.L(runCy,"OI","ELC",YTIME);
*---
VmPriceElecInd.FX(runCy,YTIME)$DATAY(YTIME) = 
[
  SUM(EF,i04DataElecProdCHP(runCy,EF,YTIME)) / 1000 * smTWhToMtoe /
  i03OutCHPTransfProcess(runCy,"STE",YTIME)
]$i03OutCHPTransfProcess(runCy,"STE",YTIME);
*---
openprom.optfile=1;
*---
openprom.scaleopt=1;
*---
