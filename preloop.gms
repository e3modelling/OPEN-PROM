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

QPotRenCurr                         !! VPotRenCurr(runCy,PGRENEF,YTIME)
QCapElecCHP                         !! VCapElecCHP(runCy,CHP,YTIME)
QLambda                             !! VLambda(runCy,YTIME)
QDemElecTot                         !! VDemElecTot(runCy,YTIME)
QBsldEst                            !! VBsldEst(runCy,YTIME)
QLoadFacDom                         !! VLoadFacDom(runCy,YTIME)
QPeakLoad                           !! VPeakLoad(runCy,YTIME)
QBaseLoadMax                        !! VBaseLoadMax(runCy,YTIME)
QBaseLoad                           !! VBaseLoad(runCy,YTIME)
QProdReqTotElec                     !! VProdReqTotElec(runCy,YTIME)
QCapElecTotEst                      !! VCapElecTotEst(runCy,YTIME)
QCapElecTot                         !! VCapElecTot(runCy,YTIME)	
QCostHourProdInvDec                 !! VCostHourProdInvDec(runCy,PGALL,HOUR,YTIME)
QCostHourProdInvDecNoCCS            !! VCostHourProdInvDecNoCCS(runCy,PGALL,HOUR,YTIME)
QSensCCS                            !! VSensCCS(runCy,YTIME)
*qCostHourProdInvCCS                !! vCostHourProdInvCCS(runCy,PGALL,HOUR,YTIME) 
QCostProdSpecTech                   !! VCostProdSpecTech(runCy,PGALL,YTIME)
QShareNewTechCCS                    !! VShareNewTechCCS(runCy,PGALL,YTIME)
QShareNewTechNoCCS                  !! VShareNewTechNoCCS(runCy,PGALL,YTIME)
QCostVarTech                        !! VCostVarTech(runCy,PGALL,YTIME)
QCostVarTechNotPGSCRN               !! VCostVarTechNotPGSCRN(runCy,PGALL,YTIME)
QCostProdTeCHPreReplac              !! VCostProdTeCHPreReplac(runCy,PGALL,YTIME)
QCostProdTeCHPreReplacAvail         !! VCostProdTeCHPreReplacAvail(runCy,PGALL,PGALL2,YTIME)
QIndxEndogScrap                     !! VIndxEndogScrap(runCy,PGALL,YTIME)
QCapElecNonCHP                      !! VCapElecNonCHP(runCy,YTIME)
QGapGenCapPowerDiff                 !! VGapGenCapPowerDiff(runCy,YTIME)
qScalWeibull                        !! vScalWeibull(runCy,PGALL,HOUR,YTIME) 
QPotRenSuppCurve                    !! VPotRenSuppCurve(runCy,PGRENEF,YTIME)
QPotRenMaxAllow                     !! VPotRenMaxAllow(runCy,PGRENEF,YTIME)
qPotRenMinAllow                     !! vPotRenMinAllow(runCy,PGRENEF,YTIME)
QRenTechMatMult                     !! VRenTechMatMult(runCy,PGALL,YTIME)
QScalWeibullSum                     !! VScalWeibullSum(runCy,PGALL,YTIME)
QNewInvElec                         !! VNewInvElec(runCy,YTIME)
QSharePowPlaNewEq                   !! VSharePowPlaNewEq(runCy,PGALL,YTIME)
QCapElec                            !! VCapElec(runCy,PGALL,YTIME)
QCapElec2                           !! VCapElec2(runCy,PGALL,YTIME)
QCostVarTechElec                    !! VCostVarTechElec(runCy,PGALL,YTIME)
QElecPeakLoads                      !! VElecPeakLoads(runCy,YTIME) 
QSortPlantDispatch                  !! VSortPlantDispatch(runCy,PGALL,YTIME)
QNewCapElec                         !! VNewCapElec(runCy,PGALL,YTIME)
QCFAvgRen                           !! VCFAvgRen(runCy,PGALL,YTIME)
QCapOverall                         !! VCapOverall(runCy,PGALL,YTIME)
QScalFacPlantDispatch               !! VScalFacPlaDisp
QProdEstElecCHP                     !! VProdEstElecCHP(runCy,YTIME) 
QProdElecNonCHP                     !! VProdElecNonCHP(runCy,YTIME) 
QProdReqElec                        !! VProdReqElec(runCy,YTIME) 
QProdElec                           !! VProdElec(runCy,PGALL,YTIME)
qSecContrTotCHPProd                 !! vSecContrTotCHPProd(runCy,INDDOM,CHP,YTIME)
QProdElecCHP                        !! VProdElecCHP(runCy,CHP,YTIME)
QCostPowGenLngTechNoCp              !! VCostPowGenLngTechNoCp(runCy,PGALL,ESET,YTIME)
qCostPowGenLonMin                   !! vCostPowGenLonMin(runCy,PGALL,YTIME)
qCostPowGenLongIntPri               !! vCostPowGenLongIntPri(runCy,PGALL,ESET,YTIME)
qCostPowGenShortIntPri              !! vCostPowGenShortIntPri(runCy,PGALL,ESET,YTIME)
QCostPowGenAvgLng                   !! VCostPowGenAvgLng(runCy,ESET,YTIME)
QCostAvgPowGenLonNoClimPol          !! VCostAvgPowGenLonNoClimPol(runCy,PGALL,ESET,YTIME)
QCostPowGenLonNoClimPol             !! VCostPowGenLonNoClimPol(runCy,ESET,YTIME)
QPriceElecIndResNoCliPol            !! VPriceElecIndResNoCliPol(runCy,ESET,YTIME)
qCostPowGenAvgShrt                  !! vCostPowGenAvgShrt(runCy,ESET,YTIME)


*' * Transport *

