*' @title Prices Preloop
*' @code

*'                *VARIABLE INITIALISATION*
*---
V08PriceFuelSepCarbonWght.scale(runCy,DSBS,EF,YTIME)=1e-6;
Q08PriceFuelSepCarbonWght.scale(runCy,DSBS,EF,YTIME)=V08PriceFuelSepCarbonWght.scale(runCy,DSBS,EF,YTIME);
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
VmPriceElecIndResConsu.FX(runCy,"i",YTIME)$(not An(YTIME)) = VmPriceFuelSubsecCarVal.L(runCy,"OI","ELC",YTIME)*smTWhToMtoe;
VmPriceElecIndResConsu.FX(runCy,"r",YTIME)$(not An(YTIME)) = VmPriceFuelSubsecCarVal.L(runCy,"HOU","ELC",YTIME)*smTWhToMtoe;
VmPriceElecIndResConsu.FX(runCy,"t",YTIME)$(not An(YTIME)) = VmPriceFuelSubsecCarVal.L(runCy,"PC","ELC",YTIME)*smTWhToMtoe;
VmPriceElecIndResConsu.FX(runCy,"c",YTIME)$(not An(YTIME)) = VmPriceFuelSubsecCarVal.L(runCy,"SE","ELC",YTIME)*smTWhToMtoe;
*---
V08PriceFuelSepCarbonWght.L(runCy,DSBS,EF,YTIME) = 0.001;
V08PriceFuelSepCarbonWght.FX(runCy,DSBS,EF,YTIME)$(not AN(YTIME)) = i08WgtSecAvgPriFueCons(runCy,DSBS,EF) * VmPriceFuelSubsecCarVal.L(runCy,DSBS,EF,YTIME);
*---
VmPriceFuelAvgSub.L(runCy,DSBS,YTIME) = 0.001;
VmPriceFuelAvgSub.FX(runCy,DSBS,YTIME)$(not An(YTIME)) = sum(EF$SECtoEF(DSBS,EF), i08WgtSecAvgPriFueCons(runCy,DSBS,EF) * imFuelPrice(runCy,DSBS,EF,YTIME));
*---
V08FuelPriSubNoCarb.FX(runCy,SBS,EF,YTIME)$(SECtoEF(SBS,EF) $(not HEATPUMP(EF))  $(not An(YTIME))) = imFuelPrice(runCy,SBS,EF,YTIME);
V08FuelPriSubNoCarb.FX(runCy,SBS,ALTEF,YTIME)$(SECtoEF(SBS,ALTEF) $(not An(YTIME))) = sum(EF$ALTMAP(SBS,ALTEF,EF),imFuelPrice(runCy,SBS,EF,YTIME));
V08FuelPriSubNoCarb.FX(runCy,"PG","NUC",YTIME) = 0.025; !! fixed price for nuclear fuel to 25Euro/toe
V08FuelPriSubNoCarb.FX(runCy,INDDOM,"HEATPUMP",YTIME)$(SECtoEF(INDDOM,"HEATPUMP")$(not An(YTIME))) = imFuelPrice(runCy,INDDOM,"ELC",YTIME);
*---
VmPriceElecIndResNoCliPol.FX(runCy,"i",YTIME)$(not an(ytime)) = VmPriceFuelSubsecCarVal.L(runCy,"OI","ELC",YTIME) * smTWhToMtoe;
VmPriceElecIndResNoCliPol.FX(runCy,"r",YTIME)$(not an(ytime)) = VmPriceFuelSubsecCarVal.L(runCy,"HOU","ELC",YTIME) * smTWhToMtoe;
*---
VmPriceElecInd.L(runCy,YTIME)= 0.9;
VmPriceElecInd.FX(runCy,YTIME)$TFIRST(YTIME) = i08ElecIndex(runCy,YTIME);
*---
$ontext
VmPriceFuelSubsecCHP.FX(runCy,DSBS,EF,YTIME)$((not An(YTIME)) $(not TRANSE(DSBS))  $SECtoEF(DSBS,EF)) =
(((VmPriceFuelSubsecCarVal.L(runCy,DSBS,EF,YTIME)+imVarCostTech(runCy,DSBS,EF,YTIME)/1000)/imUsfEneConvSubTech(runCy,DSBS,EF,YTIME)- 
(0$(not CHP(EF)) + (VmPriceFuelSubsecCarVal.L(runCy,"OI","ELC",YTIME)*smFracElecPriChp*i08ElecIndex(runCy,"2010"))$CHP(EF))) + (0.003) + 
SQRT( SQR(((VmPriceFuelSubsecCarVal.L(runCy,DSBS,EF,YTIME)+imVarCostTech(runCy,DSBS,EF,YTIME)/1000)/imUsfEneConvSubTech(runCy,DSBS,EF,YTIME)- (0$(not CHP(EF)) + 
(VmPriceFuelSubsecCarVal.L(runCy,"OI","ELC",YTIME)*smFracElecPriChp*i08ElecIndex(runCy,"2010"))$CHP(EF)))-(0.003)) + SQR(1e-7) ) )/2;
*---
$offtext