*' @title Emissions Constraints Declarations
*' @code

*' *Equations
*' *** Emissions Constraints Equations
*QGrnnHsEmisCO2Equiv(NAP,YTIME)	                           "Compute total CO2eq GHG emissions in all countries per NAP sector"
*qGrnnHsEmisCO2EquivAllCntr(YTIME)	                       "Compute total CO2eq GHG emissions in all countries"
*qExpendHouseEne(allCy,YTIME)	                           "Compute households expenditures on energy"
*;

*Variables
*' *** Emissions Constraints Variables
*VGrnnHsEmisCO2Equiv(NAP,YTIME)	                           "Total CO2eq GHG emissions in all countries per NAP sector (1)"
*vGrnnHsEmisCO2EquivAllCntr(YTIME)	                       "Total CO2eq GHG emissions in all countries (1)"
*vExpendHouseEne(allCy,YTIME)	                           "Households expenditures on energy (billions)"
*;