QLft                                !! VLft(runCy,DSBS,EF,YTIME)
QActivGoodsTransp                   !! VActivGoodsTransp(runCy,TRANSE,YTIME)
QGapTranspActiv                     !! VGapTranspActiv(runCy,TRANSE,YTIME)
QConsSpecificFuel                   !! VConsSpecificFuel(runCy,TRANSE,TTECH,EF,YTIME)
QCostTranspPerMeanConsSize          !! VCostTranspPerMeanConsSize(runCy,TRANSE,rCon,TTECH,YTIME)
QCostTranspPerVeh                   !! VCostTranspPerVeh(runCy,TRANSE,rCon,TTECH,YTIME)
QCostTranspMatFac                   !! VCostTranspMatFac(runCy,TRANSE,RCon,TTECH,YTIME) 
QTechSortVarCost                    !! VTechSortVarCost(runCy,TRANSE,rCon,YTIME)
QShareTechTr                        !! VShareTechTr(runCy,TRANSE,TTECH,YTIME)
QConsTechTranspSectoral             !! VConsTechTranspSectoral(runCy,TRANSE,TTECH,EF,YTIME)
QDemFinEneTranspPerFuel             !! VDemFinEneTranspPerFuel(runCy,TRANSE,EF,YTIME)
qDemFinEneSubTransp                 !! vDemFinEneSubTransp(runCy,TRANSE,YTIME)
QMEPcGdp                            !! VMEPcGdp(runCy,YTIME)
QMEPcNonGdp                         !! VMEPcNonGdp(runCy,YTIME)
QStockPcYearly                      !! VStockPcYearly(runCy,YTIME)
QNewRegPcYearly                     !! VNewRegPcYearly(runCy,YTIME)
QActivPassTrnsp                     !! VActivPassTrnsp(runCy,TRANSE,YTIME)
QNumPcScrap                         !! VNumPcScrap(runCy,YTIME)
QPcOwnPcLevl                        !! VPcOwnPcLevl(runCy,YTIME)
QRateScrPc                          !! VRateScrPc(runCy,YTIME)
QConsElec                           !! VConsElec(runCy,DSBS,YTIME)


*' * INDUSTRY  - DOMESTIC - NON ENERGY USES - BUNKERS VARIABLES *

QConsElecNonSubIndTert              !! VConsElecNonSubIndTert(runCy,INDDOM,YTIME)
QConsRemSubEquipSubSec              !! VConsRemSubEquipSubSec(runCy,DSBS,EF,YTIME)
QDemFinSubFuelSubsec                !! VDemFinSubFuelSubsec(runCy,DSBS,YTIME)
qConsTotElecInd                     !! vConsTotElecInd(runCy,YTIME)
qDemFinSubFuelInd                   !! vDemFinSubFuelInd(runCy,YTIME)
QPriceElecInd                       !! VPriceElecInd(runCy,YTIME)
QConsFuel                           !! VConsFuel(runCy,DSBS,EF,YTIME)
QIndxElecIndPrices                  !! VIndxElecIndPrices(runCy,YTIME)
QPriceFuelSubsecCHP                 !! VPriceFuelSubsecCHP(runCy,DSBS,EF,YTIME)
QCostElecProdCHP                    !! VCostElecProdCHP(runCy,DSBS,CHP,YTIME)
QCostTech                           !! VCostTech(runCy,DSBS,rCon,EF,YTIME) 
QCostTechIntrm                      !! VCostTechIntrm(runCy,DSBS,rCon,EF,YTIME) 
QCostTechMatFac                     !! VCostTechMatFac(runCy,DSBS,rCon,EF,YTIME) 
QSortTechVarCost                    !! VSortTechVarCost(runCy,DSBS,rCon,YTIME)
QGapFinalDem                        !! VGapFinalDem(runCy,DSBS,YTIME)
QShareTechNewEquip                  !! VShareTechNewEquip(runCy,DSBS,EF,YTIME)
QConsFuelInclHP                     !! VConsFuelInclHP(runCy,DSBS,EF,YTIME)
QCostProdCHPDem                     !! VCostProdCHPDem(runCy,DSBS,CHP,YTIME)
QCostElcAvgProdCHP                  !! VCostElcAvgProdCHP(runCy,CHP,YTIME)
QCostVarAvgElecProd                 !! VCostVarAvgElecProd(runCy,CHP,YTIME)


*' * REST OF ENERGY BALANCE SECTORS *

QConsFinEneCountry                  !! VConsFinEneCountry(runCy,EFS,YTIME)
qConsTotFinEne                      !! vConsTotFinEne(YTIME)
QConsFinNonEne                      !! VConsFinNonEne(runCy,EFS,YTIME)
QLossesDistr                        !! VLossesDistr(runCy,EFS,YTIME)
QOutTransfDhp                       !! VOutTransfDhp(runCy,STEAM,YTIME)
QTransfInputDHPlants                !! VTransfInputDHPlants(runCy,EFS,YTIME)
QCapRef                             !! VCapRef(runCy,YTIME)
QOutTransfRefSpec                   !! VOutTransfRefSpec(runCy,EFS,YTIME)
QInputTransfRef                     !! VInputTransfRef(runCy,"CRO",YTIME)
QOutTransfNuclear                   !! VOutTransfNuclear(runCy,"ELC",YTIME)
QInpTransfNuclear                   !! VInpTransfNuclear(runCy,"NUC",YTIME)
QInpTransfTherm                     !! VInpTransfTherm(runCy,PGEF,YTIME)
QOutTransfTherm                     !! VOutTransfTherm(runCy,TOCTEF,YTIME)
QInpTotTransf                       !! VInpTotTransf(runCy,EFS,YTIME)
QOutTotTransf                       !! VOutTotTransf(runCy,EFS,YTIME)
QTransfers                          !! VTransfers(runCy,EFS,YTIME)
QConsGrssInlNotEneBranch            !! VConsGrssInlNotEneBranch(runCy,EFS,YTIME)
QConsGrssInl                        !! VConsGrssInl(runCy,EFS,YTIME)            
QProdPrimary                        !! VProdPrimary(runCy,PPRODEF,YTIME)
QExp                                !! VExp(runCy,EFS,YTIME)
QImp                                !! VImp(runCy,EFS,YTIME)
QImpNetEneBrnch                     !! VImpNetEneBrnch(runCy,EFS,YTIME)
QConsFiEneSec                       !! VConsFiEneSec(runCy,EFS,YTIME)


