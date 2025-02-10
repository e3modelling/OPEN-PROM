*' @title Prices Declarations
*' @code

Equations
*' *** Prices
QPriceFuelSepCarbonWght(allCy,SBS,EF,YTIME)	               "Compute fuel prices per subsector and fuel, separate carbon value in each sector"

*'                **Interdependent Variables**
QPriceFuelSubsecCarVal(allCy,SBS,EF,YTIME)                 "Compute fuel prices per subsector and fuel, separate carbon value in each sector"
QPriceElecIndResConsu(allCy,ESET,YTIME)                    "Compute electricity price in Industrial and Residential Consumers"
QPriceFuelAvgSub(allCy,DSBS,YTIME)	                       "Compute average fuel price per subsector" 	
;

Variables
*' *** Prices Variables
VPriceFuelSepCarbonWght(allCy,SBS,EF,YTIME)	               "Fuel prices per subsector and fuel  mutliplied by weights (kUS$2015/toe)"

*'                **Interdependent Variables**
VPriceFuelSubsecCarVal(allCy,SBS,EF,YTIME)                 "Fuel prices per subsector and fuel (k$2015/toe)"
VPriceElecIndResConsu(allCy,ESET,YTIME)	                   "Electricity price to Industrial and Residential Consumers (US$2015/KWh)"
VPriceFuelAvgSub(allCy,DSBS,YTIME)                         "Average fuel prices per subsector (k$2015/toe)"
;
