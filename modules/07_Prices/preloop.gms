*' @title Prices Preloop
*' @code

model openprom /

*' * Prices *
QPriceFuelSubsecCarVal              !! VPriceFuelSubsecCarVal(runCy,SBS,EF,YTIME)
QPriceFuelSepCarbonWght             !! VPriceFuelSepCarbonWght(runCy,DSBS,EF,YTIME)
QPriceFuelAvgSub                    !! VPriceFuelAvgSub(runCy,DSBS,YTIME)
QPriceElecIndResConsu               !! VPriceElecIndResConsu(runCy,ESET,YTIME)

/;

*'                *VARIABLE INITIALISATION*
*---
VPriceFuelSepCarbonWght.scale(runCy,DSBS,EF,YTIME)=1e-6;
QPriceFuelSepCarbonWght.scale(runCy,DSBS,EF,YTIME)=VPriceFuelSepCarbonWght.scale(runCy,DSBS,EF,YTIME);
*---