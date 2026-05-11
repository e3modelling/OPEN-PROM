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
  vDummyObjPGALL + vDummyObjTRANSE + 
  SUM(DSBS$(sameas("SE", DSBS) or sameas("HOU",DSBS) or (sameas("AG",DSBS) and EU28(allCy))), vDummyObjDOMSEShares(DSBS)) + 
  SUM(DSBS$(sameas("SE", DSBS) or sameas("HOU",DSBS) or (sameas("AG",DSBS) and EU28(allCy))), vDummyObjDOMSEFinalEnergy(DSBS))
  ;

qDummyObjPGALL(allCy,YTIME)$(TIME(YTIME) and runCy(allCy))..
  vDummyObjPGALL
    =e=
  SUM(PGALL,
    SQR(
      V04SharePowPlaNewEq(allCy,PGALL,YTIME) - 
      t04SharePowPlaNewEq(allCy,PGALL,YTIME)
    )
  ) 
  ;

qDummyObjTRANSE(allCy,YTIME)$(TIME(YTIME) and runCy(allCy))..  
  vDummyObjTRANSE
    =e=
  SUM((TRANSE,TTECH)$(SECTTECH(TRANSE,TTECH) and (sameas("PC",TRANSE) or sameas("PB",TRANSE) or sameas("GU",TRANSE))),
    SQR(
      (
        V01ShareTechTr(allCy,TRANSE,TTECH,YTIME) -
        t01NewShareStockPC(allCy,TRANSE,TTECH,YTIME)
      )$(t01NewShareStockPC(allCy,TRANSE,TTECH,YTIME) >= 0) +
      0.01 * (imMatrFactor(allCy,TRANSE,TTECH,YTIME) - imMatrFactor(allCy,TRANSE,TTECH,YTIME-1))
    )
  ) 
  ;

qDummyObjDOMSEShares(allCy,YTIME,DSBS)$(TIME(YTIME) and ((sameas("SE", DSBS) and runCy(allCy)) or (sameas("HOU",DSBS) and runCy(allCy)) or (sameas("AG",DSBS) and EU28(allCy)))).. 
  vDummyObjDOMSEShares(DSBS)
    =e=
  SUM(EFS$SECtoEF(DSBS,EFS),
    SQR(
      t02SharesFuelBuildings(allCy,DSBS,EFS,YTIME) - 
      VmConsFuelShare(allCy,DSBS,EFS,YTIME)
    )
  ) 
  ;

qDummyObjDOMSEFinalEnergy(allCy,YTIME,DSBS)$(TIME(YTIME) and ((sameas("SE", DSBS) and runCy(allCy)) or (sameas("HOU",DSBS) and runCy(allCy)) or (sameas("AG",DSBS) and EU28(allCy)))).. 
  vDummyObjDOMSEFinalEnergy(DSBS)
    =e=
    SQR(
      SUM(EF2$SECtoEF(DSBS,EF2),VmConsFuel(allCy,DSBS,EF2,YTIME)) / t02FinalEnergyDOMSE(allCy,DSBS,YTIME) - 1
    ) +
    SQR(i02CalibUsefulEnergy(allCy,DSBS,YTIME) - i02CalibUsefulEnergy(allCy,DSBS,YTIME-1))
  ) +


  SUM(DSBS$(INDSE(DSBS) or sameas("NEN",DSBS) or sameas("PCH",DSBS)),
    SQR(
      SUM(EF2$SECtoEF(DSBS,EF2),VmConsFuel(allCy,DSBS,EF2,YTIME)) / t02FinalEnergyINDSE(allCy,DSBS,YTIME) - 1
    )$t02FinalEnergyINDSE(allCy,DSBS,YTIME) +
    SQR(i02CalibUsefulEnergy(allCy,DSBS,YTIME) - i02CalibUsefulEnergy(allCy,DSBS,YTIME-1))
  ) +
  SUM((DSBS,EFS)$(INDSE(DSBS) or sameas("NEN",DSBS) or sameas("PCH",DSBS) and SECtoEF(DSBS,EFS) and t02FinalEnergyINDSE(allCy,DSBS,YTIME)),
    SQR(
      t02SharesFuelINDSE(allCy,DSBS,EFS,YTIME) - 
      VmConsFuelShare(allCy,DSBS,EFS,YTIME)
    )
  )
  ;

qRestrain(allCy,TRANSE,TTECH,YTIME)$(TIME(YTIME) and SECTTECH(TRANSE,TTECH) and runCy(allCy) and (t01NewShareStockPC(allCy,TRANSE,TTECH,YTIME) < 0)).. 
  imMatrFactor(allCy,TRANSE,TTECH,YTIME)
    =e=
  common(allCy,TRANSE,YTIME);
$ELSE.calib qDummyObj.. vDummyObj =e= 1;
$ENDIF.calib

QmGDPPartGlob(allCy,YTIME)$(TIME(YTIME) and runCy(allCy))..
    VmGDPPartGlob(allCy,YTIME)
      =E=
    i01GDP(YTIME,allCy) / sum(runCy2, VmGDPPartGlob(runCy2,YTIME));