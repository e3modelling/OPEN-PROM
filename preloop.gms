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
QLambda                            !! VLoadCurveConstr(runCy,YTIME)
QElecDem                           !! VElecDem(runCy,YTIME)
QEstBaseLoad                       !! VEstBaseLoad(runCy,YTIME)
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
QEndogScrapIndex                   !! VEndogScrapIndex(runCy,PGALL,YTIME)
QElecGenNoChp                      !! VElecGenNoChp(runCy,YTIME)
QGapPowerGenCap                    !! VGapPowerGenCap(runCy,YTIME)
qScalWeibull                       !! vScalWeibull(runCy,PGALL,HOUR,YTIME) 
QRenPotSupplyCurve                 !! VRenPotSupplyCurve(runCy,PGRENEF,YTIME)
QMaxmAllowRenPotent                !! VMaxmAllowRenPotent(runCy,PGRENEF,YTIME)
QMnmAllowRenPot                    !! VMnmAllowRenPot(runCy,PGRENEF,YTIME)
QRenTechMatMult                    !! VRenTechMatMult(runCy,PGALL,YTIME)
QScalWeibullSum                    !! VScalWeibullSum(runCy,PGALL,YTIME)
QNewInvDecis                       !! VNewInvDecis(runCy,YTIME)
QPowPlaShaNewEquip                 !! VPowPlaShaNewEquip(runCy,PGALL,YTIME)
QElecGenCapacity                   !! VElecGenPlantsCapac(runCy,PGALL,YTIME)
QElecGenCap                        !! VElecGenPlanCap(runCy,PGALL,YTIME)
QVarCostTechnology                 !! VVarCostTechnology(runCy,PGALL,YTIME)
QElecPeakLoads                     !! VElecPeakLoads(runCy,YTIME) 
QElectrPeakLoad                    !! VPowPlantSorting(runCy,PGALL,YTIME)
QNewCapYearly                      !! VNewCapYearly(runCy,PGALL,YTIME)
QAvgCapFacRes                      !! VAvgCapFacRes(runCy,PGALL,YTIME)
QOverallCap                        !! VOverallCap(runCy,PGALL,YTIME)
QScalFacPlantDispatch              !! VScalFacPlaDisp
QElecChpPlants                     !! VElecChpPlants(runCy,YTIME) 
QNonChpElecProd                    !! VNonChpElecProd(runCy,YTIME) 
QReqElecProd                       !! VReqElecProd(runCy,YTIME) 
QElecProdPowGenPlants              !! VElecProd(runCy,PGALL,YTIME)
qSecContrTotChpProd                !! vSecContrTotChpProd(runCy,INDDOM,CHP,YTIME)
QElecProdChpPlants                 !! VChpElecProd(runCy,CHP,YTIME)
qShareRenGrossElecProd             !! vResShareGrossElecProd(runCy,YTIME) 
QLonPowGenCostTechNoCp             !! VLongPowGenCost(runCy,PGALL,ESET,YTIME)
qLonMnmpowGenCost                  !! vLonMnmpowGenCost(runCy,PGALL,YTIME)
qLongPowGenIntPri                  !! vLongPowGenIntPri(runCy,PGALL,ESET,YTIME)
qShoPowGenIntPri                   !! vShoPowGenIntPri(runCy,PGALL,ESET,YTIME)
QLongPowGenCost                    !! VLongAvgPowGenCost(runCy,ESET,YTIME)
QLonAvgPowGenCostNoClimPol         !! VLonAvgPowGenCostNoClimPol(runCy,PGALL,ESET,YTIME)
QLonPowGenCostNoClimPol            !! VLonPowGenCostNoClimPol(runCy,ESET,YTIME)
QElecPriIndResNoCliPol             !! VElecPriIndResNoCliPol(runCy,ESET,YTIME)
qShortPowGenCost                   !! vAvgPowerGenCostShoTrm(runCy,ESET,YTIME)


*' * Transport *

QLftPcScrRate                       !! VLftPcScrRate(runCy,DSBS,EF,TEA,YTIME)
QActivGoodsTransp                  !! VActivGoodsTransp(runCy,TRANSE,YTIME)
QGapActivNewTech                    !! VGapActivNewTech(runCy,TRANSE,YTIME)
QConsSpecFuelTech                  !! VConsSpecFuelTech(runCy,TRANSE,TTECH,TEA,EF,YTIME)
QCostTranspMeanConsSize         !! VCostTranspMeanConsSize(runCy,TRANSE,rCon,TTECH,TEA,YTIME)
QTranspCostPerVeh                  !! VTranspCostPerVeh(runCy,TRANSE,rCon,TTECH,TEA,YTIME)
QCostTranspMatFac                  !! VCostTranspMatFac(runCy,TRANSE,RCon,TTECH,TEA,YTIME) 
QTechSortVarCost                   !! VTechSortVarCost(runCy,TRANSE,rCon,YTIME)
QTechSortVarCostNewEquip           !! VTechSortVarCostNewEquip(runCy,TRANSE,TTECH,TEA,YTIME)
QConsEachTechTransp                !! VConsEachTechTransp(runCy,TRANSE,TTECH,EF,TEA,YTIME)
QFinDemFuel            !! VFinDemFuel(runCy,TRANSE,EF,YTIME)
qFinEneDemTransp                   !! vFinEneDemTranspSub(runCy,TRANSE,YTIME)
QMEPcGdp                             !! VMEPcGdp(runCy,YTIME)
QMEPcNonGdp                             !! VMEPcNonGdp(runCy,YTIME)
QNumVeh                            !! VNumVeh(runCy,YTIME)
QNewReg                            !! VNewReg(runCy,YTIME)
QTrnspActiv                        !! VTrnspActiv(runCy,TRANSE,YTIME)
QScrap                             !! VScrap(runCy,YTIME)
QPcOwnPcLevl                              !! VPcOwnPcLevl(runCy,YTIME)
QScrRate                           !! VScrRate(runCy,YTIME)
QElecConsAll                       !! VElecConsAll(runCy,DSBS,YTIME)


