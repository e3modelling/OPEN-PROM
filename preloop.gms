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

qPotResCurr                        !! vPotResCurr(runCy,PGRENEF,YTIME)
QCapElecChp                        !! VCapElecChp(runCy,CHP,YTIME)
QLambda                            !! VLambda(runCy,YTIME)
QDemElec                           !! VDemElec(runCy,YTIME)
QLoadBaseEstSec                    !! VLoadBaseEstSec(runCy,YTIME)
QLoadFacDom                        !! VLoadFacDom(runCy,YTIME)
QLoadPeakElec                      !! VLoadPeakElec(runCy,YTIME)
QLoadBaseMax                       !! VLoadBaseMax(runCy,YTIME)
QLoadBaseElecExp                   !! VLoadBaseElecExp(runCy,YTIME)
QProdReqTotElec                    !! VProdReqTotElec(runCy,YTIME)
QCapGenTotEstElec                  !! VCapGenTotEstElec(runCy,YTIME)
QCapGenTotElec                     !! VTotElecGenCap(runCy,YTIME)	
QCostHourProdInvDec                !! VCostHourProdInvDec(runCy,PGALL,HOUR,YTIME)
QCostHourProdInvDecNoCcs           !! VCostHourProdInvDecNoCcs(runCy,PGALL,HOUR,YTIME)
QSensCcs                           !! VSensCcs(runCy,YTIME)
qCostHourProdInvCCS                !! vCostHourProdInvCCS(runCy,PGALL,HOUR,YTIME) 
QCostProdSpecTech                  !! VCostProdSpecTech(runCy,PGALL,YTIME)
QShareNewTechCcs                   !! VShareNewTechCcs(runCy,PGALL,YTIME)
QShareNewTechNoCcs                 !! VShareNewTechNoCcs(runCy,PGALL,YTIME)
QCostVarTech                       !! VCostVarTech(runCy,PGALL,YTIME)
QCostVarTechNotPGSCRN              !! VCostVarTechNotPGSCRN(runCy,PGALL,YTIME)
QCostProdTechPreReplac             !! VCostProdTechPreReplac(runCy,PGALL,YTIME)
QCostProdTechPreReplacAvail        !! VCostProdTechPreReplacAvail(runCy,PGALL,PGALL2,YTIME)
QIndexEndogScrap                   !! VIndexEndogScrap(runCy,PGALL,YTIME)
QCapGenElecNoChp                      !! VCapGenElecNoChp(runCy,YTIME)
QGapGenCapPowerDiff                    !! VGapGenCapPowerDiff(runCy,YTIME)
qScalWeibull                       !! vScalWeibull(runCy,PGALL,HOUR,YTIME) 
QPotRenSuppCurve                 !! VPotRenSuppCurve(runCy,PGRENEF,YTIME)
QRenPotMaxAllow                !! VRenPotMaxAllow(runCy,PGRENEF,YTIME)
QRenPotMinAllow                    !! VRenPotMinAllow(runCy,PGRENEF,YTIME)
QRenTechMatMult                    !! VRenTechMatMult(runCy,PGALL,YTIME)
QScalWeibullSum                    !! VScalWeibullSum(runCy,PGALL,YTIME)
QDecisNewInv                       !! VDecisNewInv(runCy,YTIME)
QShaNewEqPowPla                 !! VShaNewEqPowPla(runCy,PGALL,YTIME)
QCapGenPlant                       !! VCapGenPlant(runCy,PGALL,YTIME)
QCapGenPlannedPlant                        !! VCapGenPlannedPlant(runCy,PGALL,YTIME)
QCostVarPlantTech                 !! VCostVarPlantTech(runCy,PGALL,YTIME)
QElecPeakLoads                     !! VElecPeakLoads(runCy,YTIME) 
QSortPlantDispatch                 !! VSortPlantDispatch(runCy,PGALL,YTIME)
QCapGenNewResPlant                      !! VCapGenNewResPlant(runCy,PGALL,YTIME)
QCapAvgFacRes                      !! VCapAvgFacRes(runCy,PGALL,YTIME)
QCapOverall                        !! VCapOverall(runCy,PGALL,YTIME)
QScalFacPlantDispatch              !! VScalFacPlaDisp
QGenEstElecChpPlants                     !! VGenEstElecChpPlants(runCy,YTIME) 
QProdNonChp                    !! VProdNonChp(runCy,YTIME) 
QProdReqElec                       !! VProdReqElec(runCy,YTIME) 
QProdElecPowPlantsCy                !! VProdElecPowPlantsCy(runCy,PGALL,YTIME)
qSecContrTotChpProd                !! vSecContrTotChpProd(runCy,INDDOM,CHP,YTIME)
QGenEstElecChpPlants                     !! VGenEstElecChpPlants(runCy,CHP,YTIME)
qProdGrossResShare                 !! vProdGrossResShare(runCy,YTIME) 
QCostPowGenLngTechNoCp             !! VCostPowGenLngTechNoCp(runCy,PGALL,ESET,YTIME)
qCostPowGenLonMin                  !! vCostPowGenLonMin(runCy,PGALL,YTIME)
qCostPowGenLongIntPri                  !! vCostPowGenLongIntPri(runCy,PGALL,ESET,YTIME)
qCostPowGenShortIntPri                   !! vCostPowGenShortIntPri(runCy,PGALL,ESET,YTIME)
QCostPowGenAvgLng                  !! VCostPowGenAvgLng(runCy,ESET,YTIME)
QCostAvgPowGenLonNoClimPol         !! VCostAvgPowGenLonNoClimPol(runCy,PGALL,ESET,YTIME)
QCostPowGenLonNoClimPol            !! VCostPowGenLonNoClimPol(runCy,ESET,YTIME)
QPriceElecIndResNoCliPol             !! VPriceElecIndResNoCliPol(runCy,ESET,YTIME)
qCostPowGenAvgShrt                 !! vCostPowGenAvgShrt(runCy,ESET,YTIME)


