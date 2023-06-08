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
table iDataPassCars(allCy,GompSet1,Gompset2)        "Initial Data for Passenger Cars ()"
$ondelim
$include "./iDataPassCars.csv"
$offdelim
;	
iSigma(allCy,"S1") = iDataPassCars(allCy,"PC","S1");
iSigma(allCy,"S2") = iDataPassCars(allCy,"PC","S2");
iSigma(allCy,"S3") = iDataPassCars(allCy,"PC","S3");
iPassCarsMarkSat(allCy) = iDataPassCars(allCy,"PC","SAT");
iGdpPassCarsMarkExt(allCy) = iDataPassCars(allCy,"PC","MEXTV");
iPassCarsScrapRate(allCy)  = iDataPassCars(allCy,"PC", "SCR");
table iInitSpecFuelCons(allCy,TRANSE,TTECH,EF,YTIME)        "Initial Specific fuel consumption ()"
$ondelim
$include "./iInitSpecFuelCons.csv"
$offdelim
;	
iSpeFuelConsCostBy(allCy,TRANSE,TTECH,TEA,EF) = iInitSpecFuelCons(allCy,TRANSE,TTECH,EF,"2017");
table iElaSub(allCy,DSBS)                           "Elasticities by subsectors (1)"
$ondelim
$include "./iElaSub.csv"
$offdelim
;
table iConsSizeDistHeat(allCy,conSet)               "Consumer sizes for district heating (1)"
$ondelim
$include "./iConsSizeDistHeat.csv"
$offdelim
;
table iCapCostTech(allCy,DSBS,EF,YTIME)      "Capital Cost of technology For Industrial sectors except Iron and Steel (kEuro2005/toe-year)"
                                             !! Capital Cost of technology For transport (kEuro2005/vehicle)                                       
                                             !! Capital Cost of technology For Iron and Steel is expressed (kEuro2005/tn-of-steel)                                     
                                             !! Capital Cost of Technology For Domestic Sectors is expressed (kEuro2005/toe-year) 
$ondelim$include "./iCapCostTechIndu.csv"
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
table iSupTrnasfOutputRefineries(allCy,EF,YTIME)	     "Supplementary parameter for the transformation output from refineries (Mtoe)"
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
table iPriceFuelsInt(WEF,YTIME)                "International Fuel Prices ($2015/toe)"
$ondelim
$include"./iPriceFuelsInt.csv"
$offdelim
;
table iPriceFuelsIntBase(WEF,YTIME)	           "International Fuel Prices USED IN BASELINE SCENARIO ($2015/toe)"
$ondelim
$include"./iPriceFuelsIntBase.csv"
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
iElastCO2Seq(allCy,CO2SEQELAST) = iCO2SeqData(allCy,CO2SEQELAST,"2029");
table iResDemSub(allCy,SBS,YTIME)                  "Residuals in total energy demand per subsector (1)"
$ondelim
$include"./iResDemSub.csv"
$offdelim
;
table iDataTransTech (TRANSE,EF,ECONCHAR)                  "Technoeconomic characteristics of transport (various)"
$ondelim
$include"./iDataTransTech.csv"
$offdelim
;
table iDataIndTechnology(INDSE,EF,ECONCHAR)                  "Technoeconomic characteristics of industry (various)"
$ondelim
$include"./iDataIndTechnology.csv"
$offdelim
;
table iDataDomTech(DOMSE,EF,ECONCHAR)                  "Technical lifetime of Industry (years)"
$ondelim
$include"./iDataDomTech.csv"
$offdelim
;
table iDataNonEneSec(NENSE,EF,ECONCHAR)                  "Technical data of non energy uses and bunkers (various)"
$ondelim
$include"./iDataNonEneSec.csv"
$offdelim
;
table iFuelConsIndSub(allCy,INDSE,Indu_Scon_Set)               "Fuel Consumption per industry Subsector (Mtoe)"
$ondelim
$include"./iFuelConsIndSub.csv"
$offdelim
;
table iInitConsSubAndInitShaNonSubElec(allCy,DOMSE,Indu_Scon_Set)      "Initial Consumption per Subsector and Initial Shares of Non Substitutable Electricity in Total Electricity Demand (Mtoe)"
$ondelim
$include"./iInitConsSubAndInitShaNonSubElec.csv"
$offdelim
;
iShrHeatPumpElecCons(allCy,INDSE) = iFuelConsIndSub(allCy,INDSE,"SH_HPELC");
iShrHeatPumpElecCons(allCy,DOMSE) = iInitConsSubAndInitShaNonSubElec(allCy,DOMSE,"SH_HPELC");
*iTechLft(allCy,TRANSE,EF,TEA,YTIME)$(ord(YTIME)>sum(TFIRST,(ord(TFIRST)-3))) = iDataTransTech(TRANSE,EF,"LFT");
*iTechLft(allCy,INDSE,EF,TEA,YTIME)$(ord(YTIME)>(ordfirst-12)) = iDataIndTechnology(INDSE,EF,"LFT");
*iTechLft(allCy,DOMSE,EF,TEA,YTIME)$(ord(YTIME)>(ordfirst-12)) = iDataDomLft(DOMSE,EF,"LFT");
*iTechLft(allCy,NENSE,EF,TEA,YTIME)$(ord(YTIME)>(ordfirst-4))  = iDataNonEneLft(NENSE,EF,"LFT");
iExogDemOfBiomass(allCy,DOMSE,YTIME) = 0;
iElastCO2Seq(allCy,CO2SEQELAST) = iCO2SeqData(allCy,CO2SEQELAST,"2029");
iRatioImpFinElecDem(runCy,YTIME)$an(YTIME) = iSuppRefCapacity(runCy,"ELC_IMP",YTIME);
iFuelExprts(runCy,EFS,YTIME) = iSuppExports(runCy,EFS,YTIME);
iRatePriProTotPriNeeds(runCy,PPRODEF,YTIME) = iSuppRatePrimProd(runCy,PPRODEF,YTIME);
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
iShareFueTransfInput(runCy,EFS)$sum(EF$EFS(EF),iTransfInpGasworks(runCy,EF,"2029")) =  iTransfInpGasworks(runCy,EFS,"2029") / sum(EF$EFS(EF),iTransfInpGasworks(runCy,EF,"2029"));
*VDistrLosses.FX(runCy,EFS,TT)$PERIOD(TT) = VDistrLosses.L(runCy,EFS,TT);
iRateLossesFinCons(runCy,EFS,YTIME)$an(YTIME)  = iRateLossesFinConsSup(runCy,EFS, YTIME)*iEneProdRDscenarios(runCy,"PG",YTIME);
iEffDHPlants(runCy,EFS,YTIME)  = sum(PGEFS$sameas(EFS,PGEFS),iParDHEfficiency(PGEFS,"2029"));
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


iAnnCons(runCy,'PC','smallest')= 0.5 * 0.952 * iTransChar(runCy,"KM_VEH","2029") * 1000 * 1E-6;
iAnnCons(runCy,'PC' ,'modal')=0.952 * iTransChar(runCy,"KM_VEH","2029") * 1000 * 1E-6;
iAnnCons(runCy,'PC' ,'largest')= 4 * 0.952 * iTransChar(runCy,"KM_VEH","2029") * 1000 * 1E-6;


