*' @title Preloop
*' @code
*' * Calculation of polynomial distribution lags coefficients
iNPDL(DSBS) = 6;
loop DSBS do
   loop KPDL$(ord(KPDL) le iNPDL(DSBS)) do
         iFPDL(DSBS,KPDL) = 6 * (iNPDL(DSBS)+1-ord(KPDL)) * ord(KPDL)
                           /
                           (iNPDL(DSBS) * (iNPDL(DSBS)+1) * (iNPDL(DSBS)+2))
   endloop;
endloop;

model openprom /

*' * Power Generation *

qCurrRenPot                        !! vCurrRenPot(runCy,PGRENEF,YTIME)
QChpElecPlants                     !! VElecCapChpPla(runCy,CHP,YTIME)
*QLambda                           !! VLoadCurveConstr(runCy,YTIME)
QElecDem                           !! VElecDem(runCy,YTIME)
*QEstBaseLoad                      !! VEstBaseLoad(runCy,YTIME)
QLoadFacDom                        !! VLoadFacDom(runCy,YTIME)
QElecPeakLoad                      !! VElecPeakLoad(runCy,YTIME)
QBslMaxmLoad                       !! VBslMaxmLoad(runCy,YTIME)
QElecBaseLoad                      !! VCorrBaseLoad(runCy,YTIME)
QTotReqElecProd                    !! VTotReqElecProd(runCy,YTIME)
QTotEstElecGenCap                  !! VTotElecGenCapEst(runCy,YTIME)
QTotElecGenCap                     !! VTotElecGenCap(runCy,YTIME)	
QHourProdCostInv                   !! VHourProdCostTech(runCy,PGALL,HOUR,YTIME)
QHourProdCostInvDec                !! VHourProdCostTechNoCCS(runCy,PGALL,HOUR,YTIME)
QGammaInCcsDecTree                 !! VSensCcs(runCy,YTIME)
qHourProdCostInvDecisionsAfterCCS  !! vHourProdCostTechAfterCCS(runCy,PGALL,HOUR,YTIME) 
QProdCostInvDecis                  !! VProdCostTechnology(runCy,PGALL,YTIME)
QShrcap                            !! VPowerPlaShrNewEq(runCy,PGALL,YTIME)
QShrcapNoCcs                       !! VPowerPlantNewEq(runCy,PGALL,YTIME)
QVarCostTech                       !! VVarCostTech(runCy,PGALL,YTIME)
QVarCostTechNotPGSCRN              !! VVarCostTechNotPGSCRN(runCy,PGALL,YTIME)
QProdCostTechPreReplac             !! VProdCostTechPreReplac(runCy,PGALL,YTIME)
QProdCostTechPreReplacAvail        !! VProdCostTechPreReplacAvail(runCy,PGALL,PGALL2,YTIME)
*QEndogScrapIndex                  !! VEndogScrapIndex(runCy,PGALL,YTIME)
QElecGenNoChp                      !! VElecGenNoChp(runCy,YTIME)
*QGapPowerGenCap                   !! VGapPowerGenCap(runCy,YTIME)
qScalWeibull                       !! vScalWeibull(runCy,PGALL,HOUR,YTIME) 
QRenPotSupplyCurve                 !! VRenPotSupplyCurve(runCy,PGRENEF,YTIME)
QMaxmAllowRenPotent                !! VMaxmAllowRenPotent(runCy,PGRENEF,YTIME)
QMnmAllowRenPot                    !! VMnmAllowRenPot(runCy,PGRENEF,YTIME)
*QRenTechMatMult                   !! VRenTechMatMult(runCy,PGALL,YTIME)
*QScalWeibullSum                   !! VScalWeibullSum(runCy,PGALL,YTIME)
*QNewInvDecis                      !! VNewInvDecis(runCy,YTIME)
*QPowPlaShaNewEquip                !! VPowPlaShaNewEquip(runCy,PGALL,YTIME)
*QElecGenCapacity                  !! VElecGenPlantsCapac(runCy,PGALL,YTIME)
*QElecGenCap                       !! VElecGenPlanCap(runCy,PGALL,YTIME)
QVarCostTechnology                 !! VVarCostTechnology(runCy,PGALL,YTIME)
QElecPeakLoads                     !! VElecPeakLoads(runCy,YTIME) 
QElectrPeakLoad                    !! VPowPlantSorting(runCy,PGALL,YTIME)
*QNewCapYearly                     !! VNewCapYearly(runCy,PGALL,YTIME)
*QAvgCapFacRes                     !! VAvgCapFacRes(runCy,PGALL,YTIME)
*QOverallCap                       !! VOverallCap(runCy,PGALL,YTIME)
*QScalFacPlantDispatch             !! -
*QElecChpPlants                    !! VElecChpPlants(runCy,YTIME) 
*QNonChpElecProd                   !! VNonChpElecProd(runCy,YTIME) 
*QReqElecProd                      !! VReqElecProd(runCy,YTIME) 
*QElecProdPowGenPlants             !! VElecProdPowGenPlants(runCy,PGALL,YTIME)
*qSecContrTotChpProd               !! vSecContrTotChpProd(runCy,INDDOM,CHP,YTIME)
QElecProdChpPlants                 !! VChpElecProd(runCy,CHP,YTIME)
qShareRenGrossElecProd             !! vResShareGrossElecProd(runCy,YTIME) 
QLonPowGenCostTechNoCp             !! VLongPowGenCost(runCy,PGALL,ESET,YTIME)
*qLonMnmpowGenCost                 !! vLonMnmpowGenCost(runCy,PGALL,YTIME)
*qLongPowGenIntPri                 !! vLongPowGenIntPri(runCy,PGALL,ESET,YTIME)
*qShoPowGenIntPri                  !! vShoPowGenIntPri(runCy,PGALL,ESET,YTIME)
QLongPowGenCost                    !! VLongAvgPowGenCost(runCy,ESET,YTIME)
QLonAvgPowGenCostNoClimPol         !! VLonAvgPowGenCostNoClimPol(runCy,PGALL,ESET,YTIME)
QLonPowGenCostNoClimPol            !! VLonPowGenCostNoClimPol(runCy,ESET,YTIME)
QElecPriIndResNoCliPol             !! VElecPriIndResNoCliPol(runCy,ESET,YTIME)
*qShortPowGenCost                  !! vAvgPowerGenCostShoTrm(runCy,ESET,YTIME)