*' * Transport *

QLftPc                       !! VLftPc(runCy,DSBS,EF,YTIME)
QActivGoodsTransp                  !! VActivGoodsTransp(runCy,TRANSE,YTIME)
QGapTranspActiv                    !! VGapTranspActiv(runCy,TRANSE,YTIME)
QConsSpecificFuel                  !! VConsSpecificFuel(runCy,TRANSE,TTECH,EF,YTIME)
QCostTranspPerMeanConsSize         !! VCostTranspPerMeanConsSize(runCy,TRANSE,rCon,TTECH,YTIME)
QCostTranspPerVeh                  !! VCostTranspPerVeh(runCy,TRANSE,rCon,TTECH,YTIME)
QCostTranspMatFac                  !! VCostTranspMatFac(runCy,TRANSE,RCon,TTECH,YTIME) 
QSortTechVarCost                   !! VSortTechVarCost(runCy,TRANSE,rCon,YTIME)
QShareTechSectoral           !! VShareTechSectoral(runCy,TRANSE,TTECH,YTIME)
QConsTechTranspSectoral                !! VConsTechTranspSectoral(runCy,TRANSE,TTECH,EF,YTIME)
QDemFinEneTranspPerFuel            !! VDemFinEneTranspPerFuel(runCy,TRANSE,EF,YTIME)
qDemFinEneSubTransp                   !! vDemFinEneSubTransp(runCy,TRANSE,YTIME)
QMEPcGdp                             !! VMEPcGdp(runCy,YTIME)
QMEPcNonGdp                             !! VMEPcNonGdp(runCy,YTIME)
QStockPcYearly                            !! VStockPcYearly(runCy,YTIME)
QNewRegPcYearly                            !! VNewRegPcYearly(runCy,YTIME)
QActivPassTrnsp                        !! VActivPassTrnsp(runCy,TRANSE,YTIME)
QNumPcScrap                             !! VNumPcScrap(runCy,YTIME)
QPcOwnPcLevl                              !! VPcOwnPcLevl(runCy,YTIME)
QScrRatePc                           !! VScrRatePc(runCy,YTIME)
QConsElecFinDemSec                       !! VConsElecFinDemSec(runCy,DSBS,YTIME)


*' * INDUSTRY  - DOMESTIC - NON ENERGY USES - BUNKERS VARIABLES *

QElecConsNonSub                    !! VElecNonSub(runCy,INDDOM,YTIME)
QConsOfRemSubEquip                 !! VConsRemSubEquip(runCy,DSBS,EF,YTIME)
QDemSub                            !! VDemSub(runCy,DSBS,YTIME)
qElecConsInd                       !! vElecConsInd(runCy,YTIME)
qDemInd                            !! vDemInd(runCy,YTIME)
QElecIndPrices                     !! VElecIndPrices(runCy,YTIME)
QFuelCons                          !! VConsFuel(runCy,DSBS,EF,YTIME)
QElecIndPricesEst                  !! VElecIndPricesEst(runCy,YTIME)
QFuePriSubChp                      !! VFuePriSubChp(runCy,DSBS,EF,YTIME)
QElecProdCosChp                    !! VElecProdCostChp(runCy,DSBS,CHP,YTIME)
QTechCost                          !! VTechCost(runCy,DSBS,rCon,EF,YTIME) 
QTechCostIntrm                     !! VTechCostIntrm(runCy,DSBS,rCon,EF,YTIME) 
QTechCostMatr                      !! VTechCostMatr(runCy,DSBS,rCon,EF,YTIME) 
QTechSort                          !! VTechSort(runCy,DSBS,rCon,YTIME)
QGapFinalDem                       !! VGapFinalDem(runCy,DSBS,YTIME)
QTechShareNewEquip                 !! VTechShareNewEquip(runCy,DSBS,EF,YTIME)
QFuelConsInclHP                    !! VFuelConsInclHP(runCy,DSBS,EF,YTIME)
QVarProCostPerCHPDem               !! VProCostCHPDem(runCy,DSBS,CHP,YTIME)
QAvgElcProCostCHP                  !! VAvgElcProCHP(runCy,CHP,YTIME)
QAvgVarElecProd                    !! VAvgVarProdCostCHP(runCy,CHP,YTIME)


*' * REST OF ENERGY BALANCE SECTORS *

