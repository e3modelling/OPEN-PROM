*' @title Prices postsolve
* Fix values of variables for the next time step

* Prices Module

*---
pmPriceFuelAvgSub(runCyL,DSBS,YTIME)$TIME(YTIME) = VmPriceFuelAvgSub.L(runCyL,DSBS,YTIME)$TIME(YTIME);
pmPriceFuelSubsecCarVal(runCyL,SBS,EF,YTIME)$TIME(YTIME) = VmPriceFuelSubsecCarVal.L(runCyL,SBS,EF,YTIME)$TIME(YTIME);
pmPriceElecInd(runCyL,TCHP,YTIME)$TIME(YTIME) = VmPriceElecInd.L(runCyL,TCHP,YTIME)$TIME(YTIME);
p08PriceFuelSepCarbonWght(runCyL,DSBS,EF,YTIME)$TIME(YTIME) = V08PriceFuelSepCarbonWght.L(runCyL,DSBS,EF,YTIME)$TIME(YTIME);
*---
*' ============================================================
*' Land-use emulator emission accounting (landEmiMode == curve only)
*'
*' After each yearly solve, AFOLU emissions split into two (selected by landUseEmulator
*' = GLOBIOM or MAgPIE):
*'
*'  (1) LAND CO2 -- Q-dependent -> quadratic curve evaluated at the solved demand:
*'        Em(t) = ea + eb * Q(t) + ec * Q(t)^2
*'      Q(t) = total primary biomass production V03ProdPrimary.L("BMSWAS",t) in Mtoe
*'             (same basis the emulator was fitted on; .L = solved current-year level).
*'      ea,eb,ec = imBmswasLandEmisCoef, active GHG scenario (%emulatorGHGScen%).
*'      -> imAfoluLandEmis.
*'
*'  (2) AGRICULTURE CH4/N2O -- Q-independent -> read directly from the input table
*'      imBmswasAgriEmis (no curve; agriculture barely varies with biomass demand).
*'      -> imAfoluAgriEmis.
*' ============================================================
$IFTHEN %landEmiMode% == curve
* AFOLU LAND CO2 (regressed on Q): level (incl intercept) -> inventory
imAfoluLandEmis(runCyL,EMTYPE,YTIME)$(TIME(YTIME) $sameas(EMTYPE,"CO2LandUse")) =
  imBmswasLandEmisCoef("%emulatorGHGScen%",runCyL,EMTYPE,"ea",YTIME) +
  imBmswasLandEmisCoef("%emulatorGHGScen%",runCyL,EMTYPE,"eb",YTIME) *
    V03ProdPrimary.L(runCyL,"BMSWAS",YTIME) +
  imBmswasLandEmisCoef("%emulatorGHGScen%",runCyL,EMTYPE,"ec",YTIME) *
    SQR(V03ProdPrimary.L(runCyL,"BMSWAS",YTIME));
* AFOLU AGRICULTURE CH4/N2O: Q-independent -> read directly from the input table
imAfoluAgriEmis(runCyL,EMTYPE,YTIME)$(TIME(YTIME) $(sameas(EMTYPE,"CH4LandUse") or sameas(EMTYPE,"N2OLandUse"))) =
  imBmswasAgriEmis("%emulatorGHGScen%",runCyL,EMTYPE,YTIME);
$ENDIF
*---