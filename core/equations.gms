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
  SUM(DSBS$((INDDOM(DSBS) or sameas("NEN",DSBS) or sameas("PCH",DSBS)) and not (sameas("AG",DSBS) and not EU28(allCy))), 
  vDummyObjINDDOMShares(DSBS) + vDummyObjINDDOMFinalEnergy(DSBS)
  )
  /SUM(DSBS$((INDDOM(DSBS) or sameas("NEN",DSBS) or sameas("PCH",DSBS)) and not (sameas("AG",DSBS) and not EU28(allCy))), 1)
  ;

qDummyObjPGALL(allCy,YTIME)$(TIME(YTIME) and runCy(allCy))..
  vDummyObjPGALL
    =e=
  SUM(PGALL,
    SQR(
      VmProdElec(allCy,PGALL,YTIME) / SUM(PGALL2, VmProdElec(allCy,PGALL2,YTIME)) - t04SharePowPlaNewEq(allCy,PGALL,YTIME)
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
  )
  /SUM((TRANSE,TTECH)$(SECTTECH(TRANSE,TTECH) and (sameas("PC",TRANSE) or sameas("PB",TRANSE) or sameas("GU",TRANSE))), 1)
  ;

qDummyObjINDDOMShares(allCy,YTIME,DSBS)$(TIME(YTIME) and runCy(allCy) and (INDDOM(DSBS) or sameas("NEN",DSBS) or sameas("PCH",DSBS))).. 
  vDummyObjINDDOMShares(DSBS)
    =e=
  (
    SUM(EFS$SECtoEF(DSBS,EFS),
      SQR(
        t02SharesFuelBuildings(allCy,DSBS,EFS,YTIME) - 
        VmConsFuelShare(allCy,DSBS,EFS,YTIME)
      )
    ) / SUM(EFS$SECtoEF(DSBS,EFS), 1)
  )$(DOMSE(DSBS) and not (sameas("AG",DSBS) and not EU28(allCy)))
   +
  (SUM(EFS$SECtoEF(DSBS,EFS),
    SQR(
      t02SharesFuelINDSE(allCy,DSBS,EFS,YTIME) - 
      VmConsFuelShare(allCy,DSBS,EFS,YTIME)
    )
  ) / SUM(EFS$SECtoEF(DSBS,EFS), 1)
  )$((INDSE(DSBS) or sameas("NEN",DSBS) or sameas("PCH",DSBS)) and t02FinalEnergyINDSE(allCy,DSBS,YTIME)) +
  SUM(ITECH$SECTTECH(DSBS,ITECH),
    1e-3 * SQR(
      i02ScaleEndogScrap(allCy,DSBS,ITECH,YTIME) - i02ScaleEndogScrap(allCy,DSBS,ITECH,YTIME-1)
    )
  ) / card(ITECH);

qDummyObjINDDOMFinalEnergy(allCy,YTIME,DSBS)$(TIME(YTIME) and runCy(allCy) and (INDDOM(DSBS) or sameas("NEN",DSBS) or sameas("PCH",DSBS))).. 
  vDummyObjINDDOMFinalEnergy(DSBS)
    =e=
    SQR(
      SUM(EF2$SECtoEF(DSBS,EF2),VmConsFuel(allCy,DSBS,EF2,YTIME)) / t02FinalEnergyDOMSE(allCy,DSBS,YTIME) - 1
    )$(DOMSE(DSBS) and not (sameas("AG",DSBS) and not EU28(allCy))) +
    SQR(
      SUM(EF2$SECtoEF(DSBS,EF2),VmConsFuel(allCy,DSBS,EF2,YTIME)) / t02FinalEnergyINDSE(allCy,DSBS,YTIME) - 1
    )$((INDSE(DSBS) or sameas("NEN",DSBS) or sameas("PCH",DSBS)) and t02FinalEnergyINDSE(allCy,DSBS,YTIME)) +
    SQR(i02CalibUsefulEnergy(allCy,DSBS,YTIME) - i02CalibUsefulEnergy(allCy,DSBS,YTIME-1));

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