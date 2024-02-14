    openprom.optfile=1;
    sModelStat = 100;
    loop rcc$(rcc.val <= sSolverTryMax) do !! start inner iteration loop (solver attempts)
        if sModelStat ne 2 then
            solve openprom using nlp maximizing vDummyObj;
            sModelStat = openprom.modelstat;
        endif;
    endloop;    !! close inner iteration loop (solver attempts)

* Fix values of variables for the next time step
VStockPcYearly.FX(allCy,YTIME)$TIME(YTIME) = VStockPcYearly.L(allCy,YTIME)$TIME(YTIME);
VMEPcGdp.FX(allCy,YTIME)$TIME(YTIME) = VMEPcGdp.L(allCy,YTIME)$TIME(YTIME);
VFuelPriceAvg.FX(allCy,DSBS,YTIME)$TIME(YTIME) = VFuelPriceAvg.L(allCy,DSBS,YTIME)$TIME(YTIME);
VScrRatePc.FX(allCy,YTIME)$TIME(YTIME) = VScrRatePc.L(allCy,YTIME)$TIME(YTIME);
VActivGoodsTransp.FX(allCy,TRANSE,YTIME)$TIME(YTIME) = VActivGoodsTransp.L(allCy,TRANSE,YTIME)$TIME(YTIME);
VConsSpecificFuel.FX(allCy,TRANSE,TTECH,EF,YTIME)$TIME(YTIME) = VConsSpecificFuel.L(allCy,TRANSE,TTECH,EF,YTIME)$TIME(YTIME);
VConsTechTranspSectoral.FX(allCy,TRANSE,TTECH,EF,YTIME)$TIME(YTIME) = VConsTechTranspSectoral.L(allCy,TRANSE,TTECH,EF,YTIME)$TIME(YTIME);
VElecNonSub.FX(allCy,DSBS,YTIME)$TIME(YTIME) = VElecNonSub.L(allCy,DSBS,YTIME)$TIME(YTIME);
VDemSub.FX(allCy,DSBS,YTIME)$TIME(YTIME) = VDemSub.L(allCy,DSBS,YTIME)$TIME(YTIME);
VFuelPriceSub.FX(allCy,SBS,EF,YTIME)$TIME(YTIME) = VFuelPriceSub.L(allCy,SBS,EF,YTIME)$TIME(YTIME);
VFuelConsInclHP.FX(allCy,DSBS,EF,YTIME)$TIME(YTIME) = VFuelConsInclHP.L(allCy,DSBS,EF,YTIME)$TIME(YTIME);
VActivPassTrnsp.FX(allCy,TRANSE,YTIME)$TIME(YTIME) = VActivPassTrnsp.L(allCy,TRANSE,YTIME)$TIME(YTIME);
VCostPowGenAvgLng.FX(allCy,ESET,YTIME)$TIME(YTIME) = VCostPowGenAvgLng.L(allCy,ESET,YTIME)$TIME(YTIME);
VElecIndPrices.FX(allCy,YTIME)$TIME(YTIME) = VElecIndPrices.L(allCy,YTIME)$TIME(YTIME);
VTotElecGenCap.FX(allCy,YTIME)$TIME(YTIME) = VTotElecGenCap.L(allCy,YTIME)$TIME(YTIME);
VCostPowGenLonNoClimPol.FX(allCy,ESET,YTIME)$TIME(YTIME) = VCostPowGenLonNoClimPol.L(allCy,ESET,YTIME)$TIME(YTIME);
VLoadPeakElec.FX(allCy,YTIME)$TIME(YTIME) = VLoadPeakElec.L(allCy,YTIME)$TIME(YTIME);
VCapOverall.FX(runCy,PGALL,YTIME)$TIME(YTIME) = VCapOverall.L(runCy,PGALL,YTIME)$TIME(YTIME);
VConsFuel.FX(runCy,DSBS,EF,YTIME)$TIME(YTIME) = VConsFuel.L(runCy,DSBS,EF,YTIME)$TIME(YTIME);
VIndexEndogScrap.FX(runCy,PGALL,YTIME)$TIME(YTIME) = VIndexEndogScrap.L(runCy,PGALL,YTIME)$TIME(YTIME);
VCapGenPlant.FX(runCy,PGALL,YTIME)$TIME(YTIME) = VCapGenPlant.L(runCy,PGALL,YTIME)$TIME(YTIME);
VCapGenPlannedPlant.FX(runCy,PGALL,YTIME)$TIME(YTIME) = VCapGenPlannedPlant.L(runCy,PGALL,YTIME)$TIME(YTIME);
VCapGenNewResPlant.FX(runCy,PGALL,YTIME)$TIME(YTIME) = VCapGenNewResPlant.L(runCy,PGALL,YTIME)$TIME(YTIME);
VCapAvgFacRes.FX(runCy,PGALL,YTIME)$TIME(YTIME) = VCapAvgFacRes.L(runCy,PGALL,YTIME)$TIME(YTIME);
VCO2SeqCsts.FX(runCy,YTIME)$TIME(YTIME) = VCO2SeqCsts.L(runCy,YTIME)$TIME(YTIME);
VCO2ElcHrgProd.FX(runCy,YTIME)$TIME(YTIME) = VCO2ElcHrgProd.L(runCy,YTIME)$TIME(YTIME);
VCumCO2Capt.FX(runCy,YTIME)$TIME(YTIME) = VCumCO2Capt.L(runCy,YTIME)$TIME(YTIME);
VRefCapacity.FX(runCy,YTIME)$TIME(YTIME) = VRefCapacity.L(runCy,YTIME)$TIME(YTIME);
VTransfers.FX(runCy,EFS,YTIME)$TIME(YTIME) = VTransfers.L(runCy,EFS,YTIME)$TIME(YTIME);
VTransfInputRefineries.FX(runCy,"CRO",YTIME)$(TIME(YTIME)) = VTransfInputRefineries.L(runCy,"CRO",YTIME)$(TIME(YTIME));
VPrimProd.FX(runCy,PPRODEF,YTIME)$TIME(YTIME) = VPrimProd.L(runCy,PPRODEF,YTIME)$TIME(YTIME);
VCapGenElecNoChp.FX(runCy,YTIME)$TIME(YTIME) = VCapGenElecNoChp.L(runCy,YTIME)$TIME(YTIME);
VFeCons.FX(runCy,EFS,YTIME)$TIME(YTIME) = VFeCons.L(runCy,EFS,YTIME)$TIME(YTIME);
VTransfOutputRefineries.FX(runCy,EFS,YTIME)$(TIME(YTIME) $EFtoEFA(EFS,"LQD")) = VTransfOutputRefineries.L(runCy,EFS,YTIME)$(TIME(YTIME) $EFtoEFA(EFS,"LQD"));
VFuelConsInclHP.FX(runCy,DSBS,EF,YTIME)$(TIME(YTIME) $(not TRANSE(DSBS)) $SECTTECH(DSBS,EF)) = VFuelConsInclHP.L(runCy,DSBS,EF,YTIME)$(TIME(YTIME) $(not TRANSE(DSBS)) $SECTTECH(DSBS,EF));
VExportsFake.FX(runCy,EFS,YTIME)$(TIME(YTIME) $IMPEF(EFS)) = VExportsFake.L(runCy,EFS,YTIME)$(TIME(YTIME) $IMPEF(EFS));
VGrsInlConsNotEneBranch.FX(runCy,EFS,YTIME)$TIME(YTIME) =  VGrsInlConsNotEneBranch.L(runCy,EFS,YTIME)$TIME(YTIME);
endloop;  !! close outer iteration loop (time steps)

execute_unload "blabla.gdx";