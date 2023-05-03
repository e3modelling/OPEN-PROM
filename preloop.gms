iCGI(allCy,YTIME) = 1;


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
VFuelPrice.l(allCy,TRANSE,YTIME) = 1;
VNumVeh.l(allCy,YTIME) = 1;
VTrnspActiv.l(allCy,TRANSE,YTIME) = 1;
VFuelPrice.l(allCy,DSBS,YTIME) =1;
VFuelPriceSub.l(allCy,SBS,EF,YTIME) =1;
VElecIndPrices.l(allCy,YTIME)=1;
VTechCostVar.l(allCy,SBS,EF,TEA,YTIME) = 1;
VTechCostIntrm.l(allCy,DSBS,rcon,EF,TEA,YTIME) =1;
VLifeTimeTech.l(allCy,DSBS,EF,TEA,YTIME)=1;