*' * INDUSTRY  - DOMESTIC - NON ENERGY USES - BUNKERS VARIABLES *

QConsElecIndTertNonSub                    !! VConsElecIndTertNonSub(runCy,INDDOM,YTIME)
QConsSub                 !! VConsSub(runCy,DSBS,EF,YTIME)
QDemSub                            !! VDemSub(runCy,DSBS,YTIME)
qConsElecInd                       !! vConsElecInd(runCy,YTIME)
qDemInd                            !! vDemInd(runCy,YTIME)
QElecIndPrices                     !! VElecIndPrices(runCy,YTIME)
QConsFuelNoHeat                          !! VConsFuelNoHeat(runCy,DSBS,EF,YTIME)
QElecIndPricesEst                  !! VElecIndPricesEst(runCy,YTIME)
QFuePriSubChp                      !! VFuePriSubChp(runCy,DSBS,EF,TEA,YTIME)
QCostElecProdChp                    !! VCostElecProdChp(runCy,DSBS,CHP,YTIME)
QTechCost                          !! VTechCost(runCy,DSBS,rCon,EF,TEA,YTIME) 
QTechCostIntrm                     !! VTechCostIntrm(runCy,DSBS,rCon,EF,TEA,YTIME) 
QTechCostMatr                      !! VTechCostMatr(runCy,DSBS,rCon,EF,TEA,YTIME) 
QTechSort                          !! VTechSort(runCy,DSBS,rCon,YTIME)
QGapFinalDem                       !! VGapFinalDem(runCy,DSBS,YTIME)
QTechShareNewEquip                 !! VTechShareNewEquip(runCy,DSBS,EF,TEA,YTIME)
QFuelConsInclHP                    !! VFuelConsInclHP(runCy,DSBS,EF,YTIME)
QVarProCostPerCHPDem               !! VProCostCHPDem(runCy,DSBS,CHP,YTIME)
QAvgElcProCostCHP                  !! VAvgElcProCHP(runCy,CHP,YTIME)
QCostAvgVarChpFuel                    !! VCostAvgVarChpFuel(runCy,CHP,YTIME)


*' * REST OF ENERGY BALANCE SECTORS *

QConsFinEneCountry                     !! VConsFinEneCountry(runCy,EFS,YTIME)
qConsFinEneAll                  !! vConsFinEneAll(YTIME)
QConsFinNonEne                     !! VConsFinNonEne(runCy,EFS,YTIME)
QDistrLosses                       !! VDistrLosses(runCy,EFS,YTIME)
QOutTransfDhp               !! VOutTransfDhp(runCy,STEAM,YTIME)
QTransfInputDHPlants               !! VTransfInputDHPlants(runCy,EFS,YTIME)
QCapRef                       !! VCapRef(runCy,YTIME)
QOutTransfRefSpec             !! VOutTransfRefSpec(runCy,EFS,YTIME)
QTransfInputRefineries             !! VTransfInputRefineries(runCy,"CRO",YTIME)
QTransfOutputNuclear               !! VTransfOutputNuclear(runCy,"ELC",YTIME)
QTransfInNuclear                   !! VTransfInNuclear(runCy,"NUC",YTIME)
QInpTransfTherm                  !! VInpTransfTherm(runCy,PGEF,YTIME)
QTransfOutThermPP                  !! VTransfOutThermPP(runCy,TOCTEF,YTIME)
QTotTransfInput                    !! VTotTransfInput(runCy,EFS,YTIME)
QTotTransfOutput                   !! VTotTransfOutput(runCy,EFS,YTIME)
QTransfers                         !! VTransfers(runCy,EFS,YTIME)
QGrsInlConsNotEneBranch            !! VGrsInlConsNotEneBranch(runCy,EFS,YTIME)
QGrssInCons                        !! VGrssInCons(runCy,EFS,YTIME)            
QPrimProd                          !! VPrimProd(runCy,PPRODEF,YTIME)
QExprtsFakeEneBrnch                           !! VExprtsFakeEneBrnch(runCy,EFS,YTIME)
QImptsFakeEneBrnch                        !! VImptsFakeEneBrnch(runCy,EFS,YTIME)
QNetImports                        !! VNetImports(runCy,EFS,YTIME)
QConsFiEneSec                   !! VConsFiEneSec(runCy,EFS,YTIME)


*' * CO2 SEQUESTRATION COST CURVES *

