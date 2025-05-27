endloop;  !! close countries loop
* Export model results to GDX file
execute_unload "outputData.gdx", ODummyObj, VCapElecTotEst, VPeakLoad, VMVConsFuel, VCapElec, VMVProdElec, VBaseLoad, VMVPriceFuelSubsecCarVal, VPriceElecIndResConsu;
endloop;  !! close outer iteration loop (time steps)
putclose fStat;
$if %WriteGDX% == on execute_unload "blabla.gdx";