*' Clear variables and equations (outside country loop — preserves no bounds for next year)
option clear = V08PriceFuelSepCarbonWght;
option clear = VmPriceFuelSubsecCarVal;
option clear = VmPriceFuelAvgSub;
option clear = VmPriceElecInd;
option clear = V08IndexBioSupply;
option clear = Q08PriceFuelSepCarbonWght;
option clear = Q08PriceFuelSubsecCarVal;
option clear = Q08PriceFuelAvgSub;
option clear = Q08PriceElecInd;

*' Re-apply critical bounds for all active countries (outside country loop)
VmPriceFuelSubsecCarVal.FX(runCyL,SBS,"ELC",YTIME)$(
  SECtoEF(SBS,"ELC") and pmPriceFuelSubsecCarVal(runCyL,SBS,"ELC",YTIME) > 1e-4
) =
  pmPriceFuelSubsecCarVal(runCyL,SBS,"ELC",YTIME);
V08PriceFuelSepCarbonWght.LO(runCyL,DSBS,EF,YTIME+1) = 0;
VmPriceFuelSubsecCarVal.LO(runCyL,SBS,EF,YTIME+1) = 0;
VmPriceFuelAvgSub.LO(runCyL,DSBS,YTIME+1) = 0;
V08IndexBioSupply.LO(runCy,YTIME) = 0;
V08IndexBioSupply.L(runCy,YTIME)  = 1;

*' Initialize variable levels from previous period parameter
V08PriceFuelSepCarbonWght.L(runCyL,DSBS,EF,YTIME+1) = p08PriceFuelSepCarbonWght(runCyL,DSBS,EF,YTIME);
VmPriceFuelSubsecCarVal.L(runCyL,SBS,EF,YTIME+1) = pmPriceFuelSubsecCarVal(runCyL,SBS,EF,YTIME);
VmPriceFuelSubsecCarVal.L(runCyL,SBS,"ELC",YTIME+1)$(
  SECtoEF(SBS,"ELC") and pmCostPowGenAvgLng(runCyL,YTIME) and pmCostPowGenAvgLng(runCyL,YTIME-1)
) =
  pmPriceFuelSubsecCarVal(runCyL,SBS,"ELC",YTIME) *
  pmCostPowGenAvgLng(runCyL,YTIME) / pmCostPowGenAvgLng(runCyL,YTIME-1);
VmPriceFuelSubsecCarVal.LO(runCyL,SBS,"ELC",YTIME+1)$SECtoEF(SBS,"ELC") =
  epsilon6;
VmPriceFuelAvgSub.L(runCyL,DSBS,YTIME+1) = pmPriceFuelAvgSub(runCyL,DSBS,YTIME);
VmPriceElecInd.L(runCyL,TCHP,YTIME+1) = pmPriceElecInd(runCyL,TCHP,YTIME);
V08IndexBioSupply.L(runCyL,YTIME+1) = p08IndexBioSupply(runCyL,YTIME);

*' Restore fixed prices lost by option clear. Keep this after the broad .LO/.L
*' reapply so fixed bounds win for the next solve year.
$IFTHEN %softLinkMAgPIE% == on
VmPriceFuelSubsecCarVal.FX(runCyL,SBS,"BMSWAS",YTIME+1)$(An(YTIME+1)) = iPricesMagpie(runCyL,SBS,YTIME+1);
$ENDIF
VmPriceFuelSubsecCarVal.FX(runCyL,SBS,EF,YTIME+1)$(
  SECtoEF(SBS,EF) and not sameas("NUC",EF) and DATAY(YTIME+1)
) = imFuelPrice(runCyL,SBS,EF,YTIME+1);
VmPriceFuelSubsecCarVal.FX(runCyL,SBS,"NUC",YTIME+1)$SECtoEF(SBS,"NUC") = 0.2;
VmPriceFuelSubsecCarVal.FX(runCyL,SBS,"SOL",YTIME+1) = 0;
VmPriceFuelSubsecCarVal.FX(runCyL,SBS,"GEO",YTIME+1) = 0;
VmPriceFuelSubsecCarVal.FX(runCyL,SBS,"MET",YTIME+1)$(DATAY(YTIME+1) and SECtoEF(SBS,"MET")) = 1;
VmPriceFuelSubsecCarVal.FX(runCyL,SBS,"ETH",YTIME+1)$(DATAY(YTIME+1) and SECtoEF(SBS,"ETH")) = 1;
VmPriceFuelSubsecCarVal.FX(runCyL,"H2P",EF,YTIME+1)$(SECtoEF("H2P",EF) and DATAY(YTIME+1)) = imFuelPrice(runCyL,"OI",EF,YTIME+1);
VmPriceFuelSubsecCarVal.FX(runCyL,"STEAMP",EF,YTIME+1)$(SECtoEF("STEAMP",EF) and DATAY(YTIME+1)) = imFuelPrice(runCyL,"PG",EF,YTIME+1);
VmPriceFuelSubsecCarVal.FX(runCyL,SBS,"CRO",YTIME+1) = imFuelPrice(runCyL,SBS,"CRO",YTIME+1);
VmPriceFuelSubsecCarVal.FX(runCyL,SBS,"STE",YTIME+1)$(SECtoEF(SBS,"STE") and DATAY(YTIME+1)) = imFuelPrice(runCyL,"OI","ELC",YTIME+1);
