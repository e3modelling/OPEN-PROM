*' @title Prices Preloop
*' @code

*'                *VARIABLE INITIALISATION*
*---
V08PriceFuelSepCarbonWght.scale(runCy,DSBS,EF,YTIME)=1e-6;
Q08PriceFuelSepCarbonWght.scale(runCy,DSBS,EF,YTIME)=V08PriceFuelSepCarbonWght.scale(runCy,DSBS,EF,YTIME);
*---
VMPriceFuelSubsecCarVal.L(runCy,SBS,EF,YTIME) = 1.5;
VMPriceFuelSubsecCarVal.L(runCy,"PG",PGEF,YTIME)=1;
VMPriceFuelSubsecCarVal.FX(runCy,SBS,EF,YTIME)$(SECTTECH(SBS,EF)$(not HEATPUMP(EF))$(not An(YTIME))) = iFuelPrice(runCy,SBS,EF,YTIME);
VMPriceFuelSubsecCarVal.FX(runCy,SBS,ALTEF,YTIME)$(SECTTECH(SBS,ALTEF)$(not An(YTIME))) = sum(EF$ALTMAP(SBS,ALTEF,EF),iFuelPrice(runCy,SBS,EF,YTIME));
* FIXME: VMPriceFuelSubsecCarVal (NUC/MET/ETH/BGDO) should be computed endogenously after startYear, and with mrprom before startYear
* author=giannou
VMPriceFuelSubsecCarVal.FX(runCy,"PG","NUC",YTIME) = 0.025; !! fixed price for nuclear fuel to 25Euro/toe
VMPriceFuelSubsecCarVal.FX(runCy,"H2P","NUC",YTIME) = 0.025; !! fixed price for nuclear fuel to 25Euro/toe
VMPriceFuelSubsecCarVal.FX(runCy,SBS,"MET",YTIME)$(not An(YTIME)) = 800; !! fixed price methanol
VMPriceFuelSubsecCarVal.FX(runCy,SBS,"ETH",YTIME)$(not An(YTIME)) = 800; !! fixed price for ethanol
VMPriceFuelSubsecCarVal.FX(runCy,SBS,"BGDO",YTIME)$(not An(YTIME)) = 350; !! fixed price for biodiesel
VMPriceFuelSubsecCarVal.FX(runCy,INDDOM,"HEATPUMP",YTIME)$(SECTTECH(INDDOM,"HEATPUMP")$(not An(YTIME))) = iFuelPrice(runCy,INDDOM,"ELC",YTIME);
VMPriceFuelSubsecCarVal.FX(runCy,"H2P",EF,YTIME)$(SECTTECH("H2P",EF)$(not An(YTIME))) = VMPriceFuelSubsecCarVal.L(runCy,"PG",EF,YTIME);
VMPriceFuelSubsecCarVal.FX(runCy,"H2P","ELC",YTIME)$(not An(YTIME))= VMPriceFuelSubsecCarVal.L(runCy,"OI","ELC",YTIME);
*---
VMPriceElecIndResConsu.FX(runCy,"i",YTIME)$(not An(YTIME)) = VMPriceFuelSubsecCarVal.L(runCy,"OI","ELC",YTIME)*sMTWhToMtoe;
VMPriceElecIndResConsu.FX(runCy,"r",YTIME)$(not An(YTIME)) = VMPriceFuelSubsecCarVal.L(runCy,"HOU","ELC",YTIME)*sMTWhToMtoe;
*---
VMPriceFuelAvgSub.L(runCy,DSBS,YTIME) = 0.1;
VMPriceFuelAvgSub.FX(runCy,DSBS,YTIME)$(not An(YTIME)) = sum(EF$SECTTECH(DSBS,EF), iWgtSecAvgPriFueCons(runCy,DSBS,EF) * iFuelPrice(runCy,DSBS,EF,YTIME));
*---
V08FuelPriSubNoCarb.FX(runCy,SBS,EF,YTIME)$(SECTTECH(SBS,EF) $(not HEATPUMP(EF))  $(not An(YTIME))) = iFuelPrice(runCy,SBS,EF,YTIME);
V08FuelPriSubNoCarb.FX(runCy,SBS,ALTEF,YTIME)$(SECTTECH(SBS,ALTEF) $(not An(YTIME))) = sum(EF$ALTMAP(SBS,ALTEF,EF),iFuelPrice(runCy,SBS,EF,YTIME));
V08FuelPriSubNoCarb.FX(runCy,"PG","NUC",YTIME) = 0.025; !! fixed price for nuclear fuel to 25Euro/toe
V08FuelPriSubNoCarb.FX(runCy,INDDOM,"HEATPUMP",YTIME)$(SECTTECH(INDDOM,"HEATPUMP")$(not An(YTIME))) = iFuelPrice(runCy,INDDOM,"ELC",YTIME);
*---
VMPriceElecIndResNoCliPol.FX(runCy,"i",YTIME)$(not an(ytime)) = VMPriceFuelSubsecCarVal.L(runCy,"OI","ELC",YTIME)*0.086;
VMPriceElecIndResNoCliPol.FX(runCy,"r",YTIME)$(not an(ytime)) = VMPriceFuelSubsecCarVal.L(runCy,"HOU","ELC",YTIME)*0.086;
*---
VMPriceElecInd.L(runCy,YTIME)= 0.9;
VMPriceElecInd.FX(runCy,YTIME)$TFIRST(YTIME) = iElecIndex(runCy,YTIME);
*---
VMPriceFuelSubsecCHP.FX(runCy,DSBS,EF,YTIME)$((not An(YTIME)) $(not TRANSE(DSBS))  $SECTTECH(DSBS,EF)) =
(((VMPriceFuelSubsecCarVal.L(runCy,DSBS,EF,YTIME)+iMVarCostTech(runCy,DSBS,EF,YTIME)/1000)/iMUsfEneConvSubTech(runCy,DSBS,EF,YTIME)- 
(0$(not CHP(EF)) + (VMPriceFuelSubsecCarVal.L(runCy,"OI","ELC",YTIME)*sMFracElecPriChp*iElecIndex(runCy,"2010"))$CHP(EF))) + (0.003) + 
SQRT( SQR(((VMPriceFuelSubsecCarVal.L(runCy,DSBS,EF,YTIME)+iMVarCostTech(runCy,DSBS,EF,YTIME)/1000)/iMUsfEneConvSubTech(runCy,DSBS,EF,YTIME)- (0$(not CHP(EF)) + 
(VMPriceFuelSubsecCarVal.L(runCy,"OI","ELC",YTIME)*sMFracElecPriChp*iElecIndex(runCy,"2010"))$CHP(EF)))-(0.003)) + SQR(1e-7) ) )/2;
*---