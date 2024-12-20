
* Fix values of variables for the next time step


* Power Generation Module
VCostPowGenAvgLng.FX(runCyL,ESET,YTIME)$TIME(YTIME) = VCostPowGenAvgLng.L(runCyL,ESET,YTIME)$TIME(YTIME);
VCapElecTotEst.FX(runCyL,YTIME)$TIME(YTIME) = VCapElecTotEst.L(runCyL,YTIME)$TIME(YTIME);
VCostPowGenLonNoClimPol.FX(runCyL,ESET,YTIME)$TIME(YTIME) = VCostPowGenLonNoClimPol.L(runCyL,ESET,YTIME)$TIME(YTIME);
VPeakLoad.FX(runCyL,YTIME)$TIME(YTIME) = VPeakLoad.L(runCyL,YTIME)$TIME(YTIME);
VCapOverall.FX(runCyL,PGALL,YTIME)$TIME(YTIME) = VCapOverall.L(runCyL,PGALL,YTIME)$TIME(YTIME);
VIndxEndogScrap.FX(runCyL,PGALL,YTIME)$TIME(YTIME) = VIndxEndogScrap.L(runCyL,PGALL,YTIME)$TIME(YTIME);
VCapElec.FX(runCyL,PGALL,YTIME)$TIME(YTIME) = VCapElec.L(runCyL,PGALL,YTIME)$TIME(YTIME);
VNewCapElec.FX(runCyL,PGALL,YTIME)$TIME(YTIME) = VNewCapElec.L(runCyL,PGALL,YTIME)$TIME(YTIME);
VCFAvgRen.FX(runCyL,PGALL,YTIME)$TIME(YTIME) = VCFAvgRen.L(runCyL,PGALL,YTIME)$TIME(YTIME);
VCapElecNonCHP.FX(runCyL,YTIME)$TIME(YTIME) = VCapElecNonCHP.L(runCyL,YTIME)$TIME(YTIME);
VCapElec2.FX(runCy,PGALL,YTIME)$TIME(YTIME) = VCapElec2.L(runCy,PGALL,YTIME)$TIME(YTIME);

* Transport Module
VStockPcYearly.FX(runCyL,YTIME)$TIME(YTIME) = VStockPcYearly.L(runCyL,YTIME)$TIME(YTIME);
VMEPcGdp.FX(runCyL,YTIME)$TIME(YTIME) = VMEPcGdp.L(runCyL,YTIME)$TIME(YTIME);
VRateScrPc.FX(runCyL,YTIME)$TIME(YTIME) = VRateScrPc.L(runCyL,YTIME)$TIME(YTIME);
VActivGoodsTransp.FX(runCyL,TRANSE,YTIME)$TIME(YTIME) = VActivGoodsTransp.L(runCyL,TRANSE,YTIME)$TIME(YTIME);
VConsSpecificFuel.FX(runCyL,TRANSE,TTECH,EF,YTIME)$TIME(YTIME) = VConsSpecificFuel.L(runCyL,TRANSE,TTECH,EF,YTIME)$TIME(YTIME);
VConsTechTranspSectoral.FX(runCyL,TRANSE,TTECH,EF,YTIME)$TIME(YTIME) = VConsTechTranspSectoral.L(runCyL,TRANSE,TTECH,EF,YTIME)$TIME(YTIME);
VActivPassTrnsp.FX(runCyL,TRANSE,YTIME)$TIME(YTIME) = VActivPassTrnsp.L(runCyL,TRANSE,YTIME)$TIME(YTIME);

