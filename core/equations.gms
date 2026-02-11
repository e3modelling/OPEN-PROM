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
  SUM((TRANSE,TTECH)$(SECTTECH("PC",TTECH) and (sameas("PC",TRANSE) or sameas("PB",TRANSE) or sameas("GU",TRANSE))),
    SQR(
      (
        V01ShareTechTr(allCy,TRANSE,TTECH,YTIME) -
        t01NewShareStockPC(allCy,TRANSE,TTECH,YTIME)
      )$(t01NewShareStockPC(allCy,TRANSE,TTECH,YTIME) >= 0) +
      0.01 * (imMatrFactor(allCy,TRANSE,TTECH,YTIME) - imMatrFactor(allCy,TRANSE,TTECH,YTIME-1))
    )
  );

qRestrain(allCy,TRANSE,TTECH,YTIME)$(TIME(YTIME) and runCy(allCy) and (t01NewShareStockPC(allCy,TRANSE,TTECH,YTIME) < 0)).. 
  imMatrFactor(allCy,TRANSE,TTECH,YTIME)
    =e=
  common(allCy,TRANSE,YTIME);
$ELSE.calib qDummyObj.. vDummyObj =e= 1;
$ENDIF.calib