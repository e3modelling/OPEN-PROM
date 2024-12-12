*' @title Emissions Constraints postsolve
* Fix values of variables for the next time step

* Emissions Module
$ifthen.emissions %RUN_EMISSIONS% == yes
$endif.emissions

* Export model results to GDX file
*execute_unload "outputData.gdx", ODummyObj, VPriceElecInd, VCapElecTotEst, VPeakLoad, VConsFuel, VCapElec, VProdElec, VBaseLoad;