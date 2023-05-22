table iGDP(YTIME,allCy) "GDP (billion US$2015)"
$ondelim
$include "./iGDP.csvr"
$offdelim
;
table iPop(YTIME,allCy) "Population (billion)"
$ondelim
$include "./iPop.csvr"
$offdelim
;
table iActv(YTIME,allCy,SBS) "Sector activity (various)"
                              !! main sectors (Billion Euro05) 
                              !! bunkers and households (1)
                              !! transport (Gpkm, or Gvehkm or Gtkm)
$ondelim
$include "./iActv.csvr"
$offdelim
;
table iTransChar(allCy,TRANSPCHAR,YTIME) "km per car, passengers per car and residuals for passenger cars market extension ()"
$ondelim
$include "./iTransChar.csv"
$offdelim
;
table iElastA(allCy,SBS,ETYPES,YTIME) "Activity Elasticities per subsector (1)"
$ondelim
$include "./iElastA.csv"
$offdelim
;
table iSigma(allCy,SG) "S parameters of Gompertz function for passenger cars vehicle km (1)"
$ondelim
$include "./iSigma.csv"
$offdelim
;
table iResActiv(allCy,TRANSE,YTIME) "Residuals on transport activity ()"
$ondelim
$include "./iResActiv.csv"
$offdelim
;
table iElastNonSubElec(allCy,SBS,ETYPES,YTIME) "Elasticities of Non Substitutable Electricity (1)"
$ondelim
$include "./iElastNonSubElec.csv"
$offdelim
;
table iFracElecPriChp(allCy, YTIME) "Fraction of Electricity Price at which a CHP sells electricity to network (1)"
$ondelim
$include "./iFracElecPriChp.csv"
$offdelim
;
table iCapCosChp(allCy,CHP,YTIME) "Capital Cost per CHP plant type (kEuro05/KW)"
$ondelim
$include "./iCapCosChp.csv"
$offdelim
;
table iFixOandMCosChp(allCy,CHP,YTIME) "Fixed O&M cost per CHP plant type (kEuro05/KW)"
$ondelim
$include "./iFixOandMCosChp.csv"
$offdelim
;
table iAvailRateChp(allCy,CHP) "Availability rate of CHP Plants ()"
$ondelim
$include "./iAvailRateChp.csv"
$offdelim
;
table iCosPerChp(allCy,CHP, YTIME) "Variable (other than fuel) cost per CHP Type (Gross Euro05/KW)"
$ondelim
$include "./iCosPerChp.csv"
$offdelim
;
table iBoiEffChp(allCy,CHP,YTIME) "Boiler efficiency (typical) used in adjusting CHP efficiency ()"
$ondelim
$include "./iBoiEffChp.csv"
$offdelim
;
table iDisc(allCy,SBS,YTIME) "Discount rates per subsector ()"
$ondelim
$include "./iDisc.csv"
$offdelim
;
table iCo2EmiFacAllSbs(allCy,EF) "CO2 emission factors (kgCO2/kgoe fuel burned)"
$ondelim
$include "./iCo2EmiFacAllSbs.csv"
$offdelim
;
iCo2EmiFac(allCy,SBS,EF,YTIME) = iCo2EmiFacAllSbs(allCy,EF);
iCo2EmiFac(allCy,"IS","HCL",YTIME)$(not An(YTIME))   = iCo2EmiFacAllSbs(allCy,"SLD"); !! This is the assignment for coke

table iUsfEneConvSubTech(SBS,EF,YTIME)             "Useful Energy Conversion Factor per subsector and technology (1)"
$ondelim
$include "./iUseEneConvSubTech.csv"
$offdelim
;
iUsfEnergyConvFact(allCy,SBS,EF,TEA,YTIME) = iUsfEneConvSubTech(SBS,EF,YTIME);

table iElaSub(allCy,DSBS)                           "Elasticities by subsectors (1)"
$ondelim
$include "./iElaSub.csv"
$offdelim
;
table iConsSizeDistHeat(allCy,conSet)               "Consumer sizes for district heating (1)"
$ondelim$include "./iConsSizeDistHeat.csv"
$offdelim
;
table iCapCostTech(allCy,DSBS,EF,YTIME)      "Capital Cost of technology For Industrial sectors except Iron and Steel (kEuro2005/toe-year)"
                                             !! Capital Cost of technology For transport (kEuro2005/vehicle)                                       
                                             !! Capital Cost of technology For Iron and Steel is expressed (kEuro2005/tn-of-steel)                                     
                                             !! Capital Cost of Technology For Domestic Sectors is expressed (kEuro2005/toe-year) 
$ondelim$include "./iCapCostTechIndu.csv"
$offdelim
;
table iFixOMCostTech(allCy,SBS,EF,YTIME)           "Fixed O&M cost of technology (Euro2005/toe-year)"                                   
                                            !! Fixed O&M cost of technology for Transport (kEuro2005/vehicle)
                                            !! Fixed O&M cost of technology for Industrial sectors-except Iron and Steel (Euro2005/toe-year)"                                            
                                            !! Fixed O&M cost of technology for Iron and Steel (Euro2005/tn-of-steel)"                                          
                                            !! Fixed O&M cost of technology for Domestic sectors (Euro2005/toe-year)"  