QCapCo2ElecHydr                         !! VCapCo2ElecHydr(runCy,YTIME)
QCaptCummCo2                        !! VCaptCummCo2(runCy,YTIME)
QTrnsWghtLinToExp                !! VTrnsWghtLinToExp(runCy,YTIME)
QCstCO2SeqCsts                     !! VCstCO2SeqCsts(runCy,YTIME)         


*' * EMISSIONS CONSTRAINTS *

QTotGhgEmisAllCountrNap           !! VTotGhgEmisAllCountrNap(NAP,YTIME)
qTotCo2AllCoun                    !! vTotCo2AllCoun(YTIME) 
qHouseExpEne                       !! vHouseExpEne(runCy,YTIME)


*' * Prices *

QFuelPriSubCarVal              !! VFuelPriSubCarVal(runCy,SBS,EF,YTIME)
QFuelPriSepCarbonWght                  !! VFuelPriSepCarbonWght(runCy,DSBS,EF,YTIME)
QAvgFuelPriSub                     !! VAvgFuelPriSub(runCy,DSBS,YTIME)
QElecPriIndResConsu                 !! VElecPriIndResConsu(runCy,ESET,YTIME)



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
VFuelPriSubCarVal.l(allCy,SBS,EF,YTIME) = 1.5;
VElecIndPrices.l(allCy,YTIME)= 0.1;
VTechCostIntrm.l(allCy,DSBS,rcon,EF,TEA,YTIME) = 0.1;
VLftPcScrRate.l(allCy,DSBS,EF,TEA,YTIME)= 0.1;
VTechSort.l(allCy,DSBS,rCon,YTIME) = 0.1;
VConsFuelNoHeat.l(allCy,DSBS,EF,YTIME)=0.1;
VCapRef.l(allCy,YTIME)=0.1;
*VConsFinEneCountry.l(allCy,EF,YTIME) = 000000.1;
VOutTransfRefSpec.l(allCy,EFS,YTIME)=0.1;
VGrsInlConsNotEneBranch.l(allCy,EFS,YTIME)=0.1;
VElecConsAll.l(allCy,DSBS,YTIME)=0.1;
VLoadFacDom.l(allCy,YTIME)=0.1;
*VElecProd.l(allCy,PGALL,YTIME) = 1;
*VHourProdCostTech.up(allCy,PGALL,HOUR,YTIME)=1e6;
VSensCcs.l(allCy,YTIME)=1;
*VHourProdCostTech.VPcOwnPcLevl(allCy,PGALL,HOUR,YTIME)=1;
VFuelPriSubCarVal.l(allCy,"PG",PGEF,YTIME)=1;
VProdCostTechnology.lo(allCy,PGALL2,YTIME)=0.00000001;
*VProdCostTechnology.up(allCy,PGALL2,YTIME)=1e6;
VVarCostTech.l(allCy,PGALL,YTIME)=0.1;
VProdCostTechPreReplacAvail.l(allCy,PGALL,PGALL2,YTIME)=0.1;
VTechSortVarCost.l(allCy,TRANSE,Rcon,YTIME)=0.1;
*VHourProdCostTechNoCCS.up(allCy,PGALL,HOUR,YTIME)=8000;
*VHourProdCostTechNoCCS.VPcOwnPcLevl(allCy,PGALL,HOUR,YTIME)=10;
*VTemScalWeibull.up(allCy,PGALL,HOUR,YTIME)=1e6;
*VHourProdCostTechNoCCS.lo(allCy,PGALL,HOUR,YTIME)=0.0001;
VRenPotSupplyCurve.l(allCy,PGRENEF,YTIME)=0.1;
VScrRate.l(allCy,YTIME)=0.1;
VCostTranspMeanConsSize.l(allCy,TRANSE,RCon,TTECH,TEA,YTIME)=0.1;
*VCostTranspMeanConsSize.lo(allCy,TRANSE,RCon,TTECH,TEA,YTIME)=0.0001;
VConsElecIndTertNonSub.l(allCy,DSBS,YTIME)=0.1;
*VConsElecIndTertNonSub.lo(allCy,DSBS,YTIME)=0.000001;


VPowerPlantNewEq.L(allCy,PGALL,TT)=0.1;
vHourProdCostTechAfterCCS.L(allCy,PGALL,HOUR,TT)=0.1;
VPowerPlaShrNewEq.L(allCy,PGALL,TT)=0.1;
VHourProdCostTechNoCCS.L(runCy,PGALL,HOUR,TT) = VPowerPlantNewEq.L(runCy,PGALL,TT)*vHourProdCostTechAfterCCS.L(runCy,PGALL,HOUR,TT)+
         sum(CCS$CCS_NOCCS(CCS,PGALL), VPowerPlaShrNewEq.L(runCy,CCS,TT)*vHourProdCostTechAfterCCS.L(runCy,CCS,HOUR,TT));
