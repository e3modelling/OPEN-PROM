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
QCapGenTotElec                     !! VCapGenTotElec(runCy,YTIME)	
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
QCapGenElecNoChp                   !! VCapGenElecNoChp(runCy,YTIME)
QGapGenCapPowerDiff                !! VGapGenCapPowerDiff(runCy,YTIME)
qScalWeibull                       !! vScalWeibull(runCy,PGALL,HOUR,YTIME) 
QPotRenSuppCurve                   !! VPotRenSuppCurve(runCy,PGRENEF,YTIME)
QRenPotMaxAllow                    !! VRenPotMaxAllow(runCy,PGRENEF,YTIME)
QRenPotMinAllow                    !! VRenPotMinAllow(runCy,PGRENEF,YTIME)
QRenTechMatMult                    !! VRenTechMatMult(runCy,PGALL,YTIME)
QScalWeibullSum                    !! VScalWeibullSum(runCy,PGALL,YTIME)
QDecisNewInv                       !! VDecisNewInv(runCy,YTIME)
QShaNewEqPowPla                    !! VShaNewEqPowPla(runCy,PGALL,YTIME)
QCapGenPlant                       !! VCapGenPlant(runCy,PGALL,YTIME)
QCapGenPlannedPlant                !! VCapGenPlannedPlant(runCy,PGALL,YTIME)
QCostVarPlantTech                  !! VCostVarPlantTech(runCy,PGALL,YTIME)
QElecPeakLoads                     !! VElecPeakLoads(runCy,YTIME) 
QSortPlantDispatch                 !! VSortPlantDispatch(runCy,PGALL,YTIME)
QCapGenNewResPlant                 !! VCapGenNewResPlant(runCy,PGALL,YTIME)
QCapAvgFacRes                      !! VCapAvgFacRes(runCy,PGALL,YTIME)
QCapOverall                        !! VCapOverall(runCy,PGALL,YTIME)
QScalFacPlantDispatch              !! VScalFacPlaDisp
QGenEstElecChpPlants               !! VGenEstElecChpPlants(runCy,YTIME) 
QProdNonChp                        !! VProdNonChp(runCy,YTIME) 
QProdReqElec                       !! VProdReqElec(runCy,YTIME) 
QProdElecPowPlantsCy               !! VProdElecPowPlantsCy(runCy,PGALL,YTIME)
qSecContrTotChpProd                !! vSecContrTotChpProd(runCy,INDDOM,CHP,YTIME)
QGenEstElecChpPlants               !! VGenEstElecChpPlants(runCy,CHP,YTIME)
qProdGrossResShare                 !! vProdGrossResShare(runCy,YTIME) 
QCostPowGenLngTechNoCp             !! VCostPowGenLngTechNoCp(runCy,PGALL,ESET,YTIME)
qCostPowGenLonMin                  !! vCostPowGenLonMin(runCy,PGALL,YTIME)
qCostPowGenLongIntPri              !! vCostPowGenLongIntPri(runCy,PGALL,ESET,YTIME)
qCostPowGenShortIntPri             !! vCostPowGenShortIntPri(runCy,PGALL,ESET,YTIME)
QCostPowGenAvgLng                  !! VCostPowGenAvgLng(runCy,ESET,YTIME)
QCostAvgPowGenLonNoClimPol         !! VCostAvgPowGenLonNoClimPol(runCy,PGALL,ESET,YTIME)
QCostPowGenLonNoClimPol            !! VCostPowGenLonNoClimPol(runCy,ESET,YTIME)
QPriceElecIndResNoCliPol           !! VPriceElecIndResNoCliPol(runCy,ESET,YTIME)
qCostPowGenAvgShrt                 !! vCostPowGenAvgShrt(runCy,ESET,YTIME)


*' * Transport *

QLftPc                             !! VLftPc(runCy,DSBS,EF,YTIME)
QActivGoodsTransp                  !! VActivGoodsTransp(runCy,TRANSE,YTIME)
QGapTranspActiv                    !! VGapTranspActiv(runCy,TRANSE,YTIME)
QConsSpecificFuel                  !! VConsSpecificFuel(runCy,TRANSE,TTECH,EF,YTIME)
QCostTranspPerMeanConsSize         !! VCostTranspPerMeanConsSize(runCy,TRANSE,rCon,TTECH,YTIME)
QCostTranspPerVeh                  !! VCostTranspPerVeh(runCy,TRANSE,rCon,TTECH,YTIME)
QCostTranspMatFac                  !! VCostTranspMatFac(runCy,TRANSE,RCon,TTECH,YTIME) 
QSortTechVarCost                   !! VSortTechVarCost(runCy,TRANSE,rCon,YTIME)
QShareTechSectoral                 !! VShareTechSectoral(runCy,TRANSE,TTECH,YTIME)
QConsTechTranspSectoral            !! VConsTechTranspSectoral(runCy,TRANSE,TTECH,EF,YTIME)
QDemFinEneTranspPerFuel            !! VDemFinEneTranspPerFuel(runCy,TRANSE,EF,YTIME)
qDemFinEneSubTransp                !! vDemFinEneSubTransp(runCy,TRANSE,YTIME)
QMEPcGdp                           !! VMEPcGdp(runCy,YTIME)
QMEPcNonGdp                        !! VMEPcNonGdp(runCy,YTIME)
QStockPcYearly                     !! VStockPcYearly(runCy,YTIME)
QNewRegPcYearly                    !! VNewRegPcYearly(runCy,YTIME)
QActivPassTrnsp                    !! VActivPassTrnsp(runCy,TRANSE,YTIME)
QNumPcScrap                        !! VNumPcScrap(runCy,YTIME)
QPcOwnPcLevl                       !! VPcOwnPcLevl(runCy,YTIME)
QScrRatePc                         !! VScrRatePc(runCy,YTIME)
QConsElecFinDemSec                 !! VConsElecFinDemSec(runCy,DSBS,YTIME)


