*' @title Prices postsolve
* Fix values of variables for the next time step

* Prices Module

*---
VmPriceFuelAvgSub.FX(runCyL,DSBS,YTIME)$TIME(YTIME) = VmPriceFuelAvgSub.L(runCyL,DSBS,YTIME)$TIME(YTIME);
VmPriceFuelSubsecCarVal.FX(runCyL,SBS,EF,YTIME)$TIME(YTIME) = VmPriceFuelSubsecCarVal.L(runCyL,SBS,EF,YTIME)$TIME(YTIME);
VmPriceElecInd.FX(runCyL,TCHP,YTIME)$TIME(YTIME) = VmPriceElecInd.L(runCyL,TCHP,YTIME)$TIME(YTIME);
V08PriceFuelSepCarbonWght.FX(runCyL,DSBS,EF,YTIME)$TIME(YTIME) = V08PriceFuelSepCarbonWght.L(runCyL,DSBS,EF,YTIME)$TIME(YTIME);
*---
*' ============================================================
*' Land-use emulator emission accounting (landEmiMode == curve only)
*'
*' After each yearly solve, compute the land-use emissions attributable to
*' BMSWAS consumption using the quadratic curve fitted by the land-use emulator
*' (GLOBIOM or MAgPIE, selected by landUseEmulator):
*'
*'   Em(t) = ea + eb * Q(t) + ec * Q(t)^2
*'
*' where:
*'   Em     = land-use emission for each species in EMTYPE
*'            (CO2LandUse, CH4LandUse, N2OLandUse)
*'   Q(t)   = total primary biomass production V03ProdPrimary.L("BMSWAS",t) in
*'            Mtoe (same total-primary basis the emulator was fitted on).
*'            .L is the solved current-year level (post-solve).
*'   ea,eb,ec = fitted coefficients from imBmswasEmisCoef, indexed by the
*'              active GHG scenario (%emulatorGHGScen%). For CO2 these are regressed
*'              on Q; for CH4/N2O (agriculture) eb=ec=0 so Em is the constant ea.
*'
*' Results stored in imAfoluLandEmis (land CO2, level incl intercept) and
*' imAfoluAgriEmis (agriculture CH4/N2O, constant).
*' ============================================================
$IFTHEN %landEmiMode% == curve
* AFOLU LAND CO2 (regressed on Q): level (incl intercept) -> inventory
imAfoluLandEmis(runCyL,EMTYPE,YTIME)$(TIME(YTIME) $sameas(EMTYPE,"CO2LandUse")) =
  imBmswasEmisCoef("%emulatorGHGScen%",runCyL,EMTYPE,"ea",YTIME) +
  imBmswasEmisCoef("%emulatorGHGScen%",runCyL,EMTYPE,"eb",YTIME) *
    V03ProdPrimary.L(runCyL,"BMSWAS",YTIME) +
  imBmswasEmisCoef("%emulatorGHGScen%",runCyL,EMTYPE,"ec",YTIME) *
    SQR(V03ProdPrimary.L(runCyL,"BMSWAS",YTIME));
* AFOLU AGRICULTURE CH4/N2O (not regressed; eb=ec=0 -> constant intercept ea)
imAfoluAgriEmis(runCyL,EMTYPE,YTIME)$(TIME(YTIME) $(sameas(EMTYPE,"CH4LandUse") or sameas(EMTYPE,"N2OLandUse"))) =
  imBmswasEmisCoef("%emulatorGHGScen%",runCyL,EMTYPE,"ea",YTIME);
$ENDIF
*---