*VHourProdCostTechNoCCS.SCALE(runCy,PGALL,HOUR,TT)= max(abs(VHourProdCostTechNoCCS.L(runCy,PGALL,HOUR,TT)),1E-20);
VNewInvDecis.l(allCy,YTIME)=0.1;
VVarCostTechnology.l(allCy,PGALL,YTIME)=0.1;
VElecPeakLoads.l(allCy,YTIME)=0.1;
VNewCapYearly.l(allCy,PGALL,YTIME)=0.1;
VAvgCapFacRes.l(allCy,PGALL,YTIME)=0.1;
VPowPlantSorting.l(runCy,PGALL,YTIME)=0.01;
*VOverallCap.scale(allCy,PGALL,YTIME)=1;
*VElecCapChpPla.l(runCy,CHP,YTIME) = 1/0.086 * sum(INDDOM,VConsFuelNoHeat.L(runCy,INDDOM,CHP,YTIME)) * VElecIndPrices.L(runCy,YTIME)/
*          sum(PGALL$CHPtoEON(CHP,PGALL),iAvailRate(PGALL,YTIME)) /
*         iUtilRateChpPlants(runCy,CHP,YTIME) /8.76;
VPowPlantSorting.l(runCy,PGALL,YTIME)=VVarCostTechnology.L(runCy,PGALL,YTIME)/VElecPeakLoads.L(runCy,YTIME);
VReqElecProd.l(runCy,YTIME) = 0.01;
*VReqElecProd.l(runCy,YTIME)=sum(hour, sum(CHP,VElecCapChpPla.L(runCy,CHP,YTIME)*exp(-VScalFacPlaDisp.L(runCy,HOUR,YTIME)/ sum(pgall$chptoeon(chp,pgall),VPowPlantSorting.L(runCy,PGALL,YTIME)))));
*VPowPlantSorting.up(runCy,PGALL,YTIME)=0.001;
*VPowPlantSorting.scale(runCy,PGALL,YTIME)=1;
VScalFacPlaDisp.L(runCy,HOUR,YTIME) = 1.e-12;
VElecDem.l(allCy,YTIME)=0.1;
*VHourProdCostTech.lo(runCy,PGALL,HOUR,YTIME)=0.0001;
*VHourProdCostTechNoCCS.lo(runCy,PGALL,HOUR,YTIME)=0.1;
VRenTechMatMult.l(allCy,PGALL,YTIME)=0.1;
VActivGoodsTransp.l(allCy,TRANSE,YTIME)=0.1;
*VTranspCostPerVeh.lo(allCy,TRANSE,RCon,TTECH,TEA,YTIME)=0.1;
VRenShareElecProdSub.FX(runCy,YTIME)$(NOT AN(YTIME))=0;
VRenValue.l(YTIME)=1;
VCstCO2SeqCsts.l(allCy,YTIME)=1;
VScalWeibullSum.l(allCy,PGALL,YTIME)=2;
*VScalWeibullSum.up(allCy,PGALL,YTIME)=1.0e+10;
VHourProdCostTech.l(runCy,PGALL,HOUR,TT) = 0.0001;


*' *                        VARIABLE INITIALISATION                               *


VFuelPriSubCarVal.FX(runCy,SBS,EF,YTIME)$(SECTTECH(SBS,EF)$(not HEATPUMP(EF))$(not An(YTIME))) = iFuelPrice(runCy,SBS,EF,YTIME);
VFuelPriSubCarVal.FX(runCy,SBS,ALTEF,YTIME)$(SECTTECH(SBS,ALTEF)$(not An(YTIME))) = sum(EF$ALTMAP(SBS,ALTEF,EF),iFuelPrice(runCy,SBS,EF,YTIME));
* FIXME: VFuelPriSubCarVal (NUC/MET/ETH/BGDO) should be computed endogenously after startYear, and with mrprom before startYear
* author=giannou
VFuelPriSubCarVal.FX(runCy,"PG","NUC",YTIME) = 0.025; !! fixed price for nuclear fuel to 25Euro/toe
VFuelPriSubCarVal.FX(runCy,"H2P","NUC",YTIME) = 0.025; !! fixed price for nuclear fuel to 25Euro/toe
VFuelPriSubCarVal.FX(runCy,SBS,"MET",YTIME)$(not An(YTIME)) = 800; !! fixed price methanol
VFuelPriSubCarVal.FX(runCy,SBS,"ETH",YTIME)$(not An(YTIME)) = 800; !! fixed price for ethanol
VFuelPriSubCarVal.FX(runCy,SBS,"BGDO",YTIME)$(not An(YTIME)) = 350; !! fixed price for biodiesel
VFuelPriSubCarVal.fx(runCy,INDDOM,"HEATPUMP",YTIME)$(SECTTECH(INDDOM,"HEATPUMP")$(not An(YTIME))) = iFuelPrice(runCy,INDDOM,"ELC",YTIME);
VFuelPriSubCarVal.fx(runCy,"H2P",EF,YTIME)$(SECTTECH("H2P",EF)$(not An(YTIME))) = VFuelPriSubCarVal.l(runCy,"PG",EF,YTIME);
VFuelPriSubCarVal.fx(runCy,"H2P","ELC",YTIME)$(not An(YTIME))= VFuelPriSubCarVal.l(runCy,"OI","ELC",YTIME);

