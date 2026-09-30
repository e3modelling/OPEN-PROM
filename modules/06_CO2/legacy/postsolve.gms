*' @title CO2 SEQUESTRATION COST CURVES postsolve
* Fix values of variables for the next time step

* CO2 Sequestration Module

*---
V06CaptCummCO2.FX(runCyL,YTIME)$TIME(YTIME) = V06CaptCummCO2.L(runCyL,YTIME)$TIME(YTIME);
V06CapCDR.FX(runCyL,CDRTECH,YTIME)$TIME(YTIME) = V06CapCDR.L(runCyL,CDRTECH,YTIME)$TIME(YTIME);
V06LvlCostCDR.FX(runCyL,CDRTECH,YTIME)$TIME(YTIME) = V06LvlCostCDR.L(runCyL,CDRTECH,YTIME)$TIME(YTIME);
V06CostFullCDR.FX(runCy,CDRTECH,YTIME)$TIME(YTIME) = V06CostFullCDR.L(runCy,CDRTECH,YTIME)$TIME(YTIME);
V06CapFacNewCDR.FX(runCyL,CDRTECH,YTIME)$TIME(YTIME) = V06CapFacNewCDR.L(runCyL,CDRTECH,YTIME)$TIME(YTIME);
* Aggregate only after all regions are collected, in both serial and parallel mode.
V06CaptCummCO2Glob.FX(YTIME)$(sCY = card(runCyL) and TIME(YTIME)) =
  sum(runCy2, V06CaptCummCO2.L(runCy2,YTIME));

* Next year's common tax uses the completed global stock, not annual capture.
$ifthenE.ccsStorageTax %ccsStorageReferenceGtCO2%>0
i06CCSAvailabilityCostAdder(YTIME)$(
  sCY = card(runCyL) and TIME(YTIME-1) and AN(YTIME)
) = i06CCSStorageTaxScale
  * sqr(V06CaptCummCO2Glob.L(YTIME-1) * 1e-3 / %ccsStorageReferenceGtCO2%);
$endif.ccsStorageTax
$ontext
V06GrossCapCDR.FX(CDRTECH,YTIME)$TIME(YTIME) = V06GrossCapCDR.L(CDRTECH,YTIME)$TIME(YTIME);
V06FixOandMCDR.FX(CDRTECH,YTIME)$TIME(YTIME) = V06FixOandMCDR.L(CDRTECH,YTIME)$TIME(YTIME);
V06VarCostCDR.FX(CDRTECH,YTIME)$TIME(YTIME) = V06VarCostCDR.L(CDRTECH,YTIME)$TIME(YTIME);
$offtext
*---