* modal value is assumed to be 2 tonnes/vehicle, min = 1/3*modal and max = 10*modal tkm.
* 0.706 is the constant ratio of modal/average tkm through iterations in Excel

iAnnCons(runCy,'GU','smallest')=0.5 * 0.706 * iTransChar(runCy,"KM_VEH_TRUCK","2029")* 1000 * 2 / 3  * 1E-6;
iAnnCons(runCy,'GU','modal')=0.706 * iTransChar(runCy,"KM_VEH_TRUCK","2029") * 1000 * 2  * 1E-6;
iAnnCons(runCy,'GU','largest')=4 * 0.706 * iTransChar(runCy,"KM_VEH_TRUCK","2029") * 1000 * 2 * 10  * 1E-6;

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
*iLoadCurveConstr.L(runCy,TT)$(PERIOD(TT) $TFIRSTAN(TT))= 0.21;
*iLoadCurveConstr.L(runCy,TT)$(PERIOD(TT) $(NOT TFIRSTAN(TT)))= iLoadCurveConstr.L(runCy,TT-1);
iLoadCurveConstr(allCy,YTIME)=0.21;

table iResTotCapMxmLoad(allCy,PGRES,YTIME)              "Residuals for total capacity and maximum load (1)"	
$ondelim
$include"./iResTotCapMxmLoad.csv"
$offdelim
;
iResMargTotAvailCap(allCy,PGRES,YTIME)$an(YTIME) = iResTotCapMxmLoad(allCy,PGRES,YTIME);
*$ontext
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
iCapGrossCosPlanType(runCy,PGALL,YTIME)$(ord(YTIME)<11) = iCapGrossCosPlanType(runCy,PGALL,"2029");
iCapGrossCosPlanType(runCy,PGALL,YTIME)=iInvCost(PGALL,YTIME);

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
*$offtext
table iDataDistrLosses(allCy,EF,YTIME)	    "Data for Distribution Losses (Mtoe)"
$ondelim
$include"./iDataDistrLosses.csv"
$offdelim
;
table iDataOtherTransfOutput(allCy,EF,YTIME)	    "Data for Other transformation output  (Mtoe)"
$ondelim
$include"./iDataOtherTransfOutput.csv"
$offdelim
;
iTranfOutGasworks(allCy,EFS,YTIME)$(not An(YTIME)) = iDataOtherTransfOutput(allCy,EFS,YTIME);
iDistrLosses(allCy,EFS,YTIME)$(not An(YTIME))  = iDataDistrLosses(allCy,EFS,YTIME);
table iDataTransfOutputRef(allCy,EF,YTIME)	    "Data for Other transformation output  (Mtoe)"
$ondelim
$include"./iDataTransfOutputRef.csv"
$offdelim
;
table iFuelCons(allCy,TRANSE,EF,YTIME)	 "Fuel consumption (Mtoe)"
$ondelim
$include"./iFuelCons.csv"
$offdelim
;
iTransfOutputRef(allCy,EFS,YTIME)$(not An(YTIME)) = iDataTransfOutputRef(allCy,EFS,YTIME);
iFuelCons(allCy,TRANSE,EF,YTIME)$(SECTTECH(TRANSE,EF) $(iFuelCons(allCy,TRANSE,EF,YTIME)<=0)) = 1e-6;
iFuelConsPerFueSub(allCy,TRANSE,EF,YTIME)$(not An(YTIME))  = iFuelCons(allCy,TRANSE,EF,YTIME);
table iIndFuelConsPerSub(allCy,INDSE,EF,YTIME)	 "Fuel consumption per industry subsector (Mtoe)"
$ondelim
$include"./iIndFuelConsPerSub.csv"
$offdelim
;
table iDomFuelConsPerSub(allCy,DOMSE,EF,YTIME)	 "Fuel Consumption per domestic Subsector (Mtoe)"
$ondelim
$include"./iDomFuelConsPerSub.csv"
$offdelim
;
table iFinConsSubFuel(allCy,NENSE,EF,YTIME)	 "Final Consumption per Subsector and fuel (Mtoe)"
$ondelim
$include"./iFinConsSubFuel.csv"
$offdelim
;
iFuelConsPerFueSub(allCy,INDSE,EF,YTIME)$(not An(YTIME))   = iIndFuelConsPerSub(allCy,INDSE,EF,YTIME);
iFuelConsPerFueSub(allCy,DOMSE,EF,YTIME)$(not An(YTIME))   = iDomFuelConsPerSub(allCy,DOMSE,EF,YTIME);
iFuelConsPerFueSub(allCy,NENSE,EF,YTIME)$(not An(YTIME))   = iFinConsSubFuel(allCy,NENSE,EF,YTIME);
iFinEneCons(runCy,EFS,YTIME) = sum(INDDOM,
                         sum(EF$(EFtoEFS(EF,EFS) $SECTTECH(INDDOM,EF)), iFuelConsPerFueSub(runCy,INDDOM,EF,YTIME)))
                       +
                       sum(TRANSE,
                         sum(EF$(EFtoEFS(EF,EFS) $SECTTECH(TRANSE,EF) $(not plugin(EF)) ), iFuelConsPerFueSub(runCy,TRANSE,EF,YTIME)));
iGrossCapCosSubRen(runCy,PGALL,YTIME)=iCapGrossCosPlanType(runCy,PGALL,YTIME);
loop(runCy,PGALL,YTIME)$AN(YTIME) DO
         abort $(iGrossCapCosSubRen(runCy,PGALL,YTIME)<0) "CAPITAL COST IS NEGATIVE", iGrossCapCosSubRen
ENDLOOP;


iFixGrosCostPlaType(runCy,PGALL,YTIME) = iFixOandMCost(PGALL,YTIME);
*VTotElecGenCap.FX(runCy,YTIME)$(not An(YTIME)) = iTotAvailCapBsYr(runCy);
*VTotElecGenCapEst.L(runCy,TT) = iResMargTotAvailCap(runCy,"TOT_CAP_RES",TT) * VTotElecGenCap.L(runCy,TT-1)
*        * VElecPeakLoad.L(runCy,TT)/VElecPeakLoad.L(runCy,TT-1);
table iDataElecSteamGen(allCy,PGOTH,YTIME)	          "Various Data related to electricity and steam generation (1)"
$ondelim
$include"./iDataElecSteamGen.csv"
$offdelim
;
iTotAvailCapBsYr(allCy) = iDataElecSteamGen(allCy,"TOTCAP","2018")+iDataElecSteamGen(allCy,"CHP_CAP","2018")*0.85;
iElecImp(allCy,YTIME)=0;
iCO2CaptRate(runCy,PGALL,YTIME)$(ord(YTIME)>(ordfirst-12))  =  iCO2CaptRateData(PGALL);