VElecPriIndResConsu.FX(runCy,"i",YTIME)$(not An(YTIME)) = VFuelPriSubCarVal.l(runCy,"OI","ELC",YTIME)*sTWhToMtoe;
VElecPriIndResConsu.FX(runCy,"r",YTIME)$(not An(YTIME)) = VFuelPriSubCarVal.l(runCy,"HOU","ELC",YTIME)*sTWhToMtoe;
VElecPriIndResNoCliPol.FX(runCy,"i",YTIME)$(not an(ytime)) = VFuelPriSubCarVal.l(runCy,"OI","ELC",YTIME)*0.086;
VElecPriIndResNoCliPol.FX(runCy,"r",YTIME)$(not an(ytime)) = VFuelPriSubCarVal.l(runCy,"HOU","ELC",YTIME)*0.086;
VFuelPriSubNoCarb.FX(runCy,SBS,EF,YTIME)$(SECTTECH(SBS,EF) $(not HEATPUMP(EF))  $(not An(YTIME))) = iFuelPrice(runCy,SBS,EF,YTIME);
VFuelPriSubNoCarb.FX(runCy,SBS,ALTEF,YTIME)$(SECTTECH(SBS,ALTEF) $(not An(YTIME))) = sum(EF$ALTMAP(SBS,ALTEF,EF),iFuelPrice(runCy,SBS,EF,YTIME));
VFuelPriSubNoCarb.FX(runCy,"PG","NUC",YTIME) = 0.025; !! fixed price for nuclear fuel to 25Euro/toe
VFuelPriSubNoCarb.fx(runCy,INDDOM,"HEATPUMP",YTIME)$(SECTTECH(INDDOM,"HEATPUMP")$(not An(YTIME))) = iFuelPrice(runCy,INDDOM,"ELC",YTIME);
VAvgFuelPriSub.L(runCy,DSBS,YTIME) = 0.1;
VAvgFuelPriSub.FX(runCy,DSBS,YTIME)$(not An(YTIME)) = sum(EF$SECTTECH(DSBS,EF), iWgtSecAvgPriFueCons(runCy,DSBS,EF) * iFuelPrice(runCy,DSBS,EF,YTIME));

VNumVeh.UP(runCy,YTIME) = 10000; !! upper bound of VNumVeh is 10000 million vehicles
VNumVeh.FX(runCy,YTIME)$(not An(YTIME)) = iActv(YTIME,runCy,"PC");
VPcOwnPcLevl.UP(runCy,YTIME) = 1;
iPassCarsMarkSat(runCy) = 0.7; 

* Compute electricity consumed in heatpump plants, QElecConsHeatPla(runCy,INDDOM,YTIME)$time(ytime).
VElecConsHeatPla.FX(runCy,INDDOM,YTIME) = 1E-7;

iTransChar(runCy,"RES_MEXTF",YTIME) = 0.04;
iTransChar(runCy,"RES_MEXTV",YTIME) = 0.04;

VPcOwnPcLevl.FX(runCy,YTIME)$((not An(YTIME)) $(ord(YTIME) gt 1) ) = (VNumVeh.l(runCy,YTIME-1) / (iPop(YTIME-1,runCy)*1000) /
iPassCarsMarkSat(runCy))$(iPop(YTIME-1,runCy))+VPcOwnPcLevl.l(runCy,YTIME-1)$(not iPop(YTIME-1,runCy));
VMEPcNonGdp.l(runCy,YTIME)$((not An(YTIME)) $(ord(YTIME) gt 1)  ) = ( iTransChar(runCy,"RES_MEXTF",YTIME) * iSigma(runCy,"S1") * EXP(iSigma(runCy,"S2") *
           EXP(iSigma(runCy,"S3") * VPcOwnPcLevl.l(runCy,YTIME)))
               * VNumVeh.l(runCy,YTIME-1) /(iPop(YTIME-1,runCy) * 1000) )$(iPop(YTIME-1,runCy));

VMEPcNonGdp.FX(runCy,YTIME)$((not An(YTIME)) $(ord(YTIME) gt 1)  ) = ( iTransChar(runCy,"RES_MEXTF",YTIME) * iSigma(runCy,"S1") * EXP(iSigma(runCy,"S2") * EXP(iSigma(runCy,"S3") *
                          VPcOwnPcLevl.l(runCy,YTIME)))* 
                          VNumVeh.l(runCy,YTIME-1) /(iPop(YTIME-1,runCy) * 1000) )$(iPop(YTIME-1,runCy))+VMEPcNonGdp.l(runCy,YTIME-1)$(not iPop(YTIME-1,runCy));


iDataPassCars(runCy,"PC","MEXTV") = 0.01;
VMEPcGdp.FX(runCy,YTIME)$(not An(YTIME)) = iDataPassCars(runCy,"PC","MEXTV");

VScrRate.UP(runCy,YTIME) = 1;
VScrRate.FX(runCy,"2017") = 0.1; 

VGapActivNewTech.FX(runCy,TRANSE,YTIME)$(not AN(YTIME))=0;

