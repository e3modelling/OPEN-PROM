*' @title Equations of OPEN-PROM
*' @code

*' GENERAL INFORMATION

*' Equation format: "typical useful energy demand equation"
*' The main explanatory variables (drivers) are activity indicators (economic activity) and corresponding energy costs.
*' The type of "demand" is computed based on its past value, the ratio of the current and past activity indicators (with the corresponding elasticity), 
*' and the ratio of lagged energy costs (with the corresponding elasticities). This type of equation captures both short term and long term reactions to energy costs. 

*' * Define dummy objective function

$IFTHEN.calib %Calibration% == Calibration
qDummyObj(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy))).. vDummyObj =e=
SQRT(SUM((DSBS,TECH)$(SECTTECH(DSBS,TECH)and TECHtoEF(TECH,EF) and (INDDOM(DSBS))), SQR(imFuelConsPerFueSub(allCy,DSBS,EF,YTIME)-VmConsFuel(allCy,DSBS,EF,YTIME)))) +
SQRT(SUM((DSBS,TECH)$(SECTTECH(DSBS,TECH)and TECHtoEF(TECH,EF) and (TRANSE(DSBS))), SQR(VmDemFinEneTranspPerFuel(allCy,TRANSE,EF,YTIME)-imFuelConsPerFueSub(allCy,TRANSE,EF,YTIME)))) +
0;
$ELSEIF.calib %Calibration% == MatCalibration
qDummyObj(allCy,YTIME)$(TIME(YTIME) and runCy(allCy)).. 
  vDummyObj 
      =E=
  SUM(
    (PGALL),
    SQR(
      V04SharePowPlaNewEq(allCy,PGALL,YTIME) - 
      t04SharePowPlaNewEq(allCy,PGALL,YTIME)
    )
  );
*$ELSE.calib qDummyObj.. vDummyObj =e= 1;
$ENDIF.calib

Q00ElecConsHeatPla(allCy,INDDOM,YTIME)$(TIME(YTIME) and runCy(allCy))..
  VmElecConsHeatPla(allCy,INDDOM,YTIME) 
    =E=
    (
    imFuelConsPerFueSub(allCy,INDDOM,"ELC",YTIME) *
    (1-imShrNonSubElecInTotElecDem(allCy,INDDOM)) *
    iShrHeatPumpElecCons(allCy,INDDOM)
    )$(not An(YTIME)) +
    1E-7;