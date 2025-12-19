*' @title Emissions Constraints Declarations
*' @code

*Equations
*' *** Emissions Constraints Equations
*Q07GrnnHsEmisCO2Equiv(NAP,YTIME)	                       "Compute total CO2eq GHG emissions in all countries per NAP sector"
*q07GrnnHsEmisCO2EquivAllCntr(YTIME)	                   "Compute total CO2eq GHG emissions in all countries"
*q07ExpendHouseEne(allCy,YTIME)	                           "Compute households expenditures on energy"
*;

*Variables
*' *** Emissions Constraints Variables
*V07GrnnHsEmisCO2Equiv(NAP,YTIME)	                       "Total CO2eq GHG emissions in all countries per NAP sector (1)"
*v07GrnnHsEmisCO2EquivAllCntr(YTIME)	                   "Total CO2eq GHG emissions in all countries (1)"
*v07ExpendHouseEne(allCy,YTIME)	                           "Households expenditures on energy (billions)"
*;

Parameters
    p07MarginalRed(allCy, E07SrcMacAbate, E07MAC, YTIME)   "Marginal reduction potential per step"
    p07MacCost(E07MAC)                                     "Numeric value of the MAC cost steps"
    p07UnitConvFactor(E07SrcMacAbate)                       "Multiplier to convert carbon price units to MAC units";
;

Equations
    Q07RedAbsBySrcRegTim(E07SrcMacAbate, allCy, YTIME)   "Calculate reduction fraction based on carbon price"
    Q07CostAbateBySrcRegTim(E07SrcMacAbate, allCy, YTIME) "Calculate total abatement cost"
    Q07EmiActBySrcRegTim(E07SrcMacAbate, allCy, YTIME)    "Calculate remaining actual emissions"
;

Variables
    V07RedAbsBySrcRegTim(E07SrcMacAbate,allCy,YTIME)      "Selected cumulative abatement fraction"
    V07EmiActBySrcRegTim(E07SrcMacAbate,allCy,YTIME)       "Actual emissions"
    V07CostAbateBySrcRegTim(E07SrcMacAbate,allCy,YTIME)    "Total abatement cost"
;