iScaleEndogScrap(allCy,PGALL,YTIME) = iPremReplacem(allCy,PGALL);
table iDecomPlants(allCy,PGALL,PG1_set)	            "Decomissioning Plants (MW)"
$ondelim
$include"./iDecomPlants.csv"
$offdelim
;
iPlantDecomSched(allCy,PGALL,"2029") = iDecomPlants(allCy,PGALL,"DEC_10");
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
iDecInvPlantSched(allCy,PGALL,"2029") = iInvPlants(allCy,PGALL,"INV_10");
iDecInvPlantSched(allCy,PGALL,"2011") = iInvPlants(allCy,PGALL,"INV_11");
iDecInvPlantSched(allCy,PGALL,"2012") = iInvPlants(allCy,PGALL,"INV_12");
iDecInvPlantSched(allCy,PGALL,"2013") = iInvPlants(allCy,PGALL,"INV_13");
iDecInvPlantSched(allCy,PGALL,"2014") = iInvPlants(allCy,PGALL,"INV_14");
iDecInvPlantSched(allCy,PGALL,"2034") = iInvPlants(allCy,PGALL,"INV_15");
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
table iResDomPriEq(allCy,SBS,EF,YTIME)	 "Residuals for domestic prices in equations after 2024 (1)"
$ondelim
$include"./iResDomPriEq.csv"
$offdelim
;
iHydrogenPri(allCy,SBS,YTIME)=4.3;
iResInPriceEq(allCy,SBS,EF,YTIME)$an(YTIME) = iResDomPriEq(allCy,SBS,EF,YTIME)/1000;
table iWorldPriToDomPri(allCy,SBS,EF,YTIME)	 "Parameters linking world prices to domestic prices in equations, after 2024 (1)"
$ondelim
$include"./iWorldPriToDomPri.csv"
$offdelim
;
iIntToConsuPrices(allCy,SBS,EF,YTIME)$an(YTIME) = iWorldPriToDomPri(allCy,SBS,EF,YTIME);
iIntToConsuPrices(runCy,SBS,EF,YTIME) = 0;
table iDomFuelPrices(allCy,SBS,EF,YTIME)	 "Consumer Prices of fuels per subsector (kEuro2005/toe)"
$ondelim
$include"./iDomFuelPrices.csv"
$offdelim
;
iConsPricesFuelSub(allCy,SBS,EF,YTIME)$(not AN(YTIME)) = iDomFuelPrices(allCy,SBS,EF,YTIME)/1000;
table iDataGrossInlCons(allCy,EF,YTIME)	 "Data for Gross Inland Conusmption (Mtoe)"
$ondelim
$include"./iDataGrossInlCons.csv"
$offdelim
;
table iDataConsEneBranch(allCy,EF,YTIME)	 "Data for Consumption of Energy Branch (Mtoe)"
$ondelim
$include"./iDataConsEneBranch.csv"
$offdelim
;
iTotEneBranchCons(allCy,EFS,YTIME)$(not An(YTIME)) = iDataConsEneBranch(allCy,EFS,YTIME);
table iDataImports(allCy,EF,YTIME)	           "Data for imports (Mtoe)"
$ondelim
$include"./iDataImports.csv"
$offdelim
;
iFuelImports(allCy,EFS,YTIME)$(not An(YTIME)) = iDataImports(allCy,EFS,YTIME);
iGrosInlCons(allCy,EFS,YTIME)$(not An(YTIME)) = iDataGrossInlCons(allCy,EFS,YTIME);
iGrossInConsNoEneBra(runCy,EFS,YTIME) = iGrosInlCons(runCy,EFS,YTIME) + iTotEneBranchCons(runCy,EFS,YTIME)$EFtoEFA(EFS,"LQD")
                                               - iTotEneBranchCons(runCy,EFS,YTIME)$(not EFtoEFA(EFS,"LQD"));

iPeakBsLoadBy(allCy,PGLOADTYPE) = iDataElecSteamGen(allCy,PGLOADTYPE,"2036");

table iDataElecAndSteamGen(allCy,CHP,YTIME)	 "Data releated to electricity and steam generation"
$ondelim
$include"./iDataElecAndSteamGen.csv"
$offdelim
;
iHisChpGrCapData(allCy,CHP,YTIME) = iDataElecAndSteamGen(allCy,CHP,YTIME);

table iDataTotTransfInputRef(allCy,EF,YTIME)	 "Total Transformation Input in Refineries (Mtoe)"
$ondelim
$include"./iDataTotTransfInputRef.csv"
$offdelim
;
iTransfInputRef(allCy,EFS,YTIME)$(not An(YTIME)) = iDataTotTransfInputRef(allCy,EFS,YTIME);

* Calculation of weights for sector average fuel price

parameter iDiffFuelsInSec(SBS) auxiliary parameter holding the number of different fuels in a sector;

loop SBS do
         iDiffFuelsInSec(SBS) = 0;
         loop EF$(SECTTECH(SBS,EF) $(not plugin(EF)))  do
              iDiffFuelsInSec(SBS) = iDiffFuelsInSec(SBS)+1;
         endloop;
endloop;

iTotFinEneDemSubBaseYr(runCy,TRANSE,YTIME) = sum(EF$(SECTTECH(TRANSE,EF) $(not plugin(EF))), iFuelConsPerFueSub(runCy,TRANSE,EF,YTIME));
iTotFinEneDemSubBaseYr(allCy,INDSE,YTIME)   = SUM(EF,iFuelConsPerFueSub(allCy,INDSE,EF,YTIME));
iTotFinEneDemSubBaseYr(allCy,DOMSE,YTIME)   = SUM(EF,iFuelConsPerFueSub(allCy,DOMSE,EF,YTIME));
iTotFinEneDemSubBaseYr(allCy,NENSE,YTIME)   = SUM(EF,iFuelConsPerFueSub(allCy,NENSE,EF,YTIME));


iWgtSecAvgPriFueCons(runCy,TRANSE,EF)$(SECTTECH(TRANSE,EF) $(not plugin(EF)) ) = (iFuelConsPerFueSub(runCy,TRANSE,EF,"2019") / iTotFinEneDemSubBaseYr(runCy,TRANSE,"2019"))$iTotFinEneDemSubBaseYr(runCy,TRANSE,"2019")
                                               + (1/iDiffFuelsInSec(TRANSE))$(not iTotFinEneDemSubBaseYr(runCy,TRANSE,"2019"));

iWgtSecAvgPriFueCons(runCy,NENSE,EF)$SECTTECH(NENSE,EF) = ( iFuelConsPerFueSub(runCy,NENSE,EF,"2019") / iTotFinEneDemSubBaseYr(runCy,NENSE,"2019") )$iTotFinEneDemSubBaseYr(runCy,NENSE,"2019")
                                             + (1/iDiffFuelsInSec(NENSE))$(not iTotFinEneDemSubBaseYr(runCy,NENSE,"2019"));


iWgtSecAvgPriFueCons(runCy,INDDOM,EF)$(SECTTECH(INDDOM,EF)$(not sameas(EF,"ELC"))) = ( iFuelConsPerFueSub(runCy,INDDOM,EF,"2019") / (iTotFinEneDemSubBaseYr(runCy,INDDOM,"2019") - iFuelConsPerFueSub(runCy,INDDOM,"ELC","2019")) )$( iTotFinEneDemSubBaseYr(runCy,INDDOM,"2019") - iFuelConsPerFueSub(runCy,INDDOM,"ELC","2019") )
                                                                        + (1/(iDiffFuelsInSec(INDDOM)-1))$(not (iTotFinEneDemSubBaseYr(runCy,INDDOM,"2019") - iFuelConsPerFueSub(runCy,INDDOM,"ELC","2019")));