*' * INDUSTRY  - DOMESTIC - NON ENERGY USES - BUNKERS VARIABLES *

QConsElecNonSubIndTert             !! VConsElecNonSubIndTert(runCy,INDDOM,YTIME)
QConsRemSubEquipSubSec             !! VConsRemSubEquipSubSec(runCy,DSBS,EF,YTIME)
QDemFinSubFuelSubSec               !! VDemFinSubFuelSubSec(runCy,DSBS,YTIME)
qConsTotElecInd                    !! vConsTotElecInd(runCy,YTIME)
QDemFinSubFuelInd                  !! vDemFinSubFuelInd(runCy,YTIME)
QPriceElecInd                      !! VPriceElecInd(runCy,YTIME)
QConsFuel                          !! VConsFuel(runCy,DSBS,EF,YTIME)
QIndxElecIndPrices                 !! VIndxElecIndPrices(runCy,YTIME)
QPriceFuelSubSecChp                !! VPriceFuelSubSecChp(runCy,DSBS,EF,YTIME)
QCostElecProdChp                   !! VCostElecProdChp(runCy,DSBS,CHP,YTIME)
QCostTech                          !! VCostTech(runCy,DSBS,rCon,EF,YTIME) 
QCostTechIntrm                     !! VCostTechIntrm(runCy,DSBS,rCon,EF,YTIME) 
QCostTechMatFac                    !! VCostTechMatFac(runCy,DSBS,rCon,EF,YTIME) 
QSortTechVarCost                   !! VSortTechVarCost(runCy,DSBS,rCon,YTIME)
QGapFinalDem                       !! VGapFinalDem(runCy,DSBS,YTIME)
QShareTechNewEquip                 !! VShareTechNewEquip(runCy,DSBS,EF,YTIME)
QConsFuelInclHP                    !! VConsFuelInclHP(runCy,DSBS,EF,YTIME)
QCostProdChpDem                    !! VCostProdChpDem(runCy,DSBS,CHP,YTIME)
QCostElcAvgProdCHP                 !! VCostElcAvgProdCHP(runCy,CHP,YTIME)
QCostVarAvgElecProd                !! VCostVarAvgElecProd(runCy,CHP,YTIME)


*' * REST OF ENERGY BALANCE SECTORS *

QConsFinEneCountry                 !! VConsFinEneCountry(runCy,EFS,YTIME)
qConsTotFinEne                     !! vConsTotFinEne(YTIME)
QConsFinNonEne                     !! VConsFinNonEne(runCy,EFS,YTIME)
QLossesDistr                       !! VLossesDistr(runCy,EFS,YTIME)
QOutTransfDhp                      !! VOutTransfDhp(runCy,STEAM,YTIME)
QTransfInputDHPlants               !! VTransfInputDHPlants(runCy,EFS,YTIME)
QCapRef                            !! VCapRef(runCy,YTIME)
QOutTransfRefSpec                  !! VOutTransfRefSpec(runCy,EFS,YTIME)
QInputTransfRef                    !! VInputTransfRef(runCy,"CRO",YTIME)
QOutTransfNuclear                  !! VOutTransfNuclear(runCy,"ELC",YTIME)
QInpTransfNuclear                  !! VInpTransfNuclear(runCy,"NUC",YTIME)
QInpTransfTherm                    !! VInpTransfTherm(runCy,PGEF,YTIME)
QOutTransfTherm                    !! VOutTransfTherm(runCy,TOCTEF,YTIME)
QInpTotTransf                      !! VInpTotTransf(runCy,EFS,YTIME)
QOutTotTransf                      !! VOutTotTransf(runCy,EFS,YTIME)
QTransfers                         !! VTransfers(runCy,EFS,YTIME)
QConsGrssInlNotEneBranch           !! VConsGrssInlNotEneBranch(runCy,EFS,YTIME)
QConsGrssInl                       !! VConsGrssInl(runCy,EFS,YTIME)            
QProdPrimary                       !! VProdPrimary(runCy,PPRODEF,YTIME)
QExprtsFakeEneBrnch                !! VExprtsFakeEneBrnch(runCy,EFS,YTIME)
QImptsFakeEneBrnch                 !! VImptsFakeEneBrnch(runCy,EFS,YTIME)
QImpNetEneBrnch                    !! VImpNetEneBrnch(runCy,EFS,YTIME)
QConsFiEneSec                      !! VConsFiEneSec(runCy,EFS,YTIME)


*' * CO2 SEQUESTRATION COST CURVES *

QCapCo2ElecHydr                    !! VCapCo2ElecHydr(runCy,YTIME)
QCaptCummCo2                       !! VCaptCummCo2(runCy,YTIME)
QTrnsWghtLinToExp                  !! VTrnsWghtLinToExp(runCy,YTIME)
QCstCO2SeqCsts                     !! VCstCO2SeqCsts(runCy,YTIME)         


*' * EMISSIONS CONSTRAINTS *