VTrnspActiv.FX(runCy,"PC",YTIME)$(not AN(YTIME)) = iTransChar(runCy,"KM_VEH",YTIME); 
VTrnspActiv.FX(runCy,TRANP,YTIME) $(not AN(YTIME) and not sameas(TRANP,"PC")) = iActv(YTIME,runCy,TRANP); 
VTrnspActiv.FX(runCy,TRANSE,YTIME)$(not TRANP(TRANSE)) = 0;
VActivGoodsTransp.FX(runCy,TRANG,YTIME)$(not An(YTIME)) = iActv(YTIME,runCy,TRANG);
VActivGoodsTransp.FX(runCy,TRANSE,YTIME)$(not TRANG(TRANSE)) = 0;
VLftPcScrRate.FX(runCy,DSBS,EF,TEA,YTIME)$(SECTTECH(DSBS,EF)  $(not  TRANSE(DSBS)) $(not sameas(DSBS,"PC"))) = iTechLft(runCy,DSBS,EF,YTIME);
VLftPcScrRate.FX(runCy,TRANSE,TTECH,TEA,YTIME)$(SECTTECH(TRANSE,TTECH) $(not sameas(TRANSE,"PC"))) = iTechLft(runCy,TRANSE,TTECH,YTIME);
VLftPcScrRate.FX(runCy,DSBS,EF,TEA,YTIME)$(not SECTTECH(DSBS,EF))=0;
VLftPcScrRate.FX(runCy,"PC",TTECH,TEA,YTIME)$( (not AN(YTIME)) $SECTTECH("PC",TTECH))=10;

VConsSpecFuelTech.FX(runCy,TRANSE,TTECH,TEA,EF,"2017")$(SECTTECH(TRANSE,EF) ) = iSpeFuelConsCostBy(runCy,TRANSE,TTECH,TEA,EF);
VTechSortVarCostNewEquip.FX(runCy,TRANSE,TTECH,TEA,YTIME)$( SECTTECH(TRANSE,TTECH) $(not AN(YTIME))) = 0;
* FIXME: VConsEachTechTransp.FX(runCy,TRANSE,TTECH,EF,TEA,YTIME)... , only the line of code below
* author=giannou
VConsEachTechTransp.FX(runCy,TRANSE,TTECH,EF,TEA,YTIME)$(SECTTECH(TRANSE,TTECH)  $(not PLUGIN(TTECH)) $TTECHtoEF(TTECH,EF) $(not AN(YTIME))) = iFuelConsPerFueSub(runCy,TRANSE,EF,YTIME); 
VConsEachTechTransp.FX(runCy,TRANSE,TTECH,EF,TEA,YTIME)$(SECTTECH(TRANSE,TTECH)  $PLUGIN(TTECH) $(not AN(YTIME))) = 0;
VConsEachTechTransp.FX(runCy,TRANSE,TTECH,EF,TEA,YTIME)$(SECTTECH(TRANSE,TTECH)  $CHYBV(TTECH) $(not AN(YTIME))) =0;
VFinDemFuel.FX(runCy,TRANSE,EF,YTIME) $(SECTTECH(TRANSE,EF) $(not An(YTIME))) = iFuelConsPerFueSub(runCy,TRANSE,EF,YTIME);

VConsElecIndTertNonSub.FX(runCy,INDDOM,YTIME)$(not An(YTIME)) = iFuelConsPerFueSub(runCy,INDDOM,"ELC",YTIME) * iShrNonSubElecInTotElecDem(runCy,INDDOM);
vConsElecInd.FX(runCy,YTIME)$(not An(YTIME))= SUM(INDSE,VConsElecIndTertNonSub.l(runCy,INDSE,YTIME));

VFuePriSubChp.FX(runCy,DSBS,EF,TEA,YTIME)$((not An(YTIME)) $(not TRANSE(DSBS))  $SECTTECH(DSBS,EF)) =
(((VFuelPriSubCarVal.l(runCy,DSBS,EF,YTIME)+iVarCostTech(runCy,DSBS,EF,YTIME)/1000)/iUsfEneConvSubTech(runCy,DSBS,EF,YTIME)- 
(0$(not CHP(EF)) + (VFuelPriSubCarVal.l(runCy,"OI","ELC",YTIME)*iFracElecPriChp*iElecIndex(runCy,"2010"))$CHP(EF))) + (0.003) + 
SQRT( SQR(((VFuelPriSubCarVal.l(runCy,DSBS,EF,YTIME)+iVarCostTech(runCy,DSBS,EF,YTIME)/1000)/iUsfEneConvSubTech(runCy,DSBS,EF,YTIME)- (0$(not CHP(EF)) + 
(VFuelPriSubCarVal.l(runCy,"OI","ELC",YTIME)*iFracElecPriChp*iElecIndex(runCy,"2010"))$CHP(EF)))-(0.003)) + SQR(1e-7) ) )/2;


VDemSub.FX(runCy,INDDOM,YTIME)$(not An(YTIME)) = max(iTotFinEneDemSubBaseYr(runCy,INDDOM,YTIME) - VConsElecIndTertNonSub.L(runCy,INDDOM,YTIME),1e-5);
VDemSub.FX(runCy,NENSE,YTIME)$(not An(YTIME)) = max(iTotFinEneDemSubBaseYr(runCy,NENSE,YTIME),1e-5);
VDemSub.FX(runCy,"HOU",YTIME)$(not An(YTIME)) = max(iTotFinEneDemSubBaseYr(runCy,"HOU",YTIME) - VConsElecIndTertNonSub.L(runCy,"HOU",YTIME)-iExogDemOfBiomass(runCy,"HOU",YTIME),1e-5);
vDemInd.FX(runCy,YTIME)$(not An(YTIME))= SUM(INDSE,VDemSub.L(runCy,INDSE,YTIME));