$ondelim
$include "./iFixCostTechIndu.csv"
$offdelim
;   
table iRateLossesFinConsSup(allCy,EF, YTIME)               "Supplementary parameter for Rate of losses over Available for Final Consumption (1)"
$ondelim
$include "./iRateLossesFinConsSup.csv"
$offdelim
;
table iEneProdRDscenariosSupplement(allCy,SBS,YTIME)       "Supplementary Parameter for Energy productivity indices and R&D indices (1)"  
$ondelim
$include "./iEneProdRDscenariosSupplement.csv"
$offdelim
;
iEneProdRDscenarios(runCy,SBS,YTIME)=iEneProdRDscenariosSupplement(runCy,SBS,YTIME);
table iParDHEfficiency(PGEFS,YTIME)                 "Parameter of  district heating Efficiency (1)"
$ondelim
$include "./iParDHEfficiency.csv"
$offdelim
;
table iAvgEffGas(allCy,EF,YTIME)                    "Average Efficiency of Gasworks, Blast Furnances, Briquetting plants (1)"
$ondelim
$include "./iAvgEffGas.csv"
$offdelim
;
table iSuppTransfInputPatFuel(EF,YTIME)            "Supplementary Parameter for the transformation input to patent fuel and briquetting plants,coke-oven plants,blast furnace plants and gas works (1)"
$ondelim
$include "./iSuppTransfInputPatFuel.csv"
$offdelim
; 
table iSupResRefCapacity(allCy,SUPOTH,YTIME)	           "Supplementary Parameter for the residual in refineries Capacity (1)"
$ondelim
$include "./iSupResRefCapacity.csv"
$offdelim
;
table iSuppRefCapacity(allCy,SUPOTH,YTIME)	          "Supplementary Parameter for the residual in refineries Capacity (1)"
$ondelim
$include "./iSuppRefCapacity.csv"
$offdelim
;
table iSupTrnasfOutputRefineries(allCy,EF,YTIME)	     "Supplmenetary parameter for the transformation output from refineries (Mtoe)"
$ondelim
$include"./iSupTrnasfOutputRefineries.csv"
$offdelim
;	
table iSupRateEneBranCons(allCy,EF,YTIME)	          "Rate of Energy Branch Consumption over total transformation output of iRateEneBranCons (1)"
$ondelim
$include"./iSupRateEneBranCons.csv"
$offdelim
;
table iSuppTransfers(allCy,EFS,YTIME)	                "Supplementary Parameter for Transfers (Mtoe)"
$ondelim
$include"./iSuppTransfers.csv"
$offdelim
;
table iSuppPrimProd(allCy,PPRODEF,YTIME)	          "Supplementary Parameter for Primary Production (Mtoe)"
$ondelim
$include"./iSuppPrimProd.csv"
$offdelim
;
iFuelPriPro(allCy,PPRODEF,YTIME) = iSuppPrimProd(allCy,PPRODEF,YTIME);
table iIntFuelPrcsBslnScnr(WEF,YTIME)	           "International Fuel Prices USED IN BASELINE SCENARIO ($2015/toe)"
$ondelim
$include"./iIntFuelPrcsBslnScnr.csv"
$offdelim
;
table iSuppRatePrimProd(allCy,EF,YTIME)	              "Supplementary Parameter for iRatePrimProd (1)"	
$ondelim
$include"./iSuppRatePrimProd.csv"
$offdelim
;
table iSuppExports(allCy,EF,YTIME)	                 "Supplementary parameter for  exports (Mtoe)"		
$ondelim
$include"./iSuppExports.csv"
$offdelim
;
table iImpExp(allCy,EFS,YTIME)	                 "Imports of exporting countries usually zero (1)" 
$ondelim
$include"./iImpExp.csv"
$offdelim
;
table iLoadFactorAdj(allCy,DSBS,YTIME)	"Parameters for load factor adjustment iBaseLoadShareDem (1)"	
$ondelim
$include"./iLoadFactorAdj.csv"
$offdelim
;
iBaseLoadShareDem(allCy,DSBS,YTIME)$an(YTIME)  = iLoadFactorAdj(allCy,DSBS,YTIME);
table iCO2SeqData(allCy,CO2SEQELAST,YTIME)	       "Data for CO2 sequestration (1)" 
$ondelim
$include"./iCO2SeqData.csv"
$offdelim
;
iElastCO2Seq(allCy,CO2SEQELAST) = iCO2SeqData(allCy,CO2SEQELAST,"2010");
table iResDemSub(allCy,SBS,YTIME)                  "Residuals in total energy demand per subsector (1)"
$ondelim
$include"./iResDemSub.csv"
$offdelim
;
iElastCO2Seq(allCy,CO2SEQELAST) = iCO2SeqData(allCy,CO2SEQELAST,"2010");
iRatioImpFinElecDem(runCy,YTIME)$an(YTIME) = iSuppRefCapacity(runCy,"ELC_IMP",YTIME);
iFuelExprts(runCy,EFS,YTIME) = iSuppExports(runCy,EFS,YTIME);
iIntPricesMainFuelsBsln(WEF,YTIME) = iIntFuelPrcsBslnScnr(WEF,YTIME);
iRatePriProTotPriNeeds(runCy,PPRODEF,YTIME) = iSuppRatePrimProd(runCy,PPRODEF,YTIME);
iIntPricesMainFuels(WEF,YTIME) = iIntFuelPrcsBslnScnr(WEF,YTIME);
iResHcNgOilPrProd(runCy,"HCL",YTIME)$an(YTIME)   = iSupResRefCapacity(runCy,"HCL_PPROD",YTIME);
iResHcNgOilPrProd(runCy,"NGS",YTIME)$an(YTIME)   = iSupResRefCapacity(runCy,"NGS_PPROD",YTIME);
iResHcNgOilPrProd(runCy,"CRO",YTIME)$an(YTIME)   = iSupResRefCapacity(runCy,"OIL_PPROD",YTIME);
iResFeedTransfr(runCy,YTIME)$an(YTIME) = iSupResRefCapacity(runCy,"FEED_RES",YTIME);
iFeedTransfr(runCy,EFS,YTIME) = iSuppTransfers(runCy,EFS,YTIME);
iRateEneBranCons(allCy,EFS,YTIME)= iSupRateEneBranCons(allCy,EFS,YTIME)*iEneProdRDscenarios(allCy,"PG",YTIME);
iResTransfOutputRefineries(runCy,EFS,YTIME) = iSupTrnasfOutputRefineries(runCy,EFS,YTIME);
iRefCapacity(runCy,YTIME)= iSuppRefCapacity(runCy,"REF_CAP",YTIME);
iResRefCapacity(runCy,YTIME) = iSupResRefCapacity(runCy,"REF_CAP_RES",YTIME);
iTransfInpGasworks(runCy,EFS,YTIME)= iSuppTransfInputPatFuel(EFS,YTIME);
iShareFueTransfInput(runCy,EFS)$sum(EF$EFS(EF),iTransfInpGasworks(runCy,EF,"2010")) =  iTransfInpGasworks(runCy,EFS,"2010") / sum(EF$EFS(EF),iTransfInpGasworks(runCy,EF,"2010"));
*VDistrLosses.FX(runCy,EFS,TT)$PERIOD(TT) = VDistrLosses.L(runCy,EFS,TT);
iRateLossesFinCons(runCy,EFS,YTIME)$an(YTIME)  = iRateLossesFinConsSup(runCy,EFS, YTIME)*iEneProdRDscenarios(runCy,"PG",YTIME);
iEffDHPlants(runCy,EFS,YTIME)  = sum(PGEFS$sameas(EFS,PGEFS),iParDHEfficiency(PGEFS,"2010"));
iEffDHPlants(runCy,EF,YTIME)$(an(ytime) )= iEffDHPlants(runCy,EF,YTIME) / iEneProdRDscenarios(runCy,"PG",YTIME);
table iPwrLoadFactorDem(allCy,SBS,YTIME)              "Parameters for load factor adjustment (1)"
$ondelim
$include"./iPwrLoadFactorDem.csv"
$offdelim
;
table iLoadFactorAdjMxm(allCy,VARIOUS_LABELS,YTIME)               "Parameter for load factor adjustment iMxmLoadFacElecDem (1)"
$ondelim
$include"./iLoadFactorAdjMxm.csv"
$offdelim
;
iBslCorrection(allCy,YTIME)$an(YTIME) = iLoadFactorAdjMxm(allCy,"AMAXBASE",YTIME);
iMxmLoadFacElecDem(allCy,YTIME)$an(YTIME) = iLoadFactorAdjMxm(allCy,"MAXLOADSH",YTIME);
iLoadFacElecDem(allCy,DSBS,YTIME)$(ord(YTIME)>(ordfirst-4)) = iPwrLoadFactorDem(allCy,DSBS,YTIME);
*Calculation of consumer size groups and their distribution function
iNcon(TRANSE)$(sameas(TRANSE,"PC") or sameas(TRANSE,"GU")) = 10; !! 11 different consumer size groups for cars and trucks
iNcon(TRANSE)$(not (sameas(TRANSE,"PC") or sameas(TRANSE,"GU"))) = 1; !! 2 different consumer size groups for inland navigation, trains, busses and aviation
iNcon(INDSE) = 10; !! 11 different consumer size groups for industrial sectors
iNcon(DOMSE) = 10; !! 11 different consumer size groups for domestic and tertiary sectors
iNcon(NENSE) = 10; !! 11 different consumer size groups for non energy uses
iNcon("BU") = 2;   !! ... except bunkers .