QGrnnHsEmisCo2Equiv                !! VGrnnHsEmisCo2Equiv(NAP,YTIME)
qGrnnHsEmisCo2EquivAllCntr         !! vGrnnHsEmisCo2EquivAllCntr(YTIME) 
qExpendHouseEne                    !! vExpendHouseEne(runCy,YTIME)


*' * Prices *

QPriceFuelSubCarVal                !! VPriceFuelSubCarVal(runCy,SBS,EF,YTIME)
QPriceFuelSepCarbonWght            !! VPriceFuelSepCarbonWght(runCy,DSBS,EF,YTIME)
QPriceFuelAvgSub                   !! VPriceFuelAvgSub(runCy,DSBS,YTIME)
QPriceElecIndResConsu              !! VPriceElecIndResConsu(runCy,ESET,YTIME)



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


*' *                        VARIABLE LEVEL                                        *

VStockPcYearly.L(allCy,YTIME)=0.1;
VActivPassTrnsp.L(allCy,TRANSE,YTIME) = 0.1;
VPriceFuelSubCarVal.L(allCy,SBS,EF,YTIME) = 1.5;
VPriceFuelSubCarVal.L(allCy,"PG",PGEF,YTIME)=1;
VPriceElecInd.L(allCy,YTIME)= 0.1;
VCostTechIntrm.L(allCy,DSBS,rcon,EF,YTIME) = 0.1;
VLftPc.L(allCy,DSBS,EF,YTIME)= 0.1;
VSortTechVarCost.L(allCy,DSBS,rCon,YTIME) = 0.1;
VConsFuel.L(allCy,DSBS,EF,YTIME)=0.1;
VCapRef.L(allCy,YTIME)=0.1;
VOutTransfRefSpec.L(allCy,EFS,YTIME)=0.1;
VConsGrssInlNotEneBranch.L(allCy,EFS,YTIME)=0.1;
VConsElecFinDemSec.L(allCy,DSBS,YTIME)=0.1;
VLoadFacDom.L(allCy,YTIME)=0.1;
VSensCcs.L(allCy,YTIME)=1;
VCostVarTech.L(allCy,PGALL,YTIME)=0.1;
VCostProdTechPreReplacAvail.L(allCy,PGALL,PGALL2,YTIME)=0.1;
VSortTechVarCost.L(allCy,TRANSE,Rcon,YTIME)=0.1;
VPotRenSuppCurve.L(allCy,PGRENEF,YTIME)=0.1;
VScrRatePc.L(allCy,YTIME)=0.1;
VCostTranspPerMeanConsSize.L(allCy,TRANSE,RCon,TTECH,YTIME)=0.1;
VConsElecNonSubIndTert.L(allCy,DSBS,YTIME)=0.1;
VShareNewTechNoCcs.L(allCy,PGALL,TT)=0.1;
vCostHourProdInvCCS.L(allCy,PGALL,HOUR,TT)=0.1;
VShareNewTechCcs.L(allCy,PGALL,TT)=0.1;
VDecisNewInv.L(allCy,YTIME)=0.1;
VCostVarPlantTech.L(allCy,PGALL,YTIME)=0.1;
VElecPeakLoads.L(allCy,YTIME)=0.1;
VCapGenNewResPlant.L(allCy,PGALL,YTIME)=0.1;
VCapAvgFacRes.L(allCy,PGALL,YTIME)=0.1;
VSortPlantDispatch.L(runCy,PGALL,YTIME)=0.01;
VSortPlantDispatch.L(runCy,PGALL,YTIME)=VCostVarPlantTech.L(runCy,PGALL,YTIME)/VElecPeakLoads.L(runCy,YTIME);
VProdReqElec.L(runCy,YTIME) = 0.01;
VScalFacPlaDisp.L(runCy,HOUR,YTIME) = 1.e-12;
VDemElec.L(allCy,YTIME)=0.1;
VRenTechMatMult.L(allCy,PGALL,YTIME)=0.1;
VActivGoodsTransp.L(allCy,TRANSE,YTIME)=0.1;
VRenValue.L(YTIME)=1;
VCstCO2SeqCsts.L(allCy,YTIME)=1;
VScalWeibullSum.L(allCy,PGALL,YTIME)=2;
VCostHourProdInvDec.L(runCy,PGALL,HOUR,TT) = 0.0001;
VPriceFuelAvgSub.L(runCy,DSBS,YTIME) = 0.1;
VLoadBaseElecExp.L(runCy,YTIME) = 0.5;
VLoadPeakElec.L(runCy,YTIME) = 1;
VLambda.L(runCy,YTIME)=0.21;
VCostPowGenAvgLng.L(runCy,ESET,"%fStartHorizon%") = 0;
VCostPowGenAvgLng.L(runCy,ESET,"%fBaseY%") = 0;
vCostPowGenAvgShrt.L(runCy,ESET,"%fStartHorizon%") = 0;
vCostPowGenAvgShrt.L(runCy,ESET,"%fBaseY%") = 0;
VCostAvgPowGenLonNoClimPol.L(runCy,PGALL,ESET,"%fStartHorizon%") = 0;
VCostPowGenLonNoClimPol.L(runCy,ESET,"%fBaseY%") = 0;
VCostPowGenLonNoClimPol.L(runCy,ESET,"%fStartHorizon%") = 0;
VCostPowGenLngTechNoCp.L(runCy,PGALL,ESET,"%fStartHorizon%") = 0;
VCostPowGenLngTechNoCp.L(runCy,PGALL,ESET,"%fBaseY%") = 0;
VMEPcNonGdp.L(runCy,YTIME)$((not An(YTIME)) $(ord(YTIME) gt 1)  ) = ( iTransChar(runCy,"RES_MEXTF",YTIME) * iSigma(runCy,"S1") * EXP(iSigma(runCy,"S2") *
           EXP(iSigma(runCy,"S3") * VPcOwnPcLevl.L(runCy,YTIME))) * VStockPcYearly.L(runCy,YTIME-1) /(iPop(YTIME-1,runCy) * 1000) )$(iPop(YTIME-1,runCy));
