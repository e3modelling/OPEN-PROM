*' @title Prices Preloop
*' @code

*'                *VARIABLE INITIALISATION*
*---
V08PriceFuelSepCarbonWght.LO(runCy,DSBS,EF,YTIME) = 0;
V08PriceFuelSepCarbonWght.L(runCy,DSBS,EF,YTIME) = i08WgtSecAvgPriFueCons(runCy,DSBS,EF);
V08PriceFuelSepCarbonWght.FX(runCy,DSBS,EF,YTIME)$DATAY(YTIME) = i08WgtSecAvgPriFueCons(runCy,DSBS,EF);
*---
$ontext
VmPriceFuelSubsecCHP.FX(runCy,DSBS,EF,YTIME)$((not An(YTIME)) $(not TRANSE(DSBS))  $SECtoEF(DSBS,EF)) =
(((VmPriceFuelSubsecCarVal.L(runCy,DSBS,EF,YTIME)+imVarCostTech(runCy,DSBS,EF,YTIME)/1000)/imUsfEneConvSubTech(runCy,DSBS,EF,YTIME)- 
(0$(not CHP(EF)) + (VmPriceFuelSubsecCarVal.L(runCy,"OI","ELC",YTIME)*smFracElecPriChp*i08ElecIndex(runCy,"2010"))$CHP(EF))) + (0.003) + 
SQRT( SQR(((VmPriceFuelSubsecCarVal.L(runCy,DSBS,EF,YTIME)+imVarCostTech(runCy,DSBS,EF,YTIME)/1000)/imUsfEneConvSubTech(runCy,DSBS,EF,YTIME)- (0$(not CHP(EF)) + 
(VmPriceFuelSubsecCarVal.L(runCy,"OI","ELC",YTIME)*smFracElecPriChp*i08ElecIndex(runCy,"2010"))$CHP(EF)))-(0.003)) + SQR(1e-7) ) )/2;
*---
$offtext
*---
* Init for the BMSWAS price factor (positive; neutral start = 1)
V08BmswasPriceFactor.LO(runCy,YTIME) = 0;
V08BmswasPriceFactor.L(runCy,YTIME)  = 1;
*---
* Initialize the first solved model year from observed base-year global demand:
* tau(t0) = A * (Qworld(base year) / biomassReferenceEJ)^2.
* This binds the policy start to fStartY/fBaseY rather than a calendar year.
$ifthenE.biomassTax %biomassReferenceEJ%>0
i08BmswasPriceAdder("%fStartY%") = i08BmswasTaxScale
  * sqr(
      sum(runCyL, V03ProdPrimary.L(runCyL,"BMSWAS","%fBaseY%"))
      * i08MtoeToEJ / %biomassReferenceEJ%
    );
$else.biomassTax
i08BmswasPriceAdder(YTIME) = 0;
$endif.biomassTax
*---
$IFTHEN %landEmiMode% == curve
* Both emulator backends use the same native-MAgPIE AFOLU history on DATAY.
* TIME values are calculated by the selected backend in postsolve.
imAfoluLandEmis(runCy,EMTYPE,YTIME)$(DATAY(YTIME) $sameas(EMTYPE,"CO2LandUse")) =
  i08AfoluLandCO2Hist(runCy,EMTYPE,YTIME);
imAfoluAgriEmis(runCy,EMTYPE,YTIME)$(DATAY(YTIME) $(sameas(EMTYPE,"CH4LandUse") or sameas(EMTYPE,"N2OLandUse"))) =
  i08AfoluAgriEmisHist(runCy,EMTYPE,YTIME);
