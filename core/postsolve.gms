endloop;  !! close countries loop
* Export model results to GDX file
execute_unload "outputData.gdx", ODummyObj, VCapElecTotEst, VPeakLoad, VMVConsFue, VCapElec, VProdElec, VBaseLoad, VPriceFuelSubsecCarVal, VPriceElecIndResConsu;
endloop;  !! close outer iteration loop (time steps)
putclose fStat;
$if %WriteGDX% == on execute_unload "blabla.gdx";