VCostHourProdInvDecNoCcs.L(runCy,PGALL,HOUR,TT) = VShareNewTechNoCcs.L(runCy,PGALL,TT)*vCostHourProdInvCCS.L(runCy,PGALL,HOUR,TT)+
         sum(CCS$CCS_NOCCS(CCS,PGALL), VShareNewTechCcs.L(runCy,CCS,TT)*vCostHourProdInvCCS.L(runCy,CCS,HOUR,TT));

*' *                        VARIABLE LOWER BOUND                                   *

VCostProdSpecTech.LO(allCy,PGALL2,YTIME)=0.00000001;
VScalFacPlaDisp.LO(runCy, HOUR, YTIME)=-1;
VLambda.LO(runCy,YTIME)=0;

*' *                        VARIABLE UPPER BOUND                                   *

VPcOwnPcLevl.UP(runCy,YTIME) = 1;
VStockPcYearly.UP(runCy,YTIME) = 10000; !! upper bound of VStockPcYearly is 10000 million vehicles
VScrRatePc.UP(runCy,YTIME) = 1;

*' *                        INPUT INITIALISATION                                   *

iFinEneConsPrevYear(runCy,EFS,YTIME)$(not An(YTIME)) = iFinEneCons(runCy,EFS,YTIME);
iTransChar(runCy,"RES_MEXTF",YTIME) = 0.04;
iTransChar(runCy,"RES_MEXTV",YTIME) = 0.04;
iDataPassCars(runCy,"PC","MEXTV") = 0.01;
iPassCarsMarkSat(runCy) = 0.7; 

*' *                        VARIABLE INITIALISATION                               *

VRenShareElecProdSub.FX(runCy,YTIME)$(NOT AN(YTIME))=0;
VNewRegPcYearly.FX(allCy,YTIME)$(not an(ytime)) = iNewReg(allCy,YTIME);

VShareTechSectoral.FX(allCy,TRANSE,EF2,YTIME)$(not An(YTIME)) = iFuelConsTRANSE(allCy,TRANSE,EF2,YTIME)/sum(EF$(SECTTECH(TRANSE,EF)),iFuelConsTRANSE(allCy,TRANSE,EF,YTIME)); 
VShareTechSectoral.FX(runCy,TRANSE,TTECH,YTIME)$( SECTTECH(TRANSE,TTECH) $(not AN(YTIME))) = 0;

* FIXME: VPriceFuelSubCarVal (NUC/MET/ETH/BGDO) should be computed endogenously after startYear, and with mrprom before startYear
* author=giannou
VPriceFuelSubCarVal.FX(runCy,"PG","NUC",YTIME) = 0.025; !! fixed price for nuclear fuel to 25Euro/toe
VPriceFuelSubCarVal.FX(runCy,"H2P","NUC",YTIME) = 0.025; !! fixed price for nuclear fuel to 25Euro/toe
VPriceFuelSubCarVal.FX(runCy,SBS,"MET",YTIME)$(not An(YTIME)) = 800; !! fixed price methanol
VPriceFuelSubCarVal.FX(runCy,SBS,"ETH",YTIME)$(not An(YTIME)) = 800; !! fixed price for ethanol
VPriceFuelSubCarVal.FX(runCy,SBS,"BGDO",YTIME)$(not An(YTIME)) = 350; !! fixed price for biodiesel
VPriceFuelSubCarVal.FX(runCy,SBS,EF,YTIME)$(SECTTECH(SBS,EF)$(not HEATPUMP(EF))$(not An(YTIME))) = iFuelPrice(runCy,SBS,EF,YTIME);
VPriceFuelSubCarVal.FX(runCy,SBS,ALTEF,YTIME)$(SECTTECH(SBS,ALTEF)$(not An(YTIME))) = sum(EF$ALTMAP(SBS,ALTEF,EF),iFuelPrice(runCy,SBS,EF,YTIME));
VPriceFuelSubCarVal.fx(runCy,INDDOM,"HEATPUMP",YTIME)$(SECTTECH(INDDOM,"HEATPUMP")$(not An(YTIME))) = iFuelPrice(runCy,INDDOM,"ELC",YTIME);
VPriceFuelSubCarVal.fx(runCy,"H2P",EF,YTIME)$(SECTTECH("H2P",EF)$(not An(YTIME))) = VPriceFuelSubCarVal.l(runCy,"PG",EF,YTIME);
VPriceFuelSubCarVal.fx(runCy,"H2P","ELC",YTIME)$(not An(YTIME))= VPriceFuelSubCarVal.l(runCy,"OI","ELC",YTIME);