*' * Transport *

QPassCarsLft                       !! VLifeTimeTech(runCy,DSBS,EF,TEA,YTIME)
QGoodsTranspActiv                  !! VGoodsTranspActiv(runCy,TRANSE,YTIME)
QGapTranspActiv                    !! VGapTranspFillNewTech(runCy,TRANSE,YTIME)
QSpecificFuelCons                  !! VSpecificFuelCons(runCy,TRANSE,TTECH,TEA,EF,YTIME)
QTranspCostPerMeanConsSize         !! VTranspCostPermeanConsSize(runCy,TRANSE,rCon,TTECH,TEA,YTIME)
QTranspCostPerVeh                  !! VTranspCostPerVeh(runCy,TRANSE,rCon,TTECH,TEA,YTIME)
QTranspCostMatFac                  !! VTranspCostMatFac(runCy,TRANSE,RCon,TTECH,TEA,YTIME) 
QTechSortVarCost                   !! VTechSortVarCost(runCy,TRANSE,rCon,YTIME)
QTechSortVarCostNewEquip           !! VTechSortVarCostNewEquip(runCy,TRANSE,TTECH,TEA,YTIME)
QConsEachTechTransp                !! VConsEachTechTransp(runCy,TRANSE,TTECH,EF,TEA,YTIME)
QFinEneDemTranspPerFuel            !! VDemTr(runCy,TRANSE,EF,YTIME)
qFinEneDemTransp                   !! vFinEneDemTranspSub(runCy,TRANSE,YTIME)
QMExtV                             !! VMExtV(runCy,YTIME)
QMExtF                             !! VMExtF(runCy,YTIME)
QNumVeh                            !! VNumVeh(runCy,YTIME)
QNewReg                            !! VNewReg(runCy,YTIME)
QTrnspActiv                        !! VTrnspActiv(runCy,TRANSE,YTIME)
QScrap                             !! VScrap(runCy,YTIME)
QLevl                              !! VLamda(runCy,YTIME)
QScrRate                           !! VScrRate(runCy,YTIME)
QElecConsAll                       !! VElecConsAll(runCy,DSBS,YTIME)


*' * INDUSTRY  - DOMESTIC - NON ENERGY USES - BUNKERS VARIABLES *

QElecConsNonSub                    !! VElecNonSub(runCy,INDDOM,YTIME)
QConsOfRemSubEquip                 !! VConsRemSubEquip(runCy,DSBS,EF,YTIME)
QDemSub                            !! VDemSub(runCy,DSBS,YTIME)
qElecConsInd                       !! vElecConsInd(runCy,YTIME)
qDemInd                            !! vDemInd(runCy,YTIME)
QElecIndPrices                     !! VElecIndPrices(runCy,YTIME)
QFuelCons                          !! VConsFuel(runCy,DSBS,EF,YTIME)
QElecIndPricesEst                  !! VElecIndPricesEst(runCy,YTIME)
QFuePriSubChp                      !! VFuePriSubChp(runCy,DSBS,EF,TEA,YTIME)
QElecProdCosChp                    !! VElecProdCostChp(runCy,DSBS,CHP,YTIME)
QTechCost                          !! VTechCost(runCy,DSBS,rCon,EF,TEA,YTIME) 
QTechCostIntrm                     !! VTechCostIntrm(runCy,DSBS,rCon,EF,TEA,YTIME) 
QTechCostMatr                      !! VTechCostMatr(runCy,DSBS,rCon,EF,TEA,YTIME) 
QTechSort                          !! VTechSort(runCy,DSBS,rCon,YTIME)
QGapFinalDem                       !! VGapFinalDem(runCy,DSBS,YTIME)
QTechShareNewEquip                 !! VTechShareNewEquip(runCy,DSBS,EF,TEA,YTIME)
QFuelConsInclHP                    !! VFuelConsInclHP(runCy,DSBS,EF,YTIME)
QVarProCostPerCHPDem               !! VProCostCHPDem(runCy,DSBS,CHP,YTIME)
QAvgElcProCostCHP                  !! VAvgElcProCHP(runCy,CHP,YTIME)
QAvgVarElecProd                    !! VAvgVarProdCostCHP(runCy,CHP,YTIME)


*' * REST OF ENERGY BALANCE SECTORS *

*QTransfOutputPatFuel              !! VTransfOutputPatFuel(runCy,EFS,YTIME)
QTotFinEneCons                     !! VFeCons(runCy,EFS,YTIME)
qTotFinEneConsAll                  !! vTotFinEneConsAll(YTIME)
QFinNonEneCons                     !! VFNonEnCons(runCy,EFS,YTIME)
QDistrLosses                       !! VLosses(runCy,EFS,YTIME)
*QTranfOutputDHPlants              !! VTransfOutputDHPlants(runCy,STEAM,YTIME)
*QTransfInputDHPlants              !! VTransfInputDHPlants(runCy,EFS,YTIME)
*QTransfInputPatFuel               !! VTransfInputPatFuel(runCy,EFS,YTIME)
*QRefCapacity                      !! VRefCapacity(runCy,YTIME)
*QTranfOutputRefineries            !! VTransfOutputRefineries(runCy,EFS,YTIME)
*QTransfInputRefineries            !! VTransfInputRefineries(runCy,"CRO",YTIME)
*QTransfOutputNuclear              !! VTransfOutputNuclear(runCy,"ELC",YTIME)
*QTransfInNuclear                  !! VTransfInNuclear(runCy,"NUC",YTIME)
*QTransfInPowerPls                 !! VTransfInThermPowPls(runCy,PGEF,YTIME)
*QTransfOutThermPP                 !! VTransfOutThermPowSta(runCy,TOCTEF,YTIME)
*QTotTransfInput                   !! VTotTransfInput(runCy,EFS,YTIME)
*QTotTransfOutput                  !! VTotTransfOutput(runCy,EFS,YTIME)
*QTransfers                        !! VTransfers(runCy,EFS,YTIME)
*QGrsInlConsNotEneBranch           !! VGrsInlConsNotEneBranch(runCy,EFS,YTIME)
*QGrssInCons                       !! VGrssInCons(runCy,EFS,YTIME)            
*QPrimProd                         !! VPrimProd(runCy,PPRODEF,YTIME)
*QFakeExp                          !! VExportsFake(runCy,EFS,YTIME)
*QFakeImprts                       !! VFkImpAllFuelsNotNatGas(runCy,EFS,YTIME)
*QNetImports                       !! VNetImports(runCy,EFS,YTIME)
*QEneBrnchEneCons                  !! VEnCons(runCy,EFS,YTIME)