QTotFinEneCons                     !! VFeCons(runCy,EFS,YTIME)
qTotFinEneConsAll                  !! vTotFinEneConsAll(YTIME)
QFinNonEneCons                     !! VFNonEnCons(runCy,EFS,YTIME)
QDistrLosses                       !! VLosses(runCy,EFS,YTIME)
QTranfOutputDHPlants               !! VTransfOutputDHPlants(runCy,STEAM,YTIME)
QTransfInputDHPlants               !! VTransfInputDHPlants(runCy,EFS,YTIME)
QRefCapacity                       !! VRefCapacity(runCy,YTIME)
QTranfOutputRefineries             !! VTransfOutputRefineries(runCy,EFS,YTIME)
QTransfInputRefineries             !! VTransfInputRefineries(runCy,"CRO",YTIME)
QTransfOutputNuclear               !! VTransfOutputNuclear(runCy,"ELC",YTIME)
QTransfInNuclear                   !! VTransfInNuclear(runCy,"NUC",YTIME)
QTransfInPowerPls                  !! VTransfInThermPowPls(runCy,PGEF,YTIME)
QTransfOutThermPP                  !! VTransfOutThermPP(runCy,TOCTEF,YTIME)
QTotTransfInput                    !! VTotTransfInput(runCy,EFS,YTIME)
QTotTransfOutput                   !! VTotTransfOutput(runCy,EFS,YTIME)
QTransfers                         !! VTransfers(runCy,EFS,YTIME)
QGrsInlConsNotEneBranch            !! VGrsInlConsNotEneBranch(runCy,EFS,YTIME)
QGrssInCons                        !! VGrssInCons(runCy,EFS,YTIME)            
QPrimProd                          !! VPrimProd(runCy,PPRODEF,YTIME)
QFakeExp                           !! VExportsFake(runCy,EFS,YTIME)
QFakeImprts                        !! VFkImpAllFuelsNotNatGas(runCy,EFS,YTIME)
QNetImports                        !! VNetImports(runCy,EFS,YTIME)
QEneBrnchEneCons                   !! VEnCons(runCy,EFS,YTIME)


*' * CO2 SEQUESTRATION COST CURVES *

QCO2ElcHrg                         !! VCO2ElcHrgProd(runCy,YTIME)
QCumCO2Capt                        !! VCumCO2Capt(runCy,YTIME)
QWghtTrnstLinToExpo                !! VWghtTrnstLnrToExpo(runCy,YTIME)
QCstCO2SeqCsts                     !! VCO2SeqCsts(runCy,YTIME)         


*' * EMISSIONS CONSTRAINTS *

QTotGhgEmisAllCountrNap            !! VTotGhgEmisAllCountrNap(NAP,YTIME)
qTotCo2AllCoun                     !! vTotCo2AllCoun(YTIME) 
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

VShareTechSectoral.FX(allCy,TRANSE,EF2,YTIME)$(not An(YTIME)) = iFuelConsTRANSE(allCy,TRANSE,EF2,YTIME)/sum(EF$(SECTTECH(TRANSE,EF)),iFuelConsTRANSE(allCy,TRANSE,EF,YTIME)); 
VStockPcYearly.L(allCy,YTIME)=0.1;
*VStockPcYearly.lags(allCy,YTIME) = 0.1;
VActivPassTrnsp.l(allCy,TRANSE,YTIME) = 0.1;
VNewRegPcYearly.FX(allCy,YTIME)$(not an(ytime)) = iNewReg(allCy,YTIME);
VFuelPriceSub.l(allCy,SBS,EF,YTIME) = 1.5;
VElecIndPrices.l(allCy,YTIME)= 0.1;
VTechCostIntrm.l(allCy,DSBS,rcon,EF,YTIME) = 0.1;
VLftPc.l(allCy,DSBS,EF,YTIME)= 0.1;
VTechSort.l(allCy,DSBS,rCon,YTIME) = 0.1;
VConsFuel.l(allCy,DSBS,EF,YTIME)=0.1;
VRefCapacity.l(allCy,YTIME)=0.1;
*VFeCons.l(allCy,EF,YTIME) = 000000.1;
VTransfOutputRefineries.l(allCy,EFS,YTIME)=0.1;
VGrsInlConsNotEneBranch.l(allCy,EFS,YTIME)=0.1;
VConsElecFinDemSec.l(allCy,DSBS,YTIME)=0.1;
VLoadFacDom.l(allCy,YTIME)=0.1;
*VProdElecPowPlantsCy.l(allCy,PGALL,YTIME) = 1;
*VCostHourProdInvDec.up(allCy,PGALL,HOUR,YTIME)=1e6;
VSensCcs.l(allCy,YTIME)=1;
*VCostHourProdInvDec.VPcOwnPcLevl(allCy,PGALL,HOUR,YTIME)=1;
VFuelPriceSub.l(allCy,"PG",PGEF,YTIME)=1;
VCostProdSpecTech.lo(allCy,PGALL2,YTIME)=0.00000001;
*VCostProdSpecTech.up(allCy,PGALL2,YTIME)=1e6;
VCostVarTech.l(allCy,PGALL,YTIME)=0.1;
VCostProdTechPreReplacAvail.l(allCy,PGALL,PGALL2,YTIME)=0.1;
VSortTechVarCost.l(allCy,TRANSE,Rcon,YTIME)=0.1;
*VCostHourProdInvDecNoCcs.up(allCy,PGALL,HOUR,YTIME)=8000;
*VCostHourProdInvDecNoCcs.VPcOwnPcLevl(allCy,PGALL,HOUR,YTIME)=10;
*VTemScalWeibull.up(allCy,PGALL,HOUR,YTIME)=1e6;
*VCostHourProdInvDecNoCcs.lo(allCy,PGALL,HOUR,YTIME)=0.0001;
VPotRenSuppCurve.l(allCy,PGRENEF,YTIME)=0.1;
VScrRatePc.l(allCy,YTIME)=0.1;
VCostTranspPerMeanConsSize.l(allCy,TRANSE,RCon,TTECH,YTIME)=0.1;
*VCostTranspPerMeanConsSize.lo(allCy,TRANSE,RCon,TTECH,YTIME)=0.0001;
VElecNonSub.l(allCy,DSBS,YTIME)=0.1;
*VElecNonSub.lo(allCy,DSBS,YTIME)=0.000001;