*' * CO2 SEQUESTRATION COST CURVES *

QCapCO2ElecHydr                     !! VCapCO2ElecHydr(runCy,YTIME)
QCaptCummCO2                        !! VCaptCummCO2(runCy,YTIME)
QTrnsWghtLinToExp                   !! VTrnsWghtLinToExp(runCy,YTIME)
QCstCO2SeqCsts                      !! VCstCO2SeqCsts(runCy,YTIME)         


*' * EMISSIONS CONSTRAINTS *

QGrnnHsEmisCO2Equiv                 !! VGrnnHsEmisCO2Equiv(NAP,YTIME)
qGrnnHsEmisCO2EquivAllCntr          !! vGrnnHsEmisCO2EquivAllCntr(YTIME) 
qExpendHouseEne                     !! vExpendHouseEne(runCy,YTIME)


*' * Prices *

QPriceFuelSubsecCarVal                 !! VPriceFuelSubsecCarVal(runCy,SBS,EF,YTIME)
QPriceFuelSepCarbonWght             !! VPriceFuelSepCarbonWght(runCy,DSBS,EF,YTIME)
QPriceFuelAvgSub                    !! VPriceFuelAvgSub(runCy,DSBS,YTIME)
QPriceElecIndResConsu               !! VPriceElecIndResConsu(runCy,ESET,YTIME)



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

*' *                        VARIABLE INITIALISATION                               *

iPassCarsMarkSat(runCy) = 0.7; 

iTransChar(runCy,"RES_MEXTF",YTIME) = 0.04;
iTransChar(runCy,"RES_MEXTV",YTIME) = 0.04;

iDataPassCars(runCy,"PC","MEXTV") = 0.01;

iFinEneConsPrevYear(runCy,EFS,YTIME)$(not An(YTIME)) = iFinEneCons(runCy,EFS,YTIME);

VShareTechTr.FX(runCy,TRANSE,EF2,YTIME)$(not An(YTIME)) = iFuelConsTRANSE(runCy,TRANSE,EF2,YTIME)/sum(EF$(SECTTECH(TRANSE,EF)),iFuelConsTRANSE(runCy,TRANSE,EF,YTIME)); 
VShareTechTr.FX(runCy,TRANSE,TTECH,YTIME)$( SECTTECH(TRANSE,TTECH) $(not AN(YTIME))) = 0;

VStockPcYearly.L(runCy,YTIME)=0.1;
VStockPcYearly.UP(runCy,YTIME) = 10000; !! upper bound of VStockPcYearly is 10000 million vehicles
VStockPcYearly.FX(runCy,YTIME)$(not An(YTIME)) = iActv(YTIME,runCy,"PC");

VActivPassTrnsp.l(runCy,TRANSE,YTIME) = 0.1;
VActivPassTrnsp.FX(runCy,"PC",YTIME)$(not AN(YTIME)) = iTransChar(runCy,"KM_VEH",YTIME); 
VActivPassTrnsp.FX(runCy,TRANP,YTIME) $(not AN(YTIME) and not sameas(TRANP,"PC")) = iActv(YTIME,runCy,TRANP); 
VActivPassTrnsp.FX(runCy,TRANSE,YTIME)$(not TRANP(TRANSE)) = 0;

VNewRegPcYearly.FX(runCy,YTIME)$(not an(ytime)) = iNewReg(runCy,YTIME);

VPriceFuelSubsecCarVal.l(runCy,SBS,EF,YTIME) = 1.5;
VPriceFuelSubsecCarVal.l(runCy,"PG",PGEF,YTIME)=1;
VPriceFuelSubsecCarVal.FX(runCy,SBS,EF,YTIME)$(SECTTECH(SBS,EF)$(not HEATPUMP(EF))$(not An(YTIME))) = iFuelPrice(runCy,SBS,EF,YTIME);
VPriceFuelSubsecCarVal.FX(runCy,SBS,ALTEF,YTIME)$(SECTTECH(SBS,ALTEF)$(not An(YTIME))) = sum(EF$ALTMAP(SBS,ALTEF,EF),iFuelPrice(runCy,SBS,EF,YTIME));
* FIXME: VPriceFuelSubsecCarVal (NUC/MET/ETH/BGDO) should be computed endogenously after startYear, and with mrprom before startYear
* author=giannou
VPriceFuelSubsecCarVal.FX(runCy,"PG","NUC",YTIME) = 0.025; !! fixed price for nuclear fuel to 25Euro/toe
VPriceFuelSubsecCarVal.FX(runCy,"H2P","NUC",YTIME) = 0.025; !! fixed price for nuclear fuel to 25Euro/toe
VPriceFuelSubsecCarVal.FX(runCy,SBS,"MET",YTIME)$(not An(YTIME)) = 800; !! fixed price methanol
VPriceFuelSubsecCarVal.FX(runCy,SBS,"ETH",YTIME)$(not An(YTIME)) = 800; !! fixed price for ethanol
VPriceFuelSubsecCarVal.FX(runCy,SBS,"BGDO",YTIME)$(not An(YTIME)) = 350; !! fixed price for biodiesel
VPriceFuelSubsecCarVal.fx(runCy,INDDOM,"HEATPUMP",YTIME)$(SECTTECH(INDDOM,"HEATPUMP")$(not An(YTIME))) = iFuelPrice(runCy,INDDOM,"ELC",YTIME);
VPriceFuelSubsecCarVal.fx(runCy,"H2P",EF,YTIME)$(SECTTECH("H2P",EF)$(not An(YTIME))) = VPriceFuelSubsecCarVal.l(runCy,"PG",EF,YTIME);
VPriceFuelSubsecCarVal.fx(runCy,"H2P","ELC",YTIME)$(not An(YTIME))= VPriceFuelSubsecCarVal.l(runCy,"OI","ELC",YTIME);

