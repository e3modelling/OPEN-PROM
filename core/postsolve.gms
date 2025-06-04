endloop;  !! close countries loop
* Export model results to GDX file
execute_unload "outputData.gdx",
 ODummyObj,
 VCapElecTotEst,
 VPeakLoad, 
 VConsFuel, 
 VCapElec, 
 VProdElec, 
 VBaseLoad, 
 VPriceFuelSubsecCarVal, 
 VPriceElecIndResConsu, 
 VDemElecTot, 
 VDemTotH2, 
 VDemSecH2, 
 VH2InfrArea,
 VCostTotH2,
 VGapShareH2Tech1,
 VGapShareH2Tech2,
 VDemGapH2,
 VProdH2,
 VConsFuelTechH2Prod,
 VDelivH2InfrTech,
 VCapScrapH2ProdTech,
 VPremRepH2Prod,
 VScrapLftH2Prod,
 VCostProdH2Tech,
 VCostVarProdH2Tech,
 VShareCCSH2Prod,
 VShareNoCCSH2Prod,
 VConsFuelH2Prod,
 VCostProdCCSNoCCSH2Prod,
 VCostAvgProdH2,
 VInvNewReqH2Infra,
 VCostInvTechH2Infr,
 VCostInvCummH2Transp,
 VTariffH2Infr,
 VPriceH2Infr
 ;
endloop;  !! close outer iteration loop (time steps)
putclose fStat;
$if %WriteGDX% == on execute_unload "blabla.gdx";

$ifthen.calib %Calibration% == MatCalibration
execute 'gdxdump blabla.gdx output=iMatFacPlaAvailCap.csv symb=iMatFacPlaAvailCap cDim=y format=csv';
execute 'gdxdump blabla.gdx output=iMatureFacPlaDisp.csv symb=iMatureFacPlaDisp cDim=y format=csv';
$endif.calib