* Industry Module Module
VConsElecNonSubIndTert.FX(runCyL,DSBS,YTIME)$TIME(YTIME) = VConsElecNonSubIndTert.L(runCyL,DSBS,YTIME)$TIME(YTIME);
VDemFinSubFuelSubsec.FX(runCyL,DSBS,YTIME)$TIME(YTIME) = VDemFinSubFuelSubsec.L(runCyL,DSBS,YTIME)$TIME(YTIME);
VConsFuelInclHP.FX(runCyL,DSBS,EF,YTIME)$TIME(YTIME) = VConsFuelInclHP.L(runCyL,DSBS,EF,YTIME)$TIME(YTIME);
VPriceElecInd.FX(runCyL,YTIME)$TIME(YTIME) = VPriceElecInd.L(runCyL,YTIME)$TIME(YTIME);
VConsFuel.FX(runCyL,DSBS,EF,YTIME)$TIME(YTIME) = VConsFuel.L(runCyL,DSBS,EF,YTIME)$TIME(YTIME);
VConsFuelInclHP.FX(runCyL,DSBS,EF,YTIME)$(TIME(YTIME) $(not TRANSE(DSBS)) $SECTTECH(DSBS,EF)) = VConsFuelInclHP.L(runCyL,DSBS,EF,YTIME)$(TIME(YTIME) $(not TRANSE(DSBS)) $SECTTECH(DSBS,EF));

* Rest Of Energy Module
VCapRef.FX(runCyL,YTIME)$TIME(YTIME) = VCapRef.L(runCyL,YTIME)$TIME(YTIME);
VTransfers.FX(runCyL,EFS,YTIME)$TIME(YTIME) = VTransfers.L(runCyL,EFS,YTIME)$TIME(YTIME);
VInputTransfRef.FX(runCyL,"CRO",YTIME)$(TIME(YTIME)) = VInputTransfRef.L(runCyL,"CRO",YTIME)$(TIME(YTIME));
VProdPrimary.FX(runCyL,PPRODEF,YTIME)$TIME(YTIME) = VProdPrimary.L(runCyL,PPRODEF,YTIME)$TIME(YTIME);
VConsFinEneCountry.FX(runCyL,EFS,YTIME)$TIME(YTIME) = VConsFinEneCountry.L(runCyL,EFS,YTIME)$TIME(YTIME);
VOutTransfRefSpec.FX(runCyL,EFS,YTIME)$(TIME(YTIME) $EFtoEFA(EFS,"LQD")) = VOutTransfRefSpec.L(runCyL,EFS,YTIME)$(TIME(YTIME) $EFtoEFA(EFS,"LQD"));
VExp.FX(runCyL,EFS,YTIME)$(TIME(YTIME) $IMPEF(EFS)) = VExp.L(runCyL,EFS,YTIME)$(TIME(YTIME) $IMPEF(EFS));
VConsGrssInlNotEneBranch.FX(runCyL,EFS,YTIME)$TIME(YTIME) =  VConsGrssInlNotEneBranch.L(runCyL,EFS,YTIME)$TIME(YTIME);

* CO2 Sequestration Module
VCstCO2SeqCsts.FX(runCyL,YTIME)$TIME(YTIME) = VCstCO2SeqCsts.L(runCyL,YTIME)$TIME(YTIME);
VCapCO2ElecHydr.FX(runCyL,YTIME)$TIME(YTIME) = VCapCO2ElecHydr.L(runCyL,YTIME)$TIME(YTIME);
VCaptCummCO2.FX(runCyL,YTIME)$TIME(YTIME) = VCaptCummCO2.L(runCyL,YTIME)$TIME(YTIME);

* Emissions Module
*---

* Prices Module
VPriceFuelAvgSub.FX(runCyL,DSBS,YTIME)$TIME(YTIME) = VPriceFuelAvgSub.L(runCyL,DSBS,YTIME)$TIME(YTIME);
VPriceFuelSubsecCarVal.FX(runCyL,SBS,EF,YTIME)$TIME(YTIME) = VPriceFuelSubsecCarVal.L(runCyL,SBS,EF,YTIME)$TIME(YTIME);

endloop;  !! close countries loop
* Export model results to GDX file
execute_unload "outputData.gdx", ODummyObj, VCapElecTotEst, VPeakLoad, VConsFuel, VCapElec, VProdElec, VBaseLoad, VPriceFuelSubsecCarVal, VPriceElecIndResConsu;
endloop;  !! close outer iteration loop (time steps)
putclose fStat;
$if %WriteGDX% == on execute_unload "blabla.gdx";