VPriceElecInd.l(runCy,YTIME)= 0.1;
VPriceElecInd.FX(runCy,YTIME)$TFIRST(YTIME) = iElecIndex(runCy,YTIME);

VCostTechIntrm.l(runCy,DSBS,rcon,EF,YTIME) = 0.1;

VLft.l(runCy,DSBS,EF,YTIME)= 0.1;
VLft.FX(runCy,DSBS,EF,YTIME)$(SECTTECH(DSBS,EF)  $(not  TRANSE(DSBS)) $(not sameas(DSBS,"PC"))) = iTechLft(runCy,DSBS,EF,YTIME);
VLft.FX(runCy,TRANSE,TTECH,YTIME)$(SECTTECH(TRANSE,TTECH) $(not sameas(TRANSE,"PC"))) = iTechLft(runCy,TRANSE,TTECH,YTIME);
VLft.FX(runCy,DSBS,EF,YTIME)$(not SECTTECH(DSBS,EF))=0;
VLft.FX(runCy,"PC",TTECH,YTIME)$( (not AN(YTIME)) $SECTTECH("PC",TTECH))=10;

VSortTechVarCost.l(runCy,DSBS,rCon,YTIME) = 0.1;

VConsFuel.l(runCy,DSBS,EF,YTIME)=0.0000000001;
VConsFuel.FX(runCy,DSBS,EF,YTIME)$(SECTTECH(DSBS,EF) $(not HEATPUMP(EF)) $(not TRANSE(DSBS)) $(not An(YTIME))) = iFuelConsPerFueSub(runCy,DSBS,EF,YTIME);

VCapRef.l(runCy,YTIME)=0.1;
VCapRef.FX(runCy,YTIME)$(not An(YTIME)) = iRefCapacity(runCy,YTIME);

VOutTransfRefSpec.l(runCy,EFS,YTIME)=0.1;
VOutTransfRefSpec.FX(runCy,EFS,YTIME)$(EFtoEFA(EFS,"LQD") $(not An(YTIME))) = iTransfOutputRef(runCy,EFS,YTIME);
VOutTransfRefSpec.FX(runCy,EFS,YTIME)$(not EFtoEFA(EFS,"LQD")) = 0;

VConsGrssInlNotEneBranch.l(runCy,EFS,YTIME)=0.1;
VConsGrssInlNotEneBranch.FX(runCy,EFS,YTIME)$(not An(YTIME)) = iGrossInConsNoEneBra(runCy,EFS,YTIME);

VConsElec.l(runCy,DSBS,YTIME)=0.1;

VDemFinEneTranspPerFuel.FX(runCy,TRANSE,EF,YTIME) $(SECTTECH(TRANSE,EF) $(not An(YTIME))) = iFuelConsPerFueSub(runCy,TRANSE,EF,YTIME);
VDemFinEneTranspPerFuel.FX(runCy,TRANSE,EF,YTIME)$(not SECTTECH(TRANSE,EF)) = 0;

VLoadFacDom.l(runCy,YTIME)=0.1;
VLoadFacDom.FX(runCy,YTIME)$(datay(YTIME)) =
         (sum(INDDOM,VConsFuel.l(runCy,INDDOM,"ELC",YTIME)) + sum(TRANSE, VDemFinEneTranspPerFuel.l(runCy,TRANSE,"ELC",YTIME)))/
         (sum(INDDOM,VConsFuel.l(runCy,INDDOM,"ELC",YTIME)/iLoadFacElecDem(INDDOM)) + sum(TRANSE, VDemFinEneTranspPerFuel.l(runCy,TRANSE,"ELC",YTIME)/
         iLoadFacElecDem(TRANSE)));

VSensCCS.l(runCy,YTIME)=1;

VCostProdSpecTech.lo(runCy,PGALL2,YTIME)=0.00000001;

VCostVarTech.l(runCy,PGALL,YTIME)=0.1;

VCostProdTeCHPreReplacAvail.l(runCy,PGALL,PGALL2,YTIME)=0.1;

VTechSortVarCost.l(runCy,TRANSE,Rcon,YTIME)=0.1;
VTechSortVarCost.lo(runCy,TRANSE,Rcon,YTIME)=1e-20;

VPotRenSuppCurve.l(runCy,PGRENEF,YTIME)=0.1;
VPotRenSuppCurve.FX(runCy,PGRENEF, YTIME) $(NOT AN(YTIME)) = iMinRenPotential(runCy,PGRENEF,YTIME);

VPotRenCurr.l(runCy,PGRENEF, YTIME) $(AN(YTIME)) = 1000;
VPotRenCurr.FX(runCy,PGRENEF, YTIME) $(NOT AN(YTIME)) = iMinRenPotential(runCy,PGRENEF,YTIME);

VRateScrPc.l(runCy,YTIME)=0.1;
VRateScrPc.UP(runCy,YTIME) = 1;
VRateScrPc.FX(runCy,"%fBaseY%") = 0.1; 

VCostTranspPerMeanConsSize.l(runCy,TRANSE,RCon,TTECH,YTIME)=0.1;

VConsElecNonSubIndTert.l(runCy,DSBS,YTIME)=0.1;
VConsElecNonSubIndTert.FX(runCy,INDDOM,YTIME)$(not An(YTIME)) = iFuelConsPerFueSub(runCy,INDDOM,"ELC",YTIME) * iShrNonSubElecInTotElecDem(runCy,INDDOM);