VElecIndPrices.FX(runCy,YTIME)$TFIRST(YTIME) = iElecIndex(runCy,YTIME);

VElecConsHeatPla.FX(runCy,INDDOM,YTIME)$(not An(YTIME)) = iFuelConsPerFueSub(runCy,INDDOM,"ELC",YTIME)*(1-iShrNonSubElecInTotElecDem(runCy,INDDOM))*iShrHeatPumpElecCons(runCy,INDDOM);

VConsFuelNoHeat.FX(runCy,DSBS,EF,YTIME)$(SECTTECH(DSBS,EF) $(not HEATPUMP(EF)) $(not TRANSE(DSBS)) $(not An(YTIME))) = iFuelConsPerFueSub(runCy,DSBS,EF,YTIME);

VFuelConsInclHP.FX(runCy,DSBS,EF,YTIME)$(SECTTECH(DSBS,EF) $(not TRANSE(DSBS)) $(not An(YTIME))) =
(iFuelConsPerFueSub(runCy,DSBS,EF,YTIME))$((not ELCEF(EF)) $(not HEATPUMP(EF)))
+(VElecConsHeatPla.l(runCy,DSBS,YTIME)*iUsfEneConvSubTech(runCy,DSBS,"HEATPUMP",YTIME))$HEATPUMP(EF)+
(iFuelConsPerFueSub(runCy,DSBS,EF,YTIME)-VElecConsHeatPla.l(runCy,DSBS,YTIME))$ELCEF(EF)
+1e-7$(H2EF(EF) or sameas("STE1AH2F",EF))
;

VTechShareNewEquip.FX(runCy,DSBS,EF,TEA,YTIME)$(SECTTECH(DSBS,EF)$(not An(YTIME))) = 0;
VConsSub.FX(runCy,DSBS,EF,YTIME)$(SECTTECH(DSBS,EF) $(not An(ytime))) =
(VFuelConsInclHP.l(runCy ,DSBS,EF,YTIME) - (VConsElecIndTertNonSub.l(runCy,DSBS,YTIME)$(ELCEF(EF) $INDDOM(DSBS)) + 0$(not (ELCEF(EF) $INDDOM(DSBS)) )))
;



VConsFinEneCountry.FX(runCy,EFS,YTIME)$(not An(YTIME)) = iFinEneCons(runCy,EFS,YTIME);
iFinEneConsPrevYear(runCy,EFS,YTIME)$(not An(YTIME)) = iFinEneCons(runCy,EFS,YTIME);
VDistrLosses.FX(runCy,EFS,YTIME)$(not An(YTIME)) = iDistrLosses(runCy,EFS,YTIME);

VTransfOutThermPP.FX(runCy,EFS,YTIME)$(not TOCTEF(EFS)) = 0;
VCapRef.FX(runCy,YTIME)$(not An(YTIME)) = iRefCapacity(runCy,YTIME);
VOutTransfRefSpec.FX(runCy,EFS,YTIME)$(EFtoEFA(EFS,"LQD") $(not An(YTIME))) = iTransfOutputRef(runCy,EFS,YTIME);
VTransfInputRefineries.FX(runCy,"CRO",YTIME)$(not An(YTIME)) = iTransfInputRef(runCy,"CRO",YTIME);

VGrsInlConsNotEneBranch.FX(runCy,EFS,YTIME)$(not An(YTIME)) = iGrossInConsNoEneBra(runCy,EFS,YTIME);

VGrssInCons.FX(runCy,EFS,YTIME)$(not An(YTIME)) = iGrosInlCons(runCy,EFS,YTIME);
VTransfers.FX(runCy,EFS,YTIME)$(not An(YTIME)) = iFeedTransfr(runCy,EFS,YTIME);

VPrimProd.FX(runCy,PPRODEF,YTIME)$(not An(YTIME)) = iFuelPriPro(runCy,PPRODEF,YTIME);
VConsFiEneSec.FX(runCy,EFS,YTIME)$(not An(YTIME)) = iTotEneBranchCons(runCy,EFS,YTIME);

VExprtsFakeEneBrnch.FX(runCy,EFS,YTIME)$(not An(YTIME)) = iFuelExprts(runCy,EFS,YTIME);
VImptsFakeEneBrnch.FX(runCy,"NGS",YTIME)$(not An(YTIME)) = iFuelImports(runCy,"NGS",YTIME);
VExprtsFakeEneBrnch.FX(runCy,"NGS",YTIME)$(not An(YTIME)) = iFuelExprts(runCy,"NGS",YTIME);

VElecDem.FX(runCy,YTIME)$(not An(YTIME)) =  1/0.086 * ( iFinEneCons(runCy,"ELC",YTIME) + sum(NENSE, iFuelConsPerFueSub(runCy,NENSE,"ELC",YTIME)) + iDistrLosses(runCy,"ELC",YTIME)
                                             + iTotEneBranchCons(runCy,"ELC",YTIME) - (iFuelImports(runCy,"ELC",YTIME)-iFuelExprts(runCy,"ELC",YTIME)));

