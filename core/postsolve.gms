endloop;  !! close countries loop
$ifthen.curves "%Curves%" == "LearningCurves"
V10CumCapGlobal.FX(LCTECH,YTIME)$TIME(YTIME) = V10CumCapGlobal.L(LCTECH,YTIME)$TIME(YTIME);
$endif.curves
* Export model results to GDX file
$ifthen.calib %Calibration% == MatCalibration
execute_unload "outputCalib.gdx", V03ProdPrimary, V03ConsGrssInl, V03OutTotTransf, VmImpNetEneBrnch, V04GapGenCapPowerDiff, V04CapElecNonCHP, ODummyObj, VmCapElec, VmProdElec, V04ProdElecEstCHP, V01NewRegPcTechYearly, i04MatFacPlaAvailCap, imMatrFactor, V04SharePowPlaNewEq, t04SharePowPlaNewEq, V04ShareTechPG, V04CostHourProdInvDec, V04ShareSatPG, V01ShareTechTr, V04DemElecTot, t01NewShareStockPC, iCarbValYrExog, i02ScaleEndogScrap, i02CalibUsefulEnergy;
$else.calib
execute_unload "outputData.gdx", ODummyObj, VmConsFuel, VmCapElec, V04CapElecNominal, VmProdElec, VmPriceFuelSubsecCarVal;
$endif.calib
endloop;  !! close outer iteration loop (time steps)
putclose fStat;
$if %WriteGDX% == on execute_unload "blabla.gdx";

$ifthen.calib %Calibration% == MatCalibration
execute 'gdxdump outputCalib.gdx output=iMatFacPlaAvailCap.csv symb=i04MatFacPlaAvailCap cDim=y format=csv';
execute 'gdxdump outputCalib.gdx output=iMatrFactorData.csv symb=imMatrFactor cDim=y format=csv';
execute 'gdxdump outputCalib.gdx output=iScaleEndogScrap.csv symb=i02ScaleEndogScrap cDim=y format=csv';
execute 'gdxdump outputCalib.gdx output=iCalibUsefulEnergy.csv symb=i02CalibUsefulEnergy cDim=y format=csv';
$endif.calib
