*' @title Prices postsolve
* Fix values of variables for the next time step

* Prices Module

*---
VmPriceFuelAvgSub.FX(runCyL,DSBS,YTIME)$TIME(YTIME) = VmPriceFuelAvgSub.L(runCyL,DSBS,YTIME)$TIME(YTIME);
VmPriceFuelSubsecCarVal.FX(runCyL,SBS,EF,YTIME)$TIME(YTIME) = VmPriceFuelSubsecCarVal.L(runCyL,SBS,EF,YTIME)$TIME(YTIME);
VmPriceElecInd.FX(runCyL,TCHP,YTIME)$TIME(YTIME) = VmPriceElecInd.L(runCyL,TCHP,YTIME)$TIME(YTIME);
V08PriceFuelSepCarbonWght.FX(runCyL,DSBS,EF,YTIME)$TIME(YTIME) = V08PriceFuelSepCarbonWght.L(runCyL,DSBS,EF,YTIME)$TIME(YTIME);
*---
*' Land-use emulator emission accounting (landEmiMode == curve only)
*'
*' GLOBIOM:
*'   CO2 = ea + eb*BMSWAS; agriculture CH4/N2O are direct table values.
*' MAgPIE:
*'   effective Q = 0.4*BMSWAS + 0.6*(BGSL+BKRS+BGAS);
*'   land-use-change CO2 emissions/removals, excluding indirect land CO2 and fire emissions,
*'   use OP39 coefficients and requested H12 Q, with non-EUR
*'   regions using current Q and EU28 using preceding-year EUR Q;
*'   agriculture CH4/N2O use current OP39 Q and are bounded at zero.
$IFTHEN %landEmiMode% == curve
$IFTHEN.emulatorEmissions %landUseEmulator% == globiom
* GLOBIOM land CO2 and agriculture CH4/N2O.
imAfoluLandEmis(runCyL,EMTYPE,YTIME)$(TIME(YTIME) $sameas(EMTYPE,"CO2LandUse")) =
  sum(activeGlobiomScen,
      i08LandCO2CoefGlobiom(activeGlobiomScen,runCyL,EMTYPE,"ea",YTIME)
    + i08LandCO2CoefGlobiom(activeGlobiomScen,runCyL,EMTYPE,"eb",YTIME)
      * V03ProdPrimary.L(runCyL,"BMSWAS",YTIME)
  );
imAfoluAgriEmis(runCyL,EMTYPE,YTIME)$(TIME(YTIME) $(sameas(EMTYPE,"CH4LandUse") or sameas(EMTYPE,"N2OLandUse"))) =
  sum(activeGlobiomScen,
    i08AgriEmisGlobiom(activeGlobiomScen,runCyL,EMTYPE,YTIME)
  );
$ELSEIF.emulatorEmissions %landUseEmulator% == magpie
* Current-year OP39 effective 2G Q for agriculture emissions.
i08Bioenergy2GEffectiveQMagpie(runCyL,YTIME)$TIME(YTIME) =
  sum(EFS$i08Bioenergy2GWeightMagpie(EFS),
    i08Bioenergy2GWeightMagpie(EFS) * V03ProdPrimary.L(runCyL,EFS,YTIME)
  );

* H12 effective 2G Q for Land-use Change CO2; EU28 share preceding-year EUR Q.
i08Bioenergy2GEffectiveQH12Magpie(runCyL,YTIME)$TIME(YTIME) =
  V08Bioenergy2GEffectiveQH12Magpie.L(runCyL,YTIME);

* Land-use Change CO2 is signed: negative values are retained and not clamped.
imAfoluLandEmis(runCyL,EMTYPE,YTIME)$(TIME(YTIME) $sameas(EMTYPE,"CO2LandUse")) =
  sum(activeMagpieScen,
      i08LandCO2CoefMagpie(activeMagpieScen,runCyL,EMTYPE,"ea",YTIME)
    + i08LandCO2CoefMagpie(activeMagpieScen,runCyL,EMTYPE,"eb",YTIME)
        * i08Bioenergy2GEffectiveQH12Magpie(runCyL,YTIME)
    + i08LandCO2CoefMagpie(activeMagpieScen,runCyL,EMTYPE,"ec",YTIME)
        * sqr(i08Bioenergy2GEffectiveQH12Magpie(runCyL,YTIME))
  );

* Agriculture CH4/N2O are non-negative; fitted coefficients remain signed.
imAfoluAgriEmis(runCyL,EMTYPE,YTIME)$(TIME(YTIME) $(sameas(EMTYPE,"CH4LandUse") or sameas(EMTYPE,"N2OLandUse"))) =
  max(0,
    sum(activeMagpieScen,
        i08AgriEmisCoefMagpie(activeMagpieScen,runCyL,EMTYPE,"ea",YTIME)
      + i08AgriEmisCoefMagpie(activeMagpieScen,runCyL,EMTYPE,"eb",YTIME)
          * i08Bioenergy2GEffectiveQMagpie(runCyL,YTIME)
      + i08AgriEmisCoefMagpie(activeMagpieScen,runCyL,EMTYPE,"ec",YTIME)
          * sqr(i08Bioenergy2GEffectiveQMagpie(runCyL,YTIME))
    )
  );
$ENDIF.emulatorEmissions
$ENDIF
*---
