*' @title Prices Declarations
*' @code

Equations
*' *** Prices
QPriceFuelSepCarbonWght(allCy,SBS,EF,YTIME)	               "Compute fuel prices per subsector and fuel, separate carbon value in each sector"
QPriceElecIndResConsu(allCy,ESET,YTIME)                    "Compute electricity price in Industrial and Residential Consumers"

*'                **Interdependent Equations**
Q08PriceFuelSubsecCarVal(allCy,SBS,EF,YTIME)               "Compute fuel prices per subsector and fuel, separate carbon value in each sector"
Q08PriceFuelAvgSub(allCy,DSBS,YTIME)	                   "Compute average fuel price per subsector" 	
Q08PriceElecIndResNoCliPol(allCy,ESET,YTIME)               "Compute electricity price in Industrial and Residential Consumers excluding climate policies"
Q08PriceFuelSubsecCHP(allCy,DSBS,EF,YTIME)                 "Compute fuel prices per subsector and fuel especially for chp plants"
Q08PriceElecInd(allCy,YTIME)                               "Compute electricity industry prices"
;

Variables
*' *** Prices Variables
VPriceFuelSepCarbonWght(allCy,SBS,EF,YTIME)	               "Fuel prices per subsector and fuel  mutliplied by weights (kUS$2015/toe)"
VPriceElecIndResConsu(allCy,ESET,YTIME)	                   "Electricity price to Industrial and Residential Consumers (US$2015/KWh)"

*'                **Interdependent Variables**
VMVPriceFuelSubsecCarVal(allCy,SBS,EF,YTIME)               "Fuel prices per subsector and fuel (k$2015/toe)"
VMVPriceFuelAvgSub(allCy,DSBS,YTIME)                       "Average fuel prices per subsector (k$2015/toe)"
VMVPriceElecIndResNoCliPol(allCy,ESET,YTIME)               "Electricity price to Industrial and Residential Consumers (US$2015/KWh)"
VMVPriceFuelSubsecCHP(allCy,DSBS,EF,YTIME)                 "Fuel prices per subsector and fuel for CHP plants (kUS$2015/toe)"
VMVPriceElecInd(allCy,YTIME)                               "Electricity index - a function of industry price (1)"

*' *** Miscellaneous
VFuelPriSubNoCarb(allCy,SBS,EF,YTIME)	                   "Fuel prices per subsector and fuel  without carbon value (kUS$2015/toe)"
;
