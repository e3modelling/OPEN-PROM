
    sModelStat = 100;
    loop rcc$(rcc.val <= sSolverTryMax) do !! start inner iteration loop (solver attempts)
        if sModelStat gt 2 then
            solve openprom using nlp maximizing vDummyObj;
            sModelStat = openprom.modelstat;
        endif;
    endloop;    !! close inner iteration loop (solver attempts)

* Fix values of variables for the next time step
VNumVeh.FX(runCy,YTIME)$TIME(YTIME) = VNumVeh.L(runCy,YTIME)$TIME(YTIME);
VMExtV.FX(runCy,YTIME)$TIME(YTIME) = VMExtV.L(runCy,YTIME)$TIME(YTIME);
VFuelPriceAvg.FX(runCy,DSBS,YTIME)$TIME(YTIME) = VFuelPriceAvg.L(runCy,DSBS,YTIME)$TIME(YTIME);
VScrRate.FX(runCy,YTIME)$TIME(YTIME) = VScrRate.L(runCy,YTIME)$TIME(YTIME);
VGoodsTranspActiv.FX(runCy,TRANSE,YTIME)$TIME(YTIME) = VGoodsTranspActiv.L(runCy,TRANSE,YTIME)$TIME(YTIME);
VSpecificFuelCons.FX(runCy,TRANSE,TTECH,EF,YTIME)$TIME(YTIME) = VSpecificFuelCons.L(runCy,TRANSE,TTECH,EF,YTIME)$TIME(YTIME);
VConsEachTechTransp.FX(runCy,TRANSE,TTECH,EF,YTIME)$TIME(YTIME) = VConsEachTechTransp.L(runCy,TRANSE,TTECH,EF,YTIME)$TIME(YTIME);
VElecNonSub.FX(runCy,DSBS,YTIME)$TIME(YTIME) = VElecNonSub.L(runCy,DSBS,YTIME)$TIME(YTIME);
VDemSub.FX(runCy,DSBS,YTIME)$TIME(YTIME) = VDemSub.L(runCy,DSBS,YTIME)$TIME(YTIME);
VFuelPriceSub.FX(runCy,SBS,EF,YTIME)$TIME(YTIME) = VFuelPriceSub.L(runCy,SBS,EF,YTIME)$TIME(YTIME);
VFuelConsInclHP.FX(runCy,DSBS,EF,YTIME)$TIME(YTIME) = VFuelConsInclHP.L(runCy,DSBS,EF,YTIME)$TIME(YTIME);
VTrnspActiv.FX(runCy,TRANSE,YTIME)$TIME(YTIME) = VTrnspActiv.L(runCy,TRANSE,YTIME)$TIME(YTIME);
VLongAvgPowGenCost.FX(runCy,ESET,YTIME)$TIME(YTIME) = VLongAvgPowGenCost.L(runCy,ESET,YTIME)$TIME(YTIME);
VElecIndPrices.FX(runCy,YTIME)$TIME(YTIME) = VElecIndPrices.L(runCy,YTIME)$TIME(YTIME);
VTotElecGenCap.FX(runCy,YTIME)$TIME(YTIME) = VTotElecGenCap.L(runCy,YTIME)$TIME(YTIME);
VLonPowGenCostNoClimPol.FX(runCy,ESET,YTIME)$TIME(YTIME) = VLonPowGenCostNoClimPol.L(runCy,ESET,YTIME)$TIME(YTIME);
VElecPeakLoad.FX(runCy,YTIME)$TIME(YTIME) = VElecPeakLoad.L(runCy,YTIME)$TIME(YTIME);
VOverallCap.FX(runCy,PGALL,YTIME)$TIME(YTIME) = VOverallCap.L(runCy,PGALL,YTIME)$TIME(YTIME);
VConsFuel.FX(runCy,DSBS,EF,YTIME)$TIME(YTIME) = VConsFuel.L(runCy,DSBS,EF,YTIME)$TIME(YTIME);
VEndogScrapIndex.FX(runCy,PGALL,YTIME)$TIME(YTIME) = VEndogScrapIndex.L(runCy,PGALL,YTIME)$TIME(YTIME);
VElecGenPlantsCapac.FX(runCy,PGALL,YTIME)$TIME(YTIME) = VElecGenPlantsCapac.L(runCy,PGALL,YTIME)$TIME(YTIME);
VElecGenPlanCap.FX(runCy,PGALL,YTIME)$TIME(YTIME) = VElecGenPlanCap.L(runCy,PGALL,YTIME)$TIME(YTIME);
VNewCapYearly.FX(runCy,PGALL,YTIME)$TIME(YTIME) = VNewCapYearly.L(runCy,PGALL,YTIME)$TIME(YTIME);
VAvgCapFacRes.FX(runCy,PGALL,YTIME)$TIME(YTIME) = VAvgCapFacRes.L(runCy,PGALL,YTIME)$TIME(YTIME);
VCO2SeqCsts.FX(runCy,YTIME)$TIME(YTIME) = VCO2SeqCsts.L(runCy,YTIME)$TIME(YTIME);
VCO2ElcHrgProd.FX(runCy,YTIME)$TIME(YTIME) = VCO2ElcHrgProd.L(runCy,YTIME)$TIME(YTIME);
VCumCO2Capt.FX(runCy,YTIME)$TIME(YTIME) = VCumCO2Capt.L(runCy,YTIME)$TIME(YTIME);
VRefCapacity.FX(runCy,YTIME)$TIME(YTIME) = VRefCapacity.L(runCy,YTIME)$TIME(YTIME);
VTransfers.FX(runCy,EFS,YTIME)$TIME(YTIME) = VTransfers.L(runCy,EFS,YTIME)$TIME(YTIME);
VTransfInputRefineries.FX(runCy,"CRO",YTIME)$(TIME(YTIME)) = VTransfInputRefineries.L(runCy,"CRO",YTIME)$(TIME(YTIME));
VPrimProd.FX(runCy,PPRODEF,YTIME)$TIME(YTIME) = VPrimProd.L(runCy,PPRODEF,YTIME)$TIME(YTIME);
VElecGenNoChp.FX(runCy,YTIME)$TIME(YTIME) = VElecGenNoChp.L(runCy,YTIME)$TIME(YTIME);
VFeCons.FX(runCy,EFS,YTIME)$TIME(YTIME) = VFeCons.L(runCy,EFS,YTIME)$TIME(YTIME);
VTransfOutputRefineries.FX(runCy,EFS,YTIME)$(TIME(YTIME) $EFtoEFA(EFS,"LQD")) = VTransfOutputRefineries.L(runCy,EFS,YTIME)$(TIME(YTIME) $EFtoEFA(EFS,"LQD"));
VFuelConsInclHP.FX(runCy,DSBS,EF,YTIME)$(TIME(YTIME) $(not TRANSE(DSBS)) $SECTTECH(DSBS,EF)) = VFuelConsInclHP.L(runCy,DSBS,EF,YTIME)$(TIME(YTIME) $(not TRANSE(DSBS)) $SECTTECH(DSBS,EF));
VExportsFake.FX(runCy,EFS,YTIME)$(TIME(YTIME) $IMPEF(EFS)) = VExportsFake.L(runCy,EFS,YTIME)$(TIME(YTIME) $IMPEF(EFS));
VGrsInlConsNotEneBranch.FX(runCy,EFS,YTIME)$TIME(YTIME) =  VGrsInlConsNotEneBranch.L(runCy,EFS,YTIME)$TIME(YTIME);
endloop;  !! close countries loop
endloop;  !! close outer iteration loop (time steps)

$if %WriteGDX% == on execute_unload "blabla.gdx";