VShareNewTechNoCcs.L(allCy,PGALL,TT)=0.1;
vCostHourProdInvCCS.L(allCy,PGALL,HOUR,TT)=0.1;
VShareNewTechCcs.L(allCy,PGALL,TT)=0.1;
VCostHourProdInvDecNoCcs.L(runCy,PGALL,HOUR,TT) = VShareNewTechNoCcs.L(runCy,PGALL,TT)*vCostHourProdInvCCS.L(runCy,PGALL,HOUR,TT)+
         sum(CCS$CCS_NOCCS(CCS,PGALL), VShareNewTechCcs.L(runCy,CCS,TT)*vCostHourProdInvCCS.L(runCy,CCS,HOUR,TT));
*VCostHourProdInvDecNoCcs.SCALE(runCy,PGALL,HOUR,TT)= max(abs(VCostHourProdInvDecNoCcs.L(runCy,PGALL,HOUR,TT)),1E-20);
VDecisNewInv.l(allCy,YTIME)=0.1;
VCostVarPlantTech.l(allCy,PGALL,YTIME)=0.1;
VElecPeakLoads.l(allCy,YTIME)=0.1;
VCapGenNewResPlant.l(allCy,PGALL,YTIME)=0.1;
VCapAvgFacRes.l(allCy,PGALL,YTIME)=0.1;
VSortPlantDispatch.l(runCy,PGALL,YTIME)=0.01;
*VCapOverall.scale(allCy,PGALL,YTIME)=1;
*VCapElecChp.l(runCy,CHP,YTIME) = 1/0.086 * sum(INDDOM,VConsFuel.L(runCy,INDDOM,CHP,YTIME)) * VElecIndPrices.L(runCy,YTIME)/
*          sum(PGALL$CHPtoEON(CHP,PGALL),iAvailRate(PGALL,YTIME)) /
*         iUtilRateChpPlants(runCy,CHP,YTIME) /8.76;
VSortPlantDispatch.l(runCy,PGALL,YTIME)=VCostVarPlantTech.L(runCy,PGALL,YTIME)/VElecPeakLoads.L(runCy,YTIME);
VProdReqElec.l(runCy,YTIME) = 0.01;
*VProdReqElec.l(runCy,YTIME)=sum(hour, sum(CHP,VCapElecChp.L(runCy,CHP,YTIME)*exp(-VScalFacPlaDisp.L(runCy,HOUR,YTIME)/ sum(pgall$chptoeon(chp,pgall),VSortPlantDispatch.L(runCy,PGALL,YTIME)))));
*VSortPlantDispatch.up(runCy,PGALL,YTIME)=0.001;
*VSortPlantDispatch.scale(runCy,PGALL,YTIME)=1;
VScalFacPlaDisp.L(runCy,HOUR,YTIME) = 1.e-12;
VDemElec.l(allCy,YTIME)=0.1;
*VCostHourProdInvDec.lo(runCy,PGALL,HOUR,YTIME)=0.0001;
*VCostHourProdInvDecNoCcs.lo(runCy,PGALL,HOUR,YTIME)=0.1;
VRenTechMatMult.l(allCy,PGALL,YTIME)=0.1;
VActivGoodsTransp.l(allCy,TRANSE,YTIME)=0.1;
*VCostTranspPerVeh.lo(allCy,TRANSE,RCon,TTECH,YTIME)=0.1;
VRenShareElecProdSub.FX(runCy,YTIME)$(NOT AN(YTIME))=0;
VRenValue.l(YTIME)=1;
VCO2SeqCsts.l(allCy,YTIME)=1;
VScalWeibullSum.l(allCy,PGALL,YTIME)=2;
*VScalWeibullSum.up(allCy,PGALL,YTIME)=1.0e+10;
VCostHourProdInvDec.l(runCy,PGALL,HOUR,TT) = 0.0001;


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
VPriceElecIndResNoCliPol.FX(runCy,"i",YTIME)$(not an(ytime)) = VFuelPriceSub.l(runCy,"OI","ELC",YTIME)*0.086;
VPriceElecIndResNoCliPol.FX(runCy,"r",YTIME)$(not an(ytime)) = VFuelPriceSub.l(runCy,"HOU","ELC",YTIME)*0.086;
VFuelPriSubNoCarb.FX(runCy,SBS,EF,YTIME)$(SECTTECH(SBS,EF) $(not HEATPUMP(EF))  $(not An(YTIME))) = iFuelPrice(runCy,SBS,EF,YTIME);
VFuelPriSubNoCarb.FX(runCy,SBS,ALTEF,YTIME)$(SECTTECH(SBS,ALTEF) $(not An(YTIME))) = sum(EF$ALTMAP(SBS,ALTEF,EF),iFuelPrice(runCy,SBS,EF,YTIME));
VFuelPriSubNoCarb.FX(runCy,"PG","NUC",YTIME) = 0.025; !! fixed price for nuclear fuel to 25Euro/toe
VFuelPriSubNoCarb.fx(runCy,INDDOM,"HEATPUMP",YTIME)$(SECTTECH(INDDOM,"HEATPUMP")$(not An(YTIME))) = iFuelPrice(runCy,INDDOM,"ELC",YTIME);
VFuelPriceAvg.L(runCy,DSBS,YTIME) = 0.1;
VFuelPriceAvg.FX(runCy,DSBS,YTIME)$(not An(YTIME)) = sum(EF$SECTTECH(DSBS,EF), iWgtSecAvgPriFueCons(runCy,DSBS,EF) * iFuelPrice(runCy,DSBS,EF,YTIME));