* 11 vehicle mileage groups
* 0.952 turned out to be a (constant) ratio between modal and average mileage through iterations in Excel


iAnnCons(runCy,'PC','smallest')= 0.5 * 0.952 * iTransChar(runCy,"KM_VEH","2010") * 1000 * 1E-6;
iAnnCons(runCy,'PC' ,'modal')=0.952 * iTransChar(runCy,"KM_VEH","2010") * 1000 * 1E-6;
iAnnCons(runCy,'PC' ,'largest')= 4 * 0.952 * iTransChar(runCy,"KM_VEH","2010") * 1000 * 1E-6;


* modal value is assumed to be 2 tonnes/vehicle, min = 1/3*modal and max = 10*modal tkm.
* 0.706 is the constant ratio of modal/average tkm through iterations in Excel

iAnnCons(runCy,'GU','smallest')=0.5 * 0.706 * iTransChar(runCy,"KM_VEH_TRUCK","2010")* 1000 * 2 / 3  * 1E-6;
iAnnCons(runCy,'GU','modal')=0.706 * iTransChar(runCy,"KM_VEH_TRUCK","2010") * 1000 * 2  * 1E-6;
iAnnCons(runCy,'GU','largest')=4 * 0.706 * iTransChar(runCy,"KM_VEH_TRUCK","2010") * 1000 * 2 * 10  * 1E-6;