* Rescaling the weights
iWgtSecAvgPriFueCons(runCy,SBS,EF)$(SECTTECH(SBS,EF) $sum(ef2$SECTTECH(SBS,EF),iWgtSecAvgPriFueCons(runCy,SBS,EF2))) = iWgtSecAvgPriFueCons(runCy,SBS,EF)/sum(ef2$SECTTECH(SBS,EF),iWgtSecAvgPriFueCons(runCy,SBS,EF2));
table iResNonSubElec(allCy,INDSE,YTIME)	 "Residuals for non subsitutable electricity (1)"
$ondelim
$include"./iResNonSubElec.csv"
$offdelim
;
table iResNonSubElecCons(allCy,DOMSE,YTIME)	 "Residuals in Non Substitutable Electricity Consumption per substector (1)"
$ondelim
$include"./iResNonSubElecCons.csv"
$offdelim
;
iResNonSubsElecDem(allCy,INDSE,YTIME)$an(YTIME) = iResNonSubElec(allCy,INDSE,YTIME);
iResNonSubsElecDem(allCy,DOMSE,YTIME)$an(YTIME) = iResNonSubElecCons(allCy,DOMSE,YTIME);
table iResFuelConsSub(allCy,INDSE,EF,YTIME)	 "Residuals for fuel consumption per subsector (1)"
$ondelim
$include"./iResFuelConsSub.csv"
$offdelim
;
table iResFuelConsPerFuelAndSub(allCy,DOMSE,EF,YTIME)	 "Residuals in fuel consumption per fuel and subsector (1)"
$ondelim
$include"./iResFuelConsPerFuelAndSub.csv"
$offdelim
;
table iResInFuelConsPerFuelAndSub(allCy,NENSE,EF,YTIME)	 "Residuals in fuel consumption per fuel and subsector (1)"
$ondelim
$include"./iResInFuelConsPerFuelAndSub.csv"
$offdelim
;
iResFuelConsPerSubAndFuel(allCy,INDSE,EF,YTIME)$an(YTIME) = iResFuelConsSub(allCy,INDSE,EF,YTIME);
iResFuelConsPerSubAndFuel(allCy,DOMSE,EF,YTIME)$an(YTIME) = iResFuelConsPerFuelAndSub(allCy,DOMSE,EF,YTIME);
iResFuelConsPerSubAndFuel(allCy,NENSE,EF,YTIME)$an(YTIME) = iResInFuelConsPerFuelAndSub(allCy,NENSE,EF,YTIME);

iTransfOutputGasw(allCy,YTIME)$an(YTIME)  = iSupResRefCapacity(allCy,"TOOTH_RES",YTIME);
table iResTranspFuelConsSubTech(allCy,TRANSE,EF,YTIME)	 "Residual Transport on Specific Fuel Consumption per Subsector and Technology (1)"
$ondelim
$include"./iResTranspFuelConsSubTech.csv"
$offdelim
;
iResSpecificFuelConsCost(allCy,TRANSE,TTECH,EF,YTIME)$(sameas(TTECH,EF)$an(YTIME)) = iResTranspFuelConsSubTech(allCy,TRANSE,EF,YTIME)*iEneProdRDscenarios(allCy,TRANSE,YTIME);
iResSpecificFuelConsCost(allCy,TRANSE,"BGDO","BGDO",YTIME)$(an(YTIME) $SECTTECH(TRANSE,"BGDO")) = iResSpecificFuelConsCost(allCy,TRANSE,"GDO","GDO",YTIME);

iResSpecificFuelConsCost(allCy,TRANSE,"PHEVGSL","GSL",YTIME)$(TRANSETTECH(TRANSE,"PHEVGSL") $an(YTIME))= iResSpecificFuelConsCost(allCy,TRANSE,"GSL","GSL",YTIME);
iResSpecificFuelConsCost(allCy,TRANSE,"PHEVGSL","ELC",YTIME)$(TRANSETTECH(TRANSE,"PHEVGSL") $an(YTIME))= iResSpecificFuelConsCost(allCy,TRANSE,"ELC","ELC",YTIME);

iResSpecificFuelConsCost(allCy,TRANSE,"PHEVGDO","GDO",YTIME)$(TRANSETTECH(TRANSE,"PHEVGDO") $an(YTIME))= iResSpecificFuelConsCost(allCy,TRANSE,"GDO","GDO",YTIME);
iResSpecificFuelConsCost(allCy,TRANSE,"PHEVGDO","ELC",YTIME)$(TRANSETTECH(TRANSE,"PHEVGDO") $an(YTIME))= iResSpecificFuelConsCost(allCy,TRANSE,"ELC","ELC",YTIME);

iResSpecificFuelConsCost(allCy,TRANSE,"cHEVGDO","GDO",YTIME)$(TRANSETTECH(TRANSE,"cHEVGDO") $an(YTIME))= iResSpecificFuelConsCost(allCy,TRANSE,"GDO","GDO",YTIME);
iResSpecificFuelConsCost(allCy,TRANSE,"cHEVGsl","gsl",YTIME)$(TRANSETTECH(TRANSE,"cHEVGsl") $an(YTIME))= iResSpecificFuelConsCost(allCy,TRANSE,"Gsl","Gsl",YTIME);
table iPlugHybrFractOfMileage(allCy,ELSH_SET,YTIME)	 "Plug in hybrid fraction of mileage covered by electricity, residualls on GDP-Depnd car market ext (1)"
$ondelim
$include"./iPlugHybrFractOfMileage.csv"
$offdelim
;
iShareAnnMilePlugInHybrid(allCy,YTIME)$an(YTIME) = iPlugHybrFractOfMileage(allCy,"ELSH",YTIME);
table iCapDataLoadFacEachTransp(TRANSE,TRANSUSE)	 "Capacity data and Load factor for each transportation mode (passenger or tonnes/vehicle)"
$ondelim
$include"./iCapDataLoadFacEachTransp.csv"
$offdelim
;
table iPlantEffByTypeTemp(PGALL,PGECONCHAR)           "Plant efficiency per plant type (1)"
$ondelim
$include"./iPlantEffByType.csv"
$offdelim
;
iPlantEffByType(allCy,PGALL,YTIME) = iPlantEffByTypeTemp(PGALL,"EFF_05");

table iSuppPlantCapFac(allCy,PGRENEF,YTIME)	                "Capacity Factors (1)"	
$ondelim
$include"./iSuppPlantCapFac.csv"
$offdelim
;
iPlantAvailRate(allCy,"PGLHYD",YTIME)=iSuppPlantCapFac(allCy,"LHYD",YTIME);
iPlantAvailRate(allCy,"PGSHYD",YTIME)=iSuppPlantCapFac(allCy,"SHYD",YTIME);
iPlantAvailRate(allCy,"PGWND",YTIME)=iSuppPlantCapFac(allCy,"WND",YTIME);
iPlantAvailRate(allCy,"PGAWNO",YTIME)=iSuppPlantCapFac(allCy,"WNO",YTIME);
iPlantAvailRate(allCy,"PGSOL",YTIME)=iSuppPlantCapFac(allCy,"SOL",YTIME);
iPlantAvailRate(allCy,"PGADPV",YTIME)=iSuppPlantCapFac(allCy,"DPV",YTIME);
iPlantAvailRate(allCy,"ATHBMSWAS",YTIME)=iSuppPlantCapFac(allCy,"BMSWAS",YTIME);
iPlantAvailRate(allCy,"IGCCBMS",YTIME)=iSuppPlantCapFac(allCy,"BMSWAS",YTIME);
iPlantAvailRate(allCy,"PGAOTHREN",YTIME)= iSuppPlantCapFac(allCy,"OTHREN",YTIME);

