*' @title Prices Preloop
*' @code

*'                *VARIABLE INITIALISATION*
*---
V08PriceFuelSepCarbonWght.scale(runCy,DSBS,EF,YTIME)=1e-6;
Q08PriceFuelSepCarbonWght.scale(runCy,DSBS,EF,YTIME)=V08PriceFuelSepCarbonWght.scale(runCy,DSBS,EF,YTIME);
*---
VmPriceFuelSubsecCarVal.L(runCy,SBS,EF,YTIME) = 1.5;
VmPriceFuelSubsecCarVal.L(runCy,"PG",PGEF,YTIME) = 1;
VmPriceFuelSubsecCarVal.LO(runCy,SBS,"H2F",YTIME) = 1E-6;
$IFTHEN %link2MAgPIE% == on 
VmPriceFuelSubsecCarVal.FX(runCy,SBS,"BMSWAS",YTIME)$(An(YTIME)) = iPricesMagpie(runCy,SBS,YTIME);
$ENDIF
VmPriceFuelSubsecCarVal.FX(runCy,SBS,EF,YTIME)$(SECTTECH(SBS,EF)$(not HEATPUMP(EF))$(not An(YTIME))) = imFuelPrice(runCy,SBS,EF,YTIME);
VmPriceFuelSubsecCarVal.FX(runCy,SBS,ALTEF,YTIME)$(SECTTECH(SBS,ALTEF)$(not An(YTIME))) = sum(EF$ALTMAP(SBS,ALTEF,EF),imFuelPrice(runCy,SBS,EF,YTIME));
* FIXME: VmPriceFuelSubsecCarVal (NUC/MET/ETH/BGDO) should be computed endogenously after startYear, and with mrprom before startYear
* author=giannou
VmPriceFuelSubsecCarVal.FX(runCy,"PG","NUC",YTIME) = 0.025; !! fixed price for nuclear fuel to 25Euro/toe
VmPriceFuelSubsecCarVal.FX(runCy,"H2P","NUC",YTIME) = 0.025; !! fixed price for nuclear fuel to 25Euro/toe
VmPriceFuelSubsecCarVal.FX(runCy,SBS,"MET",YTIME)$(not An(YTIME)) = 800; !! fixed price methanol
VmPriceFuelSubsecCarVal.FX(runCy,SBS,"ETH",YTIME)$(not An(YTIME)) = 800; !! fixed price for ethanol
VmPriceFuelSubsecCarVal.FX(runCy,SBS,"BGDO",YTIME)$(not An(YTIME)) = 350; !! fixed price for biodiesel
VmPriceFuelSubsecCarVal.FX(runCy,INDDOM,"HEATPUMP",YTIME)$(SECTTECH(INDDOM,"HEATPUMP")$(not An(YTIME))) = imFuelPrice(runCy,INDDOM,"ELC",YTIME);
VmPriceFuelSubsecCarVal.FX(runCy,"H2P",EF,YTIME)$(SECTTECH("H2P",EF)$(not An(YTIME))) = VmPriceFuelSubsecCarVal.L(runCy,"PG",EF,YTIME);
VmPriceFuelSubsecCarVal.FX(runCy,"H2P","ELC",YTIME)$(not An(YTIME))= VmPriceFuelSubsecCarVal.L(runCy,"OI","ELC",YTIME);
*---
VmPriceElecIndResConsu.FX(runCy,"i",YTIME)$(not An(YTIME)) = VmPriceFuelSubsecCarVal.L(runCy,"OI","ELC",YTIME)*smTWhToMtoe;
VmPriceElecIndResConsu.FX(runCy,"r",YTIME)$(not An(YTIME)) = VmPriceFuelSubsecCarVal.L(runCy,"HOU","ELC",YTIME)*smTWhToMtoe;
*---
VmPriceFuelAvgSub.L(runCy,DSBS,YTIME) = 0.1;
VmPriceFuelAvgSub.FX(runCy,DSBS,YTIME)$(not An(YTIME)) = sum(EF$SECTTECH(DSBS,EF), i08WgtSecAvgPriFueCons(runCy,DSBS,EF) * imFuelPrice(runCy,DSBS,EF,YTIME));
*---
V08FuelPriSubNoCarb.FX(runCy,SBS,EF,YTIME)$(SECTTECH(SBS,EF) $(not HEATPUMP(EF))  $(not An(YTIME))) = imFuelPrice(runCy,SBS,EF,YTIME);
V08FuelPriSubNoCarb.FX(runCy,SBS,ALTEF,YTIME)$(SECTTECH(SBS,ALTEF) $(not An(YTIME))) = sum(EF$ALTMAP(SBS,ALTEF,EF),imFuelPrice(runCy,SBS,EF,YTIME));
V08FuelPriSubNoCarb.FX(runCy,"PG","NUC",YTIME) = 0.025; !! fixed price for nuclear fuel to 25Euro/toe
V08FuelPriSubNoCarb.FX(runCy,INDDOM,"HEATPUMP",YTIME)$(SECTTECH(INDDOM,"HEATPUMP")$(not An(YTIME))) = imFuelPrice(runCy,INDDOM,"ELC",YTIME);
*---
VmPriceElecIndResNoCliPol.FX(runCy,"i",YTIME)$(not an(ytime)) = VmPriceFuelSubsecCarVal.L(runCy,"OI","ELC",YTIME)*0.086;
VmPriceElecIndResNoCliPol.FX(runCy,"r",YTIME)$(not an(ytime)) = VmPriceFuelSubsecCarVal.L(runCy,"HOU","ELC",YTIME)*0.086;
*---
VmPriceElecInd.L(runCy,YTIME)= 0.9;
VmPriceElecInd.FX(runCy,YTIME)$TFIRST(YTIME) = i08ElecIndex(runCy,YTIME);
*---
VmPriceFuelSubsecCHP.FX(runCy,DSBS,EF,YTIME)$((not An(YTIME)) $(not TRANSE(DSBS))  $SECTTECH(DSBS,EF)) =
(((VmPriceFuelSubsecCarVal.L(runCy,DSBS,EF,YTIME)+imVarCostTech(runCy,DSBS,EF,YTIME)/1000)/imUsfEneConvSubTech(runCy,DSBS,EF,YTIME)- 
(0$(not CHP(EF)) + (VmPriceFuelSubsecCarVal.L(runCy,"OI","ELC",YTIME)*smFracElecPriChp*i08ElecIndex(runCy,"2010"))$CHP(EF))) + (0.003) + 
SQRT( SQR(((VmPriceFuelSubsecCarVal.L(runCy,DSBS,EF,YTIME)+imVarCostTech(runCy,DSBS,EF,YTIME)/1000)/imUsfEneConvSubTech(runCy,DSBS,EF,YTIME)- (0$(not CHP(EF)) + 
(VmPriceFuelSubsecCarVal.L(runCy,"OI","ELC",YTIME)*smFracElecPriChp*i08ElecIndex(runCy,"2010"))$CHP(EF)))-(0.003)) + SQR(1e-7) ) )/2;
*---