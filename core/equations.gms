*' @title Equations of OPEN-PROM
*' @code

*' GENERAL INFORMATION

*' Equation format: "typical useful energy demand equation"
*' The main explanatory variables (drivers) are activity indicators (economic activity) and corresponding energy costs.
*' The type of "demand" is computed based on its past value, the ratio of the current and past activity indicators (with the corresponding elasticity), 
*' and the ratio of lagged energy costs (with the corresponding elasticities). This type of equation captures both short term and long term reactions to energy costs. 

*' * Define dummy objective function

$IFTHEN.calib %Calibration% == on
qDummyObj(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy))).. vDummyObj =e=
SQRT(SUM(SECTTECH(DSBS,EF)$(INDDOM(DSBS)), SQR(iFuelConsPerFueSub(allCy,DSBS,EF,YTIME)-VConsFuelInclHP(allCy,DSBS,EF,YTIME))) ) +
SQRT(SUM(SECTTECH(TRANSE,EF), SQR(VDemFinEneTranspPerFuel(allCy,TRANSE,EF,YTIME)-iFuelConsPerFueSub(allCy,TRANSE,EF,YTIME)))) +
0;
$ELSE.calib qDummyObj.. vDummyObj =e= 1;
$ENDIF.calib