iPlantAvailRate(allCy,"PGASHYD",YTIME)=iPlantAvailRate(allCy,"PGSHYD",ytime);
iPlantAvailRate(allCy,"PGAWND",YTIME)=iPlantAvailRate(allCy,"PGWND",ytime);
iPlantAvailRate(allCy,"PGASOL",YTIME)=iPlantAvailRate(allCy,"PGSOL",ytime);
iPlantAvailRate(allCy,"ATHBMSWAS",YTIME)=iPlantAvailRate(allCy,"CTHBMSWAS",ytime);

iUtilRateChpPlants(allCy,CHP,YTIME) = 0.5;
$ontext
loop YTIME$((ord(YTIME) gt TF+1) $(ord(YTIME) lt TF+6)) do
         iUtilRateChpPlants(allCy,CHP,YTIME) = (iUtilRateChpPlants(allCy,CHP,"2020")-iUtilRateChpPlants(allCy,CHP,"2018"))/5+iUtilRateChpPlants(allCy,CHP,YTIME-1);
endloop;
loop YTIME$((ord(YTIME) gt TF+6) $(ord(YTIME) lt TF+11)) do
         iUtilRateChpPlants(allCy,CHP,YTIME) = (iUtilRateChpPlants(allCy,CHP,"2025")-iUtilRateChpPlants(allCy,CHP,"2020"))/5+iUtilRateChpPlants(allCy,CHP,YTIME-1);
endloop;
loop YTIME$((ord(YTIME) gt TF+11) $(ord(YTIME) lt TF+16)) do
         iUtilRateChpPlants(allCy,CHP,YTIME) = (iUtilRateChpPlants(allCy,CHP,"2030")-iUtilRateChpPlants(allCy,CHP,"2025"))/5+iUtilRateChpPlants(allCy,CHP,YTIME-1);
endloop;
loop YTIME$((ord(YTIME) gt TF+16) $(ord(YTIME) lt TF+21)) do
         iUtilRateChpPlants(allCy,CHP,YTIME) = (iUtilRateChpPlants(allCy,CHP,"2035")-iUtilRateChpPlants(allCy,CHP,"2030"))/5+iUtilRateChpPlants(allCy,CHP,YTIME-1);
endloop;
loop YTIME$((ord(YTIME) gt TF+21) $(ord(YTIME) lt TF+41)) do
         iUtilRateChpPlants(allCy,CHP,YTIME) = (iUtilRateChpPlants(allCy,CHP,"2050")-iUtilRateChpPlants(allCy,CHP,"2030"))/20+iUtilRateChpPlants(allCy,CHP,YTIME-1);
endloop;
$offtext
**                   Power Generation
table iInstCapElecFuel(allCy,PGALL,PG1_set)	     "Installed capacity only for reporting by electricity from fuel (GW)"	
$ondelim
$include"./iInstCapElecFuel.csv"
$offdelim
;
table iEnvPolicies(POLICIES_SET,YTIME)	          "Environmental policies on emissions constraints  and subsidy on renewables (Mtn CO2)"
$ondelim
$include"./iEnvPolicies.csv"
$offdelim
;
table iDataPowGenCost(PGALL,PGECONCHAR)   "Data for power generation costs (various)"
$ondelim
$include"./iDataPowGenCost.csv"
$offdelim
;
iCarbValYrExog(YTIME)$an(YTIME) = iEnvPolicies("exogCV",YTIME);

                                                   
** Industry
iShrNonSubElecInTotElecDem(allCy,INDSE)  = iFuelConsIndSub(allCy,INDSE,"SHR_NSE");
iShrNonSubElecInTotElecDem(allCy,INDSE)$(iShrNonSubElecInTotElecDem(allCy,INDSE)>0.98) = 0.98;
**Domestic - Tertiary
iShrNonSubElecInTotElecDem(allCy,DOMSE) = iInitConsSubAndInitShaNonSubElec(allCy,DOMSE,"SHR_NSE");
iShrNonSubElecInTotElecDem(allCy,DOMSE)$(iShrNonSubElecInTotElecDem(allCy,DOMSE)>0.98) = 0.98;
**   Macroeconomic
$ontext

**  Prices

INTPRICE(WEF,YTIME)              = IntPricePRN(WEF,YTIME);
INTPRICEB(WEF,YTIME)             = IntPriceBPRN(WEF,YTIME);
$offtext

**  Transport Sector

iCapCostTech(runCy,TRANSE,EF,YTIME)$(ord(YTIME) eq TF-12)  = iDataTransTech(TRANSE,EF,"IC_05");
iCapCostTech(runCy,TRANSE,EF,YTIME)$(ord(YTIME) eq TF+8)   = iDataTransTech(TRANSE,EF,"IC_25");
iCapCostTech(runCy,TRANSE,EF,YTIME)$(ord(YTIME) eq TF+33)  = iDataTransTech(TRANSE,EF,"IC_50");

iFixOMCostTech(runCy,TRANSE,EF,YTIME)$(ord(YTIME) eq TF-12)= iDataTransTech(TRANSE,EF,"FC_05");
iFixOMCostTech(runCy,TRANSE,EF,YTIME)$(ord(YTIME) eq TF+8) = iDataTransTech(TRANSE,EF,"FC_25");
iFixOMCostTech(runCy,TRANSE,EF,YTIME)$(ord(YTIME) eq TF+33)= iDataTransTech(TRANSE,EF,"FC_50");

iCosTech(runCy,TRANSE,EF,TEA,YTIME)$(ord(YTIME) eq TF-12)= iDataTransTech(TRANSE,EF,"VC_05");
iCosTech(runCy,TRANSE,EF,TEA,YTIME)$(ord(YTIME) eq TF+8) = iDataTransTech(TRANSE,EF,"VC_25");
iCosTech(runCy,TRANSE,EF,TEA,YTIME)$(ord(YTIME) eq TF+33)= iDataTransTech(TRANSE,EF,"VC_50");

iTechLft(runCy,TRANSE,EF,TEA,YTIME)$(ord(YTIME)>sum(TFIRST,(ord(TFIRST)-3))) = iDataTransTech(TRANSE,EF,"LFT");
iAvgVehCapLoadFac(runCy,TRANSE,TRANSUSE,YTIME)$(ord(YTIME)>sum(TFIRST,(ord(TFIRST)-3)))= iCapDataLoadFacEachTransp(TRANSE,TRANSUSE);


**  Industrial Sector