VPriceElecIndResConsu.FX(runCy,"i",YTIME)$(not An(YTIME)) = VPriceFuelSubCarVal.l(runCy,"OI","ELC",YTIME)*sTWhToMtoe;
VPriceElecIndResConsu.FX(runCy,"r",YTIME)$(not An(YTIME)) = VPriceFuelSubCarVal.l(runCy,"HOU","ELC",YTIME)*sTWhToMtoe;

VPriceElecIndResNoCliPol.FX(runCy,"i",YTIME)$(not an(ytime)) = VPriceFuelSubCarVal.l(runCy,"OI","ELC",YTIME)*0.086;
VPriceElecIndResNoCliPol.FX(runCy,"r",YTIME)$(not an(ytime)) = VPriceFuelSubCarVal.l(runCy,"HOU","ELC",YTIME)*0.086;

VFuelPriSubNoCarb.FX(runCy,SBS,EF,YTIME)$(SECTTECH(SBS,EF) $(not HEATPUMP(EF))  $(not An(YTIME))) = iFuelPrice(runCy,SBS,EF,YTIME);
VFuelPriSubNoCarb.FX(runCy,SBS,ALTEF,YTIME)$(SECTTECH(SBS,ALTEF) $(not An(YTIME))) = sum(EF$ALTMAP(SBS,ALTEF,EF),iFuelPrice(runCy,SBS,EF,YTIME));
VFuelPriSubNoCarb.FX(runCy,"PG","NUC",YTIME) = 0.025; !! fixed price for nuclear fuel to 25Euro/toe
VFuelPriSubNoCarb.fx(runCy,INDDOM,"HEATPUMP",YTIME)$(SECTTECH(INDDOM,"HEATPUMP")$(not An(YTIME))) = iFuelPrice(runCy,INDDOM,"ELC",YTIME);

VPriceFuelAvgSub.FX(runCy,DSBS,YTIME)$(not An(YTIME)) = sum(EF$SECTTECH(DSBS,EF), iWgtSecAvgPriFueCons(runCy,DSBS,EF) * iFuelPrice(runCy,DSBS,EF,YTIME));
VStockPcYearly.FX(runCy,YTIME)$(not An(YTIME)) = iActv(YTIME,runCy,"PC");

* Compute electricity consumed in heatpump plants, QElecConsHeatPla(runCy,INDDOM,YTIME)$time(ytime).
VElecConsHeatPla.FX(runCy,INDDOM,YTIME) = 1E-7;
VElecConsHeatPla.FX(runCy,INDDOM,YTIME)$(not An(YTIME)) = iFuelConsPerFueSub(runCy,INDDOM,"ELC",YTIME)*(1-iShrNonSubElecInTotElecDem(runCy,INDDOM))*iShrHeatPumpElecCons(runCy,INDDOM);

VPcOwnPcLevl.FX(runCy,YTIME)$((not An(YTIME)) $(ord(YTIME) gt 1) ) = (VStockPcYearly.l(runCy,YTIME-1) / (iPop(YTIME-1,runCy)*1000) /
                           iPassCarsMarkSat(runCy))$(iPop(YTIME-1,runCy))+VPcOwnPcLevl.l(runCy,YTIME-1)$(not iPop(YTIME-1,runCy));

VMEPcNonGdp.FX(runCy,YTIME)$((not An(YTIME)) $(ord(YTIME) gt 1)  ) = ( iTransChar(runCy,"RES_MEXTF",YTIME) * iSigma(runCy,"S1") * EXP(iSigma(runCy,"S2") * EXP(iSigma(runCy,"S3") *
                          VPcOwnPcLevl.l(runCy,YTIME)))* VStockPcYearly.l(runCy,YTIME-1) /(iPop(YTIME-1,runCy) * 1000) )$(iPop(YTIME-1,runCy))+VMEPcNonGdp.l(runCy,YTIME-1)$(not iPop(YTIME-1,runCy));
VMEPcGdp.FX(runCy,YTIME)$(not An(YTIME)) = iDataPassCars(runCy,"PC","MEXTV");
VScrRatePc.FX(runCy,"%fBaseY%") = 0.1; 
VGapTranspActiv.FX(runCy,TRANSE,YTIME)$(not AN(YTIME))=0;
VConsSpecificFuel.FX(runCy,TRANSE,TTECH,EF,"%fBaseY%")$(SECTTECH(TRANSE,EF) ) = iSpeFuelConsCostBy(runCy,TRANSE,TTECH,EF);

VActivPassTrnsp.FX(runCy,"PC",YTIME)$(not AN(YTIME)) = iTransChar(runCy,"KM_VEH",YTIME); 
VActivPassTrnsp.FX(runCy,TRANP,YTIME) $(not AN(YTIME) and not sameas(TRANP,"PC")) = iActv(YTIME,runCy,TRANP); 
VActivPassTrnsp.FX(runCy,TRANSE,YTIME)$(not TRANP(TRANSE)) = 0;

VActivGoodsTransp.FX(runCy,TRANG,YTIME)$(not An(YTIME)) = iActv(YTIME,runCy,TRANG);
VActivGoodsTransp.FX(runCy,TRANSE,YTIME)$(not TRANG(TRANSE)) = 0;

VLftPc.FX(runCy,DSBS,EF,YTIME)$(SECTTECH(DSBS,EF)  $(not  TRANSE(DSBS)) $(not sameas(DSBS,"PC"))) = iTechLft(runCy,DSBS,EF,YTIME);
VLftPc.FX(runCy,TRANSE,TTECH,YTIME)$(SECTTECH(TRANSE,TTECH) $(not sameas(TRANSE,"PC"))) = iTechLft(runCy,TRANSE,TTECH,YTIME);
VLftPc.FX(runCy,DSBS,EF,YTIME)$(not SECTTECH(DSBS,EF))=0;
VLftPc.FX(runCy,"PC",TTECH,YTIME)$( (not AN(YTIME)) $SECTTECH("PC",TTECH))=10;