iAnnCons(runCy,'PA','smallest')=40000 * 50 * 1E-6;
iAnnCons(runCy,'PA','modal')=400000 * 100 * 1E-6;
iAnnCons(runCy,'PA','largest')=800000 * 300 * 1E-6;

* Size will not play a role in buses, trains, ships and aircraft
* Following values are given only for the sake of uniformity, but iDisFunConSize is not really calculated for non-road transport!

*iAnnConsPB(runCy,'PB',"smallest") = 20000 * 5 * 1E-6;
*iAnnConsPB(runCy,'PB',"modal") = 50000* 15 * 1E-6;
*iAnnConsPB(runCy,'PB',"largest") = 200000 * 50 * 1E-6;


iAnnCons(runCy,'PT',"smallest") = 50000 * 50 * 1E-6;
iAnnCons(runCy,'PT',"modal") = 200000 * 150 * 1e-6;
iAnnCons(runCy,'PT',"largest") = 400000 * 500 * 1E-6;


iAnnCons(runCy,'GT',"smallest") = 50000 * 20 * 1E-6;
iAnnCons(runCy,'GT',"modal") = 200000 * 200 * 1e-6;
iAnnCons(runCy,'GT',"largest") = 400000 * 500 * 1E-6;

*iAnnConsPN(runCy,'PN',"smallest") = 10000 * 50 * 1E-6;
*iAnnConsPN(runCy,'PN',"modal") = 50000 * 100 * 1e-6;
*iAnnConsPN(runCy,'PN',"largest") = 100000 * 500 * 1E-6;


iAnnCons(runCy,'GN',"smallest") = 10000 * 20 * 1E-6;
iAnnCons(runCy,'GN',"modal") = 50000 * 300 * 1e-6;
iAnnCons(runCy,'GN',"largest") = 100000 * 1000 * 1E-6;

iAnnCons(runCy,INDSE,"smallest") = 0.2  ;
iAnnCons(runCy,INDSE,"largest") = 0.9 ;
* assuming an average utilisation rate of 0.6 for iron & steel and 0.5 for other industry (see iterations in Excel):
iAnnCons(runCy,"IS","modal") = 0.587;
iAnnCons(runCy,INDSE,"modal")$(not sameas(INDSE,"IS")) = 0.487;

iAnnCons(runCy,DOMSE,"smallest") = iConsSizeDistHeat(runCy,"smallest")  ;
iAnnCons(runCy,DOMSE,"largest") = iConsSizeDistHeat(runCy,"largest") ;
iAnnCons(runCy,DOMSE,"modal") = iConsSizeDistHeat(runCy,"modal");

iAnnCons(runCy,NENSE,"smallest") = 0.2  ;
iAnnCons(runCy,NENSE,"largest") = 0.9 ;
* assuming an average utilisation rate of 0.5 for non-energy uses:
iAnnCons(runCy,NENSE,"modal") = 0.487 ;

iAnnCons(runCy,"BU","smallest") = 0.2 ;
iAnnCons(runCy,"BU","largest") = 1 ;
iAnnCons(runCy,"BU","modal") = 0.5 ;

* Consumer size groups distribution function

Loop (runCy,DSBS) DO
     Loop rCon$(ord(rCon) le iNcon(DSBS)+1) DO
          iDisFunConSize(runCy,DSBS,rCon) =
                 Prod(nSet$(ord(Nset) le iNcon(DSBS)),ord(nSet))
                 /
                 (
                  (
                   Prod(nSet$(ord(nSet) le iNcon(DSBS)-(ord(rCon)-1)),ord(nSet))$(ord(rCon) lt iNcon(DSBS)+1)
                       +1$(ord(rCon) eq iNcon(DSBS)+1)
                   )
                   *
                   (
                      Prod(nSet$(ord(nSet) le ord(rCon)-1),ord(nSet))$(ord(rCon) ne 1)+1$(ord(rCon) eq 1))
                 )
                 *
                 Power(log(iAnnCons(runCy,DSBS,"modal")/iAnnCons(runCy,DSBS,"smallest")),ord(rCon)-1)
                 *
                 Power(log(iAnnCons(runCy,DSBS,"largest")/iAnnCons(runCy,DSBS,"modal")),iNcon(DSBS)-(ord(rCon)-1))
                 /
                (Power(log(iAnnCons(runCy,DSBS,"largest")/iAnnCons(runCy,DSBS,"smallest")),iNcon(DSBS)) )
                *
                iAnnCons(runCy,DSBS,"smallest")*(iAnnCons(runCy,DSBS,"largest")/iAnnCons(runCy,DSBS,"smallest"))**((ord(rCon)-1)/iNcon(DSBS))
