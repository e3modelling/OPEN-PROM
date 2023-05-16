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
display iGDP;


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