VConsTechTranspSectoral.FX(runCy,TRANSE,TTECH,EF,YTIME)$(SECTTECH(TRANSE,TTECH)  $(not PLUGIN(TTECH)) $TTECHtoEF(TTECH,EF) $(not AN(YTIME))) = iFuelConsPerFueSub(runCy,TRANSE,EF,YTIME); 
VConsTechTranspSectoral.FX(runCy,TRANSE,TTECH,EF,YTIME)$(SECTTECH(TRANSE,TTECH)  $PLUGIN(TTECH) $(not AN(YTIME))) = 0;
VConsTechTranspSectoral.FX(runCy,TRANSE,TTECH,EF,YTIME)$(SECTTECH(TRANSE,TTECH)  $CHYBV(TTECH) $(not AN(YTIME))) =0;

VDemFinEneTranspPerFuel.FX(runCy,TRANSE,EF,YTIME) $(SECTTECH(TRANSE,EF) $(not An(YTIME))) = iFuelConsPerFueSub(runCy,TRANSE,EF,YTIME);
VDemFinEneTranspPerFuel.FX(runCy,TRANSE,EF,YTIME) $(not SECTTECH(TRANSE,EF)) = 0;

VConsElecNonSubIndTert.FX(runCy,INDDOM,YTIME)$(not An(YTIME)) = iFuelConsPerFueSub(runCy,INDDOM,"ELC",YTIME) * iShrNonSubElecInTotElecDem(runCy,INDDOM);
vConsTotElecInd.FX(runCy,YTIME)$(not An(YTIME))= SUM(INDSE,VConsElecNonSubIndTert.l(runCy,INDSE,YTIME));
VPriceFuelSubSecChp.FX(runCy,DSBS,EF,YTIME)$((not An(YTIME)) $(not TRANSE(DSBS))  $SECTTECH(DSBS,EF)) =
   (((VPriceFuelSubCarVal.l(runCy,DSBS,EF,YTIME)+iVarCostTech(runCy,DSBS,EF,YTIME)/1000)/iUsfEneConvSubTech(runCy,DSBS,EF,YTIME)- 
   (0$(not CHP(EF)) + (VPriceFuelSubCarVal.l(runCy,"OI","ELC",YTIME)*iFracElecPriChp*iElecIndex(runCy,"%fStartHorizon%"))$CHP(EF))) + (0.003) + 
   SQRT( SQR(((VPriceFuelSubCarVal.l(runCy,DSBS,EF,YTIME)+iVarCostTech(runCy,DSBS,EF,YTIME)/1000)/iUsfEneConvSubTech(runCy,DSBS,EF,YTIME)- (0$(not CHP(EF)) + 
   (VPriceFuelSubCarVal.l(runCy,"OI","ELC",YTIME)*iFracElecPriChp*iElecIndex(runCy,"%fStartHorizon%"))$CHP(EF)))-(0.003)) + SQR(1e-7) ) )/2;

VDemFinSubFuelSubSec.FX(runCy,INDDOM,YTIME)$(not An(YTIME)) = max(iTotFinEneDemSubBaseYr(runCy,INDDOM,YTIME) - VConsElecNonSubIndTert.L(runCy,INDDOM,YTIME),1e-5);
VDemFinSubFuelSubSec.FX(runCy,NENSE,YTIME)$(not An(YTIME)) = max(iTotFinEneDemSubBaseYr(runCy,NENSE,YTIME),1e-5);
VDemFinSubFuelSubSec.FX(runCy,"HOU",YTIME)$(not An(YTIME)) = max(iTotFinEneDemSubBaseYr(runCy,"HOU",YTIME) - VConsElecNonSubIndTert.L(runCy,"HOU",YTIME)-iExogDemOfBiomass(runCy,"HOU",YTIME),1e-5);

vDemFinSubFuelInd.FX(runCy,YTIME)$(not An(YTIME))= SUM(INDSE,VDemFinSubFuelSubSec.L(runCy,INDSE,YTIME));
VPriceElecInd.FX(runCy,YTIME)$TFIRST(YTIME) = iElecIndex(runCy,YTIME);
VConsFuel.FX(runCy,DSBS,EF,YTIME)$(SECTTECH(DSBS,EF) $(not HEATPUMP(EF)) $(not TRANSE(DSBS)) $(not An(YTIME))) = iFuelConsPerFueSub(runCy,DSBS,EF,YTIME);
VFuelConsInclHP.FX(runCy,DSBS,EF,YTIME)$(SECTTECH(DSBS,EF) $(not TRANSE(DSBS)) $(not An(YTIME))) =
   (iFuelConsPerFueSub(runCy,DSBS,EF,YTIME))$((not ELCEF(EF)) $(not HEATPUMP(EF)))
   +(VElecConsHeatPla.l(runCy,DSBS,YTIME)*iUsfEneConvSubTech(runCy,DSBS,"HEATPUMP",YTIME))$HEATPUMP(EF)+
   (iFuelConsPerFueSub(runCy,DSBS,EF,YTIME)-VElecConsHeatPla.l(runCy,DSBS,YTIME))$ELCEF(EF)
   +1e-7$(H2EF(EF) or sameas("STE1AH2F",EF));