;
     ENDLOOP;
ENDLOOP;

iCumDistrFuncConsSize(allCy,DSBS) = sum(rCon, iDisFunConSize(allCy,DSBS,rCon));
iCGI(allCy,YTIME) = 1;
iLoadCurveConstr(allCy,YTIME)=0;

table iResTotCapMxmLoad(allCy,PGRES,YTIME)              "Residuals for total capacity and maximum load (1)"	
$ondelim
$include"./iResTotCapMxmLoad.csv"
$offdelim
;
iResMargTotAvailCap(allCy,PGRES,YTIME)$an(YTIME) = iResTotCapMxmLoad(allCy,PGRES,YTIME);
table iInvCost(PGALL,YTIME)             "Investment Cost (KEuro2005/Kw)"
$ondelim
$include"./iInvCost.csv"
$offdelim
;
table iVarCost(PGALL,YTIME)             "Investment Cost (KEuro2005/Kw)"
$ondelim
$include"./iVarCost.csv"
$offdelim
;
iVarGroCostPlaType(runCy,PGALL,YTIME)$(ord(YTIME) eq TF-12)  = iVarCost(PGALL,"2011");
iVarGroCostPlaType(runCy,PGALL,YTIME)$(ord(YTIME) eq TF+3) = iVarCost(PGALL,"2020");
iVarGroCostPlaType(runCy,PGALL,YTIME)$(ord(YTIME) eq TF+33) = iVarCost(PGALL,"2050");
iVarGroCostPlaType(runCy,PGALL,YTIME)$(ord(YTIME)<11) = iVarGroCostPlaType(runCy,PGALL,"2011");
iVarGroCostPlaType(runCy,PGALL,YTIME)  = iVarCost(PGALL,YTIME);

iCapGrossCosPlanType(runCy,PGALL,YTIME)$(ord(YTIME) eq TF-12)  = iInvCost(PGALL,"2011");
iCapGrossCosPlanType(runCy,PGALL,YTIME)$(ord(YTIME) eq TF+3) = iInvCost(PGALL,"2020");
iCapGrossCosPlanType(runCy,PGALL,YTIME)$(ord(YTIME) eq TF+33) = iInvCost(PGALL,"2050");
iCapGrossCosPlanType(runCy,PGALL,YTIME)$(ord(YTIME)<11) = iCapGrossCosPlanType(runCy,PGALL,"2010");
iCapGrossCosPlanType(runCy,PGALL,YTIME)=iInvCost(PGALL,YTIME);
iGrossCapCosSubRen(runCy,PGALL,YTIME)=iCapGrossCosPlanType(runCy,PGALL,YTIME);
table iFixOandMCost(PGALL,YTIME)    "Fixed O&M costs (Euro2005/Kw)"
$ondelim
$include"./iFixOandMCost.csv"
$offdelim
;
table iAvailRate(PGALL,YTIME)	    "Plant availability rate (1)"
$ondelim
$include"./iAvailRate.csv"
$offdelim
;
iPlantAvailRate(runCy,PGALL,"2011") = iAvailRate(PGALL,"2011");
iPlantAvailRate(runCy,PGALL,"2020") = iAvailRate(PGALL,"2020");
iPlantAvailRate(runCy,PGALL,"2050") = iAvailRate(PGALL,"2050");
iFixGrosCostPlaType(runCy,PGALL,YTIME)$(ord(YTIME) eq TF-12)  = iFixOandMCost(PGALL,"2011");
iFixGrosCostPlaType(runCy,PGALL,YTIME)$(ord(YTIME) eq TF+3) = iFixOandMCost(PGALL,"2020");
iFixGrosCostPlaType(runCy,PGALL,YTIME)$(ord(YTIME) eq TF+33) = iFixOandMCost(PGALL,"2050");

loop(runCy,PGALL,YTIME)$AN(YTIME) DO
         abort $(iGrossCapCosSubRen(runCy,PGALL,YTIME)<0) "CAPITAL COST IS NEGATIVE", iGrossCapCosSubRen
ENDLOOP;