iCapCostTech(runCy,INDSE,EF,YTIME)$(ord(YTIME) eq TF-12)= iDataIndTechnology(INDSE,EF,"IC_05");
iCapCostTech(runCy,INDSE,EF,YTIME)$(ord(YTIME) eq TF+8) = iDataIndTechnology(INDSE,EF,"IC_25");
iCapCostTech(runCy,INDSE,EF,YTIME)$(ord(YTIME) eq TF+33)= iDataIndTechnology(INDSE,EF,"IC_50");

iFixOMCostTech(runCy,INDSE,EF,YTIME)$(ord(YTIME) eq TF-12) = iDataIndTechnology(INDSE,EF,"FC_05");
iFixOMCostTech(runCy,INDSE,EF,YTIME)$(ord(YTIME) eq TF+8) = iDataIndTechnology(INDSE,EF,"FC_25");
iFixOMCostTech(runCy,INDSE,EF,YTIME)$(ord(YTIME) eq TF+33) = iDataIndTechnology(INDSE,EF,"FC_50");

iCosTech(runCy,INDSE,EF,TEA,YTIME)$(ord(YTIME) eq TF-12) = iDataIndTechnology(INDSE,EF,"VC_05");
iCosTech(runCy,INDSE,EF,TEA,YTIME)$(ord(YTIME) eq TF+8) = iDataIndTechnology(INDSE,EF,"VC_25");
iCosTech(runCy,INDSE,EF,TEA,YTIME)$(ord(YTIME) eq TF+33) = iDataIndTechnology(INDSE,EF,"VC_50");

iUsfEneConvSubTech(runCy,INDSE,EF,YTIME)$(ord(YTIME) <= TF-12)    = iDataIndTechnology(INDSE,EF,"USC_05");
iUsfEneConvSubTech(runCy,INDSE,EF,YTIME)$(ord(YTIME) eq TF+8) = iDataIndTechnology(INDSE,EF,"USC_25");
iUsfEneConvSubTech(runCy,INDSE,EF,YTIME)$(ord(YTIME) eq TF+33) = iDataIndTechnology(INDSE,EF,"USC_50");

iTechLft(runCy,INDSE,EF,TEA,YTIME)$(ord(YTIME)>(ordfirst-12)) = iDataIndTechnology(INDSE,EF,"LFT");


**  Domestic Sector


iCapCostTech(runCy,DOMSE,EF,YTIME)$(ord(YTIME) eq TF-12)= iDataDomTech(DOMSE,EF,"IC_05");
iCapCostTech(runCy,DOMSE,EF,YTIME)$(ord(YTIME) eq TF+8) = iDataDomTech(DOMSE,EF,"IC_25");
iCapCostTech(runCy,DOMSE,EF,YTIME)$(ord(YTIME) eq TF+33)= iDataDomTech(DOMSE,EF,"IC_50");

iFixOMCostTech(runCy,DOMSE,EF,YTIME)$(ord(YTIME) eq TF-12)= iDataDomTech(DOMSE,EF,"FC_05");
iFixOMCostTech(runCy,DOMSE,EF,YTIME)$(ord(YTIME) eq TF+8) = iDataDomTech(DOMSE,EF,"FC_25");
iFixOMCostTech(runCy,DOMSE,EF,YTIME)$(ord(YTIME) eq TF+33)= iDataDomTech(DOMSE,EF,"FC_50");

iCosTech(runCy,DOMSE,EF,TEA,YTIME)$(ord(YTIME) eq TF-12)= iDataDomTech(DOMSE,EF,"VC_05");
iCosTech(runCy,DOMSE,EF,TEA,YTIME)$(ord(YTIME) eq TF+8) = iDataDomTech(DOMSE,EF,"VC_25");
iCosTech(runCy,DOMSE,EF,TEA,YTIME)$(ord(YTIME) eq TF+33)= iDataDomTech(DOMSE,EF,"VC_50");

iUsfEneConvSubTech(runCy,DOMSE,EF,YTIME)$(ord(YTIME) <= TF-12)= iDataDomTech(DOMSE,EF,"USC_05");
iUsfEneConvSubTech(runCy,DOMSE,EF,YTIME)$(ord(YTIME) eq TF+8) = iDataDomTech(DOMSE,EF,"USC_25");
iUsfEneConvSubTech(runCy,DOMSE,EF,YTIME)$(ord(YTIME) eq TF+33)= iDataDomTech(DOMSE,EF,"USC_50");

iTechLft(runCy,DOMSE,EF,TEA,YTIME)$(ord(YTIME)>(ordfirst-12))  = iDataDomTech(DOMSE,EF,"LFT");

$ontext
NETWORKPARAM(NETWSET,INDDOM,NETEF)$(NETTECH(INDDOM,NETEF))                               = NetEffect(NETWSET,NETEF,"OTH");
NETWORKPARAM(NETWSET,INDDOM,"STE1AH2F")$(NETTECH(INDDOM,"STE1AH2F"))                     = NetEffect(NETWSET,"H2F","OTH");

NETWORKPARAM(NETWSET,TRANSE,NETEF)$(NETTECH(TRANSE,NETEF))                               = NetEffect(NETWSET,NETEF,"TRA");
NETWORKPARAM(NETWSET,TRANSE,EF)$(NETTECH(TRANSE,EF)$PLUGIN(EF) )                         = NetEffect(NETWSET,"ELC","TRA");
$offtext
**  Non Energy Sector and Bunkers


iCapCostTech(runCy,NENSE,EF,YTIME)$(ord(YTIME) eq TF-12)= iDataNonEneSec(NENSE,EF,"IC_05");
iCapCostTech(runCy,NENSE,EF,YTIME)$(ord(YTIME) eq TF+8) = iDataNonEneSec(NENSE,EF,"IC_25");
iCapCostTech(runCy,NENSE,EF,YTIME)$(ord(YTIME) eq TF+33)= iDataNonEneSec(NENSE,EF,"IC_50");

iFixOMCostTech(runCy,NENSE,EF,YTIME)$(ord(YTIME) eq TF-12)= iDataNonEneSec(NENSE,EF,"FC_05");
iFixOMCostTech(runCy,NENSE,EF,YTIME)$(ord(YTIME) eq TF+8) = iDataNonEneSec(NENSE,EF,"FC_25");
iFixOMCostTech(runCy,NENSE,EF,YTIME)$(ord(YTIME) eq TF+33)= iDataNonEneSec(NENSE,EF,"FC_50");

iCosTech(runCy,NENSE,EF,TEA,YTIME)$(ord(YTIME) eq TF-12)= iDataNonEneSec(NENSE,EF,"VC_05");
iCosTech(runCy,NENSE,EF,TEA,YTIME)$(ord(YTIME) eq TF+8) = iDataNonEneSec(NENSE,EF,"VC_25");
iCosTech(runCy,NENSE,EF,TEA,YTIME)$(ord(YTIME) eq TF+33)= iDataNonEneSec(NENSE,EF,"VC_50");

iUsfEneConvSubTech(runCy,NENSE,EF,YTIME)$(ord(YTIME) <= TF-12)= iDataNonEneSec(NENSE,EF,"USC_05");
iUsfEneConvSubTech(runCy,NENSE,EF,YTIME)$(ord(YTIME) eq TF+8) = iDataNonEneSec(NENSE,EF,"USC_25");
iUsfEneConvSubTech(runCy,NENSE,EF,YTIME)$(ord(YTIME) eq TF+33)= iDataNonEneSec(NENSE,EF,"USC_50");