VShareNewTechNoCCS.L(runCy,PGALL,TT)=0.1;
VShareNewTechNoCCS.FX(runCy,PGALL,YTIME)$((NOT AN(YTIME)) )=0;
VShareNewTechNoCCS.FX(runCy,PGALL,YTIME)$(AN(YTIME) $(NOT NOCCS(PGALL)) )=0;

vCostHourProdInvCCS.L(runCy,PGALL,HOUR,TT)=0.1;

VShareNewTechCCS.L(runCy,PGALL,TT)=0.1;
VShareNewTechCCS.FX(runCy,PGALL,YTIME)$((NOT AN(YTIME)) )=0;
VShareNewTechCCS.FX(runCy,PGALL,YTIME)$(AN(YTIME) $(NOT CCS(PGALL)))=0;

VCostHourProdInvDecNoCCS.L(runCy,PGALL,HOUR,TT) = VShareNewTechNoCCS.L(runCy,PGALL,TT)*vCostHourProdInvCCS.L(runCy,PGALL,HOUR,TT)+
         sum(CCS$CCS_NOCCS(CCS,PGALL), VShareNewTechCCS.L(runCy,CCS,TT)*vCostHourProdInvCCS.L(runCy,CCS,HOUR,TT));

VNewInvElec.l(runCy,YTIME)=0.1;
VNewInvElec.FX(runCy,YTIME)$(NOT AN(YTIME))=1;

VCostVarTechElec.l(runCy,PGALL,YTIME)=0.1;

VElecPeakLoads.l(runCy,YTIME)=0.1;

VNewCapElec.l(runCy,PGALL,YTIME)=0.1;
VNewCapElec.FX(runCy,PGALL,"2011")$PGREN(PGALL) = iInstCapPast(runCy,PGALL,"2011")- iInstCapPast(runCy,PGALL,"2010") +1E-10;
VNewCapElec.FX(runCy,PGALL,"2012")$PGREN(PGALL) = iInstCapPast(runCy,PGALL,"2012")- iInstCapPast(runCy,PGALL,"2011") +1E-10;
VNewCapElec.FX(runCy,PGALL,"2013")$PGREN(PGALL) = iInstCapPast(runCy,PGALL,"2013")- iInstCapPast(runCy,PGALL,"2012") +1E-10;
VNewCapElec.FX(runCy,PGALL,"2014")$PGREN(PGALL) = iInstCapPast(runCy,PGALL,"2014")- iInstCapPast(runCy,PGALL,"2013") +1E-10;
VNewCapElec.FX(runCy,PGALL,"2015")$PGREN(PGALL) = iInstCapPast(runCy,PGALL,"2015")- iInstCapPast(runCy,PGALL,"2014") +1E-10;
VNewCapElec.FX(runCy,PGALL,"2016")$PGREN(PGALL) = iInstCapPast(runCy,PGALL,"2016")- iInstCapPast(runCy,PGALL,"2015") +1E-10;
VNewCapElec.FX(runCy,PGALL,"2017")$PGREN(PGALL) = iInstCapPast(runCy,PGALL,"2017")- iInstCapPast(runCy,PGALL,"2016") +1E-10;
VNewCapElec.FX(runCy,PGALL,"2018")$PGREN(PGALL) = iInstCapPast(runCy,PGALL,"2018")- iInstCapPast(runCy,PGALL,"2017") +1E-10;
VNewCapElec.FX(runCy,PGALL,"2019")$PGREN(PGALL) = iInstCapPast(runCy,PGALL,"2019")- iInstCapPast(runCy,PGALL,"2018") +1E-10;
VNewCapElec.FX(runCy,PGALL,"2020")$PGREN(PGALL) = iInstCapPast(runCy,PGALL,"2020")- iInstCapPast(runCy,PGALL,"2019") +1E-10;
VNewCapElec.FX(runCy,"PGLHYD",YTIME)$TFIRST(YTIME) = +1E-10;

VCFAvgRen.l(runCy,PGALL,YTIME)=0.1;
VCFAvgRen.FX(runCy,PGALL,YTIME)$DATAY(YTIME) =iAvailRate(PGALL,YTIME);

VSortPlantDispatch.lo(runCy,PGALL,YTIME)=1.E-12;
VSortPlantDispatch.l(runCy,PGALL,YTIME)=VCostVarTechElec.L(runCy,PGALL,YTIME)/VElecPeakLoads.L(runCy,YTIME);

VProdReqElec.l(runCy,YTIME) = 0.01;

VScalFacPlaDisp.L(runCy,HOUR,YTIME) = 1.e-20;
VScalFacPlaDisp.LO(runCy, HOUR, YTIME)=-1;

VDemElecTot.l(runCy,YTIME)=0.1;
VDemElecTot.FX(runCy,YTIME)$(not An(YTIME)) =  1/0.086 * ( iFinEneCons(runCy,"ELC",YTIME) + sum(NENSE, iFuelConsPerFueSub(runCy,NENSE,"ELC",YTIME)) + iDistrLosses(runCy,"ELC",YTIME)
                                             + iTotEneBranchCons(runCy,"ELC",YTIME) - (iFuelImports(runCy,"ELC",YTIME)-iFuelExprts(runCy,"ELC",YTIME)));

VRenTechMatMult.l(runCy,PGALL,YTIME)=0.1;

VActivGoodsTransp.l(runCy,TRANSE,YTIME)=0.1;
VActivGoodsTransp.FX(runCy,TRANG,YTIME)$(not An(YTIME)) = iActv(YTIME,runCy,TRANG);
VActivGoodsTransp.FX(runCy,TRANSE,YTIME)$(not TRANG(TRANSE)) = 0;

VRenValue.l(YTIME)=1;
VRenValue.FX(YTIME) = 0 ;

