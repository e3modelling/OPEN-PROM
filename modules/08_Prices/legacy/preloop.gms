*' @title Prices Preloop
*' @code

*'                *VARIABLE INITIALISATION*
*---
VPriceFuelSepCarbonWght.scale(runCy,DSBS,EF,YTIME)=1e-6;
QPriceFuelSepCarbonWght.scale(runCy,DSBS,EF,YTIME)=VPriceFuelSepCarbonWght.scale(runCy,DSBS,EF,YTIME);
*---
VPriceFuelSubsecCarVal.L(runCy,SBS,EF,YTIME) = 1.5;
VPriceFuelSubsecCarVal.L(runCy,"PG",PGEF,YTIME)=1;
VPriceFuelSubsecCarVal.FX(runCy,SBS,EF,YTIME)$(SECTTECH(SBS,EF)$(not HEATPUMP(EF))$(not An(YTIME))) = iFuelPrice(runCy,SBS,EF,YTIME);
VPriceFuelSubsecCarVal.FX(runCy,SBS,ALTEF,YTIME)$(SECTTECH(SBS,ALTEF)$(not An(YTIME))) = sum(EF$ALTMAP(SBS,ALTEF,EF),iFuelPrice(runCy,SBS,EF,YTIME));
* FIXME: VPriceFuelSubsecCarVal (NUC/MET/ETH/BGDO) should be computed endogenously after startYear, and with mrprom before startYear
* author=giannou
VPriceFuelSubsecCarVal.FX(runCy,"PG","NUC",YTIME) = 0.025; !! fixed price for nuclear fuel to 25Euro/toe
VPriceFuelSubsecCarVal.FX(runCy,"H2P","NUC",YTIME) = 0.025; !! fixed price for nuclear fuel to 25Euro/toe
VPriceFuelSubsecCarVal.FX(runCy,SBS,"MET",YTIME)$(not An(YTIME)) = 800; !! fixed price methanol
VPriceFuelSubsecCarVal.FX(runCy,SBS,"ETH",YTIME)$(not An(YTIME)) = 800; !! fixed price for ethanol
VPriceFuelSubsecCarVal.FX(runCy,SBS,"BGDO",YTIME)$(not An(YTIME)) = 350; !! fixed price for biodiesel
VPriceFuelSubsecCarVal.FX(runCy,INDDOM,"HEATPUMP",YTIME)$(SECTTECH(INDDOM,"HEATPUMP")$(not An(YTIME))) = iFuelPrice(runCy,INDDOM,"ELC",YTIME);
VPriceFuelSubsecCarVal.FX(runCy,"H2P",EF,YTIME)$(SECTTECH("H2P",EF)$(not An(YTIME))) = VPriceFuelSubsecCarVal.L(runCy,"PG",EF,YTIME);
VPriceFuelSubsecCarVal.FX(runCy,"H2P","ELC",YTIME)$(not An(YTIME))= VPriceFuelSubsecCarVal.L(runCy,"OI","ELC",YTIME);
*---
VPriceElecIndResConsu.FX(runCy,"i",YTIME)$(not An(YTIME)) = VPriceFuelSubsecCarVal.L(runCy,"OI","ELC",YTIME)*sTWhToMtoe;
VPriceElecIndResConsu.FX(runCy,"r",YTIME)$(not An(YTIME)) = VPriceFuelSubsecCarVal.L(runCy,"HOU","ELC",YTIME)*sTWhToMtoe;
*---
VPriceFuelAvgSub.L(runCy,DSBS,YTIME) = 0.1;
VPriceFuelAvgSub.FX(runCy,DSBS,YTIME)$(not An(YTIME)) = sum(EF$SECTTECH(DSBS,EF), iWgtSecAvgPriFueCons(runCy,DSBS,EF) * iFuelPrice(runCy,DSBS,EF,YTIME));
*---
VFuelPriSubNoCarb.FX(runCy,SBS,EF,YTIME)$(SECTTECH(SBS,EF) $(not HEATPUMP(EF))  $(not An(YTIME))) = iFuelPrice(runCy,SBS,EF,YTIME);
VFuelPriSubNoCarb.FX(runCy,SBS,ALTEF,YTIME)$(SECTTECH(SBS,ALTEF) $(not An(YTIME))) = sum(EF$ALTMAP(SBS,ALTEF,EF),iFuelPrice(runCy,SBS,EF,YTIME));
VFuelPriSubNoCarb.FX(runCy,"PG","NUC",YTIME) = 0.025; !! fixed price for nuclear fuel to 25Euro/toe
VFuelPriSubNoCarb.FX(runCy,INDDOM,"HEATPUMP",YTIME)$(SECTTECH(INDDOM,"HEATPUMP")$(not An(YTIME))) = iFuelPrice(runCy,INDDOM,"ELC",YTIME);
*---
VPriceElecIndResNoCliPol.FX(runCy,"i",YTIME)$(not an(ytime)) = VPriceFuelSubsecCarVal.L(runCy,"OI","ELC",YTIME)*0.086;
VPriceElecIndResNoCliPol.FX(runCy,"r",YTIME)$(not an(ytime)) = VPriceFuelSubsecCarVal.L(runCy,"HOU","ELC",YTIME)*0.086;
*---
VPriceElecInd.L(runCy,YTIME)= 0.9;
VPriceElecInd.FX(runCy,YTIME)$TFIRST(YTIME) = iElecIndex(runCy,YTIME);
*---
VPriceFuelSubsecCHP.FX(runCy,DSBS,EF,YTIME)$((not An(YTIME)) $(not TRANSE(DSBS))  $SECTTECH(DSBS,EF)) =
(((VPriceFuelSubsecCarVal.L(runCy,DSBS,EF,YTIME)+iVarCostTech(runCy,DSBS,EF,YTIME)/1000)/iUsfEneConvSubTech(runCy,DSBS,EF,YTIME)- 
(0$(not CHP(EF)) + (VPriceFuelSubsecCarVal.L(runCy,"OI","ELC",YTIME)*sFracElecPriChp*iElecIndex(runCy,"2010"))$CHP(EF))) + (0.003) + 
SQRT( SQR(((VPriceFuelSubsecCarVal.L(runCy,DSBS,EF,YTIME)+iVarCostTech(runCy,DSBS,EF,YTIME)/1000)/iUsfEneConvSubTech(runCy,DSBS,EF,YTIME)- (0$(not CHP(EF)) + 
(VPriceFuelSubsecCarVal.L(runCy,"OI","ELC",YTIME)*sFracElecPriChp*iElecIndex(runCy,"2010"))$CHP(EF)))-(0.003)) + SQR(1e-7) ) )/2;
*---