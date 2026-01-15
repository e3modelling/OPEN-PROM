*' @title Equations of OPEN-PROM
*' @code

*' GENERAL INFORMATION

*' Equation format: "typical useful energy demand equation"
*' The main explanatory variables (drivers) are activity indicators (economic activity) and corresponding energy costs.
*' The type of "demand" is computed based on its past value, the ratio of the current and past activity indicators (with the corresponding elasticity), 
*' and the ratio of lagged energy costs (with the corresponding elasticities). This type of equation captures both short term and long term reactions to energy costs. 

*' * Define dummy objective function

$IFTHEN.calib %Calibration% == MatCalibration
qDummyObj(allCy,YTIME)$(TIME(YTIME) and runCy(allCy)).. 
  vDummyObj 
      =e=
  SUM(PGALL,
    SQR(
      V04SharePowPlaNewEq(allCy,PGALL,YTIME) - 
      t04SharePowPlaNewEq(allCy,PGALL,YTIME)
    )
  ) +
  SUM(TTECH$SECTTECH("PC",TTECH),
    SQR(
      V01StockPcYearlyTech(allCy,TTECH,YTIME) /
      SUM(TTECH2$SECTTECH("PC",TTECH2),V01StockPcYearlyTech(allCy,TTECH2,YTIME)) -
      t01StockPC(allCy,TTECH,YTIME)
    )
  );
$ELSE.calib qDummyObj.. vDummyObj =e= 1;
$ENDIF.calib