VStockPcYearly.UP(runCy,YTIME) = 10000; !! upper bound of VStockPcYearly is 10000 million vehicles
VStockPcYearly.FX(runCy,YTIME)$(not An(YTIME)) = iActv(YTIME,runCy,"PC");
VPcOwnPcLevl.UP(runCy,YTIME) = 1;
iPassCarsMarkSat(runCy) = 0.7; 

* Compute electricity consumed in heatpump plants, QElecConsHeatPla(runCy,INDDOM,YTIME)$time(ytime).
VElecConsHeatPla.FX(runCy,INDDOM,YTIME) = 1E-7;

iTransChar(runCy,"RES_MEXTF",YTIME) = 0.04;
iTransChar(runCy,"RES_MEXTV",YTIME) = 0.04;

VPcOwnPcLevl.FX(runCy,YTIME)$((not An(YTIME)) $(ord(YTIME) gt 1) ) = (VStockPcYearly.l(runCy,YTIME-1) / (iPop(YTIME-1,runCy)*1000) /
iPassCarsMarkSat(runCy))$(iPop(YTIME-1,runCy))+VPcOwnPcLevl.l(runCy,YTIME-1)$(not iPop(YTIME-1,runCy));
VMEPcNonGdp.l(runCy,YTIME)$((not An(YTIME)) $(ord(YTIME) gt 1)  ) = ( iTransChar(runCy,"RES_MEXTF",YTIME) * iSigma(runCy,"S1") * EXP(iSigma(runCy,"S2") *
           EXP(iSigma(runCy,"S3") * VPcOwnPcLevl.l(runCy,YTIME)))
               * VStockPcYearly.l(runCy,YTIME-1) /(iPop(YTIME-1,runCy) * 1000) )$(iPop(YTIME-1,runCy));

VMEPcNonGdp.FX(runCy,YTIME)$((not An(YTIME)) $(ord(YTIME) gt 1)  ) = ( iTransChar(runCy,"RES_MEXTF",YTIME) * iSigma(runCy,"S1") * EXP(iSigma(runCy,"S2") * EXP(iSigma(runCy,"S3") *
                          VPcOwnPcLevl.l(runCy,YTIME)))* 
                          VStockPcYearly.l(runCy,YTIME-1) /(iPop(YTIME-1,runCy) * 1000) )$(iPop(YTIME-1,runCy))+VMEPcNonGdp.l(runCy,YTIME-1)$(not iPop(YTIME-1,runCy));


iDataPassCars(runCy,"PC","MEXTV") = 0.01;
VMEPcGdp.FX(runCy,YTIME)$(not An(YTIME)) = iDataPassCars(runCy,"PC","MEXTV");

VScrRatePc.UP(runCy,YTIME) = 1;
VScrRatePc.FX(runCy,"2017") = 0.1; 

VGapTranspActiv.FX(runCy,TRANSE,YTIME)$(not AN(YTIME))=0;

