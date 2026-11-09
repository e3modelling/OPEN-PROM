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
  SUM(DSBS$INDDOM(DSBS),
  vDummyObjINDDOMShares(DSBS) + vDummyObjINDDOMFinalEnergy(DSBS)
  ) /
  CARD(INDDOM);

qDummyObjPGALL(allCy,YTIME)$(TIME(YTIME) and runCy(allCy))..
  vDummyObjPGALL
    =e=
  SUM(PGALL,
    SQR(
      VmProdElec(allCy,PGALL,YTIME) / (SUM(PGALL2, VmProdElec(allCy,PGALL2,YTIME)) + 1e-6) - t04SharePowPlaNewEq(allCy,PGALL,YTIME)
    ) +
    1e-5 * SQR(
      i04MatFacPlaAvailCap(allCy,PGALL,YTIME) - i04MatFacPlaAvailCap(allCy,PGALL,YTIME-1)
    ) +
    1e-4 * SQR(
      i04ScaleEndogScrap(allCy,PGALL,YTIME) - i04ScaleEndogScrap(allCy,PGALL,YTIME-1)
    )
  ) / CARD(PGALL);

qDummyObjTRANSE(allCy,YTIME)$(TIME(YTIME) and runCy(allCy))..  
  vDummyObjTRANSE
    =e=
  SUM((TRANSE,TTECH)$(SECTTECH(TRANSE,TTECH) and (sameas("PC",TRANSE) or sameas("PB",TRANSE) or sameas("GU",TRANSE))),
    SQR(
      (
        V01ShareTechTr(allCy,TRANSE,TTECH,YTIME) -
        t01NewShareStockPC(allCy,TRANSE,TTECH,YTIME)
      )$(t01NewShareStockPC(allCy,TRANSE,TTECH,YTIME) >= 0) +
      0 * (imMatrFactor(allCy,TRANSE,TTECH,YTIME) - imMatrFactor(allCy,TRANSE,TTECH,YTIME-1))
    )
  ) /
  SUM((TRANSE,TTECH)$(SECTTECH(TRANSE,TTECH) and (sameas("PC",TRANSE) or sameas("PB",TRANSE) or sameas("GU",TRANSE))), 1);

qDummyObjINDDOMShares(allCy,YTIME,INDDOM)$(TIME(YTIME) and runCy(allCy)).. 
  vDummyObjINDDOMShares(INDDOM)
    =e=
  (
    SUM(EFS$SECtoEF(INDDOM,EFS),
      SQR(
        t02SharesFuelBuildings(allCy,INDDOM,EFS,YTIME) -
        VmFinalEnergy(allCy,INDDOM,EFS,YTIME) / SUM(EFS2$SECtoEF(INDDOM,EFS2),VmFinalEnergy(allCy,INDDOM,EFS2,YTIME))
      )
    ) / SUM(EFS$SECtoEF(INDDOM,EFS), 1)
  )$DOMSE(INDDOM)
   +
  (SUM(EFS$SECtoEF(INDDOM,EFS),
    SQR(
      t02SharesFuelINDSE(allCy,INDDOM,EFS,YTIME) - 
      VmFinalEnergy(allCy,INDDOM,EFS,YTIME) / SUM(EFS2$SECtoEF(INDDOM,EFS2),VmFinalEnergy(allCy,INDDOM,EFS2,YTIME))
    )
  ) / SUM(EFS$SECtoEF(INDDOM,EFS), 1)
  )$(INDSE(INDDOM) and t02FinalEnergyINDSE(allCy,INDDOM,YTIME)) +
  SUM(INDITECH$SECTTECH(INDDOM,INDITECH),
    1e-3 * SQR(
      i02ScaleEndogScrap(allCy,INDDOM,INDITECH,YTIME) - i02ScaleEndogScrap(allCy,INDDOM,INDITECH,YTIME-1)
    )
  ) / card(INDITECH);

qDummyObjINDDOMFinalEnergy(allCy,YTIME,INDDOM)$(TIME(YTIME) and runCy(allCy)).. 
  vDummyObjINDDOMFinalEnergy(INDDOM)
    =e=
    SQR(
      SUM(EFS2$SECtoEF(INDDOM,EFS2), VmFinalEnergy(allCy,INDDOM,EFS2,YTIME)) / t02FinalEnergyDOMSE(allCy,INDDOM,YTIME) - 1
    )$(DOMSE(INDDOM) and t02FinalEnergyDOMSE(allCy,INDDOM,YTIME)) +
    SQR(
      SUM(EFS2$SECtoEF(INDDOM,EFS2),VmFinalEnergy(allCy,INDDOM,EFS2,YTIME)) / t02FinalEnergyINDSE(allCy,INDDOM,YTIME) - 1
    )$(INDSE(INDDOM) and t02FinalEnergyINDSE(allCy,INDDOM,YTIME)) +
    SQR(i02CalibUsefulEnergy(allCy,INDDOM,YTIME) - i02CalibUsefulEnergy(allCy,INDDOM,YTIME-1));

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
