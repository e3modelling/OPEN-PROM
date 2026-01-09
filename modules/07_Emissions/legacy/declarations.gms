*' @title Emissions Constraints Declarations
*' @code

Parameters
p07MarginalRed(allCy, E07SrcMacAbate, E07MAC, YTIME)   "Marginal reduction potential per step"
p07MacCost(E07MAC)                                     "Numeric value of the MAC cost steps"
p07UnitConvFactor(E07SrcMacAbate)                      "Multiplier to convert carbon price units to MAC units"
p07GWP(E07SrcMacAbate)                                 "Global Warming Potentials, AR4 100yr (CO2=1, CH4=25, N2O=298, etc), Data from Hamsen et al 2019"
p07CostCorrection(E07SrcMacAbate)                      "Factor to convert (Qty * Cost) to Million 2015$"
;

Equations
*' *** Emissions Constraints Equations
*Q07GrnnHsEmisCO2Equiv(NAP,YTIME)	                       "Compute total CO2eq GHG emissions in all countries per NAP sector"
*q07GrnnHsEmisCO2EquivAllCntr(YTIME)	                   "Compute total CO2eq GHG emissions in all countries"
*q07ExpendHouseEne(allCy,YTIME)	                           "Compute households expenditures on energy"
Q07EmissCO2Supply(allCy,SSBS,YTIME)                   "Compute total CO2eq GHG emissions per supply sector"
Q07RedAbsBySrcRegTim(E07SrcMacAbate, allCy, YTIME)    "Calculate reduction fraction based on carbon price"
Q07CostAbateBySrcRegTim(E07SrcMacAbate, allCy, YTIME) "Calculate total abatement cost"
Q07EmiActBySrcRegTim(E07SrcMacAbate, allCy, YTIME)    "Calculate remaining actual emissions"
;

Variables
*' *** Emissions Constraints Variables
*V07GrnnHsEmisCO2Equiv(NAP,YTIME)	                       "Total CO2eq GHG emissions in all countries per NAP sector (1)"
*v07GrnnHsEmisCO2EquivAllCntr(YTIME)	                   "Total CO2eq GHG emissions in all countries (1)"
*v07ExpendHouseEne(allCy,YTIME)	                           "Households expenditures on energy (billions)"
V07EmissCO2Supply(allCy,SSBS,YTIME)                 "Total CO2eq GHG emissions per supply sector (Mt CO2/yr)"
V07RedAbsBySrcRegTim(E07SrcMacAbate,allCy,YTIME)      "Selected cumulative abatement fraction"
V07EmiActBySrcRegTim(E07SrcMacAbate,allCy,YTIME)       "Actual emissions"
V07CostAbateBySrcRegTim(E07SrcMacAbate,allCy,YTIME)    "Total abatement cost"
*;