VActivPassTrnsp.FX(runCy,"PC",YTIME)$(not AN(YTIME)) = iTransChar(runCy,"KM_VEH",YTIME); 
VActivPassTrnsp.FX(runCy,TRANP,YTIME) $(not AN(YTIME) and not sameas(TRANP,"PC")) = iActv(YTIME,runCy,TRANP); 
VActivPassTrnsp.FX(runCy,TRANSE,YTIME)$(not TRANP(TRANSE)) = 0;
VActivGoodsTransp.FX(runCy,TRANG,YTIME)$(not An(YTIME)) = iActv(YTIME,runCy,TRANG);
VActivGoodsTransp.FX(runCy,TRANSE,YTIME)$(not TRANG(TRANSE)) = 0;
VLftPc.FX(runCy,DSBS,EF,YTIME)$(SECTTECH(DSBS,EF)  $(not  TRANSE(DSBS)) $(not sameas(DSBS,"PC"))) = iTechLft(runCy,DSBS,EF,YTIME);
VLftPc.FX(runCy,TRANSE,TTECH,YTIME)$(SECTTECH(TRANSE,TTECH) $(not sameas(TRANSE,"PC"))) = iTechLft(runCy,TRANSE,TTECH,YTIME);
VLftPc.FX(runCy,DSBS,EF,YTIME)$(not SECTTECH(DSBS,EF))=0;
VLftPc.FX(runCy,"PC",TTECH,YTIME)$( (not AN(YTIME)) $SECTTECH("PC",TTECH))=10;

VConsSpecificFuel.FX(runCy,TRANSE,TTECH,EF,"2017")$(SECTTECH(TRANSE,EF) ) = iSpeFuelConsCostBy(runCy,TRANSE,TTECH,EF);
VShareTechSectoral.FX(runCy,TRANSE,TTECH,YTIME)$( SECTTECH(TRANSE,TTECH) $(not AN(YTIME))) = 0;
* FIXME: VConsTechTranspSectoral.FX(runCy,TRANSE,TTECH,EF,YTIME)... , only the line of code below
* author=giannou
VConsTechTranspSectoral.FX(runCy,TRANSE,TTECH,EF,YTIME)$(SECTTECH(TRANSE,TTECH)  $(not PLUGIN(TTECH)) $TTECHtoEF(TTECH,EF) $(not AN(YTIME))) = iFuelConsPerFueSub(runCy,TRANSE,EF,YTIME); 
VConsTechTranspSectoral.FX(runCy,TRANSE,TTECH,EF,YTIME)$(SECTTECH(TRANSE,TTECH)  $PLUGIN(TTECH) $(not AN(YTIME))) = 0;
VConsTechTranspSectoral.FX(runCy,TRANSE,TTECH,EF,YTIME)$(SECTTECH(TRANSE,TTECH)  $CHYBV(TTECH) $(not AN(YTIME))) =0;
VDemFinEneTranspPerFuel.FX(runCy,TRANSE,EF,YTIME) $(SECTTECH(TRANSE,EF) $(not An(YTIME))) = iFuelConsPerFueSub(runCy,TRANSE,EF,YTIME);

VElecNonSub.FX(runCy,INDDOM,YTIME)$(not An(YTIME)) = iFuelConsPerFueSub(runCy,INDDOM,"ELC",YTIME) * iShrNonSubElecInTotElecDem(runCy,INDDOM);
vElecConsInd.FX(runCy,YTIME)$(not An(YTIME))= SUM(INDSE,VElecNonSub.l(runCy,INDSE,YTIME));

VFuePriSubChp.FX(runCy,DSBS,EF,YTIME)$((not An(YTIME)) $(not TRANSE(DSBS))  $SECTTECH(DSBS,EF)) =
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

VTechShareNewEquip.FX(runCy,DSBS,EF,YTIME)$(SECTTECH(DSBS,EF)$(not An(YTIME))) = 0;
VConsRemSubEquip.FX(runCy,DSBS,EF,YTIME)$(SECTTECH(DSBS,EF) $(not An(ytime))) =
(VFuelConsInclHP.l(runCy ,DSBS,EF,YTIME) - (VElecNonSub.l(runCy,DSBS,YTIME)$(ELCEF(EF) $INDDOM(DSBS)) + 0$(not (ELCEF(EF) $INDDOM(DSBS)) )))
;



VFeCons.FX(runCy,EFS,YTIME)$(not An(YTIME)) = iFinEneCons(runCy,EFS,YTIME);
iFinEneConsPrevYear(runCy,EFS,YTIME)$(not An(YTIME)) = iFinEneCons(runCy,EFS,YTIME);
VLosses.FX(runCy,EFS,YTIME)$(not An(YTIME)) = iDistrLosses(runCy,EFS,YTIME);

VTransfOutThermPP.FX(runCy,EFS,YTIME)$(not TOCTEF(EFS)) = 0;
VRefCapacity.FX(runCy,YTIME)$(not An(YTIME)) = iRefCapacity(runCy,YTIME);
VTransfOutputRefineries.FX(runCy,EFS,YTIME)$(EFtoEFA(EFS,"LQD") $(not An(YTIME))) = iTransfOutputRef(runCy,EFS,YTIME);
VTransfInputRefineries.FX(runCy,"CRO",YTIME)$(not An(YTIME)) = iTransfInputRef(runCy,"CRO",YTIME);

VGrsInlConsNotEneBranch.FX(runCy,EFS,YTIME)$(not An(YTIME)) = iGrossInConsNoEneBra(runCy,EFS,YTIME);

VGrssInCons.FX(runCy,EFS,YTIME)$(not An(YTIME)) = iGrosInlCons(runCy,EFS,YTIME);
VTransfers.FX(runCy,EFS,YTIME)$(not An(YTIME)) = iFeedTransfr(runCy,EFS,YTIME);

