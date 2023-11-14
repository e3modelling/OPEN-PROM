    openprom.optfile=1;
    sModelStat = 100;
    loop rcc$(rcc.val <= sSolverTryMax) do !! start inner iteration loop (solver attempts)
        if sModelStat ne 2 then
            solve openprom using nlp maximizing vDummyObj;
            sModelStat = openprom.modelstat;
        endif;
    endloop;    !! close inner iteration loop (solver attempts)

* Fix values of variables for the next time step
VNumVeh.FX(allCy,YTIME)$TIME(YTIME) = VNumVeh.L(allCy,YTIME)$TIME(YTIME);
VMExtV.FX(allCy,YTIME)$TIME(YTIME) = VMExtV.L(allCy,YTIME)$TIME(YTIME);
VFuelPriceAvg.FX(allCy,DSBS,YTIME)$TIME(YTIME) = VFuelPriceAvg.L(allCy,DSBS,YTIME)$TIME(YTIME);
VScrRate.FX(allCy,YTIME)$TIME(YTIME) = VScrRate.L(allCy,YTIME)$TIME(YTIME);
VGoodsTranspActiv.FX(allCy,TRANSE,YTIME)$TIME(YTIME) = VGoodsTranspActiv.L(allCy,TRANSE,YTIME)$TIME(YTIME);
VSpecificFuelCons.FX(allCy,TRANSE,TTECH,TEA,EF,YTIME)$TIME(YTIME) = VSpecificFuelCons.L(allCy,TRANSE,TTECH,TEA,EF,YTIME)$TIME(YTIME);
VConsEachTechTransp.FX(allCy,TRANSE,TTECH,EF,TEA,YTIME)$TIME(YTIME) = VConsEachTechTransp.L(allCy,TRANSE,TTECH,EF,TEA,YTIME)$TIME(YTIME);
VElecNonSub.FX(allCy,DSBS,YTIME)$TIME(YTIME) = VElecNonSub.L(allCy,DSBS,YTIME)$TIME(YTIME);
VDemSub.FX(allCy,DSBS,YTIME)$TIME(YTIME) = VDemSub.L(allCy,DSBS,YTIME)$TIME(YTIME);
VFuelPriceSub.FX(allCy,SBS,EF,YTIME)$TIME(YTIME) = VFuelPriceSub.L(allCy,SBS,EF,YTIME)$TIME(YTIME);
VFuelConsInclHP.FX(allCy,DSBS,EF,YTIME)$TIME(YTIME) = VFuelConsInclHP.L(allCy,DSBS,EF,YTIME)$TIME(YTIME);
endloop;  !! close outer iteration loop (time steps)

*execute_unload "blabla.gdx";