loop YTIME$((ord(YTIME) gt TF-12) $(ord(YTIME) lt TF+3)) do
         iCapGrossCosPlanType(runCy,PGALL,YTIME) = (iCapGrossCosPlanType(runCy,PGALL,"2020")-
         iCapGrossCosPlanType(runCy,PGALL,"2011"))/15+iCapGrossCosPlanType(runCy,PGALL,YTIME-1);
         iFixGrosCostPlaType(runCy,PGALL,YTIME) = (iFixGrosCostPlaType(runCy,PGALL,"2020")-
         iFixGrosCostPlaType(runCy,PGALL,"2011"))/15+iFixGrosCostPlaType(runCy,PGALL,YTIME-1);
         iPlantAvailRate(runCy,PGALL,YTIME) = (iPlantAvailRate(runCy,PGALL,"2020")-
         iPlantAvailRate(runCy,PGALL,"2011"))/15+iPlantAvailRate(runCy,PGALL,YTIME-1);
         iVarGroCostPlaType(runCy,PGALL,YTIME) = (iVarGroCostPlaType(runCy,PGALL,"2020")-
         iVarGroCostPlaType(runCy,PGALL,"2011"))/15+iVarGroCostPlaType(runCy,PGALL,YTIME-1);
endloop;

loop YTIME$((ord(YTIME) gt TF+3) $(ord(YTIME) lt TF+33)) do
         iCapGrossCosPlanType(runCy,PGALL,YTIME) = (iCapGrossCosPlanType(runCy,PGALL,"2050")-
         iCapGrossCosPlanType(runCy,PGALL,"2020"))/30+iCapGrossCosPlanType(runCy,PGALL,YTIME-1);
         iFixGrosCostPlaType(runCy,PGALL,YTIME) = (iFixGrosCostPlaType(runCy,PGALL,"2050")-
         iFixGrosCostPlaType(runCy,PGALL,"2020"))/30+iFixGrosCostPlaType(runCy,PGALL,YTIME-1);
         iPlantAvailRate(runCy,PGALL,YTIME) = (iPlantAvailRate(runCy,PGALL,"2050")-
         iPlantAvailRate(runCy,PGALL,"2020"))/30+iPlantAvailRate(runCy,PGALL,YTIME-1);
         iVarGroCostPlaType(runCy,PGALL,YTIME) = (iVarGroCostPlaType(runCy,PGALL,"2050")-
         iVarGroCostPlaType(runCy,PGALL,"2020"))/30+iVarGroCostPlaType(runCy,PGALL,YTIME-1);
endloop;
iFixGrosCostPlaType(runCy,PGALL,YTIME) = iFixOandMCost(PGALL,YTIME);
*table iTotAvailCapBsYr(allCy)	            "Total installed available capacity in base year (GW)"
*$ondelim
*$include"./iTotAvailCapBsYr.csv"
*$offdelim
*;
*VTotElecGenCap.FX(runCy,YTIME)$(not An(YTIME)) = iTotAvailCapBsYr(runCy);
*VTotElecGenCapEst.L(runCy,TT) = iResMargTotAvailCap(runCy,"TOT_CAP_RES",TT) * VTotElecGenCap.L(runCy,TT-1)
*        * VElecPeakLoad.L(runCy,TT)/VElecPeakLoad.L(runCy,TT-1);

*iTotAvailCapBsYr(allCy) = iDataElecSteamGen("TOTCAP","2017")+iDataElecSteamGen("CHP_CAP","2017")*0.85;

iCO2CaptRate(runCy,PGALL,YTIME)$(ord(YTIME)>(ordfirst-12))  =  iCO2CaptRateData(PGALL);

iScaleEndogScrap(allCy,PGALL,YTIME) = iPremReplacem(allCy,PGALL);
table iDecomPlants(allCy,PGALL,PG1_set)	            "Decomissioning Plants (MW)"
$ondelim
$include"./iDecomPlants.csv"
$offdelim
;
iPlantDecomSched(allCy,PGALL,"2010") = iDecomPlants(allCy,PGALL,"DEC_10");
iPlantDecomSched(allCy,PGALL,"2018") = iDecomPlants(allCy,PGALL,"DEC_18");
iPlantDecomSched(allCy,PGALL,YTIME) $((ord(YTIME) gt TF-5) $(ord(YTIME) le TF))     = (iDecomPlants(allCy,PGALL,"DEC_05")/5);
iPlantDecomSched(allCy,PGALL,YTIME)$((ord(YTIME) gt TF) $(ord(YTIME) le TF+5))      = (iDecomPlants(allCy,PGALL,"DEC_10")/5);
iPlantDecomSched(allCy,PGALL,YTIME)$((ord(YTIME) gt TF+5) $(ord(YTIME) le TF+10))   = (iDecomPlants(allCy,PGALL,"DEC_15")/5);
iPlantDecomSched(allCy,PGALL,YTIME)$((ord(YTIME) gt TF+10) $(ord(YTIME) le TF+15))  = (iDecomPlants(allCy,PGALL,"DEC_20")/5);
iPlantDecomSched(allCy,PGALL,YTIME)$((ord(YTIME) gt TF+15) $(ord(YTIME) le TF+20))  = (iDecomPlants(allCy,PGALL,"DEC_25")/5);
iPlantDecomSched(allCy,PGALL,YTIME)$((ord(YTIME) gt TF+20) $(ord(YTIME) le TF+25))  = (iDecomPlants(allCy,PGALL,"DEC_30")/5);
table iInvPlants(allCy,PGALL,PG1_set)	            "Investment Plants (MW)"
$ondelim
$include"./iInvPlants.csv"
$offdelim
;
iDecInvPlantSched(allCy,PGALL,"2010") = iInvPlants(allCy,PGALL,"INV_10");
iDecInvPlantSched(allCy,PGALL,"2011") = iInvPlants(allCy,PGALL,"INV_11");
iDecInvPlantSched(allCy,PGALL,"2012") = iInvPlants(allCy,PGALL,"INV_12");
iDecInvPlantSched(allCy,PGALL,"2013") = iInvPlants(allCy,PGALL,"INV_13");
iDecInvPlantSched(allCy,PGALL,"2014") = iInvPlants(allCy,PGALL,"INV_14");
iDecInvPlantSched(allCy,PGALL,"2015") = iInvPlants(allCy,PGALL,"INV_15");
iDecInvPlantSched(allCy,PGALL,"2018") = iInvPlants(allCy,PGALL,"INV_18");
iDecInvPlantSched(allCy,PGALL,"2019") = iInvPlants(allCy,PGALL,"INV_19");

