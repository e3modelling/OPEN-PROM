*' @title Emissions Constraints Declarations
*' @code

Equations
*' *** Emissions Constraints Equations
*Q07GrnnHsEmisCO2Equiv(NAP,YTIME)	                       "Compute total CO2eq GHG emissions in all countries per NAP sector"
*q07GrnnHsEmisCO2EquivAllCntr(YTIME)	                   "Compute total CO2eq GHG emissions in all countries"
*q07ExpendHouseEne(allCy,YTIME)	                           "Compute households expenditures on energy"
Q07EmissCO2Supply(allCy,SSBS,YTIME)                 "Compute total CO2eq GHG emissions per supply sector"
;

Variables
*' *** Emissions Constraints Variables
*V07GrnnHsEmisCO2Equiv(NAP,YTIME)	                       "Total CO2eq GHG emissions in all countries per NAP sector (1)"
*v07GrnnHsEmisCO2EquivAllCntr(YTIME)	                   "Total CO2eq GHG emissions in all countries (1)"
*v07ExpendHouseEne(allCy,YTIME)	                           "Households expenditures on energy (billions)"
V07EmissCO2Supply(allCy,SSBS,YTIME)                 "Total CO2eq GHG emissions per supply sector (Mt CO2/yr)"
;