VPrimProd.FX(runCy,PPRODEF,YTIME)$(not An(YTIME)) = iFuelPriPro(runCy,PPRODEF,YTIME);
VEnCons.FX(runCy,EFS,YTIME)$(not An(YTIME)) = iTotEneBranchCons(runCy,EFS,YTIME);

VExportsFake.FX(runCy,EFS,YTIME)$(not An(YTIME)) = iFuelExprts(runCy,EFS,YTIME);
VFkImpAllFuelsNotNatGas.FX(runCy,"NGS",YTIME)$(not An(YTIME)) = iFuelImports(runCy,"NGS",YTIME);
VExportsFake.FX(runCy,"NGS",YTIME)$(not An(YTIME)) = iFuelExprts(runCy,"NGS",YTIME);

VDemElec.FX(runCy,YTIME)$(not An(YTIME)) =  1/0.086 * ( iFinEneCons(runCy,"ELC",YTIME) + sum(NENSE, iFuelConsPerFueSub(runCy,NENSE,"ELC",YTIME)) + iDistrLosses(runCy,"ELC",YTIME)
                                             + iTotEneBranchCons(runCy,"ELC",YTIME) - (iFuelImports(runCy,"ELC",YTIME)-iFuelExprts(runCy,"ELC",YTIME)));

VLoadBaseElecExp.L(runCy,YTIME) = 0.5;
VLoadBaseElecExp.FX(runCy,YTIME)$(not An(YTIME)) = iPeakBsLoadBy(runCy,"BASELOAD");

VLoadFacDom.FX(runCy,YTIME)$(datay(YTIME)) =
         (sum(INDDOM,VConsFuel.l(runCy,INDDOM,"ELC",YTIME)) + sum(TRANSE, VDemFinEneTranspPerFuel.l(runCy,TRANSE,"ELC",YTIME)))/
         (sum(INDDOM,VConsFuel.l(runCy,INDDOM,"ELC",YTIME)/iLoadFacElecDem(INDDOM)) + sum(TRANSE, VDemFinEneTranspPerFuel.l(runCy,TRANSE,"ELC",YTIME)/
         iLoadFacElecDem(TRANSE)));
VLoadPeakElec.L(runCy,YTIME) = 1;
VLoadPeakElec.FX(runCy,YTIME)$(datay(YTIME)) = VDemElec.l(runCy,YTIME)/(VLoadFacDom.l(runCy,YTIME)*8.76);

VTotElecGenCap.FX(runCy,YTIME)$(not An(YTIME)) = iTotAvailCapBsYr(runCy);
VCapGenElecNoChp.FX(runCy,YTIME)$(not An(YTIME)) = iTotAvailCapBsYr(runCy);
VCapElecChp.FX(runCy,CHP,YTIME)$(not An(YTIME)) = iHisChpGrCapData(runCy,CHP,YTIME);
VShaNewEqPowPla.FX(runCy,PGALL,YTIME)$((NOT AN(YTIME)) )=0;

VCostHourProdInvDec.FX(runCy,PGALL,HOUR,YTIME)$((NOT AN(YTIME)))=0;

VShareNewTechCcs.FX(runCy,PGALL,YTIME)$((NOT AN(YTIME)) )=0;
VShareNewTechNoCcs.FX(runCy,PGALL,YTIME)$((NOT AN(YTIME)) )=0;
VShareNewTechCcs.FX(runCy,PGALL,YTIME)$(AN(YTIME) $(NOT CCS(PGALL)))=0;
VShareNewTechNoCcs.FX(runCy,PGALL,YTIME)$(AN(YTIME) $(NOT NOCCS(PGALL)) )=0;

VDecisNewInv.FX(runCy,YTIME)$(NOT AN(YTIME))=1;

VCapGenPlannedPlant.FX(runCy,PGALL,YTIME)$DATAY(YTIME) = iInstCapPast(runCy,PGALL,YTIME);
VCapGenPlant.FX(runCy,PGALL,YTIME)$DATAY(YTIME) =  iInstCapPast(runCy,PGALL,YTIME);
VCapOverall.FX(runCy,PGALL,YTIME)$TFIRST(YTIME) =  iInstCapPast(runCy,PGALL,YTIME)$TFIRST(YTIME);

VCapGenNewResPlant.FX(runCy,PGALL,"2011")$PGREN(PGALL) = iInstCapPast(runCy,PGALL,"2011")- iInstCapPast(runCy,PGALL,"2010") +1E-10;
VCapGenNewResPlant.FX(runCy,PGALL,"2012")$PGREN(PGALL) = iInstCapPast(runCy,PGALL,"2012")- iInstCapPast(runCy,PGALL,"2011") +1E-10;
VCapGenNewResPlant.FX(runCy,PGALL,"2013")$PGREN(PGALL) = iInstCapPast(runCy,PGALL,"2013")- iInstCapPast(runCy,PGALL,"2012") +1E-10;
VCapGenNewResPlant.FX(runCy,PGALL,"2014")$PGREN(PGALL) = iInstCapPast(runCy,PGALL,"2014")- iInstCapPast(runCy,PGALL,"2013") +1E-10;
VCapGenNewResPlant.FX(runCy,PGALL,"2015")$PGREN(PGALL) = iInstCapPast(runCy,PGALL,"2015")- iInstCapPast(runCy,PGALL,"2014") +1E-10;
VCapGenNewResPlant.FX(runCy,PGALL,"2016")$PGREN(PGALL) = iInstCapPast(runCy,PGALL,"2016")- iInstCapPast(runCy,PGALL,"2015") +1E-10;
VCapGenNewResPlant.FX(runCy,PGALL,"2017")$PGREN(PGALL) = iInstCapPast(runCy,PGALL,"2017")- iInstCapPast(runCy,PGALL,"2016") +1E-10;
VCapGenNewResPlant.FX(runCy,"PGLHYD",YTIME)$TFIRST(YTIME) = +1E-10;

