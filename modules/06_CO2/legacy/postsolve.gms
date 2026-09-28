*' @title CO2 SEQUESTRATION COST CURVES postsolve
* Fix values of variables for the next time step

* CO2 Sequestration Module

*---
V06CaptCummCO2.FX(runCyL,YTIME)$TIME(YTIME) = V06CaptCummCO2.L(runCyL,YTIME)$TIME(YTIME);
V06CapCDR.FX(runCyL,CDRTECH,YTIME)$TIME(YTIME) = V06CapCDR.L(runCyL,CDRTECH,YTIME)$TIME(YTIME);
V06LvlCostCDR.FX(runCyL,CDRTECH,YTIME)$TIME(YTIME) = V06LvlCostCDR.L(runCyL,CDRTECH,YTIME)$TIME(YTIME);
V06CostFullCDR.FX(runCy,CDRTECH,YTIME)$TIME(YTIME) = V06CostFullCDR.L(runCy,CDRTECH,YTIME)$TIME(YTIME);
V06CapFacNewCDR.FX(runCyL,CDRTECH,YTIME)$TIME(YTIME) = V06CapFacNewCDR.L(runCyL,CDRTECH,YTIME)$TIME(YTIME);
* After the last regional solve, update next year's global CCS availability adder.
i06CCSAvailabilityCostAdder(YTIME)$(
  sCY = card(runCyL) and TIME(YTIME-1) and AN(YTIME)
) = %ccsAvailabilityCostAdder%
  * sqr(
      (
        sum((runCy2,SBS,EFS)$SECtoEF(SBS,EFS),
          V06CO2CaptureCCS.L(runCy2,SBS,EFS,YTIME-1)) * 1e-3
        + sum((runCy2,DACTECH),
          V06CapCDR.L(runCy2,DACTECH,YTIME-1)) * 1e-9
      ) / 10
    );
$ontext
V06GrossCapCDR.FX(CDRTECH,YTIME)$TIME(YTIME) = V06GrossCapCDR.L(CDRTECH,YTIME)$TIME(YTIME);
V06FixOandMCDR.FX(CDRTECH,YTIME)$TIME(YTIME) = V06FixOandMCDR.L(CDRTECH,YTIME)$TIME(YTIME);
V06VarCostCDR.FX(CDRTECH,YTIME)$TIME(YTIME) = V06VarCostCDR.L(CDRTECH,YTIME)$TIME(YTIME);
$offtext
*---
