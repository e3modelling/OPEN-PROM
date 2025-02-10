*QPriceFuelSepCarbonWght
VPriceFuelSepCarbonWght.L(runCy,DSBS,EF,YTIME)$(An(YTIME))
    =
iWgtSecAvgPriFueCons(runCy,DSBS,EF) * VPriceFuelSubsecCarVal.L(runCy,DSBS,EF,YTIME);