VCapAvgFacRes.FX(runCy,PGALL,YTIME)$DATAY(YTIME) =iAvailRate(PGALL,YTIME);


VProdElecPowPlantsCy.FX(runCy,pgall,YTIME)$DATAY(YTIME)=iDataElecProd(runCy,pgall,YTIME)/1000;
VIndexEndogScrap.FX(runCy,PGALL,YTIME)$(not an(YTIME) ) = 1;

VIndexEndogScrap.FX(runCy,PGSCRN,YTIME) = 1;            !! premature replacement it is not allowed for all new plants


VCO2ElcHrgProd.FX(runCy,YTIME)$(not An(YTIME)) = 0;

VRenShareElecProdSub.FX(runCy,YTIME)$(NOT AN(YTIME))=0;
VPotRenSuppCurve.FX(runCy,PGRENEF, YTIME) $(NOT AN(YTIME)) = iMinRenPotential(runCy,PGRENEF,YTIME);

VCostPowGenAvgLng.L(runCy,ESET,"2010") = 0;
VCostPowGenLonNoClimPol.L(runCy,ESET,"2010") = 0;
vCostPowGenAvgShrt.L(runCy,ESET,"2010") = 0;
VCostPowGenLngTechNoCp.L(runCy,PGALL,ESET,"2010") = 0;
VCostAvgPowGenLonNoClimPol.L(runCy,PGALL,ESET,"2010") = 0;
VCostPowGenAvgLng.L(runCy,ESET,"2017") = 0;
VCostPowGenLonNoClimPol.l(runCy,ESET,"%fBaseY%") = 0;
vCostPowGenAvgShrt.L(runCy,ESET,"%fBaseY%") = 0;

VCostPowGenLngTechNoCp.L(runCy,PGALL,ESET,"2017") = 0;
VCostAvgPowGenLonNoClimPol.FX(runCy,PGALL,ESET,"%fBaseY%") = 0;

VCarVal.fx(runCy,NAP,YTIME)$(not An(YTIME))=0;
VCarVal.FX(runCy,"TRADE",YTIME)$an(YTIME) = sExogCarbValue*iCarbValYrExog(runCy,YTIME);
VCarVal.FX(runCy,"NOTRADE",YTIME)$an(YTIME) =sExogCarbValue*iCarbValYrExog(runCy,YTIME);

VCumCO2Capt.FX(runCy,YTIME)$(not an(YTIME)) = 0 ;

*VCO2SeqCsts.FX(runCy,YTIME) = iElastCO2Seq(runCy,"mc_a") *iElastCO2Seq(runCy,"mc_b");

VDemFinEneTranspPerFuel.FX(runCy,TRANSE,EF,YTIME)$(not SECTTECH(TRANSE,EF)) = 0;
VTransfOutputDHPlants.FX(runCy,EFS,YTIME)$(not STEAM(EFS)) = 0;
VTransfOutputRefineries.FX(runCy,EFS,YTIME)$(not EFtoEFA(EFS,"LQD")) = 0;
VTransfInputRefineries.FX(runCy,EFS,YTIME)$(not sameas("CRO",EFS)) = 0;
VTransfOutputNuclear.FX(runCy,EFS,YTIME)$(not sameas("ELC",EFS)) = 0;
VTransfInNuclear.FX(runCy,EFS,YTIME)$(not sameas("NUC",EFS)) = 0;
VTransfInThermPowPls.FX(runCy,EFS,YTIME)$(not PGEF(EFS)) = 0;
VExportsFake.FX(runCy,EFS,YTIME)$(not IMPEF(EFS)) = 0;
VFkImpAllFuelsNotNatGas.FX(runCy,EFS,YTIME)$(not IMPEF(EFS)) = 0;

VScalFacPlaDisp.LO(runCy, HOUR, YTIME)=-1;
VLambda.LO(runCy,YTIME)=0;
VLambda.L(runCy,YTIME)=0.21;
VRenValue.FX(YTIME) = 0 ;
VProdReqTotElec.fx(runCy,"%fBaseY%")=sum(pgall,VProdElecPowPlantsCy.L(runCy,pgall,"%fBaseY%"));
display VCostProdTechPreReplacAvail.l;

loop an do !! start outer iteration loop (time steps)
   s = s + 1;
   TIME(YTIME) = NO;
   TIME(AN)$(ord(an)=s) = YES;
   display TIME;