VTechShareNewEquip.FX(runCy,DSBS,EF,YTIME)$(SECTTECH(DSBS,EF)$(not An(YTIME))) = 0;
VConsRemSubEquipSubSec.FX(runCy,DSBS,EF,YTIME)$(SECTTECH(DSBS,EF) $(not An(ytime))) =
   (VFuelConsInclHP.l(runCy ,DSBS,EF,YTIME) - (VConsElecNonSubIndTert.l(runCy,DSBS,YTIME)$(ELCEF(EF) $INDDOM(DSBS)) + 0$(not (ELCEF(EF) $INDDOM(DSBS)) )));
VConsFinEneCountry.FX(runCy,EFS,YTIME)$(not An(YTIME)) = iFinEneCons(runCy,EFS,YTIME);
VLossesDistr.FX(runCy,EFS,YTIME)$(not An(YTIME)) = iDistrLosses(runCy,EFS,YTIME);
VOutTransfTherm.FX(runCy,EFS,YTIME)$(not TOCTEF(EFS)) = 0;
VCapRef.FX(runCy,YTIME)$(not An(YTIME)) = iRefCapacity(runCy,YTIME);

VOutTransfRefSpec.FX(runCy,EFS,YTIME)$(EFtoEFA(EFS,"LQD") $(not An(YTIME))) = iTransfOutputRef(runCy,EFS,YTIME);
VOutTransfRefSpec.FX(runCy,EFS,YTIME)$(not EFtoEFA(EFS,"LQD")) = 0;

VInputTransfRef.FX(runCy,"CRO",YTIME)$(not An(YTIME)) = iTransfInputRef(runCy,"CRO",YTIME);
VInputTransfRef.FX(runCy,EFS,YTIME)$(not sameas("CRO",EFS)) = 0;

VConsGrssInlNotEneBranch.FX(runCy,EFS,YTIME)$(not An(YTIME)) = iGrossInConsNoEneBra(runCy,EFS,YTIME);
VConsGrssInl.FX(runCy,EFS,YTIME)$(not An(YTIME)) = iGrosInlCons(runCy,EFS,YTIME);
VTransfers.FX(runCy,EFS,YTIME)$(not An(YTIME)) = iFeedTransfr(runCy,EFS,YTIME);
VProdPrimary.FX(runCy,PPRODEF,YTIME)$(not An(YTIME)) = iFuelPriPro(runCy,PPRODEF,YTIME);
VConsFiEneSec.FX(runCy,EFS,YTIME)$(not An(YTIME)) = iTotEneBranchCons(runCy,EFS,YTIME);

VExprtsFakeEneBrnch.FX(runCy,EFS,YTIME)$(not An(YTIME)) = iFuelExprts(runCy,EFS,YTIME);
VExprtsFakeEneBrnch.FX(runCy,"NGS",YTIME)$(not An(YTIME)) = iFuelExprts(runCy,"NGS",YTIME);
VExprtsFakeEneBrnch.FX(runCy,EFS,YTIME)$(not IMPEF(EFS)) = 0;

VImptsFakeEneBrnch.FX(runCy,"NGS",YTIME)$(not An(YTIME)) = iFuelImports(runCy,"NGS",YTIME);
VImptsFakeEneBrnch.FX(runCy,EFS,YTIME)$(not IMPEF(EFS)) = 0;

VDemElec.FX(runCy,YTIME)$(not An(YTIME)) =  1/0.086 * ( iFinEneCons(runCy,"ELC",YTIME) + sum(NENSE, iFuelConsPerFueSub(runCy,NENSE,"ELC",YTIME)) + iDistrLosses(runCy,"ELC",YTIME)
                                             + iTotEneBranchCons(runCy,"ELC",YTIME) - (iFuelImports(runCy,"ELC",YTIME)-iFuelExprts(runCy,"ELC",YTIME)));
VLoadBaseElecExp.FX(runCy,YTIME)$(not An(YTIME)) = iPeakBsLoadBy(runCy,"BASELOAD");
VLoadFacDom.FX(runCy,YTIME)$(datay(YTIME)) =
         (sum(INDDOM,VConsFuel.l(runCy,INDDOM,"ELC",YTIME)) + sum(TRANSE, VDemFinEneTranspPerFuel.l(runCy,TRANSE,"ELC",YTIME)))/
         (sum(INDDOM,VConsFuel.l(runCy,INDDOM,"ELC",YTIME)/iLoadFacElecDem(INDDOM)) + sum(TRANSE, VDemFinEneTranspPerFuel.l(runCy,TRANSE,"ELC",YTIME)/
         iLoadFacElecDem(TRANSE)));
VLoadPeakElec.FX(runCy,YTIME)$(datay(YTIME)) = VDemElec.l(runCy,YTIME)/(VLoadFacDom.l(runCy,YTIME)*8.76);
VCapGenTotElec.FX(runCy,YTIME)$(not An(YTIME)) = iTotAvailCapBsYr(runCy);
VCapGenElecNoChp.FX(runCy,YTIME)$(not An(YTIME)) = iTotAvailCapBsYr(runCy);
VCapElecChp.FX(runCy,CHP,YTIME)$(not An(YTIME)) = iHisChpGrCapData(runCy,CHP,YTIME);
VShaNewEqPowPla.FX(runCy,PGALL,YTIME)$((NOT AN(YTIME)) )=0;
VCostHourProdInvDec.FX(runCy,PGALL,HOUR,YTIME)$((NOT AN(YTIME)))=0;