*' * CO2 SEQUESTRATION COST CURVES *

*QCO2ElcHrg                        !! VCO2ElcHrgProd(runCy,YTIME)
*QCumCO2Capt                       !! VCumCO2Capt(runCy,YTIME)
*QWghtTrnstLinToExpo               !! VWghtTrnstLnrToExpo(runCy,YTIME)
*QCstCO2SeqCsts                    !! VCO2SeqCsts(runCy,YTIME)         


*' * EMISSIONS CONSTRAINTS *

*QTotGhgEmisAllCountrNap           !! VTotGhgEmisAllCountrNap(NAP,YTIME)
*qTotCo2AllCoun                    !! vTotCo2AllCoun(YTIME) 
qHouseExpEne                       !! vHouseExpEne(runCy,YTIME)


*' * Prices *

QFuelPriSubSepCarbVal              !! VFuelPriceSub(runCy,SBS,EF,YTIME)
QFuelPriSepCarbon                  !! VFuelPriMultWgt(runCy,DSBS,EF,YTIME)
QAvgFuelPriSub                     !! VFuelPriceAvg(runCy,DSBS,YTIME)
QElecPriIndResCons                 !! VElecPriInduResConsu(runCy,ESET,YTIME)



qDummyObj
/;


option iPop:2:0:6;
display iPop;
display iDisc;
display TF;
display TFIRST;
display runCy;
display iWgtSecAvgPriFueCons;
display iVarCostTech;

VTechSortVarCostNewEquip.FX(allCy,TRANSE,EF2,TEA,YTIME)$(not An(YTIME)) = iFuelConsTRANSE(allCy,TRANSE,EF2,YTIME)/sum(EF$(SECTTECH(TRANSE,EF)),iFuelConsTRANSE(allCy,TRANSE,EF,YTIME)); 
VNumVeh.L(allCy,YTIME)=0.1;
*VNumVeh.lags(allCy,YTIME) = 0.1;
VTrnspActiv.l(allCy,TRANSE,YTIME) = 0.1;
VNewReg.FX(allCy,YTIME)$(not an(ytime)) = iNewReg(allCy,YTIME);
VFuelPriceSub.l(allCy,SBS,EF,YTIME) = 1.5;
VElecIndPrices.l(allCy,YTIME)= 0.1;
VTechCostIntrm.l(allCy,DSBS,rcon,EF,TEA,YTIME) = 0.1;
VLifeTimeTech.l(allCy,DSBS,EF,TEA,YTIME)= 0.1;
VTechSort.l(allCy,DSBS,rCon,YTIME) = 0.1;
VConsFuel.l(allCy,DSBS,EF,YTIME)=0.1;
VRefCapacity.l(allCy,YTIME)=0.1;
*VFeCons.l(allCy,EF,YTIME) = 000000.1;
VTransfOutputRefineries.l(allCy,EFS,YTIME)=0.1;
VGrsInlConsNotEneBranch.l(allCy,EFS,YTIME)=0.1;
VElecConsAll.l(allCy,DSBS,YTIME)=0.1;
VLoadFacDom.l(allCy,YTIME)=0.1;
VElecProdPowGenPlants.l(allCy,PGALL,YTIME) = 1;
*VHourProdCostTech.up(allCy,PGALL,HOUR,YTIME)=1e6;
VSensCcs.l(allCy,YTIME)=1;
*VHourProdCostTech.VLamda(allCy,PGALL,HOUR,YTIME)=1;
VFuelPriceSub.l(allCy,"PG",PGEF,YTIME)=1;
VProdCostTechnology.lo(allCy,PGALL2,YTIME)=0.00000001;
*VProdCostTechnology.up(allCy,PGALL2,YTIME)=1e6;
VVarCostTech.l(allCy,PGALL,YTIME)=0.1;
VProdCostTechPreReplacAvail.l(allCy,PGALL,PGALL2,YTIME)=0.1;
VTechSortVarCost.l(allCy,TRANSE,Rcon,YTIME)=0.1;
*VHourProdCostTechNoCCS.up(allCy,PGALL,HOUR,YTIME)=8000;
*VHourProdCostTechNoCCS.VLamda(allCy,PGALL,HOUR,YTIME)=10;
*VTemScalWeibull.up(allCy,PGALL,HOUR,YTIME)=1e6;
*VHourProdCostTechNoCCS.lo(allCy,PGALL,HOUR,YTIME)=0.0001;
VRenPotSupplyCurve.l(allCy,PGRENEF,YTIME)=0.1;
VScrRate.l(allCy,YTIME)=0.1;
VTranspCostPermeanConsSize.l(allCy,TRANSE,RCon,TTECH,TEA,YTIME)=0.1;
*VTranspCostPermeanConsSize.lo(allCy,TRANSE,RCon,TTECH,TEA,YTIME)=0.0001;
VElecNonSub.l(allCy,DSBS,YTIME)=0.1;
*VElecNonSub.lo(allCy,DSBS,YTIME)=0.000001;