iTechLft(runCy,NENSE,EF,TEA,YTIME)$(ord(YTIME)>(ordfirst-4)) = iDataNonEneSec(NENSE,EF,"LFT");
display TF;

loop YTIME$((ord(YTIME) gt TF-12) $(ord(YTIME) lt TF+3)) do
         iCapGrossCosPlanType(runCy,PGALL,YTIME) = (iCapGrossCosPlanType(runCy,PGALL,"2020")-
         iCapGrossCosPlanType(runCy,PGALL,"2011"))/15+iCapGrossCosPlanType(runCy,PGALL,YTIME-1);

         iFixGrosCostPlaType(runCy,PGALL,YTIME) = (iFixGrosCostPlaType(runCy,PGALL,"2020")-
         iFixGrosCostPlaType(runCy,PGALL,"2011"))/15+iFixGrosCostPlaType(runCy,PGALL,YTIME-1);

         iPlantAvailRate(runCy,PGALL,YTIME) = (iPlantAvailRate(runCy,PGALL,"2020")-
         iPlantAvailRate(runCy,PGALL,"2011"))/15+iPlantAvailRate(runCy,PGALL,YTIME-1);

         iVarGroCostPlaType(runCy,PGALL,YTIME) = (iVarGroCostPlaType(runCy,PGALL,"2020")-
         iVarGroCostPlaType(runCy,PGALL,"2011"))/15+iVarGroCostPlaType(runCy,PGALL,YTIME-1);

          iUsfEneConvSubTech(runCy,SBS,EF,YTIME) = (iUsfEneConvSubTech(runCy,SBS,EF,"2025")-iUsfEneConvSubTech(runCy,SBS,EF,"2005"))/
          20+iUsfEneConvSubTech(runCy,SBS,EF,YTIME-1);
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

         iUsfEneConvSubTech(runCy,SBS,EF,YTIME)     = (iUsfEneConvSubTech(runCy,SBS,EF,"2050")-iUsfEneConvSubTech(runCy,SBS,EF,"2025"))/
         25+iUsfEneConvSubTech(runCy,SBS,EF,YTIME-1);
endloop;


**  Power Generation


iCapGrossCosPlanType(runCy,PGALL,YTIME)$(ord(YTIME) eq TF-4)  = iDataPowGenCost(PGALL,"IC_05");
iCapGrossCosPlanType(runCy,PGALL,YTIME)$(ord(YTIME) eq TF+11) = iDataPowGenCost(PGALL,"IC_20");
iCapGrossCosPlanType(runCy,PGALL,YTIME)$(ord(YTIME) eq TF+41) = iDataPowGenCost(PGALL,"IC_50");

iFixGrosCostPlaType(runCy,PGALL,YTIME)$(ord(YTIME) eq TF-4)  = iDataPowGenCost(PGALL,"FC_05");
iFixGrosCostPlaType(runCy,PGALL,YTIME)$(ord(YTIME) eq TF+11) = iDataPowGenCost(PGALL,"FC_20");
iFixGrosCostPlaType(runCy,PGALL,YTIME)$(ord(YTIME) eq TF+41) = iDataPowGenCost(PGALL,"FC_50");

iVarGroCostPlaType(runCy,PGALL,YTIME)$(ord(YTIME) eq TF-4)  = iDataPowGenCost(PGALL,"VC_05");
iVarGroCostPlaType(runCy,PGALL,YTIME)$(ord(YTIME) eq TF+11) = iDataPowGenCost(PGALL,"VC_20");
iVarGroCostPlaType(runCy,PGALL,YTIME)$(ord(YTIME) eq TF+41) = iDataPowGenCost(PGALL,"VC_50");

iTechLftPlaType(runCy,PGALL) = iDataPowGenCost(PGALL, "LFT");

iPlantAvailRate(runCy,PGALL,"2005") = iDataPowGenCost(PGALL,"AVAIL_05");
iPlantAvailRate(runCy,PGALL,"2020") = iDataPowGenCost(PGALL,"AVAIL_20");
iPlantAvailRate(runCy,PGALL,"2050") = iDataPowGenCost(PGALL,"AVAIL_50");

iPlantEffByType(runCy,PGALL,"2005") = iDataPowGenCost(PGALL,"EFF_05");
iPlantEffByType(runCy,PGALL,"2020") = iDataPowGenCost(PGALL,"EFF_20");
iPlantEffByType(runCy,PGALL,"2050") = iDataPowGenCost(PGALL,"EFF_50");

loop YTIME$((ord(YTIME) gt TF-4) $(ord(YTIME) lt TF+11)) do
         iCapGrossCosPlanType(runCy,PGALL,YTIME) = (iCapGrossCosPlanType(runCy,PGALL,"2020")-iCapGrossCosPlanType(runCy,PGALL,"2005"))/15+iCapGrossCosPlanType(runCy,PGALL,YTIME-1);
         iFixGrosCostPlaType(runCy,PGALL,YTIME) = (iFixGrosCostPlaType(runCy,PGALL,"2020")-iFixGrosCostPlaType(runCy,PGALL,"2005"))/15+iFixGrosCostPlaType(runCy,PGALL,YTIME-1);
         iVarGroCostPlaType(runCy,PGALL,YTIME) = (iVarGroCostPlaType(runCy,PGALL,"2020")-iVarGroCostPlaType(runCy,PGALL,"2005"))/15+iVarGroCostPlaType(runCy,PGALL,YTIME-1);
         iPlantAvailRate(runCy,PGALL,YTIME) = (iPlantAvailRate(runCy,PGALL,"2020")-iPlantAvailRate(runCy,PGALL,"2005"))/15+iPlantAvailRate(runCy,PGALL,YTIME-1);
         iPlantEffByType(runCy,PGALL,YTIME) = (iPlantEffByType(runCy,PGALL,"2020")-iPlantEffByType(runCy,PGALL,"2005"))/15+iPlantEffByType(runCy,PGALL,YTIME-1);
endloop;


loop YTIME$((ord(YTIME) gt TF+11) $(ord(YTIME) lt TF+41)) do
         iCapGrossCosPlanType(runCy,PGALL,YTIME) = (iCapGrossCosPlanType(runCy,PGALL,"2050")-iCapGrossCosPlanType(runCy,PGALL,"2020"))/30+iCapGrossCosPlanType(runCy,PGALL,YTIME-1);
         iFixGrosCostPlaType(runCy,PGALL,YTIME) = (iFixGrosCostPlaType(runCy,PGALL,"2050")-iFixGrosCostPlaType(runCy,PGALL,"2020"))/30+iFixGrosCostPlaType(runCy,PGALL,YTIME-1);
         iVarGroCostPlaType(runCy,PGALL,YTIME) = (iVarGroCostPlaType(runCy,PGALL,"2050")-iVarGroCostPlaType(runCy,PGALL,"2020"))/30+iVarGroCostPlaType(runCy,PGALL,YTIME-1);
         iPlantAvailRate(runCy,PGALL,YTIME) = (iPlantAvailRate(runCy,PGALL,"2050")-iPlantAvailRate(runCy,PGALL,"2020"))/30+iPlantAvailRate(runCy,PGALL,YTIME-1);
         iPlantEffByType(runCy,PGALL,YTIME) = (iPlantEffByType(runCy,PGALL,"2050")-iPlantEffByType(runCy,PGALL,"2020"))/30+iPlantEffByType(runCy,PGALL,YTIME-1);