VCstCO2SeqCsts.l(runCy,YTIME)=1;
*VCstCO2SeqCsts.FX(runCy,YTIME)$(not an(YTIME)) = iElastCO2Seq(allCy,"mc_b")

VScalWeibullSum.l(runCy,PGALL,YTIME)=2;

VCostHourProdInvDec.l(runCy,PGALL,HOUR,TT) = 0.0001;
VCostHourProdInvDec.FX(runCy,PGALL,HOUR,YTIME)$((NOT AN(YTIME)))=0;

VPriceElecIndResConsu.FX(runCy,"i",YTIME)$(not An(YTIME)) = VPriceFuelSubsecCarVal.l(runCy,"OI","ELC",YTIME)*sTWhToMtoe;
VPriceElecIndResConsu.FX(runCy,"r",YTIME)$(not An(YTIME)) = VPriceFuelSubsecCarVal.l(runCy,"HOU","ELC",YTIME)*sTWhToMtoe;

VPriceElecIndResNoCliPol.FX(runCy,"i",YTIME)$(not an(ytime)) = VPriceFuelSubsecCarVal.l(runCy,"OI","ELC",YTIME)*0.086;
VPriceElecIndResNoCliPol.FX(runCy,"r",YTIME)$(not an(ytime)) = VPriceFuelSubsecCarVal.l(runCy,"HOU","ELC",YTIME)*0.086;

VFuelPriSubNoCarb.FX(runCy,SBS,EF,YTIME)$(SECTTECH(SBS,EF) $(not HEATPUMP(EF))  $(not An(YTIME))) = iFuelPrice(runCy,SBS,EF,YTIME);
VFuelPriSubNoCarb.FX(runCy,SBS,ALTEF,YTIME)$(SECTTECH(SBS,ALTEF) $(not An(YTIME))) = sum(EF$ALTMAP(SBS,ALTEF,EF),iFuelPrice(runCy,SBS,EF,YTIME));
VFuelPriSubNoCarb.FX(runCy,"PG","NUC",YTIME) = 0.025; !! fixed price for nuclear fuel to 25Euro/toe
VFuelPriSubNoCarb.fx(runCy,INDDOM,"HEATPUMP",YTIME)$(SECTTECH(INDDOM,"HEATPUMP")$(not An(YTIME))) = iFuelPrice(runCy,INDDOM,"ELC",YTIME);

VPriceFuelAvgSub.L(runCy,DSBS,YTIME) = 0.1;
VPriceFuelAvgSub.FX(runCy,DSBS,YTIME)$(not An(YTIME)) = sum(EF$SECTTECH(DSBS,EF), iWgtSecAvgPriFueCons(runCy,DSBS,EF) * iFuelPrice(runCy,DSBS,EF,YTIME));

VPcOwnPcLevl.UP(runCy,YTIME) = 1;
VPcOwnPcLevl.FX(runCy,YTIME)$((not An(YTIME)) $(ord(YTIME) gt 1) ) = (VStockPcYearly.l(runCy,YTIME-1) / (iPop(YTIME-1,runCy)*1000) /
iPassCarsMarkSat(runCy))$(iPop(YTIME-1,runCy))+VPcOwnPcLevl.l(runCy,YTIME-1)$(not iPop(YTIME-1,runCy));

VMEPcNonGdp.l(runCy,YTIME)$((not An(YTIME)) $(ord(YTIME) gt 1)  ) = ( iTransChar(runCy,"RES_MEXTF",YTIME) * iSigma(runCy,"S1") * EXP(iSigma(runCy,"S2") *
           EXP(iSigma(runCy,"S3") * VPcOwnPcLevl.l(runCy,YTIME)))
               * VStockPcYearly.l(runCy,YTIME-1) /(iPop(YTIME-1,runCy) * 1000) )$(iPop(YTIME-1,runCy));

VMEPcNonGdp.FX(runCy,YTIME)$((not An(YTIME)) $(ord(YTIME) gt 1)  ) = ( iTransChar(runCy,"RES_MEXTF",YTIME) * iSigma(runCy,"S1") * EXP(iSigma(runCy,"S2") * EXP(iSigma(runCy,"S3") *
                          VPcOwnPcLevl.l(runCy,YTIME)))* 
                          VStockPcYearly.l(runCy,YTIME-1) /(iPop(YTIME-1,runCy) * 1000) )$(iPop(YTIME-1,runCy))+VMEPcNonGdp.l(runCy,YTIME-1)$(not iPop(YTIME-1,runCy));

VMEPcGdp.FX(runCy,YTIME)$(not An(YTIME)) = iDataPassCars(runCy,"PC","MEXTV");

VGapTranspActiv.FX(runCy,TRANSE,YTIME)$(not AN(YTIME))=0;

VConsSpecificFuel.FX(runCy,TRANSE,TTECH,EF,"%fBaseY%")$(SECTTECH(TRANSE,EF) ) = iSpeFuelConsCostBy(runCy,TRANSE,TTECH,EF);

VConsTechTranspSectoral.FX(runCy,TRANSE,TTECH,EF,YTIME)$(SECTTECH(TRANSE,TTECH)  $(not PLUGIN(TTECH)) $TTECHtoEF(TTECH,EF) $(not AN(YTIME))) = iFuelConsPerFueSub(runCy,TRANSE,EF,YTIME); 
VConsTechTranspSectoral.FX(runCy,TRANSE,TTECH,EF,YTIME)$(SECTTECH(TRANSE,TTECH)  $PLUGIN(TTECH) $(not AN(YTIME))) = 0;
VConsTechTranspSectoral.FX(runCy,TRANSE,TTECH,EF,YTIME)$(SECTTECH(TRANSE,TTECH)  $CHYBV(TTECH) $(not AN(YTIME))) =0;

vConsTotElecInd.FX(runCy,YTIME)$(not An(YTIME))= SUM(INDSE,VConsElecNonSubIndTert.l(runCy,INDSE,YTIME));

