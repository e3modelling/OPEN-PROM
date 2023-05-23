* Calculation of polynomial distribution lags coefficients
iNPDL(DSBS) = 6;
loop DSBS do
   loop KPDL$(ord(KPDL) le iNPDL(DSBS)) do
         iFPDL(DSBS,KPDL) = 6 * (iNPDL(DSBS)+1-ord(KPDL)) * ord(KPDL)
                           /
                           (iNPDL(DSBS) * (iNPDL(DSBS)+1) * (iNPDL(DSBS)+2))
   endloop;
endloop;

model openprom /all/;


option iGDP:2:0:6;
display iCapGrossCosPlanType;
display iFixGrosCostPlaType;
display iCGI;
display iDisc;
display TF;
display TFIRST;
display iPlantAvailRate;
display iCo2EmiFac;

*TIME(YTIME) = %fStartY%;
VFuelPrice.l(allCy,TRANSE,YTIME) = 0.1;
VNumVeh.l(allCy,YTIME) = 0.1;
VTrnspActiv.l(allCy,TRANSE,YTIME) = 0.1;
VFuelPrice.l(allCy,DSBS,YTIME) =1;
VFuelPriceSub.l(allCy,SBS,EF,YTIME) = 0.1;
VElecIndPrices.l(allCy,YTIME)= 0.1;
VTechCostVar.l(allCy,SBS,EF,TEA,YTIME) = 0.1;
VTechCostIntrm.l(allCy,DSBS,rcon,EF,TEA,YTIME) = 0.1;
VLifeTimeTech.l(allCy,DSBS,EF,TEA,YTIME)= 0.1;
VTechSort.l(allCy,DSBS,rCon,YTIME) = 0.1;
VMatrFactor.l(allCy,SBS,EF,TEA,YTIME) =0.1;
VConsFuel.l(allCy,DSBS,EF,YTIME)=0.1;
VRefCapacity.l(allCy,YTIME)=0.1;
VTotFinEneCons.l(allCy,EF,YTIME)=0.1;  
VTransfOutputRefineries.l(allCy,EFS,YTIME)=0.1;
VPlantEffPlantType.l(allCy,PGALL,YTIME)=0.1;	
VGrsInlConsNotEneBranch.l(allCy,EFS,YTIME)=0.1;
VElecConsAll.l(allCy,DSBS,YTIME)=0.1;
VCapChpPlants.l(allCy,YTIME)=0.1;
VElecPeakLoad.l(allCy,YTIME)=0.1;
VElecPeakLoad.up(allCy,YTIME)=1e6;
VHourProdTech.up(allCy,PGALL,HOUR,YTIME)=1e6;
VSensCcs.l(allCy,YTIME)=1;
VHourProdTech.l(allCy,PGALL,HOUR,YTIME)=1;
VCarVal.l(allCy,NAP,YTIME)=1;
VFuelPriceSub.l(allCy,"PG",PGEF,YTIME)=1;
VProdCostTechnology.l(allCy,PGALL2,YTIME)=0.1;
VProdCostTechnology.up(allCy,PGALL2,YTIME)=1e6;
VVarCostTech.l(allCy,PGALL,YTIME)=0.1;
VProdCostTechPreReplacAvail.l(allCy,PGALL,PGALL2,YTIME)=0.1;
*VHourProdCostTech.up(allCy,PGALL,HOUR,YTIME)=8000;
*VHourProdCostTech.l(allCy,PGALL,HOUR,YTIME)=10;
*VTemScalWeibull.up(allCy,PGALL,HOUR,YTIME)=1e6;
*VHourProdCostTech.lo(allCy,PGALL,HOUR,YTIME)=0.0001;
VRenPotSupplyCurve.l(allCy,PGRENEF,YTIME)=0.1;
VScrRate.l(allCy,YTIME)=0.1;
$ontext

VPowerPlantNewEq.l(allCy,PGALL,TT)=0.1;
VHourProdCostOfTech.l(allCy,PGALL,HOUR,TT)=0.1;
VPowerPlaShrNewEq.l(allCy,PGALL,TT)=0.1;
VHourProdCostTech.l(runCy,PGALL,HOUR,TT)$period(ytime) = VPowerPlantNewEq.l(runCy,PGALL,TT)*VHourProdCostOfTech.l(runCy,PGALL,HOUR,TT)+
         sum(CCS$CCS_NOCCS(CCS,PGALL), VPowerPlaShrNewEq.L(runCy,CCS,TT)*VHourProdCostOfTech.L(runCy,CCS,HOUR,TT));
VHourProdCostTech.SCALE(runCy,PGALL,HOUR,TT)$PERIOD(ytime) = max(abs(VHourProdCostTech.l(runCy,PGALL,HOUR,TT)),1E-20);
$offtext
VNewInvDecis.l(allCy,YTIME)=0.1;
VVarCostTechnology.l(allCy,PGALL,YTIME)=0.1;
VElecPeakLoads.l(allCy,YTIME)=0.1;
VNewCapYearly.l(allCy,PGALL,YTIME)=0.1;
VAvgCapFacRes.l(allCy,PGALL,YTIME)=0.1;
*VOverallCap.scale(allCy,PGALL,YTIME)=1;
VPowPlantSorting.l(runCy,PGALL,YTIME)=0.01;
VReqElecProd.l(runCy,YTIME)=0.1;
*VPowPlantSorting.up(runCy,PGALL,YTIME)=0.001;
*VPowPlantSorting.scale(runCy,PGALL,YTIME)=1;
VElecDem.l(allCy,YTIME)=0.1;
VHourProdTech.lo(runCy,PGALL,HOUR,YTIME)=0.1;
VHourProdCostTech.lo(runCy,PGALL,HOUR,YTIME)=0.1;
VRenTechMatMult.l(allCy,PGALL,YTIME)=0.1;
VGoodsTranspActiv.l(allCy,TRANSE,YTIME)=0.1;
*VTranspCostPerVeh.lo(allCy,TRANSE,RCon,TTECH,TEA,YTIME)=0.1;
loop an do
   i = i + 1;
   TIME(YTIME) = NO;
   TIME(AN)$(ord(an)=i) = YES;
   display TIME;