endloop;


iCO2CaptRate(runCy,PGALL,YTIME)$(ord(YTIME)>(ordfirst-4))  =  iDataPowGenCost(PGALL,"CR");

iEffDHPlants(runCy,EFS,YTIME)$(ord(YTIME)>(ordfirst-4))  = sum(PGEFS$sameas(EFS,PGEFS),iParDHEfficiency(PGEFS,"2005"));



** CHP economic and technical data initialisation for electricity production
table iDataChpPowGen(EF,YTIME,CHPPGSET)   "Data for power generation costs (various)"
$ondelim
$include"./iDataChpPowGen.csv"
$offdelim
;
iFixOandMCosChp(runCy,DSBS,CHP,YTIME) = iDataChpPowGen(CHP,YTIME,"IC");
iFixOMCostPerChp(runCy,DSBS,CHP,YTIME) = iDataChpPowGen(CHP,YTIME,"FC");
iCosPerChp(runCy,DSBS,CHP,YTIME) = iDataChpPowGen(CHP,YTIME,"VOM");
iLifChpPla(runCy,DSBS,CHP) = iDataChpPowGen(CHP,"2005","LFT");
iAvailRateChp(runCy,DSBS,CHP) = iDataChpPowGen(CHP,"2005","AVAIL");
iBoiEffChp(runCy,CHP,YTIME) = iDataChpPowGen(CHP,YTIME,"iBoiEffChp");

         !! Interpolation for years in between


loop YTIME$((ord(YTIME) gt TF-12) $(ord(YTIME) lt TF+3)) do
         iFixOandMCosChp(runCy,DSBS,CHP,YTIME) = (iFixOandMCosChp(runCy,DSBS,CHP,"2020")-iFixOandMCosChp(runCy,DSBS,CHP,"2005"))/15+iFixOandMCosChp(runCy,DSBS,CHP,YTIME-1);
         iFixOMCostPerChp(runCy,DSBS,CHP,YTIME) = (iFixOMCostPerChp(runCy,DSBS,CHP,"2020")-iFixOMCostPerChp(runCy,DSBS,CHP,"2005"))/15+iFixOMCostPerChp(runCy,DSBS,CHP,YTIME-1);
         iCosPerChp(runCy,DSBS,CHP,YTIME) = (iCosPerChp(runCy,DSBS,CHP,"2020")-iCosPerChp(runCy,DSBS,CHP,"2005"))/15+iCosPerChp(runCy,DSBS,CHP,YTIME-1);
         iBoiEffChp(runCy,CHP,YTIME) = (iBoiEffChp(runCy,CHP,"2020")-iBoiEffChp(runCy,CHP,"2005"))/15+iBoiEffChp(runCy,CHP,YTIME-1);
endloop;


loop YTIME$((ord(YTIME) gt TF+3) $(ord(YTIME) lt TF+33)) do
         iFixOandMCosChp(runCy,DSBS,CHP,YTIME) = (iFixOandMCosChp(runCy,DSBS,CHP,"2050")-iFixOandMCosChp(runCy,DSBS,CHP,"2020"))/30+iFixOandMCosChp(runCy,DSBS,CHP,YTIME-1);
         iFixOMCostPerChp(runCy,DSBS,CHP,YTIME) = (iFixOMCostPerChp(runCy,DSBS,CHP,"2050")-iFixOMCostPerChp(runCy,DSBS,CHP,"2020"))/30+iFixOMCostPerChp(runCy,DSBS,CHP,YTIME-1);
         iCosPerChp(runCy,DSBS,CHP,YTIME) = (iCosPerChp(runCy,DSBS,CHP,"2050")-iCosPerChp(runCy,DSBS,CHP,"2020"))/30+iCosPerChp(runCy,DSBS,CHP,YTIME-1);
         iBoiEffChp(runCy,CHP,YTIME) = (iBoiEffChp(runCy,CHP,"2050")-iBoiEffChp(runCy,CHP,"2020"))/30+iBoiEffChp(runCy,CHP,YTIME-1);
endloop;

**  Policies for climate change and renewables

EMMCONSTR("TRADE",YTIME)$an(YTIME)= POLICIES("TRADE",YTIME);
EMMCONSTRT(YTIME)$an(YTIME) = POLICIES("OPT",YTIME);
RESCONSTR(YTIME)$an(YTIME) = POLICIES("REN",YTIME);
EFFCONSTR(YTIME)$an(YTIME) = POLICIES("EFF",YTIME);
exogCVp(YTIME)$an(YTIME)   = POLICIES("exogCV",YTIME);

$ontext
**  Energy productivity indices and R&D indices

EN_PRD_INDX(runCy,SBS,YTIME)$an(YTIME)=EN_PRD_INDX_PRN(runCy,SBS,YTIME);
CCRES(PGALL,YTIME)$AN(YTIME)=CCRES_PRN(PGALL,YTIME)  ;
FOMRES(PGALL,YTIME)$AN(YTIME)=FOMRES_PRN(PGALL,YTIME) ;
VOMRES(PGALL,YTIME)$AN(YTIME)=VOMRES_PRN(PGALL,YTIME)  ;
EFFRES(PGALL,YTIME)$AN(YTIME)=EFFRES_PRN(PGALL,YTIME);
NUCRES(YTIME)$an(ytime)=NUCRES_PRN("RES",YTIME);
$offtext
* Update efficiencies according to energy productivity index
iPlantEffByType(runCy,PGALL,YTIME)$(an(ytime) )= iPlantEffByType(runCy,PGALL,YTIME) / iEneProdRDscenarios(runCy,"pg",ytime);
iEffDHPlants(runCy,EF,YTIME)$(an(ytime) )= iEffDHPlants(runCy,EF,YTIME) / iEneProdRDscenarios(runCy,"pg",ytime);

* Update capital costs, fom costs and vom costs according to RD index (used only in RD scenario otherwise is set to 1)

iCapGrossCosPlanType(runCy,PGALL,YTIME)$AN(YTIME)=iCapGrossCosPlanType(runCy,PGALL,YTIME)*iCapCostRnDPowGen(PGALL,YTIME);
iFixGrosCostPlaType(runCy,PGALL,YTIME)$AN(YTIME)=iFixGrosCostPlaType(runCy,PGALL,YTIME)*iFixedOnMCostRnDPowGen(PGALL,YTIME);
iVarGroCostPlaType(runCy,PGALL,YTIME)$AN(YTIME)=iVarGroCostPlaType(runCy,PGALL,YTIME)*iVarOnMCostRnDPowGen(PGALL,YTIME);
iCapGrossCosPlanType(runCy,"PGANUC",YTIME)$AN(YTIME)=iCapGrossCosPlanType(runCy,"PGANUC",YTIME)*iNucCapCostRed(YTIME);