VPowerPlantNewEq.L(allCy,PGALL,TT)=0.1;
vHourProdCostTechAfterCCS.L(allCy,PGALL,HOUR,TT)=0.1;
VPowerPlaShrNewEq.L(allCy,PGALL,TT)=0.1;
VHourProdCostTechNoCCS.L(runCy,PGALL,HOUR,TT) = VPowerPlantNewEq.L(runCy,PGALL,TT)*vHourProdCostTechAfterCCS.L(runCy,PGALL,HOUR,TT)+
         sum(CCS$CCS_NOCCS(CCS,PGALL), VPowerPlaShrNewEq.L(runCy,CCS,TT)*vHourProdCostTechAfterCCS.L(runCy,CCS,HOUR,TT));
VHourProdCostTechNoCCS.SCALE(runCy,PGALL,HOUR,TT)= max(abs(VHourProdCostTechNoCCS.L(runCy,PGALL,HOUR,TT)),1E-20);
VNewInvDecis.l(allCy,YTIME)=0.1;
VVarCostTechnology.l(allCy,PGALL,YTIME)=0.1;
VElecPeakLoads.l(allCy,YTIME)=0.1;
VNewCapYearly.l(allCy,PGALL,YTIME)=0.1;
VAvgCapFacRes.l(allCy,PGALL,YTIME)=0.1;
VOverallCap.scale(allCy,PGALL,YTIME)=1;
VPowPlantSorting.l(runCy,PGALL,YTIME)=0.01;
VReqElecProd.l(runCy,YTIME)=0.1;
*VPowPlantSorting.up(runCy,PGALL,YTIME)=0.001;
VPowPlantSorting.scale(runCy,PGALL,YTIME)=1;
VElecDem.l(allCy,YTIME)=0.1;
*VHourProdCostTech.lo(runCy,PGALL,HOUR,YTIME)=0.0001;
*VHourProdCostTechNoCCS.lo(runCy,PGALL,HOUR,YTIME)=0.1;
VRenTechMatMult.l(allCy,PGALL,YTIME)=0.1;
VGoodsTranspActiv.l(allCy,TRANSE,YTIME)=0.1;
*VTranspCostPerVeh.lo(allCy,TRANSE,RCon,TTECH,TEA,YTIME)=0.1;
VRenShareElecProdSub.FX(runCy,YTIME)$(NOT AN(YTIME))=0;
VRenValue.l(YTIME)=1;
VCO2SeqCsts.l(allCy,YTIME)=1;
VScalWeibullSum.l(allCy,PGALL,YTIME)=2;
*VScalWeibullSum.up(allCy,PGALL,YTIME)=1.0e+10;
VHourProdCostTech.l(runCy,PGALL,HOUR,TT) = 0.0001;


*' *                        VARIABLE INITIALISATION                               *


VFuelPriceSub.FX(runCy,SBS,EF,YTIME)$(SECTTECH(SBS,EF)$(not HEATPUMP(EF))$(not An(YTIME))) = iFuelPrice(runCy,SBS,EF,YTIME);
VFuelPriceSub.FX(runCy,SBS,ALTEF,YTIME)$(SECTTECH(SBS,ALTEF)$(not An(YTIME))) = sum(EF$ALTMAP(SBS,ALTEF,EF),iFuelPrice(runCy,SBS,EF,YTIME));
* FIXME: VFuelPriceSub (NUC/MET/ETH/BGDO) should be computed endogenously after startYear, and with mrprom before startYear
* author=giannou
VFuelPriceSub.FX(runCy,"PG","NUC",YTIME) = 0.025; !! fixed price for nuclear fuel to 25Euro/toe
VFuelPriceSub.FX(runCy,"H2P","NUC",YTIME) = 0.025; !! fixed price for nuclear fuel to 25Euro/toe
VFuelPriceSub.FX(runCy,SBS,"MET",YTIME)$(not An(YTIME)) = 800; !! fixed price methanol
VFuelPriceSub.FX(runCy,SBS,"ETH",YTIME)$(not An(YTIME)) = 800; !! fixed price for ethanol
VFuelPriceSub.FX(runCy,SBS,"BGDO",YTIME)$(not An(YTIME)) = 350; !! fixed price for biodiesel
VFuelPriceSub.fx(runCy,INDDOM,"HEATPUMP",YTIME)$(SECTTECH(INDDOM,"HEATPUMP")$(not An(YTIME))) = iFuelPrice(runCy,INDDOM,"ELC",YTIME);
VFuelPriceSub.fx(runCy,"H2P",EF,YTIME)$(SECTTECH("H2P",EF)$(not An(YTIME))) = VFuelPriceSub.l(runCy,"PG",EF,YTIME);
VFuelPriceSub.fx(runCy,"H2P","ELC",YTIME)$(not An(YTIME))= VFuelPriceSub.l(runCy,"OI","ELC",YTIME);

VElecPriInduResConsu.FX(runCy,"i",YTIME)$(not An(YTIME)) = VFuelPriceSub.l(runCy,"OI","ELC",YTIME)*sTWhToMtoe;
VElecPriInduResConsu.FX(runCy,"r",YTIME)$(not An(YTIME)) = VFuelPriceSub.l(runCy,"HOU","ELC",YTIME)*sTWhToMtoe;
VElecPriIndResNoCliPol.FX(runCy,"i",YTIME)$(not an(ytime)) = VFuelPriceSub.l(runCy,"OI","ELC",YTIME)*0.086;
VElecPriIndResNoCliPol.FX(runCy,"r",YTIME)$(not an(ytime)) = VFuelPriceSub.l(runCy,"HOU","ELC",YTIME)*0.086;
VFuelPriSubNoCarb.FX(runCy,SBS,EF,YTIME)$(SECTTECH(SBS,EF) $(not HEATPUMP(EF))  $(not An(YTIME))) = iFuelPrice(runCy,SBS,EF,YTIME);
VFuelPriSubNoCarb.FX(runCy,SBS,ALTEF,YTIME)$(SECTTECH(SBS,ALTEF) $(not An(YTIME))) = sum(EF$ALTMAP(SBS,ALTEF,EF),iFuelPrice(runCy,SBS,EF,YTIME));
VFuelPriSubNoCarb.FX(runCy,"PG","NUC",YTIME) = 0.025; !! fixed price for nuclear fuel to 25Euro/toe
VFuelPriSubNoCarb.fx(runCy,INDDOM,"HEATPUMP",YTIME)$(SECTTECH(INDDOM,"HEATPUMP")$(not An(YTIME))) = iFuelPrice(runCy,INDDOM,"ELC",YTIME);
VFuelPriceAvg.L(runCy,DSBS,YTIME) = 0.1;
VFuelPriceAvg.FX(runCy,DSBS,YTIME)$(not An(YTIME)) = sum(EF$SECTTECH(DSBS,EF), iWgtSecAvgPriFueCons(runCy,DSBS,EF) * iFuelPrice(runCy,DSBS,EF,YTIME));