VPriceFuelSubsecCHP.FX(runCy,DSBS,EF,YTIME)$((not An(YTIME)) $(not TRANSE(DSBS))  $SECTTECH(DSBS,EF)) =
(((VPriceFuelSubsecCarVal.l(runCy,DSBS,EF,YTIME)+iVarCostTech(runCy,DSBS,EF,YTIME)/1000)/iUsfEneConvSubTech(runCy,DSBS,EF,YTIME)- 
(0$(not CHP(EF)) + (VPriceFuelSubsecCarVal.l(runCy,"OI","ELC",YTIME)*iFracElecPriChp*iElecIndex(runCy,"2010"))$CHP(EF))) + (0.003) + 
SQRT( SQR(((VPriceFuelSubsecCarVal.l(runCy,DSBS,EF,YTIME)+iVarCostTech(runCy,DSBS,EF,YTIME)/1000)/iUsfEneConvSubTech(runCy,DSBS,EF,YTIME)- (0$(not CHP(EF)) + 
(VPriceFuelSubsecCarVal.l(runCy,"OI","ELC",YTIME)*iFracElecPriChp*iElecIndex(runCy,"2010"))$CHP(EF)))-(0.003)) + SQR(1e-7) ) )/2;


VDemFinSubFuelSubsec.FX(runCy,INDDOM,YTIME)$(not An(YTIME)) = max(iTotFinEneDemSubBaseYr(runCy,INDDOM,YTIME) - VConsElecNonSubIndTert.L(runCy,INDDOM,YTIME),1e-5);
VDemFinSubFuelSubsec.FX(runCy,NENSE,YTIME)$(not An(YTIME)) = max(iTotFinEneDemSubBaseYr(runCy,NENSE,YTIME),1e-5);
VDemFinSubFuelSubsec.FX(runCy,"HOU",YTIME)$(not An(YTIME)) = max(iTotFinEneDemSubBaseYr(runCy,"HOU",YTIME) - VConsElecNonSubIndTert.L(runCy,"HOU",YTIME)-iExogDemOfBiomass(runCy,"HOU",YTIME),1e-5);

vDemFinSubFuelInd.FX(runCy,YTIME)$(not An(YTIME))= SUM(INDSE,VDemFinSubFuelSubsec.L(runCy,INDSE,YTIME));

VElecConsHeatPla.FX(runCy,INDDOM,YTIME)$(not An(YTIME)) = iFuelConsPerFueSub(runCy,INDDOM,"ELC",YTIME)*(1-iShrNonSubElecInTotElecDem(runCy,INDDOM))*iShrHeatPumpElecCons(runCy,INDDOM);
* Compute electricity consumed in heatpump plants, QElecConsHeatPla(runCy,INDDOM,YTIME)$time(ytime).
VElecConsHeatPla.FX(runCy,INDDOM,YTIME) = 1E-7;

VConsFuelInclHP.FX(runCy,DSBS,EF,YTIME)$(SECTTECH(DSBS,EF) $(not TRANSE(DSBS)) $(not An(YTIME))) =
(iFuelConsPerFueSub(runCy,DSBS,EF,YTIME))$((not ELCEF(EF)) $(not HEATPUMP(EF)))
+(VElecConsHeatPla.l(runCy,DSBS,YTIME)*iUsfEneConvSubTech(runCy,DSBS,"HEATPUMP",YTIME))$HEATPUMP(EF)+
(iFuelConsPerFueSub(runCy,DSBS,EF,YTIME)-VElecConsHeatPla.l(runCy,DSBS,YTIME))$ELCEF(EF)
+1e-7$(H2EF(EF) or sameas("STE1AH2F",EF))
;

VShareTechNewEquip.FX(runCy,DSBS,EF,YTIME)$(SECTTECH(DSBS,EF)$(not An(YTIME))) = 0;

VConsRemSubEquipSubSec.FX(runCy,DSBS,EF,YTIME)$(SECTTECH(DSBS,EF) $(not An(ytime))) =
(VConsFuelInclHP.l(runCy ,DSBS,EF,YTIME) - (VConsElecNonSubIndTert.l(runCy,DSBS,YTIME)$(ELCEF(EF) $INDDOM(DSBS)) + 0$(not (ELCEF(EF) $INDDOM(DSBS)) )))
;

VConsFinEneCountry.FX(runCy,EFS,YTIME)$(not An(YTIME)) = iFinEneCons(runCy,EFS,YTIME);

VLossesDistr.FX(runCy,EFS,YTIME)$(not An(YTIME)) = iDistrLosses(runCy,EFS,YTIME);

VOutTransfTherm.FX(runCy,EFS,YTIME)$(not TOCTEF(EFS)) = 0;

VInputTransfRef.FX(runCy,"CRO",YTIME)$(not An(YTIME)) = iTransfInputRef(runCy,"CRO",YTIME);
VInputTransfRef.FX(runCy,EFS,YTIME)$(not sameas("CRO",EFS)) = 0;

VConsGrssInl.FX(runCy,EFS,YTIME)$(not An(YTIME)) = iGrosInlCons(runCy,EFS,YTIME);

VTransfers.FX(runCy,EFS,YTIME)$(not An(YTIME)) = iFeedTransfr(runCy,EFS,YTIME);

VProdPrimary.FX(runCy,PPRODEF,YTIME)$(not An(YTIME)) = iFuelPriPro(runCy,PPRODEF,YTIME);

VConsFiEneSec.FX(runCy,EFS,YTIME)$(not An(YTIME)) = iTotEneBranchCons(runCy,EFS,YTIME);

VImp.FX(runCy,"NGS",YTIME)$(not An(YTIME)) = iFuelImports(runCy,"NGS",YTIME);
VImp.FX(runCy,EFS,YTIME)$(not IMPEF(EFS)) = 0;

