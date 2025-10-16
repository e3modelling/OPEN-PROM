endloop;  !! close countries loop
* Export model results to GDX file
$ifthen.calib %Calibration% == MatCalibration
execute_unload "outputCalib.gdx", ODummyObj, VmCapElec, V04CapElecNominal, VmProdElec, V04ProdElecEstCHP, i04MatFacPlaAvailCap, i04MatureFacPlaDisp, V04SharePowPlaNewEq, t04SharePowPlaNewEq, V04ShareTechPG, V04CostHourProdInvDec, V04ShareSatPG, i04AvailRate, V04DemElecTot, t04DemElecTot,iCarbValYrExog;
$else.calib
execute_unload "outputData.gdx", ODummyObj, VmCapElecTotEst, VmPeakLoad, VmConsFuel, VmCapElec, V04CapElecNominal, VmProdElec, VmPriceFuelSubsecCarVal, VmPriceElecIndResConsu;
$endif.calib
endloop;  !! close outer iteration loop (time steps)
putclose fStat;
$if %WriteGDX% == on execute_unload "blabla.gdx";

$ifthen.calib %Calibration% == MatCalibration
execute 'gdxdump outputCalib.gdx output=i04MatFacPlaAvailCap.csv symb=i04MatFacPlaAvailCap cDim=y format=csv';
execute 'gdxdump outputCalib.gdx output=i04MatureFacPlaDisp.csv symb=i04MatureFacPlaDisp cDim=y format=csv';
$endif.calib