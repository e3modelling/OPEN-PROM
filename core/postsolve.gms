endloop;  !! close countries loop
* Export model results to GDX file
execute_unload "outputData.gdx", ODummyObj, VMCapElecTotEst, VMPeakLoad, VMConsFuel, VMCapElec, V04CapElecNominal, VMProdElec, VMBaseLoad, VMPriceFuelSubsecCarVal, VMPriceElecIndResConsu;
endloop;  !! close outer iteration loop (time steps)
putclose fStat;
$if %WriteGDX% == on execute_unload "blabla.gdx";

$ifthen.calib %Calibration% == MatCalibration
execute 'gdxdump blabla.gdx output=iMatFacPlaAvailCap.csv symb=iMatFacPlaAvailCap cDim=y format=csv';
execute 'gdxdump blabla.gdx output=iMatureFacPlaDisp.csv symb=iMatureFacPlaDisp cDim=y format=csv';
$endif.calib