VExp.FX(runCy,EFS,YTIME)$(not An(YTIME)) = iFuelExprts(runCy,EFS,YTIME);
VExp.FX(runCy,"NGS",YTIME)$(not An(YTIME)) = iFuelExprts(runCy,"NGS",YTIME);
VExp.FX(runCy,EFS,YTIME)$(not IMPEF(EFS)) = 0;


VBaseLoad.L(runCy,YTIME) = 0.5;
VBaseLoad.FX(runCy,YTIME)$(not An(YTIME)) = iPeakBsLoadBy(runCy,"BASELOAD");

VPeakLoad.L(runCy,YTIME) = 1;
VPeakLoad.FX(runCy,YTIME)$(datay(YTIME)) = VDemElecTot.l(runCy,YTIME)/(VLoadFacDom.l(runCy,YTIME)*8.76);

VCapElecTot.FX(runCy,YTIME)$(not An(YTIME)) = iTotAvailCapBsYr(runCy);

VCapElecNonCHP.FX(runCy,YTIME)$(not An(YTIME)) = iTotAvailCapBsYr(runCy);

VCapElecCHP.FX(runCy,CHP,YTIME)$(not An(YTIME)) = iHisChpGrCapData(runCy,CHP,YTIME);

VSharePowPlaNewEq.FX(runCy,PGALL,YTIME)$((NOT AN(YTIME)) )=0;

VCapElec2.FX(runCy,PGALL,YTIME)$DATAY(YTIME) = iInstCapPast(runCy,PGALL,YTIME);

VCapElec.FX(runCy,PGALL,YTIME)$DATAY(YTIME) =  iInstCapPast(runCy,PGALL,YTIME);

VCapOverall.FX(runCy,PGALL,YTIME)$TFIRST(YTIME) =  iInstCapPast(runCy,PGALL,YTIME)$TFIRST(YTIME);

VProdElec.FX(runCy,pgall,YTIME)$DATAY(YTIME)=iDataElecProd(runCy,pgall,YTIME)/1000;

VIndxEndogScrap.FX(runCy,PGALL,YTIME)$(not an(YTIME) ) = 1;
VIndxEndogScrap.FX(runCy,PGSCRN,YTIME) = 1;            !! premature replacement it is not allowed for all new plants

VCapCO2ElecHydr.FX(runCy,YTIME)$(not An(YTIME)) = 0;

VCostPowGenAvgLng.L(runCy,ESET,"2010") = 0;
VCostPowGenAvgLng.L(runCy,ESET,"%fBaseY%") = 0;

VCostPowGenLonNoClimPol.L(runCy,ESET,"2010") = 0;
VCostPowGenLonNoClimPol.l(runCy,ESET,"%fBaseY%") = 0;

vCostPowGenAvgShrt.L(runCy,ESET,"2010") = 0;
vCostPowGenAvgShrt.L(runCy,ESET,"%fBaseY%") = 0;

VCostPowGenLngTechNoCp.L(runCy,PGALL,ESET,"2010") = 0;
VCostPowGenLngTechNoCp.L(runCy,PGALL,ESET,"%fBaseY%") = 0;

VCostAvgPowGenLonNoClimPol.L(runCy,PGALL,ESET,"2010") = 0;
VCostAvgPowGenLonNoClimPol.FX(runCy,PGALL,ESET,"%fBaseY%") = 0;

VCarVal.fx(runCy,NAP,YTIME)$(not An(YTIME))=0;
VCarVal.FX(runCy,"TRADE",YTIME)$an(YTIME) = sExogCarbValue*iCarbValYrExog(runCy,YTIME);
VCarVal.FX(runCy,"NOTRADE",YTIME)$an(YTIME) =sExogCarbValue*iCarbValYrExog(runCy,YTIME);

VCaptCummCO2.FX(runCy,YTIME)$(not an(YTIME)) = 0 ;

VOutTransfDhp.FX(runCy,EFS,YTIME)$(not STEAM(EFS)) = 0;

VOutTransfNuclear.FX(runCy,EFS,YTIME)$(not sameas("ELC",EFS)) = 0;

VInpTransfNuclear.FX(runCy,EFS,YTIME)$(not sameas("NUC",EFS)) = 0;

VInpTransfTherm.FX(runCy,EFS,YTIME)$(not PGEF(EFS)) = 0;

VLambda.LO(runCy,YTIME)=0;
VLambda.L(runCy,YTIME)=0.21;

VProdReqTotElec.fx(runCy,"%fBaseY%")=sum(pgall,VProdElec.L(runCy,pgall,"%fBaseY%"));

VW.L(allCy,SBS,EF,YTIME) = 1 ;                                   
VWPGC.L(allCy,PGALL,YTIME) = 1 ;                                 
VWPGD.L(allCy,PGALL,YTIME) = 1 ;                                  
VWTAG.L(allCy,TRANSE,YTIME) = 1 ;                                
VWMPG.L(allCy,YTIME) = 1 ;                                       
VWTF.L(allCy,TRANSE,TTECH,YTIME) = 1 ;                           
VWTT.L(allCy,TRANSE,TTECH,YTIME) = 1 ;                            
VWTAP.L(allCy,TRANSE,YTIME) = 1 ;                                 
VWCRS.L(allCy,DSBS,EF,YTIME) = 1 ;                                
VWDFS.L(allCy,DSBS,YTIME) = 1 ;                                   
VWCT.L(allCy,DSBS,EF,YTIME) = 1 ;                                 

openprom.optfile=1;

loop an do !! start outer iteration loop (time steps)
   s = s + 1;
   TIME(YTIME) = NO;
   TIME(AN)$(ord(an)=s) = YES;
   display TIME;
   cy = 0;
   loop runCyL do !! start countries loop
      cy = cy + 1;
      runCy(allCy) = NO;
      runCy(runCyL)$(ord(runCyL)=cy) = YES;
      display runCy;
