endloop;  !! close countries loop
$ifthen.curves "%Curves%" == "LearningCurves"
V10CumCapGlobal.FX(LCTECH,YTIME)$TIME(YTIME) = V10CumCapGlobal.L(LCTECH,YTIME)$TIME(YTIME);
$endif.curves
* Export model results to GDX file
$ifthen.calib %Calibration% == MatCalibration
execute_unload "outputCalib.gdx", ODummyObj, VmCapElec, VmProdElec, V04ProdElecEstCHP, V01NewRegPcTechYearly, i04MatFacPlaAvailCap, imMatrFactor, i01PremScrpFac, V04SharePowPlaNewEq, t04SharePowPlaNewEq, V04ShareTechPG, V04CostHourProdInvDec, V04ShareSatPG, V01ShareTechTr, i04AvailRate, V04DemElecTot, t01NewShareStockPC, t04DemElecTot, iCarbValYrExog;
$else.calib
execute_unload "outputData.gdx", ODummyObj, VmCapElecTotEst, VmPeakLoad, VmConsFuel, VmCapElec, V04CapElecNominal, VmProdElec, VmPriceFuelSubsecCarVal, VmPriceElecIndResConsu;
$endif.calib
endloop;  !! close outer iteration loop (time steps)
putclose fStat;
$if %WriteGDX% == on execute_unload "blabla.gdx";

$ifthen.calib %Calibration% == MatCalibration
execute 'gdxdump outputCalib.gdx output=iMatFacPlaAvailCap.csv symb=i04MatFacPlaAvailCap cDim=y format=csv';
execute 'gdxdump outputCalib.gdx output=iMatrFactorData.csv symb=imMatrFactor cDim=y format=csv';
$endif.calib
