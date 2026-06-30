*' Clear variables and equations (outside country loop — preserves no bounds for next year)
option clear = V08PriceFuelSepCarbonWght;
option clear = VmPriceFuelSubsecCarVal;
option clear = VmPriceFuelAvgSub;
option clear = VmPriceElecInd;

option clear = Q08PriceFuelSepCarbonWght;
option clear = Q08PriceFuelSubsecCarVal;
option clear = Q08PriceFuelAvgSub;
option clear = Q08PriceElecInd;

*' Re-apply critical bounds for all active countries (outside country loop)
V08PriceFuelSepCarbonWght.LO(runCyL,DSBS,EF,YTIME) = 0;
VmPriceFuelSubsecCarVal.LO(runCyL,SBS,EF,YTIME) = 0;
VmPriceFuelAvgSub.LO(runCyL,DSBS,YTIME) = 0;

*' Initialize variable levels from previous period parameter
V08PriceFuelSepCarbonWght.L(runCyL,DSBS,EF,YTIME+1) = p08PriceFuelSepCarbonWght(runCyL,DSBS,EF,YTIME);
VmPriceFuelSubsecCarVal.L(runCyL,SBS,EF,YTIME+1) = pmPriceFuelSubsecCarVal(runCyL,SBS,EF,YTIME);
VmPriceFuelAvgSub.L(runCyL,DSBS,YTIME+1) = pmPriceFuelAvgSub(runCyL,DSBS,YTIME);
VmPriceElecInd.L(runCyL,TCHP,YTIME+1) = pmPriceElecInd(runCyL,TCHP,YTIME);
