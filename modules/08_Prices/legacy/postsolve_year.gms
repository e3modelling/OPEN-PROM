*' Clear variables and equations (outside country loop — preserves no bounds for next year)
option clear = V08PriceFuelSepCarbonWght;
option clear = VmPriceFuelSubsecCarVal;
option clear = VmPriceFuelAvgSub;
option clear = VmPriceElecInd;

option clear = Q08PriceFuelSepCarbonWght;
option clear = Q08PriceFuelSubsecCarVal;
option clear = Q08PriceFuelAvgSub;
option clear = Q08PriceElecInd;

*' Re-apply preloop bounds for all active countries (outside country loop)
$include "./modules/08_Prices/legacy/preloop.gms"

*' Initialize variable levels from previous period parameter
V08PriceFuelSepCarbonWght.L(runCy,DSBS,EF,YTIME) = p08PriceFuelSepCarbonWght(runCy,DSBS,EF,YTIME-1);
VmPriceFuelSubsecCarVal.L(runCy,SBS,EF,YTIME) = pmPriceFuelSubsecCarVal(runCy,SBS,EF,YTIME-1);
VmPriceFuelAvgSub.L(runCy,DSBS,YTIME) = pmPriceFuelAvgSub(runCy,DSBS,YTIME-1);
VmPriceElecInd.L(runCy,TCHP,YTIME) = pmPriceElecInd(runCy,TCHP,YTIME-1);