VNumVeh.UP(runCy,YTIME) = 10000; !! upper bound of VNumVeh is 10000 million vehicles
* FIXME: VNumVeh.FX(runCy,YTIME) = iActv(YTIME,runCy,"PC"), to be used only if eq QNumVeh is deactivated.
* author=redmonkeycloud
VNumVeh.FX(runCy,YTIME)$(not An(YTIME)) = iActv(YTIME,runCy,"PC");
VLamda.UP(runCy,YTIME) = 1;
iPassCarsMarkSat(runCy) = 0.7; 

* Compute electricity consumed in heatpump plants, QElecConsHeatPla(runCy,INDDOM,YTIME)$time(ytime).
VElecConsHeatPla.FX(runCy,INDDOM,YTIME) =E= 1E-7;

iTransChar(runCy,"RES_MEXTF",YTIME) = 0.04;
iTransChar(runCy,"RES_MEXTV",YTIME) = 0.04;

VLamda.FX(runCy,YTIME)$((not An(YTIME)) $(ord(YTIME) gt 1) ) = (VNumVeh.l(runCy,YTIME-1) / (iPop(YTIME-1,runCy)*1000) /
iPassCarsMarkSat(runCy))$(iPop(YTIME-1,runCy))+VLamda.l(runCy,YTIME-1)$(not iPop(YTIME-1,runCy));
VMExtF.l(runCy,YTIME)$((not An(YTIME)) $(ord(YTIME) gt 1)  ) = ( iTransChar(runCy,"RES_MEXTF",YTIME) * iSigma(runCy,"S1") * EXP(iSigma(runCy,"S2") *
           EXP(iSigma(runCy,"S3") * VLamda.l(runCy,YTIME)))
               * VNumVeh.l(runCy,YTIME-1) /(iPop(YTIME-1,runCy) * 1000) )$(iPop(YTIME-1,runCy));

VMExtF.FX(runCy,YTIME)$((not An(YTIME)) $(ord(YTIME) gt 1)  ) = ( iTransChar(runCy,"RES_MEXTF",YTIME) * iSigma(runCy,"S1") * EXP(iSigma(runCy,"S2") * EXP(iSigma(runCy,"S3") *
                          VLamda.l(runCy,YTIME)))* 
                          VNumVeh.l(runCy,YTIME-1) /(iPop(YTIME-1,runCy) * 1000) )$(iPop(YTIME-1,runCy))+VMExtF.l(runCy,YTIME-1)$(not iPop(YTIME-1,runCy));


iDataPassCars(runCy,"PC","MEXTV") = 0.01;
VMExtV.FX(runCy,YTIME)$(not An(YTIME)) = iDataPassCars(runCy,"PC","MEXTV");

VScrRate.UP(runCy,YTIME) = 1;
VScrRate.FX(runCy,"2017") = 0.1; 

VGapTranspFillNewTech.FX(runCy,TRANSE,YTIME)$(not AN(YTIME))=0;

VTrnspActiv.FX(runCy,"PC",YTIME)$(not AN(YTIME)) = iTransChar(runCy,"KM_VEH",YTIME); 
VTrnspActiv.FX(runCy,TRANP,YTIME) $(not AN(YTIME) and not sameas(TRANP,"PC")) = iActv(YTIME,runCy,TRANP); 
VTrnspActiv.FX(runCy,TRANSE,YTIME)$(not TRANP(TRANSE)) = 0;
VGoodsTranspActiv.FX(runCy,TRANG,YTIME)$(not An(YTIME)) = iActv(YTIME,runCy,TRANG);
VGoodsTranspActiv.FX(runCy,TRANSE,YTIME)$(not TRANG(TRANSE)) = 0;
VLifeTimeTech.FX(runCy,DSBS,EF,TEA,YTIME)$(SECTTECH(DSBS,EF)  $(not  TRANSE(DSBS)) $(not sameas(DSBS,"PC"))) = iTechLft(runCy,DSBS,EF,YTIME);
VLifeTimeTech.FX(runCy,TRANSE,TTECH,TEA,YTIME)$(SECTTECH(TRANSE,TTECH) $(not sameas(TRANSE,"PC"))) = iTechLft(runCy,TRANSE,TTECH,YTIME);
VLifeTimeTech.FX(runCy,DSBS,EF,TEA,YTIME)$(not SECTTECH(DSBS,EF))=0;
VLifeTimeTech.FX(runCy,"PC",TTECH,TEA,YTIME)$( (not AN(YTIME)) $SECTTECH("PC",TTECH))=10;

