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
*' GLOBIOM land-use emission accounting (link2GLOBIOM == on only)
*'
*' After each yearly solve, compute the land-use emissions attributable to
*' BMSWAS consumption using the quadratic curve fitted from GLOBIOM data:
*'
*'   Em(t) = ea + eb * Q(t) + ec * Q(t)^2
*'
*' where:
*'   Em     = land-use emission for each species in EMTYPE
*'            (CO2LandUse, CH4LandUse, N2OLandUse)
*'   Q(t)   = total BMSWAS consumption in year t, summed over all demand
*'            subsectors DSBS that are mapped to BMSWAS via SECtoEF.
*'            VmConsFuel.L is used (not .FX) because this runs post-solve
*'            in the same year — .FX is set below for carry-forward.
*'   ea,eb,ec = OLS-fitted coefficients from imBmswasEmisCoefGLOBIOM,
*'              indexed by the active GHG scenario (%globiomGHGScen%).
*'
*' Result stored in the parameter imBmswasLandUseEmis(allCy,EMTYPE,YTIME).
*' Note: all EU country rows currently have zero coefficients because EU
*' land-use emissions are absent from the GLOBIOM lookup table; they will
*' become non-zero when an improved table is delivered.
*' ============================================================
$IFTHEN %link2GLOBIOM% == on
imBmswasLandUseEmis(runCyL,EMTYPE,YTIME)$TIME(YTIME) =
  imBmswasEmisCoefGLOBIOM("%globiomGHGScen%",runCyL,EMTYPE,"ea",YTIME) +
  imBmswasEmisCoefGLOBIOM("%globiomGHGScen%",runCyL,EMTYPE,"eb",YTIME) *
    SUM(DSBS$SECtoEF(DSBS,"BMSWAS"), VmConsFuel.L(runCyL,DSBS,"BMSWAS",YTIME)) +
  imBmswasEmisCoefGLOBIOM("%globiomGHGScen%",runCyL,EMTYPE,"ec",YTIME) *
    SQR(SUM(DSBS$SECtoEF(DSBS,"BMSWAS"), VmConsFuel.L(runCyL,DSBS,"BMSWAS",YTIME)));
$ENDIF
*---