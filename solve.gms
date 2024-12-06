
    sModelStat = 100;
    loop rcc$(rcc.val <= sSolverTryMax) do !! start inner iteration loop (solver attempts)
        if sModelStat gt 2 then
            solve openprom using nlp minimizing vDummyObj;
            sModelStat = openprom.modelstat;
            ODummyObj(runCyL,YTIME)$TIME(YTIME) = vDummyObj.L;  !! Assign objective function value
        endif;
    endloop;


put fStat;
put "Country:", runCyL.tl, " Model Status:", sModelStat:0:2, " Year:", an.tl /;

** MODULE-SPECIFIC POSTSOLVE **
$ifthen %RUN_POWER_GENERATION% == yes
    $include "./modules/01_PowerGeneration/postsolve.gms";
$endif

$ifthen %RUN_TRANSPORT% == yes
    $include "./modules/02_Transport/postsolve.gms";
$endif

$ifthen %RUN_INDUSTRY% == yes
    $include "./modules/03_Industry/postsolve.gms";
$endif

$ifthen %RUN_REST_OF_ENERGY% == yes
    $include "./modules/04_RestOfEnergy/postsolve.gms";
$endif

$ifthen %RUN_CO2% == yes
    $include "./modules/05_CO2/postsolve.gms";
$endif

$ontext
$ifthen %RUN_EMISSIONS% == yes
    $include "./modules/06_Emissions/postsolve.gms";
$endif
$offtext

$ifthen %RUN_PRICES% == yes
    $include "./modules/07_Prices/postsolve.gms";
$endif

endloop;  !! close countries loop
* Export model results to GDX file
*execute_unload "outputData.gdx", ODummyObj, VPriceElecInd, VCapElecTotEst, VPeakLoad, VConsFuel, VCapElec, VProdElec, VBaseLoad;
endloop;  !! close outer iteration loop (time steps)
putclose fStat;
$if %WriteGDX% == on execute_unload "blabla.gdx";