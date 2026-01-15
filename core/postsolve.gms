endloop;  !! close countries loop
V10CumCapGlobal.FX(LCTECH,YTIME)$TIME(YTIME) = V10CumCapGlobal.L(LCTECH,YTIME)$TIME(YTIME);
* Export model results to GDX file
$ifthen.calib %Calibration% == MatCalibration
execute_unload "outputCalib.gdx", ODummyObj, VmCapElec, V04CapElecNominal, VmProdElec, V04ProdElecEstCHP, i04MatFacPlaAvailCap, imMatrFactor, i01PremScrpFac, V04SharePowPlaNewEq, t04SharePowPlaNewEq, V04ShareTechPG, V04CostHourProdInvDec, V04ShareSatPG, V01ShareTechTr, i04AvailRate, V04DemElecTot, t01StockPC, t04DemElecTot, iCarbValYrExog;
$else.calib
execute_unload "outputData.gdx", ODummyObj, VmCapElecTotEst, VmPeakLoad, VmConsFuel, VmCapElec, V04CapElecNominal, VmProdElec, VmPriceFuelSubsecCarVal, VmPriceElecIndResConsu;
$endif.calib
endloop;  !! close outer iteration loop (time steps)
putclose fStat;
$if %WriteGDX% == on execute_unload "blabla.gdx";

$ifthen.calib %Calibration% == MatCalibration
execute 'gdxdump outputCalib.gdx output=iMatFacPlaAvailCap.csv symb=i04MatFacPlaAvailCap cDim=y format=csv';
execute 'gdxdump outputCalib.gdx output=iMatrFactor.csv symb=imMatrFactor cDim=y format=csv';
execute 'gdxdump outputCalib.gdx output=iPremScrpFac.csv symb=i01PremScrpFac cDim=y format=csv';
$endif.calib
