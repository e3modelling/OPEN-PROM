*' @title Prices Declarations
*' @code

Equations
*' *** Prices
Q08PriceFuelSepCarbonWght(allCy,SBS,EF,YTIME)	           "Compute fuel prices per subsector and fuel, separate carbon value in each sector"

*'                **Interdependent Equations**
Q08PriceElecIndResConsu(allCy,ESET,YTIME)                  "Compute electricity price in Industrial and Residential Consumers"
Q08PriceFuelSubsecCarVal(allCy,SBS,EF,YTIME)               "Compute fuel prices per subsector and fuel, separate carbon value in each sector"
Q08PriceFuelAvgSub(allCy,DSBS,YTIME)	                   "Compute average fuel price per subsector" 	
Q08PriceElecIndResNoCliPol(allCy,ESET,YTIME)               "Compute electricity price in Industrial and Residential Consumers excluding climate policies"
Q08PriceFuelSubsecCHP(allCy,DSBS,EF,YTIME)                 "Compute fuel prices per subsector and fuel especially for chp plants"
Q08PriceElecInd(allCy,YTIME)                               "Compute electricity industry prices"
;

Variables
*' *** Prices Variables
V08PriceFuelSepCarbonWght(allCy,SBS,EF,YTIME)	           "Fuel prices per subsector and fuel  mutliplied by weights (kUS$2015/toe)"

*'                **Interdependent Variables**
VmPriceElecIndResConsu(allCy,ESET,YTIME)	               "Electricity price to Industrial and Residential Consumers (US$2015/KWh)"
VmPriceFuelSubsecCarVal(allCy,SBS,EF,YTIME)                "Fuel prices per subsector and fuel (k$2015/toe)"
VmPriceFuelAvgSub(allCy,DSBS,YTIME)                        "Average fuel prices per subsector (k$2015/toe)"
VmPriceElecIndResNoCliPol(allCy,ESET,YTIME)                "Electricity price to Industrial and Residential Consumers (US$2015/KWh)"
VmPriceFuelSubsecCHP(allCy,DSBS,EF,YTIME)                  "Fuel prices per subsector and fuel for CHP plants (kUS$2015/toe)"
VmPriceElecInd(allCy,YTIME)                                "Electricity index - a function of industry price (1)"

*' *** Miscellaneous
V08FuelPriSubNoCarb(allCy,SBS,EF,YTIME)	                   "Fuel prices per subsector and fuel  without carbon value (kUS$2015/toe)"
;