$ENDIF
* Init for the BMSWAS bio-supply index variable (positive; neutral start = 1)
V08SupplyCurves.LO(runCy,EFS,YTIME) = 0;
V08SupplyCurves.L(runCy,EFS,YTIME) = 1;
V08SupplyCurves.FX(runCy,EFS,YTIME)$DATAY(YTIME) = 
(
$IFTHEN.bmswasBackend %bmswasPriceMode% == softlink
  iPricesMagpie(runCy,SBS,YTIME)
$ELSEIF.bmswasBackend %bmswasPriceMode% == curve
$IFTHEN.bmswasEmulatorBackend %landUseEmulator% == magpie
  sum((MAGPIEH12REG,activeMagpieScen)$mapMagpieH12Cy(MAGPIEH12REG,runCy),
    i08BmswasPriceH12Magpie(activeMagpieScen,MAGPIEH12REG,"pa",YTIME) +
    i08BmswasPriceH12Magpie(activeMagpieScen,MAGPIEH12REG,"pb",YTIME) * V08Bioenergy2GEffectiveQH12Magpie.L(runCy,YTIME) + 
    i08BmswasPriceH12Magpie(activeMagpieScen,MAGPIEH12REG,"pc",YTIME) * sqr(V08Bioenergy2GEffectiveQH12Magpie.L(runCy,YTIME))
  )
$ELSE.bmswasEmulatorBackend
  1e-3 +
  sum(activeGlobiomScen, i08BmswasSupplyCoefGlobiom(activeGlobiomScen,runCy,"a",YTIME)) + 
  sum(activeGlobiomScen, i08BmswasSupplyCoefGlobiom(activeGlobiomScen,runCy,"b",YTIME)) * 
  V03ProdPrimary.L(runCy,"BMSWAS",YTIME) ** sum(activeGlobiomScen, i08BmswasSupplyCoefGlobiom(activeGlobiomScen,runCy,"c",YTIME)) 
$ENDIF.bmswasEmulatorBackend
$ELSE.bmswasBackend
  1
$ENDIF.bmswasBackend
)$sameas("BMSWAS",EFS) +
1$(not sameas("BMSWAS",EFS));
*---
V08PricePrimary.LO(runCy,EFS,YTIME) = 0;
V08PricePrimary.L(runCy,EFS,YTIME) = 1;
V08PricePrimary.FX(runCy,EFS,YTIME)$DATAY(YTIME) = i08PrimaryPrice(runCy,EFS,YTIME);
V08PricePrimary.FX(runCy,EFS,YTIME)$sameas(EFS,"CRO") = i08PrimaryPrice(runCy,EFS,YTIME);
V08PricePrimary.FX(runCy,EFS,YTIME)$(not PRIM_PRICES(EFS)) = 0;
*---
VmCostAvgProd.LO(runCy,EFS,YTIME) = 0;
VmCostAvgProd.L(runCy,EFS,YTIME) = 1;
VmCostAvgProd.FX(runCy,EFS,YTIME)$DATAY(YTIME) = 
VmCostPowGenAvgLng.L(runCy,YTIME)$sameas("ELC",EFS) +
VmCostAvgProdH2.L(runCy,YTIME)$sameas("H2F",EFS) +
1$sameas("STE",EFS) + !! ERROR
!!VmCostAvgProdSte.L(runCy,YTIME)$sameas("STE",EFS) +
(
  SUM((SSBS,EFS2)$(SECtoEFPROD(SSBS,EFS) and SECtoEF(SSBS,EFS2)),
    (V03InpTotTransf.L(runCy,SSBS,EFS2,YTIME) + VmConsFiEneSec.L(runCy,SSBS,EFS2,YTIME)) * V08PricePrimary.L(runCy,EFS2,YTIME) +
    1e-3 * imFactorEmissProcessesCO2(runCy,SSBS,EFS2,YTIME) * sum(NAP$NAPtoALLSBS(NAP,SSBS), VmCarVal.L(runCy,NAP,YTIME)) * V03InpTotTransf.L(runCy,SSBS,EFS2,YTIME) +
    1e-3 * imFactorEmissEnergyCO2(runCy,SSBS,EFS2) * sum(NAP$NAPtoALLSBS(NAP,SSBS), VmCarVal.L(runCy,NAP,YTIME)) * VmConsFiEneSec.L(runCy,SSBS,EFS2,YTIME) + 1e-3
  ) / SUM((SSBS,EFS2)$(SECtoEFPROD(SSBS,EFS) and SECtoEF(SSBS,EFS2)), V03OutTotTransf.L(runCy,SSBS,EFS2,YTIME) + 1e-3)
)$(sameas("GSL",EFS) or sameas("GDO",EFS)) +
(
  1
)$(not (sameas("ELC",EFS) or sameas("H2F",EFS) or sameas("STE",EFS) or sameas("GSL",EFS) or sameas("GDO",EFS)));