VSpecificFuelCons.FX(runCy,TRANSE,TTECH,TEA,EF,"2017")$(SECTTECH(TRANSE,EF) ) = iSpeFuelConsCostBy(runCy,TRANSE,TTECH,TEA,EF);
VTechSortVarCostNewEquip.FX(runCy,TRANSE,TTECH,TEA,YTIME)$( SECTTECH(TRANSE,TTECH) $(not AN(YTIME))) = 0;
* FIXME: VConsEachTechTransp.FX(runCy,TRANSE,TTECH,EF,TEA,YTIME)... , only the line of code below
* author=giannou
VConsEachTechTransp.FX(runCy,TRANSE,TTECH,EF,TEA,YTIME)$(SECTTECH(TRANSE,TTECH)  $(not PLUGIN(TTECH)) $TTECHtoEF(TTECH,EF) $(not AN(YTIME))) = iFuelConsPerFueSub(runCy,TRANSE,EF,YTIME); 
VConsEachTechTransp.FX(runCy,TRANSE,TTECH,EF,TEA,YTIME)$(SECTTECH(TRANSE,TTECH)  $PLUGIN(TTECH) $(not AN(YTIME))) = 0;
VConsEachTechTransp.FX(runCy,TRANSE,TTECH,EF,TEA,YTIME)$(SECTTECH(TRANSE,TTECH)  $CHYBV(TTECH) $(not AN(YTIME))) =0;
VDemTr.FX(runCy,TRANSE,EF,YTIME) $(SECTTECH(TRANSE,EF) $(not An(YTIME))) = iFuelConsPerFueSub(runCy,TRANSE,EF,YTIME);

VElecNonSub.FX(runCy,INDDOM,YTIME)$(not An(YTIME)) = iFuelConsPerFueSub(runCy,INDDOM,"ELC",YTIME) * iShrNonSubElecInTotElecDem(runCy,INDDOM);
vElecConsInd.FX(runCy,YTIME)$(not An(YTIME))= SUM(INDSE,VElecNonSub.l(runCy,INDSE,YTIME));

VFuePriSubChp.FX(runCy,DSBS,EF,TEA,YTIME)$((not An(YTIME)) $(not TRANSE(DSBS))  $SECTTECH(DSBS,EF)) =
(((VFuelPriceSub.l(runCy,DSBS,EF,YTIME)+iVarCostTech(runCy,DSBS,EF,YTIME)/1000)/iUsfEneConvSubTech(runCy,DSBS,EF,YTIME)- 
(0$(not CHP(EF)) + (VFuelPriceSub.l(runCy,"OI","ELC",YTIME)*iFracElecPriChp*iElecIndex(runCy,"2010"))$CHP(EF))) + (0.003) + 
SQRT( SQR(((VFuelPriceSub.l(runCy,DSBS,EF,YTIME)+iVarCostTech(runCy,DSBS,EF,YTIME)/1000)/iUsfEneConvSubTech(runCy,DSBS,EF,YTIME)- (0$(not CHP(EF)) + 
(VFuelPriceSub.l(runCy,"OI","ELC",YTIME)*iFracElecPriChp*iElecIndex(runCy,"2010"))$CHP(EF)))-(0.003)) + SQR(1e-7) ) )/2;


VDemSub.FX(runCy,INDDOM,YTIME)$(not An(YTIME)) = max(iTotFinEneDemSubBaseYr(runCy,INDDOM,YTIME) - VElecNonSub.L(runCy,INDDOM,YTIME),1e-5);
VDemSub.FX(runCy,NENSE,YTIME)$(not An(YTIME)) = max(iTotFinEneDemSubBaseYr(runCy,NENSE,YTIME),1e-5);
VDemSub.FX(runCy,"HOU",YTIME)$(not An(YTIME)) = max(iTotFinEneDemSubBaseYr(runCy,"HOU",YTIME) - VElecNonSub.L(runCy,"HOU",YTIME)-iExogDemOfBiomass(runCy,"HOU",YTIME),1e-5);
vDemInd.FX(runCy,YTIME)$(not An(YTIME))= SUM(INDSE,VDemSub.L(runCy,INDSE,YTIME));

VElecIndPrices.FX(runCy,YTIME)$TFIRST(YTIME) = iElecIndex(runCy,YTIME);

VElecConsHeatPla.FX(runCy,INDDOM,YTIME)$(not An(YTIME)) = iFuelConsPerFueSub(runCy,INDDOM,"ELC",YTIME)*(1-iShrNonSubElecInTotElecDem(runCy,INDDOM))*iShrHeatPumpElecCons(runCy,INDDOM);

VConsFuel.FX(runCy,DSBS,EF,YTIME)$(SECTTECH(DSBS,EF) $(not HEATPUMP(EF)) $(not TRANSE(DSBS)) $(not An(YTIME))) = iFuelConsPerFueSub(runCy,DSBS,EF,YTIME);

VFuelConsInclHP.FX(runCy,DSBS,EF,YTIME)$(SECTTECH(DSBS,EF) $(not TRANSE(DSBS)) $(not An(YTIME))) =
(iFuelConsPerFueSub(runCy,DSBS,EF,YTIME))$((not ELCEF(EF)) $(not HEATPUMP(EF)))
+(VElecConsHeatPla.l(runCy,DSBS,YTIME)*iUsfEneConvSubTech(runCy,DSBS,"HEATPUMP",YTIME))$HEATPUMP(EF)+
(iFuelConsPerFueSub(runCy,DSBS,EF,YTIME)-VElecConsHeatPla.l(runCy,DSBS,YTIME))$ELCEF(EF)
+1e-7$(H2EF(EF) or sameas("STE1AH2F",EF))
;

VTechShareNewEquip.FX(runCy,DSBS,EF,TEA,YTIME)$(SECTTECH(DSBS,EF)$(not An(YTIME))) = 0;
VConsRemSubEquip.FX(runCy,DSBS,EF,YTIME)$(SECTTECH(DSBS,EF) $(not An(ytime))) =
(VFuelConsInclHP.l(runCy ,DSBS,EF,YTIME) - (VElecNonSub.l(runCy,DSBS,YTIME)$(ELCEF(EF) $INDDOM(DSBS)) + 0$(not (ELCEF(EF) $INDDOM(DSBS)) )))
;



VFeCons.FX(runCy,EFS,YTIME)$(not An(YTIME)) = iFinEneCons(runCy,EFS,YTIME);
iFinEneConsPrevYear(runCy,EFS,YTIME)$(not An(YTIME)) = iFinEneCons(runCy,EFS,YTIME);
VLosses.FX(runCy,EFS,YTIME)$(not An(YTIME)) = iDistrLosses(runCy,EFS,YTIME);

