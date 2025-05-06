endloop;  !! close countries loop
* Export model results to GDX file
execute_unload "outputData.gdx", ODummyObj, VCapElecTotEst, VPeakLoad, VConsFuel, VCapElec, VProdElec, VBaseLoad, VPriceFuelSubsecCarVal, VPriceElecIndResConsu;
endloop;  !! close outer iteration loop (time steps)
putclose fStat;
$if %WriteGDX% == on execute_unload "blabla.gdx";

$ifthen.calib %Calibration% == MatCalibration
execute 'gdxdump blabla.gdx output=iMatFacPlaAvailCapCalib.csv symb=iMatFacPlaAvailCap cDim=y format=csv header="dummy;dummy;value';
execute 'gdxdump blabla.gdx output=iMatureFacPlaDispCalib.csv symb=iMatureFacPlaDisp cDim=y format=csv header="dummy;dummy;value';
$endif.calib