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
VPriceFuelAvgSub.FX(allCy,DSBS,YTIME)$TIME(YTIME) = VPriceFuelAvgSub.L(allCy,DSBS,YTIME)$TIME(YTIME);
VScrRatePc.FX(allCy,YTIME)$TIME(YTIME) = VScrRatePc.L(allCy,YTIME)$TIME(YTIME);
VActivGoodsTransp.FX(allCy,TRANSE,YTIME)$TIME(YTIME) = VActivGoodsTransp.L(allCy,TRANSE,YTIME)$TIME(YTIME);
VConsSpecificFuel.FX(allCy,TRANSE,TTECH,EF,YTIME)$TIME(YTIME) = VConsSpecificFuel.L(allCy,TRANSE,TTECH,EF,YTIME)$TIME(YTIME);
VConsTechTranspSectoral.FX(allCy,TRANSE,TTECH,EF,YTIME)$TIME(YTIME) = VConsTechTranspSectoral.L(allCy,TRANSE,TTECH,EF,YTIME)$TIME(YTIME);
VConsElecNonSubIndTert.FX(allCy,DSBS,YTIME)$TIME(YTIME) = VConsElecNonSubIndTert.L(allCy,DSBS,YTIME)$TIME(YTIME);
VDemFinSubFuelSubSec.FX(allCy,DSBS,YTIME)$TIME(YTIME) = VDemFinSubFuelSubSec.L(allCy,DSBS,YTIME)$TIME(YTIME);
VPriceFuelSubCarVal.FX(allCy,SBS,EF,YTIME)$TIME(YTIME) = VPriceFuelSubCarVal.L(allCy,SBS,EF,YTIME)$TIME(YTIME);
VConsFuelInclHP.FX(allCy,DSBS,EF,YTIME)$TIME(YTIME) = VConsFuelInclHP.L(allCy,DSBS,EF,YTIME)$TIME(YTIME);
VActivPassTrnsp.FX(allCy,TRANSE,YTIME)$TIME(YTIME) = VActivPassTrnsp.L(allCy,TRANSE,YTIME)$TIME(YTIME);
VCostPowGenAvgLng.FX(allCy,ESET,YTIME)$TIME(YTIME) = VCostPowGenAvgLng.L(allCy,ESET,YTIME)$TIME(YTIME);
VPriceElecInd.FX(allCy,YTIME)$TIME(YTIME) = VPriceElecInd.L(allCy,YTIME)$TIME(YTIME);
VCapElecTot.FX(allCy,YTIME)$TIME(YTIME) = VCapElecTot.L(allCy,YTIME)$TIME(YTIME);
VCostPowGenLonNoClimPol.FX(allCy,ESET,YTIME)$TIME(YTIME) = VCostPowGenLonNoClimPol.L(allCy,ESET,YTIME)$TIME(YTIME);
VPeakLoad.FX(allCy,YTIME)$TIME(YTIME) = VPeakLoad.L(allCy,YTIME)$TIME(YTIME);
VCapOverall.FX(runCy,PGALL,YTIME)$TIME(YTIME) = VCapOverall.L(runCy,PGALL,YTIME)$TIME(YTIME);
VConsFuel.FX(runCy,DSBS,EF,YTIME)$TIME(YTIME) = VConsFuel.L(runCy,DSBS,EF,YTIME)$TIME(YTIME);
VIndexEndogScrap.FX(runCy,PGALL,YTIME)$TIME(YTIME) = VIndexEndogScrap.L(runCy,PGALL,YTIME)$TIME(YTIME);
VCapElec.FX(runCy,PGALL,YTIME)$TIME(YTIME) = VCapElec.L(runCy,PGALL,YTIME)$TIME(YTIME);
VCapElec2.FX(runCy,PGALL,YTIME)$TIME(YTIME) = VCapElec2.L(runCy,PGALL,YTIME)$TIME(YTIME);
VNewCapElec.FX(runCy,PGALL,YTIME)$TIME(YTIME) = VNewCapElec.L(runCy,PGALL,YTIME)$TIME(YTIME);
VCFAvgRen.FX(runCy,PGALL,YTIME)$TIME(YTIME) = VCFAvgRen.L(runCy,PGALL,YTIME)$TIME(YTIME);
VCstCO2SeqCsts.FX(runCy,YTIME)$TIME(YTIME) = VCstCO2SeqCsts.L(runCy,YTIME)$TIME(YTIME);
VCapCO2ElecHydr.FX(runCy,YTIME)$TIME(YTIME) = VCapCO2ElecHydr.L(runCy,YTIME)$TIME(YTIME);
VCaptCummCO2.FX(runCy,YTIME)$TIME(YTIME) = VCaptCummCO2.L(runCy,YTIME)$TIME(YTIME);
VCapRef.FX(runCy,YTIME)$TIME(YTIME) = VCapRef.L(runCy,YTIME)$TIME(YTIME);
VTransfers.FX(runCy,EFS,YTIME)$TIME(YTIME) = VTransfers.L(runCy,EFS,YTIME)$TIME(YTIME);
VInputTransfRef.FX(runCy,"CRO",YTIME)$(TIME(YTIME)) = VInputTransfRef.L(runCy,"CRO",YTIME)$(TIME(YTIME));
VProdPrimary.FX(runCy,PPRODEF,YTIME)$TIME(YTIME) = VProdPrimary.L(runCy,PPRODEF,YTIME)$TIME(YTIME);
VCapElecNonCHP.FX(runCy,YTIME)$TIME(YTIME) = VCapElecNonCHP.L(runCy,YTIME)$TIME(YTIME);
VConsFinEneCountry.FX(runCy,EFS,YTIME)$TIME(YTIME) = VConsFinEneCountry.L(runCy,EFS,YTIME)$TIME(YTIME);
VOutTransfRefSpec.FX(runCy,EFS,YTIME)$(TIME(YTIME) $EFtoEFA(EFS,"LQD")) = VOutTransfRefSpec.L(runCy,EFS,YTIME)$(TIME(YTIME) $EFtoEFA(EFS,"LQD"));
VConsFuelInclHP.FX(runCy,DSBS,EF,YTIME)$(TIME(YTIME) $(not TRANSE(DSBS)) $SECTTECH(DSBS,EF)) = VConsFuelInclHP.L(runCy,DSBS,EF,YTIME)$(TIME(YTIME) $(not TRANSE(DSBS)) $SECTTECH(DSBS,EF));
VExp.FX(runCy,EFS,YTIME)$(TIME(YTIME) $IMPEF(EFS)) = VExp.L(runCy,EFS,YTIME)$(TIME(YTIME) $IMPEF(EFS));
VConsGrssInlNotEneBranch.FX(runCy,EFS,YTIME)$TIME(YTIME) =  VConsGrssInlNotEneBranch.L(runCy,EFS,YTIME)$TIME(YTIME);
endloop;  !! close outer iteration loop (time steps)

$if %WriteGDX% == on execute_unload "blabla.gdx";