VCorrBaseLoad.L(runCy,YTIME) = 0.5;
VCorrBaseLoad.FX(runCy,YTIME)$(not An(YTIME)) = iPeakBsLoadBy(runCy,"BASELOAD");

VLoadFacDom.FX(runCy,YTIME)$(datay(YTIME)) =
         (sum(INDDOM,VConsFuelNoHeat.l(runCy,INDDOM,"ELC",YTIME)) + sum(TRANSE, VFinDemFuel.l(runCy,TRANSE,"ELC",YTIME)))/
         (sum(INDDOM,VConsFuelNoHeat.l(runCy,INDDOM,"ELC",YTIME)/iLoadFacElecDem(INDDOM)) + sum(TRANSE, VFinDemFuel.l(runCy,TRANSE,"ELC",YTIME)/
         iLoadFacElecDem(TRANSE)));
VElecPeakLoad.L(runCy,YTIME) = 1;
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

VElecGenPlanCap.FX(runCy,PGALL,YTIME)$DATAY(YTIME) = iInstCapPast(runCy,PGALL,YTIME);
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


VElecProd.FX(runCy,pgall,YTIME)$DATAY(YTIME)=iDataElecProd(runCy,pgall,YTIME)/1000;
VEndogScrapIndex.FX(runCy,PGALL,YTIME)$(not an(YTIME) ) = 1;

VEndogScrapIndex.FX(runCy,PGSCRN,YTIME) = 1;            !! premature replacement it is not allowed for all new plants


VCapCo2ElecHydr.FX(runCy,YTIME)$(not An(YTIME)) = 0;

VRenShareElecProdSub.FX(runCy,YTIME)$(NOT AN(YTIME))=0;
VRenPotSupplyCurve.FX(runCy,PGRENEF, YTIME) $(NOT AN(YTIME)) = iMinRenPotential(runCy,PGRENEF,YTIME);

VLongAvgPowGenCost.L(runCy,ESET,"2010") = 0;
VLonPowGenCostNoClimPol.L(runCy,ESET,"2010") = 0;
vAvgPowerGenCostShoTrm.L(runCy,ESET,"2010") = 0;
VLongPowGenCost.L(runCy,PGALL,ESET,"2010") = 0;
VLonAvgPowGenCostNoClimPol.L(runCy,PGALL,ESET,"2010") = 0;
VLongAvgPowGenCost.L(runCy,ESET,"2017") = 0;
VLonPowGenCostNoClimPol.l(runCy,ESET,"%fBaseY%") = 0;
vAvgPowerGenCostShoTrm.L(runCy,ESET,"%fBaseY%") = 0;

VLongPowGenCost.L(runCy,PGALL,ESET,"2017") = 0;
VLonAvgPowGenCostNoClimPol.FX(runCy,PGALL,ESET,"%fBaseY%") = 0;

VCarVal.fx(runCy,NAP,YTIME)$(not An(YTIME))=0;
VCarVal.FX(runCy,"TRADE",YTIME)$an(YTIME) = sExogCarbValue*iCarbValYrExog(runCy,YTIME);
VCarVal.FX(runCy,"NOTRADE",YTIME)$an(YTIME) =sExogCarbValue*iCarbValYrExog(runCy,YTIME);

VCaptCummCo2.FX(runCy,YTIME)$(not an(YTIME)) = 0 ;

*VCstCO2SeqCsts.FX(runCy,YTIME) = iElastCO2Seq(runCy,"mc_a") *iElastCO2Seq(runCy,"mc_b");

VFinDemFuel.FX(runCy,TRANSE,EF,YTIME)$(not SECTTECH(TRANSE,EF)) = 0;
VOutTransfDhp.FX(runCy,EFS,YTIME)$(not STEAM(EFS)) = 0;
VOutTransfRefSpec.FX(runCy,EFS,YTIME)$(not EFtoEFA(EFS,"LQD")) = 0;
VTransfInputRefineries.FX(runCy,EFS,YTIME)$(not sameas("CRO",EFS)) = 0;
VTransfOutputNuclear.FX(runCy,EFS,YTIME)$(not sameas("ELC",EFS)) = 0;
VTransfInNuclear.FX(runCy,EFS,YTIME)$(not sameas("NUC",EFS)) = 0;
VInpTransfTherm.FX(runCy,EFS,YTIME)$(not PGEF(EFS)) = 0;
VExprtsFakeEneBrnch.FX(runCy,EFS,YTIME)$(not IMPEF(EFS)) = 0;
VImptsFakeEneBrnch.FX(runCy,EFS,YTIME)$(not IMPEF(EFS)) = 0;

VScalFacPlaDisp.LO(runCy, HOUR, YTIME)=-1;
VLoadCurveConstr.LO(runCy,YTIME)=0;
VLoadCurveConstr.L(runCy,YTIME)=0.21;
VRenValue.FX(YTIME) = 0 ;
VTotReqElecProd.fx(runCy,"%fBaseY%")=sum(pgall,VElecProd.L(runCy,pgall,"%fBaseY%"));
display VProdCostTechPreReplacAvail.l;

loop an do !! start outer iteration loop (time steps)
   s = s + 1;
   TIME(YTIME) = NO;
   TIME(AN)$(ord(an)=s) = YES;
   display TIME;