VTransfOutputPatFuel.FX(runCy,EFS,YTIME)$(not An(YTIME)) = iTranfOutGasworks(runCy,EFS,YTIME);
VTransfOutThermPowSta.FX(runCy,EFS,YTIME)$(not TOCTEF(EFS)) = 0;
VRefCapacity.FX(runCy,YTIME)$(not An(YTIME)) = iRefCapacity(runCy,YTIME);
VTransfOutputRefineries.FX(runCy,EFS,YTIME)$(EFtoEFA(EFS,"LQD") $(not An(YTIME))) = iTransfOutputRef(runCy,EFS,YTIME);
VTransfInputRefineries.FX(runCy,"CRO",YTIME)$(not An(YTIME)) = iTransfInputRef(runCy,"CRO",YTIME);
VGrsInlConsNotEneBranch.FX(runCy,EFS,YTIME)$(not An(YTIME)) = iGrossInConsNoEneBra(runCy,EFS,YTIME);
* FIXME: Add $(not An(YTIME)) to VGrssInCons when QGrssInCons is included to the model.
* author=derevirn
VGrssInCons.FX(runCy,EFS,YTIME) = iGrosInlCons(runCy,EFS,YTIME);
VTransfers.FX(runCy,EFS,YTIME)$(not An(YTIME)) = iFeedTransfr(runCy,EFS,YTIME);
VPrimProd.FX(runCy,PPRODEF,YTIME)$(not An(YTIME)) = iFuelPriPro(runCy,PPRODEF,YTIME);
* FIXME: VEnCons to be added $(not An(YTIME)), when the QEneBrnchEneCons is activated.
* author=redmonkeycloud
VEnCons.FX(runCy,EFS,YTIME) = iTotEneBranchCons(runCy,EFS,YTIME);

VExportsFake.FX(runCy,EFS,YTIME)$(not An(YTIME)) = iFuelExprts(runCy,EFS,YTIME);
VFkImpAllFuelsNotNatGas.FX(runCy,"NGS",YTIME)$(not An(YTIME)) = iFuelImports(runCy,"NGS",YTIME);
VExportsFake.FX(runCy,"NGS",YTIME)$(not An(YTIME)) = iFuelExprts(runCy,"NGS",YTIME);

VElecDem.FX(runCy,YTIME)$(not An(YTIME)) =  1/0.086 * ( iFinEneCons(runCy,"ELC",YTIME) + sum(NENSE, iFuelConsPerFueSub(runCy,NENSE,"ELC",YTIME)) + iDistrLosses(runCy,"ELC",YTIME)
                                             + iTotEneBranchCons(runCy,"ELC",YTIME) - (iFuelImports(runCy,"ELC",YTIME)-iFuelExprts(runCy,"ELC",YTIME)));


VCorrBaseLoad.FX(runCy,YTIME)$(not An(YTIME)) = iPeakBsLoadBy(runCy,"BASELOAD");

VLoadFacDom.FX(runCy,YTIME)$(datay(YTIME)) =
         (sum(INDDOM,VConsFuel.l(runCy,INDDOM,"ELC",YTIME)) + sum(TRANSE, VDemTr.l(runCy,TRANSE,"ELC",YTIME)))/
         (sum(INDDOM,VConsFuel.l(runCy,INDDOM,"ELC",YTIME)/iLoadFacElecDem(INDDOM)) + sum(TRANSE, VDemTr.l(runCy,TRANSE,"ELC",YTIME)/
         iLoadFacElecDem(TRANSE)));

VElecPeakLoad.FX(runCy,YTIME)$(datay(YTIME)) = VElecDem.l(runCy,YTIME)/(VLoadFacDom.l(runCy,YTIME)*8.76);

VTotElecGenCap.FX(runCy,YTIME)$(not An(YTIME)) = iTotAvailCapBsYr(runCy);
VElecGenNoChp.FX(runCy,YTIME)$(not An(YTIME)) = iTotAvailCapBsYr(runCy);
VElecCapChpPla.FX(runCy,CHP,YTIME)$(not An(YTIME)) = iHisChpGrCapData(runCy,CHP,YTIME);
VPowPlaShaNewEquip.FX(runCy,PGALL,YTIME)$((NOT AN(YTIME)) )=0;

VHourProdCostTech.FX(runCy,PGALL,HOUR,YTIME)$((NOT AN(YTIME)))=0;

VPowerPlaShrNewEq.FX(runCy,PGALL,YTIME)$((NOT AN(YTIME)) )=0;
VPowerPlantNewEq.FX(runCy,PGALL,YTIME)$((NOT AN(YTIME)) )=0;
VPowerPlaShrNewEq.FX(runCy,PGALL,YTIME)$(AN(YTIME) $(NOT CCS(PGALL)))=0;
VPowerPlantNewEq.FX(runCy,PGALL,YTIME)$(AN(YTIME) $(NOT NOCCS(PGALL)) )=0;

VNewInvDecis.FX(runCy,YTIME)$(NOT AN(YTIME))=1;

VElecGenPlanCap.FX(runCy,PGALL,YTIME)$DATAY(YTIME) =  iInstCapPast(runCy,PGALL,YTIME);
VElecGenPlantsCapac.FX(runCy,PGALL,YTIME)$DATAY(YTIME) =  iInstCapPast(runCy,PGALL,YTIME);
VOverallCap.FX(runCy,PGALL,YTIME)$TFIRST(YTIME) =  iInstCapPast(runCy,PGALL,YTIME)$TFIRST(YTIME);

