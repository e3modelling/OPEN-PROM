endloop;  !! close countries loop
* Export model results to GDX file
execute_unload "outputData.gdx", ODummyObj, VmCapElecTotEst, VmPeakLoad, VmConsFuel, VmCapElec, V04CapElecNominal, VmProdElec, VmBaseLoad, VmPriceFuelSubsecCarVal, VmPriceElecIndResConsu;
endloop;  !! close outer iteration loop (time steps)
putclose fStat;
$if %WriteGDX% == on execute_unload "blabla.gdx";

$ifthen.calib %Calibration% == MatCalibration
execute 'gdxdump blabla.gdx output=i04MatFacPlaAvailCap.csv symb=i04MatFacPlaAvailCap cDim=y format=csv';
execute 'gdxdump blabla.gdx output=i04MatureFacPlaDisp.csv symb=i04MatureFacPlaDisp cDim=y format=csv';
$endif.calib