VShareNewTechCcs.FX(runCy,PGALL,YTIME)$((NOT AN(YTIME)) )=0;
VShareNewTechCcs.FX(runCy,PGALL,YTIME)$(AN(YTIME) $(NOT CCS(PGALL)))=0;

VShareNewTechNoCcs.FX(runCy,PGALL,YTIME)$((NOT AN(YTIME)) )=0;
VShareNewTechNoCcs.FX(runCy,PGALL,YTIME)$(AN(YTIME) $(NOT NOCCS(PGALL)) )=0;

VDecisNewInv.FX(runCy,YTIME)$(NOT AN(YTIME))=1;
VCapGenPlannedPlant.FX(runCy,PGALL,YTIME)$DATAY(YTIME) = iInstCapPast(runCy,PGALL,YTIME);
VCapGenPlant.FX(runCy,PGALL,YTIME)$DATAY(YTIME) =  iInstCapPast(runCy,PGALL,YTIME);
VCapOverall.FX(runCy,PGALL,YTIME)$TFIRST(YTIME) =  iInstCapPast(runCy,PGALL,YTIME)$TFIRST(YTIME);

VCapGenNewResPlant.FX(runCy,PGALL,"2011")$PGREN(PGALL) = iInstCapPast(runCy,PGALL,"2011")- iInstCapPast(runCy,PGALL,"%fStartHorizon%") +1E-10;
VCapGenNewResPlant.FX(runCy,PGALL,"2012")$PGREN(PGALL) = iInstCapPast(runCy,PGALL,"2012")- iInstCapPast(runCy,PGALL,"2011") +1E-10;
VCapGenNewResPlant.FX(runCy,PGALL,"2013")$PGREN(PGALL) = iInstCapPast(runCy,PGALL,"2013")- iInstCapPast(runCy,PGALL,"2012") +1E-10;
VCapGenNewResPlant.FX(runCy,PGALL,"2014")$PGREN(PGALL) = iInstCapPast(runCy,PGALL,"2014")- iInstCapPast(runCy,PGALL,"2013") +1E-10;
VCapGenNewResPlant.FX(runCy,PGALL,"2015")$PGREN(PGALL) = iInstCapPast(runCy,PGALL,"2015")- iInstCapPast(runCy,PGALL,"2014") +1E-10;
VCapGenNewResPlant.FX(runCy,PGALL,"2016")$PGREN(PGALL) = iInstCapPast(runCy,PGALL,"2016")- iInstCapPast(runCy,PGALL,"2015") +1E-10;
VCapGenNewResPlant.FX(runCy,PGALL,"%fBaseY%")$PGREN(PGALL) = iInstCapPast(runCy,PGALL,"%fBaseY%")- iInstCapPast(runCy,PGALL,"2016") +1E-10;
VCapGenNewResPlant.FX(runCy,"PGLHYD",YTIME)$TFIRST(YTIME) = +1E-10;

VCapAvgFacRes.FX(runCy,PGALL,YTIME)$DATAY(YTIME) =iAvailRate(PGALL,YTIME);
VProdElecPowPlantsCy.FX(runCy,pgall,YTIME)$DATAY(YTIME)=iDataElecProd(runCy,pgall,YTIME)/1000;

VIndexEndogScrap.FX(runCy,PGALL,YTIME)$(not an(YTIME) ) = 1;
VIndexEndogScrap.FX(runCy,PGSCRN,YTIME) = 1;            !! premature replacement it is not allowed for all new plants

VCapCo2ElecHydr.FX(runCy,YTIME)$(not An(YTIME)) = 0;
VPotRenSuppCurve.FX(runCy,PGRENEF, YTIME) $(NOT AN(YTIME)) = iMinRenPotential(runCy,PGRENEF,YTIME);
VCostAvgPowGenLonNoClimPol.FX(runCy,PGALL,ESET,"%fBaseY%") = 0;

VCarVal.fx(runCy,NAP,YTIME)$(not An(YTIME))=0;
VCarVal.FX(runCy,"TRADE",YTIME)$an(YTIME) = sExogCarbValue*iCarbValYrExog(runCy,YTIME);
VCarVal.FX(runCy,"NOTRADE",YTIME)$an(YTIME) =sExogCarbValue*iCarbValYrExog(runCy,YTIME);

VCaptCummCo2.FX(runCy,YTIME)$(not an(YTIME)) = 0 ;
VOutTransfDhp.FX(runCy,EFS,YTIME)$(not STEAM(EFS)) = 0;
VOutTransfNuclear.FX(runCy,EFS,YTIME)$(not sameas("ELC",EFS)) = 0;
VInpTransfNuclear.FX(runCy,EFS,YTIME)$(not sameas("NUC",EFS)) = 0;
VInpTransfTherm.FX(runCy,EFS,YTIME)$(not PGEF(EFS)) = 0;
VRenValue.FX(YTIME) = 0 ;
VProdReqTotElec.fx(runCy,"%fBaseY%")=sum(pgall,VProdElecPowPlantsCy.L(runCy,pgall,"%fBaseY%"));

display VCostProdTechPreReplacAvail.l;
loop an do !! start outer iteration loop (time steps)
   s = s + 1;
   TIME(YTIME) = NO;
   TIME(AN)$(ord(an)=s) = YES;
   display TIME;