table iCummMxmInstRenCap(allCy,PGRENEF,YTIME)	 "Cummulative maximum potential installed Capacity for Renewables (GW)"
$ondelim
$include"./iCummMxmInstRenCap.csv"
$offdelim
;
iCummMxmInstRenCap(allCy,PGRENEF,YTIME)$(not iCummMxmInstRenCap(allCy,PGRENEF,YTIME)) = 1e-4;
iMaxRenPotential(allCy,"LHYD",YTIME) = iCummMxmInstRenCap(allCy,"LHYD",YTIME);
iMaxRenPotential(allCy,"SHYD",YTIME) = iCummMxmInstRenCap(allCy,"SHYD",YTIME);
iMaxRenPotential(allCy,"WND",YTIME)$AN(YTIME) = iCummMxmInstRenCap(allCy,"WND",YTIME);
iMaxRenPotential(allCy,"WNO",YTIME)$AN(YTIME) = iCummMxmInstRenCap(allCy,"WNO",YTIME);
iMaxRenPotential(allCy,"SOL",YTIME)$AN(YTIME) = iCummMxmInstRenCap(allCy,"SOL",YTIME);
iMaxRenPotential(allCy,"DPV",YTIME)$AN(YTIME) = iCummMxmInstRenCap(allCy,"DPV",YTIME);
iMaxRenPotential(allCy,"BMSWAS",YTIME)$AN(YTIME) = iCummMxmInstRenCap(allCy,"BMSWAS",YTIME);
iMaxRenPotential(allCy,"OTHREN",YTIME)$AN(YTIME) = iCummMxmInstRenCap(allCy,"OTHREN",YTIME);
table iCummMnmInstRenCap(allCy,PGRENEF,YTIME)	 "Cummulative minimum potential installed Capacity for Renewables (GW)"
$ondelim
$include"./iCummMnmInstRenCap.csv"
$offdelim
;
iCummMnmInstRenCap(allCy,PGRENEF,YTIME)$(not iCummMnmInstRenCap(allCy,PGRENEF,YTIME)) = 1e-4;
iMinRenPotential(allCy,"LHYD",YTIME) = iCummMnmInstRenCap(allCy,"LHYD",YTIME);
iMinRenPotential(allCy,"SHYD",YTIME) = iCummMnmInstRenCap(allCy,"SHYD",YTIME);
iMinRenPotential(allCy,"WND",YTIME)  = iCummMnmInstRenCap(allCy,"WND",YTIME);
iMinRenPotential(allCy,"WNO",YTIME)  = iCummMnmInstRenCap(allCy,"WNO",YTIME);
iMinRenPotential(allCy,"SOL",YTIME)  = iCummMnmInstRenCap(allCy,"SOL",YTIME);
iMinRenPotential(allCy,"DPV",YTIME)  = iCummMnmInstRenCap(allCy,"DPV",YTIME);
iMinRenPotential(allCy,"BMSWAS",YTIME) = iCummMnmInstRenCap(allCy,"BMSWAS",YTIME);
iMinRenPotential(allCy,"OTHREN",YTIME) = iCummMnmInstRenCap(allCy,"OTHREN",YTIME);
*$ontext
table iMatFacCap(allCy,PGALL,YTIME)	 "Maturty factors on Capacity (1)"
$ondelim
$include"./iMatFacCap.csv"
$offdelim
;
iMatFacPlaAvailCap(allCy,PGALL,YTIME)$an(YTIME) = iMatFacCap(allCy,PGALL,YTIME);
iMatFacPlaAvailCap(allCy,CCS,YTIME)$an(YTIME)  =0;
*$offtext
table iMatureFacLoad(allCy,PGALL,YTIME)	 "Maturty factors on Load (1)"
$ondelim
$include"./iMatureFacLoad.csv"
$offdelim
;
iMatureFacPlaDisp(allCy,PGALL,YTIME)$an(YTIME) = iMatureFacLoad(allCy,PGALL,YTIME);
table iMxmShareChpElec(allCy,YTIME)	 "Maximum share of CHP electricity in a country (1)"
$ondelim
$include"./iMxmShareChpElec.csv"
$offdelim
;
iEffValueInEuro(allCy,SBS,YTIME)=0;
table iContrElecPrice(allCy,ELCPCHAR,YTIME)	 "Parameters controlling electricity price (1)"
$ondelim
$include"./iContrElecPrice.csv"
$offdelim
;
iFacElecPriConsu(allCy,ELCPCHAR,YTIME)$an(YTIME) = iContrElecPrice(allCy,ELCPCHAR,YTIME);
iScenarioPri(WEF,"NOTRADE",YTIME)=0;
table iDataPriceReform(allCy,AGSECT,EF,YTIME)	 "Price reform (1)"
$ondelim
$include"./iDataPriceReform.csv"
$offdelim
;
* INSERT MECHANSIM FOR PRICE REFORM!!
iPriceReform(runCy,INDSE1(SBS),EF,YTIME)=iDataPriceReform(runCy,"INDSE1",EF,YTIME) ;
iPriceReform(runCy,DOMSE1(SBS),EF,YTIME)=iDataPriceReform(runCy,"DOMSE1",EF,YTIME) ;
iPriceReform(runCy,NENSE1(SBS),EF,YTIME)=iDataPriceReform(runCy,"NENSE1",EF,YTIME) ;
iPriceReform(runCy,TRANS1(SBS),EF,YTIME)=iDataPriceReform(runCy,"TRANS1",EF,YTIME) ;
iPriceReform(runCy,PG(SBS),EF,YTIME)=iDataPriceReform(runCy,"INDSE1",EF,YTIME) ;
table iDataPriceTargets(allCy,AGSECT,EF,YTIME)	 "Data for the Price targets (1)"
$ondelim
$include"./iDataPriceTargets.csv"
$offdelim
;
iPriceTragets(runCy,INDSE1(SBS),EF,YTIME)=iDataPriceTargets(runCy,"INDSE1",EF,"2030") ;
iPriceTragets(runCy,DOMSE1(SBS),EF,YTIME)=iDataPriceTargets(runCy,"DOMSE1",EF,"2030") ;
iPriceTragets(runCy,NENSE1(SBS),EF,YTIME)=iDataPriceTargets(runCy,"NENSE1",EF,"2030") ;
iPriceTragets(runCy,TRANS1(SBS),EF,YTIME)=iDataPriceTargets(runCy,"TRANS1",EF,"2030") ;
iPriceTragets(runCy,PG(SBS),EF,YTIME)=iDataPriceTargets(runCy,"INDSE1",EF,"2030") ;

