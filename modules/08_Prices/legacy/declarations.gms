*' @title Prices Declarations
*' @code

Equations
*' *** Prices
Q08PriceFuelSepCarbonWght(allCy,SBS,EF,YTIME)	           "Compute fuel prices per subsector and fuel, separate carbon value in each sector"

*'                **Interdependent Equations**
*Q08PriceElecIndResConsu(allCy,ESET,YTIME)                  "Compute electricity price in Industrial and Residential Consumers"
Q08BmswasPriceFactor(allCy,YTIME)                         "Compute the BMSWAS price factor selected by the active land-use mode"
$IFTHEN.magpiePriceEquation "%bmswasPriceMode%" == "curve"
$IFTHEN.magpiePriceDeclarationSource "%landUseEmulator%" == "magpie"
Q08Bioenergy2GEffectiveQH12Magpie(allCy,YTIME)            "Compute effective 2G biomass Q for the mapped MAgPIE H12 supply curve"
Q08PriceBmswasMagpie(allCy,SBS,YTIME)                     "Broadcast the MAgPIE H12 native BMSWAS price to every subsector"
$ENDIF.magpiePriceDeclarationSource
$ENDIF.magpiePriceEquation
Q08PriceFuelSubsecCarVal(allCy,SBS,EF,YTIME)               "Compute fuel prices per subsector and fuel, separate carbon value in each sector"
Q08PriceFuelAvgSub(allCy,DSBS,YTIME)	                   "Compute average fuel price per subsector" 	
*Q08PriceFuelSubsecCHP(allCy,DSBS,EF,YTIME)                 "Compute fuel prices per subsector and fuel especially for chp plants"
Q08PriceElecInd(allCy,TCHP,YTIME)                               "Compute electricity industry prices"
Q08PriceCarbon(allCy,SBS,EFS,YTIME)
;

Parameters
i08Bioenergy2GEffectiveQMagpie(allCy,YTIME)                "Current regional MAgPIE effective 2G biomass Q (Mtoe)"
i08Bioenergy2GEffectiveQH12Magpie(allCy,YTIME)             "MAgPIE effective 2G biomass Q used by the mapped H12 land-CO2 curve (Mtoe)"
;

Variables
*' *** Prices Variables
V08PriceFuelSepCarbonWght(allCy,SBS,EF,YTIME)	           "Fuel prices per subsector and fuel  mutliplied by weights (kUS$2015/toe)"

*'                **Interdependent Variables**
*VmPriceElecIndResConsu(allCy,ESET,YTIME)	               "Electricity price to Industrial and Residential Consumers (US$2015/KWh)"
$IFTHEN.magpiePriceVariable "%bmswasPriceMode%" == "curve"
$IFTHEN.magpiePriceVariableSource "%landUseEmulator%" == "magpie"
V08Bioenergy2GEffectiveQH12Magpie(allCy,YTIME)             "Effective 2G biomass Q used by the mapped MAgPIE H12 supply curve (Mtoe)"
$ENDIF.magpiePriceVariableSource
$ENDIF.magpiePriceVariable
V08BmswasPriceFactor(allCy,YTIME)                         "Multiplicative factor mapping the preceding BMSWAS price to the active price target (1)"
VmPriceFuelSubsecCarVal(allCy,SBS,EF,YTIME)                "Fuel prices per subsector and fuel (k$2015/toe)"
VmPriceFuelAvgSub(allCy,DSBS,YTIME)                        "Average fuel prices per subsector (k$2015/toe)"
* VmPriceFuelSubsecCHP(allCy,DSBS,EF,YTIME)                  "Fuel prices per subsector and fuel for CHP plants (kUS$2015/toe)"
VmPriceElecInd(allCy,TCHP,YTIME)                                "Electricity index - a function of industry price (1)"
VmPriceCarbon(allCy,SBS,EFS,YTIME)

*' *** Miscellaneous
*V08FuelPriSubNoCarb(allCy,SBS,EF,YTIME)	                   "Fuel prices per subsector and fuel  without carbon value (kUS$2015/toe)"
;