VNewCapYearly.FX(runCy,PGALL,"2011")$PGREN(PGALL) = iInstCapPast(runCy,PGALL,"2011")- iInstCapPast(runCy,PGALL,"2010") +1E-10;
VNewCapYearly.FX(runCy,PGALL,"2012")$PGREN(PGALL) = iInstCapPast(runCy,PGALL,"2012")- iInstCapPast(runCy,PGALL,"2011") +1E-10;
VNewCapYearly.FX(runCy,PGALL,"2013")$PGREN(PGALL) = iInstCapPast(runCy,PGALL,"2013")- iInstCapPast(runCy,PGALL,"2012") +1E-10;
VNewCapYearly.FX(runCy,PGALL,"2014")$PGREN(PGALL) = iInstCapPast(runCy,PGALL,"2014")- iInstCapPast(runCy,PGALL,"2013") +1E-10;
VNewCapYearly.FX(runCy,PGALL,"2015")$PGREN(PGALL) = iInstCapPast(runCy,PGALL,"2015")- iInstCapPast(runCy,PGALL,"2014") +1E-10;
VNewCapYearly.FX(runCy,PGALL,"2016")$PGREN(PGALL) = iInstCapPast(runCy,PGALL,"2016")- iInstCapPast(runCy,PGALL,"2015") +1E-10;
VNewCapYearly.FX(runCy,PGALL,"2017")$PGREN(PGALL) = iInstCapPast(runCy,PGALL,"2017")- iInstCapPast(runCy,PGALL,"2016") +1E-10;
VNewCapYearly.FX(runCy,"PGLHYD",YTIME)$TFIRST(YTIME) = +1E-10;

VAvgCapFacRes.FX(runCy,PGALL,YTIME)$DATAY(YTIME) =iAvailRate(PGALL,YTIME);


VElecProdPowGenPlants.FX(runCy,pgall,YTIME)=iDataElecProd(runCy,pgall,YTIME)/1000;


VEndogScrapIndex.FX(runCy,PGALL,YTIME)$(not an(YTIME) ) = 1;
VEndogScrapIndex.FX(runCy,PGSCRN,YTIME) = 1;            !! premature replacement it is not allowed for all new plants


VCO2ElcHrgProd.FX(runCy,YTIME)$(not An(YTIME)) = 0;

VRenShareElecProdSub.FX(runCy,YTIME)$(NOT AN(YTIME))=0;
VRenPotSupplyCurve.FX(runCy,PGRENEF, YTIME) $(NOT AN(YTIME)) = iMinRenPotential(runCy,PGRENEF,YTIME);

VLongAvgPowGenCost.L(runCy,ESET,"2010") = 0;
VLonPowGenCostNoClimPol.L(runCy,ESET,"2010") = 0;
vAvgPowerGenCostShoTrm.L(runCy,ESET,"2010") = 0;
VLongPowGenCost.L(runCy,PGALL,ESET,"2010") = 0;
VLonAvgPowGenCostNoClimPol.L(runCy,PGALL,ESET,"2010") = 0;
VLongAvgPowGenCost.L(runCy,ESET,"2017") = 0;
VLonPowGenCostNoClimPol.FX(runCy,ESET,"%fBaseY%") = 0;
* FIXME: Temporary fix. To be reversed back to vAvgPowerGenCostShoTrm.L(runCy,ESET,"%fBaseY%") = 0, when qShortPowGenCost is activated.
* author=redmonkeycloud
vAvgPowerGenCostShoTrm.FX(runCy,ESET,YTIME) = 0.02;

VLongPowGenCost.L(runCy,PGALL,ESET,"2017") = 0;
VLonAvgPowGenCostNoClimPol.FX(runCy,PGALL,ESET,"%fBaseY%") = 0;

VCarVal.fx(runCy,NAP,YTIME)$(not An(YTIME))=0;
VCarVal.FX(runCy,"TRADE",YTIME)$an(YTIME) = sExogCarbValue*iCarbValYrExog(runCy,YTIME);
VCarVal.FX(runCy,"NOTRADE",YTIME)$an(YTIME) =sExogCarbValue*iCarbValYrExog(runCy,YTIME);

VCumCO2Capt.FX(runCy,YTIME)$(not an(YTIME)) = 0 ;

VCO2SeqCsts.FX(runCy,YTIME) = iElastCO2Seq(runCy,"mc_a") *iElastCO2Seq(runCy,"mc_b");

VDemTr.FX(runCy,TRANSE,EF,YTIME)$(not SECTTECH(TRANSE,EF)) = 0;
VTransfOutputDHPlants.FX(runCy,EFS,YTIME)$(not STEAM(EFS)) = 0;
VTransfOutputRefineries.FX(runCy,EFS,YTIME)$(not EFtoEFA(EFS,"LQD")) = 0;
VTransfInputRefineries.FX(runCy,EFS,YTIME)$(not sameas("CRO",EFS)) = 0;
VTransfOutputNuclear.FX(runCy,EFS,YTIME)$(not sameas("ELC",EFS)) = 0;
VTransfInNuclear.FX(runCy,EFS,YTIME)$(not sameas("NUC",EFS)) = 0;
VTransfInThermPowPls.FX(runCy,EFS,YTIME)$(not PGEF(EFS)) = 0;
* FIXME: This is a test issue that was generated automatically
* author=derevirn
VExportsFake.FX(runCy,EFS,YTIME)$(not IMPEF(EFS)) = 0;
VFkImpAllFuelsNotNatGas.FX(runCy,EFS,YTIME)$(not IMPEF(EFS)) = 0;

VScalFacPlaDisp.LO(runCy, HOUR, YTIME)=-1;
VLoadCurveConstr.LO(runCy,YTIME)=0;
* FIXME: To be reverted back to VLoadCurveConstr.L(runCy,YTIME)=0.21 , when QLambda is activated.
* author=redmonkeycloud
VLoadCurveConstr.FX(runCy,YTIME)=0.21;

VRenValue.FX(YTIME) = 0 ;

VTotReqElecProd.fx(runCy,YTIME)$TFIRST(YTIME)=sum(pgall,VElecProdPowGenPlants.L(runCy,pgall,YTIME)$TFIRST(YTIME));
display iDisFunConSize;

loop an do !! start outer iteration loop (time steps)
   s = s + 1;
   TIME(YTIME) = NO;
   TIME(AN)$(ord(an)=s) = YES;
   display TIME;