*SPECIFIC CASE FOR NATURAL GAS PRICES!!!

iPriceTragets("RAS",INDSE1(SBS),"NGS",YTIME)=iDataPriceTargets("RAS","INDSE1","NGS",YTIME) ;
iPriceTragets("RAS",DOMSE1(SBS),"NGS",YTIME)=iDataPriceTargets("RAS","DOMSE1","NGS",YTIME) ;
iPriceTragets("RAS",NENSE1(SBS),"NGS",YTIME)=iDataPriceTargets("RAS","NENSE1","NGS",YTIME) ;
iPriceTragets("RAS",PG(SBS),"NGS",YTIME)=iDataPriceTargets("RAS","INDSE1","NGS",YTIME) ;

iPriceTragets("MAR",INDSE1(SBS),"NGS",YTIME)=iDataPriceTargets("MAR","INDSE1","NGS",YTIME) ;
iPriceTragets("MAR",DOMSE1(SBS),"NGS",YTIME)=iDataPriceTargets("MAR","DOMSE1","NGS",YTIME) ;
iPriceTragets("MAR",NENSE1(SBS),"NGS",YTIME)=iDataPriceTargets("MAR","NENSE1","NGS",YTIME) ;
iPriceTragets("MAR",PG(SBS),"NGS",YTIME)=iDataPriceTargets("MAR","INDSE1","NGS",YTIME) ;
table iResDomPriEq(allCy,SBS,EF,YTIME)	 "Residuals for domestic prices in equations after 2005 (1)"
$ondelim
$include"./iResDomPriEq.csv"
$offdelim
;
iResInPriceEq(allCy,SBS,EF,YTIME)$an(YTIME) = iResDomPriEq(allCy,SBS,EF,YTIME)/1000;
table iWorldPriToDomPri(allCy,SBS,EF,YTIME)	 "Parameters linking world prices to domestic prices in equations, after 2005 (1)"
$ondelim
$include"./iWorldPriToDomPri.csv"
$offdelim
;
iIntToConsuPrices(allCy,SBS,EF,YTIME)$an(YTIME) = iWorldPriToDomPri(allCy,SBS,EF,YTIME);
table iDomFuelPrices(allCy,SBS,EF,YTIME)	 "Consumer Prices of fuels per subsector (kEuro2005/toe)"
$ondelim
$include"./iDomFuelPrices.csv"
$offdelim
;
iConsPricesFuelSub(allCy,SBS,EF,YTIME)$(not AN(YTIME)) = iDomFuelPrices(allCy,SBS,EF,YTIME)/1000;