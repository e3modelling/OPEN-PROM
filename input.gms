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
* FIXME: derive elasticities for all countries, not just for MAR
* author=giannou
iElastA(allCy,SBS,ETYPES,YTIME) = iElastA("MAR",SBS,ETYPES,YTIME);
table iResActiv(allCy,TRANSE,YTIME) "Residuals on transport activity ()"
$ondelim
$include "./iResActiv.csv"
$offdelim
;
* FIXME: derive elasticities per country
* author=giannou
table iElastNonSubElecData(SBS,ETYPES,YTIME) "Elasticities of Non Substitutable Electricity (1)"
$ondelim
$include "./iElastNonSubElecData.csv"
$offdelim
;
iElastNonSubElec(allCy,SBS,ETYPES,YTIME) = iElastNonSubElecData(SBS,ETYPES,YTIME);
table iDisc(allCy,SBS,YTIME) "Discount rates per subsector ()"
$ondelim
$include "./iDisc.csv"
$offdelim
;
* FIXME: iCo2EmiFacAllSbs(EF) derive the emission factors with mrprom
* author=giannou
parameter iCo2EmiFacAllSbs(EF) "CO2 emission factors (kgCO2/kgoe fuel burned)" /
LGN 4.15330622,
HCL 3.941453651,
SLD 4.438008647,
GSL 2.872144882,
GDO 3.068924588,
LPG 2.612562612,
KRS 2.964253636,
RFO 3.207089028,
OLQ 3.207089028,
NGS 2.336234395,
OGS 3.207089028,
BMSWAS 0/;

iCo2EmiFac(allCy,SBS,EF,YTIME) = iCo2EmiFacAllSbs(EF);
iCo2EmiFac(allCy,"IS","HCL",YTIME)   = iCo2EmiFacAllSbs("SLD"); !! This is the assignment for coke
table iDataPassCars(allCy,GompSet1,Gompset2)        "Initial Data for Passenger Cars ()"
$ondelim
$include "./iDataPassCars.csv"
$offdelim
;

iDataPassCars(allCy,"PC","S1") = 1.0;
iSigma(allCy,"S1") = iDataPassCars(allCy,"PC","S1");
iDataPassCars(allCy,"PC","S2") = -0.01;
iSigma(allCy,"S2") = iDataPassCars(allCy,"PC","S2");
iDataPassCars(allCy,"PC","S3") = 6.5;
iSigma(allCy,"S3") = iDataPassCars(allCy,"PC","S3");
iPassCarsMarkSat(allCy) = iDataPassCars(allCy,"PC","SAT");
iGdpPassCarsMarkExt(allCy) = iDataPassCars(allCy,"PC","MEXTV");
iPassCarsScrapRate(allCy)  = iDataPassCars(allCy,"PC", "SCR");
table iInitSpecFuelCons(allCy,TRANSE,TTECH,EF,YTIME)        "Initial Specific fuel consumption ()"
$ondelim
$include "./iInitSpecFuelCons.csv"
$offdelim
;

* FIXME: iDisc("MAR",SBS,YTIME) values for all countries equal to  values of MAR.
* author=redmonkeycloud
iDisc(allCy,SBS,YTIME) = iDisc("MAR",SBS,YTIME) ;

* FIXME: iInitSpecFuelCons("MAR",TRANSE,TTECH,EF,"2017") initial values for all countries equal to initial values of MAR.
* author=redmonkeycloud
iInitSpecFuelCons(allCy,TRANSE,TTECH,EF,YTIME) = iInitSpecFuelCons("MAR",TRANSE,TTECH,EF,"2017"); 
iSpeFuelConsCostBy(allCy,TRANSE,TTECH,TEA,EF) = iInitSpecFuelCons("MAR",TRANSE,TTECH,EF,"2017");

table iElaSub(allCy,DSBS)                           "Elasticities by subsectors (1)"
$ondelim
$include "./iElaSub.csv"
$offdelim
;
iElaSub(allCy,DSBS) = iElaSub("MAR",DSBS);
parameter iConsSizeDistHeat(conSet)               "Consumer sizes for district heating (1)" /smallest 0.425506805,
                                                                                             modal    0.595709528,
                                                                                             largest 0.833993339/;

table iCapCostTechTr(allCy,TRANSE,EF,YTIME)      "Capital Cost of technology for transport (kEuro2005/vehicle)" 
$ondelim$include "./iCapCostTechTr.csv"
$offdelim
;
table iRateLossesFinCons(allCy,EF,YTIME)               "Rate of losses over Available for Final Consumption (1)"
$ondelim
$include "./iRateLossesFinCons.csv"
$offdelim
;
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
table iCO2SeqData(CO2SEQELAST,YTIME)	       "Data for CO2 sequestration (1)" 
$ondelim
$include"./iCO2SeqData.csv"
$offdelim
;
iElastCO2Seq(allCy,CO2SEQELAST) = sum(tfirst,iCO2SeqData(CO2SEQELAST,TFIRST));

*Sources for vehicle lifetime:
*US Department of Transportation, International Union of Railways, Statista, EU CORDIS
table iDataTransTech (TRANSE, EF, ECONCHAR, YTIME) "Technoeconomic characteristics of transport (various)"
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
* FIXME: check if country-specific data is needed; move to mrprom
* author=giannou
table iIndCharData(allCy,INDSE,Indu_Scon_Set)               "Industry sector charactetistics (various)"
$ondelim
$include"./iIndCharData.csv"
$offdelim
;
iIndChar(allCy,INDSE,Indu_Scon_Set) = iIndCharData("MAR",INDSE,Indu_Scon_Set);
table iInitConsSubAndInitShaNonSubElec(allCy,DOMSE,Indu_Scon_Set)      "Initial Consumption per Subsector and Initial Shares of Non Substitutable Electricity in Total Electricity Demand (Mtoe)"
$ondelim
$include"./iInitConsSubAndInitShaNonSubElec.csv"
$offdelim
;
iShrHeatPumpElecCons(allCy,INDSE) = iIndChar(allCy,INDSE,"SH_HPELC");
iShrHeatPumpElecCons(allCy,DOMSE) = iInitConsSubAndInitShaNonSubElec(allCy,DOMSE,"SH_HPELC");
*iTechLft(allCy,TRANSE,EF,TEA,YTIME)$(ord(YTIME)>sum(TFIRST,(ord(TFIRST)-3))) = iDataTransTech(TRANSE,EF,"LFT");
*iTechLft(allCy,INDSE,EF,TEA,YTIME)$(ord(YTIME)>(ordfirst-12)) = iDataIndTechnology(INDSE,EF,"LFT");
*iTechLft(allCy,DOMSE,EF,TEA,YTIME)$(ord(YTIME)>(ordfirst-12)) = iDataDomLft(DOMSE,EF,"LFT");
*iTechLft(allCy,NENSE,EF,TEA,YTIME)$(ord(YTIME)>(ordfirst-4))  = iDataNonEneLft(NENSE,EF,"LFT");
iExogDemOfBiomass(allCy,DOMSE,YTIME) = 0;
iElastCO2Seq(allCy,CO2SEQELAST) = iCO2SeqData(CO2SEQELAST,"%fBaseY%");
iRatioImpFinElecDem(runCy,YTIME)$an(YTIME) = iSuppRefCapacity(runCy,"ELC_IMP",YTIME);
iFuelExprts(runCy,EFS,YTIME) = iSuppExports(runCy,EFS,YTIME);
iRatePriProTotPriNeeds(runCy,PPRODEF,YTIME) = iSuppRatePrimProd(runCy,PPRODEF,YTIME);
iResHcNgOilPrProd(runCy,"HCL",YTIME)$an(YTIME)   = iSupResRefCapacity(runCy,"HCL_PPROD",YTIME);
iResHcNgOilPrProd(runCy,"NGS",YTIME)$an(YTIME)   = iSupResRefCapacity(runCy,"NGS_PPROD",YTIME);
iResHcNgOilPrProd(runCy,"CRO",YTIME)$an(YTIME)   = iSupResRefCapacity(runCy,"OIL_PPROD",YTIME);
iResFeedTransfr(runCy,YTIME)$an(YTIME) = iSupResRefCapacity(runCy,"FEED_RES",YTIME);
iFeedTransfr(runCy,EFS,YTIME) = iSuppTransfers(runCy,EFS,YTIME);
iRateEneBranCons(allCy,EFS,YTIME)= iSupRateEneBranCons(allCy,EFS,YTIME);
iResTransfOutputRefineries(runCy,EFS,YTIME) = iSupTrnasfOutputRefineries(runCy,EFS,YTIME);
iRefCapacity(runCy,YTIME)= iSuppRefCapacity(runCy,"REF_CAP",YTIME);
iResRefCapacity(runCy,YTIME) = iSupResRefCapacity(runCy,"REF_CAP_RES",YTIME);
iTransfInpGasworks(runCy,EFS,YTIME)= iSuppTransfInputPatFuel(EFS,YTIME);
iShareFueTransfInput(runCy,EFS)$sum(EF$EFS(EF),iTransfInpGasworks(runCy,EF,"%fBaseY%")) =  iTransfInpGasworks(runCy,EFS,"%fBaseY%") / sum(EF$EFS(EF),iTransfInpGasworks(runCy,EF,"%fBaseY%"));
*VDistrLosses.FX(runCy,EFS,TT)$PERIOD(TT) = VDistrLosses.L(runCy,EFS,TT);

table iLoadFactorAdjMxm(allCy,VARIOUS_LABELS,YTIME)               "Parameter for load factor adjustment iMxmLoadFacElecDem (1)"
$ondelim
$include"./iLoadFactorAdjMxm.csv"
$offdelim
;
iBslCorrection(allCy,YTIME)$an(YTIME) = iLoadFactorAdjMxm(allCy,"AMAXBASE",YTIME);
iMxmLoadFacElecDem(allCy,YTIME)$an(YTIME) = iLoadFactorAdjMxm(allCy,"MAXLOADSH",YTIME);

parameter iLoadFacElecDem(DSBS)    "Load factor of electricity demand per sector (1)" /
IS 	0.92,
NF 	0.94,
CH 	0.83,
BM 	0.82,
PP 	0.74,
FD 	0.65,
EN 	0.7,
TX 	0.61,
OE 	0.92,
OI 	0.67,
SE 	0.64,
AG 	0.52,
HOU	0.72,
PC 	0.7,
*PB 	0.7,
PT 	0.62,
*PN 	0.7,
PA 	0.7,
GU 	0.7,
GT 	0.62,
GN 	0.7,
BU 	0.7,
PCH	0.83,
NEN	0.83 / ;

*Calculation of consumer size groups and their distribution function
iNcon(TRANSE)$(sameas(TRANSE,"PC") or sameas(TRANSE,"GU")) = 10; !! 11 different consumer size groups for cars and trucks
iNcon(TRANSE)$(not (sameas(TRANSE,"PC") or sameas(TRANSE,"GU"))) = 1; !! 2 different consumer size groups for inland navigation, trains, busses and aviation
iNcon(INDSE) = 10; !! 11 different consumer size groups for industrial sectors
iNcon(DOMSE) = 10; !! 11 different consumer size groups for domestic and tertiary sectors
iNcon(NENSE) = 10; !! 11 different consumer size groups for non energy uses
iNcon("BU") = 2;   !! ... except bunkers .


* 11 vehicle mileage groups
* 0.952 turned out to be a (constant) ratio between modal and average mileage through iterations in Excel


iAnnCons(runCy,'PC','smallest')= 0.5 * 0.952 * iTransChar(runCy,"KM_VEH","%fBaseY%") * 1000 * 1E-6;
iAnnCons(runCy,'PC' ,'modal')=0.952 * iTransChar(runCy,"KM_VEH","%fBaseY%") * 1000 * 1E-6;
iAnnCons(runCy,'PC' ,'largest')= 4 * 0.952 * iTransChar(runCy,"KM_VEH","%fBaseY%") * 1000 * 1E-6;


* modal value is assumed to be 2 tonnes/vehicle, min = 1/3*modal and max = 10*modal tkm.
* 0.706 is the constant ratio of modal/average tkm through iterations in Excel

iAnnCons(runCy,'GU','smallest')=0.5 * 0.706 * iTransChar(runCy,"KM_VEH_TRUCK","%fBaseY%")* 1000 * 2 / 3  * 1E-6;
iAnnCons(runCy,'GU','modal')=0.706 * iTransChar(runCy,"KM_VEH_TRUCK","%fBaseY%") * 1000 * 2  * 1E-6;
iAnnCons(runCy,'GU','largest')=4 * 0.706 * iTransChar(runCy,"KM_VEH_TRUCK","%fBaseY%") * 1000 * 2 * 10  * 1E-6;

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

iAnnCons(runCy,DOMSE,"smallest") = iConsSizeDistHeat("smallest")  ;
iAnnCons(runCy,DOMSE,"largest") = iConsSizeDistHeat("largest") ;
iAnnCons(runCy,DOMSE,"modal") = iConsSizeDistHeat("modal");

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

table iResTotCapMxmLoad(allCy,PGRES,YTIME)              "Residuals for total capacity and maximum load (1)"	
$ondelim
$include"./iResTotCapMxmLoad.csv"
$offdelim
;
iResMargTotAvailCap(allCy,PGRES,YTIME)$an(YTIME) = iResTotCapMxmLoad(allCy,PGRES,YTIME);
*$ontext
table iInvCost(PGALL,YTIME)             "Capital gross cost per plant type (kEuro2005/KW)"
$ondelim
$include"./iInvCost.csv"
$offdelim
;
table iVarCost(PGALL,YTIME)             "Variable gross cost other than fuel per Plant Type (Euro2005/KW)"
$ondelim
$include"./iVarCost.csv"
$offdelim
;

table iFixOandMCost(PGALL,YTIME)    "Fixed O&M Gross Cost per Plant Type (Euro2005/KW)"
$ondelim
$include"./iFixOandMCost.csv"
$offdelim
;

table iAvailRate(PGALL,YTIME)	    "Plant availability rate (1)"
$ondelim
$include"./iAvailRate.csv"
$offdelim
;
table iDataElecProd(allCy,PGALL,YTIME) "Electricity production past years (GWh)"
$ondelim
$include"./iDataElecProd.csv"
$offdelim
;

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
iDistrLosses(allCy,EFS,YTIME) = iDataDistrLosses(allCy,EFS,YTIME);
table iDataTransfOutputRef(allCy,EF,YTIME)	    "Data for Other transformation output  (Mtoe)"
$ondelim
$include"./iDataTransfOutputRef.csv"
$offdelim
;
table iFuelConsTRANSE(allCy,TRANSE,EF,YTIME)	 "Fuel consumption (Mtoe)"
$ondelim
$include"./iFuelConsTRANSE.csv"
$offdelim
;
iTransfOutputRef(allCy,EFS,YTIME)$(not An(YTIME)) = iDataTransfOutputRef(allCy,EFS,YTIME);
iFuelConsTRANSE(allCy,TRANSE,EF,YTIME)$(SECTTECH(TRANSE,EF) $(iFuelConsTRANSE(allCy,TRANSE,EF,YTIME)<=0)) = 1e-6;
iFuelConsPerFueSub(allCy,TRANSE,EF,YTIME) = iFuelConsTRANSE(allCy,TRANSE,EF,YTIME);
table iFuelConsINDSE(allCy,INDSE,EF,YTIME)	 "Fuel consumption of industry subsector (Mtoe)"
$ondelim
$include"./iFuelConsINDSE.csv"
$offdelim
;
iFuelConsINDSE(allCy,INDSE,EF,YTIME)$(SECTTECH(INDSE,EF) $(iFuelConsINDSE(allCy,INDSE,EF,YTIME)<=0)) = 1e-6;
table iFuelConsDOMSE(allCy,DOMSE,EF,YTIME)	 "Fuel consumption of domestic subsector (Mtoe)"
$ondelim
$include"./iFuelConsDOMSE.csv"
$offdelim
;
iFuelConsDOMSE(allCy,DOMSE,EF,YTIME)$(SECTTECH(DOMSE,EF) $(iFuelConsDOMSE(allCy,DOMSE,EF,YTIME)<=0)) = 1e-6;
table iFuelConsNENSE(allCy,NENSE,EF,YTIME)	 "Fuel consumption of non energy and bunkers (Mtoe)"
$ondelim
$include"./iFuelConsNENSE.csv"
$offdelim
;
* FIXME: Include $(not An(YTIME)) to iFuelConsPerFueSub when necessary (removing for now)
* author=derevirn
iFuelConsNENSE(allCy,NENSE,EF,YTIME)$(SECTTECH(NENSE,EF) $(iFuelConsNENSE(allCy,NENSE,EF,YTIME)<=0)) = 1e-6;
iFuelConsPerFueSub(allCy,INDSE,EF,YTIME) = iFuelConsINDSE(allCy,INDSE,EF,YTIME);
iFuelConsPerFueSub(allCy,DOMSE,EF,YTIME) = iFuelConsDOMSE(allCy,DOMSE,EF,YTIME);
iFuelConsPerFueSub(allCy,NENSE,EF,YTIME) = iFuelConsNENSE(allCy,NENSE,EF,YTIME);
iFinEneCons(runCy,EFS,YTIME) = sum(INDDOM,
                         sum(EF$(EFtoEFS(EF,EFS) $SECTTECH(INDDOM,EF)), iFuelConsPerFueSub(runCy,INDDOM,EF,YTIME)))
                       +
                       sum(TRANSE,
                         sum(EF$(EFtoEFS(EF,EFS) $SECTTECH(TRANSE,EF) $(not plugin(EF)) ), iFuelConsPerFueSub(runCy,TRANSE,EF,YTIME)));
iGrossCapCosSubRen(runCy,PGALL,YTIME)=iInvCost(PGALL,YTIME);
loop(runCy,PGALL,YTIME)$AN(YTIME) DO
         abort $(iGrossCapCosSubRen(runCy,PGALL,YTIME)<0) "CAPITAL COST IS NEGATIVE", iGrossCapCosSubRen
ENDLOOP;

*VTotElecGenCap.FX(runCy,YTIME)$(not An(YTIME)) = iTotAvailCapBsYr(runCy);
*VTotElecGenCapEst.L(runCy,TT) = iResMargTotAvailCap(runCy,"TOT_CAP_RES",TT) * VTotElecGenCap.L(runCy,TT-1)
*        * VElecPeakLoad.L(runCy,TT)/VElecPeakLoad.L(runCy,TT-1);
table iDataElecSteamGen(allCy,PGOTH,YTIME)	          "Various Data related to electricity and steam generation (1)"
$ondelim
$include"./iDataElecSteamGen.csv"
$offdelim
;
iTotAvailCapBsYr(allCy) = sum(tfirst,iDataElecSteamGen(allCy,"TOTCAP",TFIRST))+sum(tfirst,iDataElecSteamGen(allCy,"CHP_CAP",TFIRST))*0.85;
iElecImp(allCy,YTIME)=0;

iScaleEndogScrap(allCy,PGALL,YTIME) = iPremReplacem(allCy,PGALL);
table iDecomPlants(allCy,PGALL,PG1_set)	            "Decomissioning Plants (MW)"
$ondelim
$include"./iDecomPlants.csv"
$offdelim
;
iPlantDecomSched(allCy,PGALL,YTIME) = iDecomPlants(allCy,PGALL,"DEC_10");

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
iDecInvPlantSched(allCy,PGALL,"2034") = iInvPlants(allCy,PGALL,"INV_15");
iDecInvPlantSched(allCy,PGALL,"2018") = iInvPlants(allCy,PGALL,"INV_18");
iDecInvPlantSched(allCy,PGALL,"2019") = iInvPlants(allCy,PGALL,"INV_19");

table iCummMxmInstRenCap(allCy,PGRENEF,YTIME)	 "Cummulative maximum potential installed Capacity for Renewables (GW)"
$ondelim
$include"./iMaxResPot.csv"
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
$include"./iMinResPot.csv"
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

$ontext
table iMatureFacLoad(allCy,PGALL,YTIME)	 "Maturty factors on Load (1)"
$ondelim
$include"./iMatureFacLoad.csv"
$offdelim
;
$offtext 

* FIXME: Temporarily setting maturity factors related to plant dispatching equal to 1.
* author=derevirn
iMatureFacPlaDisp(allCy,PGALL,YTIME)$an(YTIME) = 1;
iCO2CaptRate(runCy,PGALL,YTIME) = 0; 

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
* FIXME: iContrElecPrice values will be pinned down during model calibration, using MAR values for now
* author=giannou
iFacElecPriConsu(allCy,ELCPCHAR,YTIME)$an(YTIME) = iContrElecPrice("MAR",ELCPCHAR,YTIME);
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
iPriceReform(runCy,"PG",EF,YTIME)=iDataPriceReform(runCy,"INDSE1",EF,YTIME) ;
table iDataPriceTargets(allCy,AGSECT,EF,YTIME)	 "Data for the Price targets (1)"
$ondelim
$include"./iDataPriceTargets.csv"
$offdelim
;
iPriceTragets(runCy,INDSE1(SBS),EF,YTIME)=iDataPriceTargets(runCy,"INDSE1",EF,"2030") ;
iPriceTragets(runCy,DOMSE1(SBS),EF,YTIME)=iDataPriceTargets(runCy,"DOMSE1",EF,"2030") ;
iPriceTragets(runCy,NENSE1(SBS),EF,YTIME)=iDataPriceTargets(runCy,"NENSE1",EF,"2030") ;
iPriceTragets(runCy,TRANS1(SBS),EF,YTIME)=iDataPriceTargets(runCy,"TRANS1",EF,"2030") ;
iPriceTragets(runCy,"PG",EF,YTIME)=iDataPriceTargets(runCy,"INDSE1",EF,"2030") ;

*SPECIFIC CASE FOR NATURAL GAS PRICES!!!

iPriceTragets("RAS",INDSE1(SBS),"NGS",YTIME)=iDataPriceTargets("RAS","INDSE1","NGS",YTIME) ;
iPriceTragets("RAS",DOMSE1(SBS),"NGS",YTIME)=iDataPriceTargets("RAS","DOMSE1","NGS",YTIME) ;
iPriceTragets("RAS",NENSE1(SBS),"NGS",YTIME)=iDataPriceTargets("RAS","NENSE1","NGS",YTIME) ;
iPriceTragets("RAS","PG","NGS",YTIME)=iDataPriceTargets("RAS","INDSE1","NGS",YTIME) ;

iPriceTragets("MAR",INDSE1(SBS),"NGS",YTIME)=iDataPriceTargets("MAR","INDSE1","NGS",YTIME) ;
iPriceTragets("MAR",DOMSE1(SBS),"NGS",YTIME)=iDataPriceTargets("MAR","DOMSE1","NGS",YTIME) ;
iPriceTragets("MAR",NENSE1(SBS),"NGS",YTIME)=iDataPriceTargets("MAR","NENSE1","NGS",YTIME) ;
iPriceTragets("MAR","PG","NGS",YTIME)=iDataPriceTargets("MAR","INDSE1","NGS",YTIME) ;
* FIXME: iHydrogenPri should be computed with mrprom
* author=giannou
iHydrogenPri(allCy,SBS,YTIME)=4.3;
table iFuelPrice(allCy,SBS,EF,YTIME)	 "Prices of fuels per subsector (k$2015/toe)"
$ondelim
$include"./iFuelPrice.csv"
$offdelim
;
iFuelPrice(allCy,SBS,EF,YTIME) = iFuelPrice(allCy,SBS,EF,YTIME)/1000; !! change units $15 -> k$15
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
iTotEneBranchCons(allCy,EFS,YTIME) = iDataConsEneBranch(allCy,EFS,YTIME);
table iDataImports(allCy,EF,YTIME)	           "Data for imports (Mtoe)"
$ondelim
$include"./iDataImports.csv"
$offdelim
;
iFuelImports(allCy,EFS,YTIME)$(not An(YTIME)) = iDataImports(allCy,EFS,YTIME);

iNetImp(allCy,EFS,YTIME) = iDataImports(allCy,"ELC",YTIME);

iGrosInlCons(allCy,EFS,YTIME)$(not An(YTIME)) = iDataGrossInlCons(allCy,EFS,YTIME);
iGrossInConsNoEneBra(runCy,EFS,YTIME) = iGrosInlCons(runCy,EFS,YTIME) + iTotEneBranchCons(runCy,EFS,YTIME)$EFtoEFA(EFS,"LQD")
                                               - iTotEneBranchCons(runCy,EFS,YTIME)$(not EFtoEFA(EFS,"LQD"));

iPeakBsLoadBy(allCy,PGLOADTYPE) = sum(tfirst, iDataElecSteamGen(allCy,PGLOADTYPE,tfirst));

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
iResElecIndex(allCy,YTIME) = 1;

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
iResSpecificFuelConsCost(allCy,TRANSE,TTECH,EF,YTIME)$(sameas(TTECH,EF)$an(YTIME)) = iResTranspFuelConsSubTech(allCy,TRANSE,EF,YTIME);
iResSpecificFuelConsCost(allCy,TRANSE,"BGDO","BGDO",YTIME)$(an(YTIME) $SECTTECH(TRANSE,"BGDO")) = iResSpecificFuelConsCost(allCy,TRANSE,"GDO","GDO",YTIME);

iResSpecificFuelConsCost(allCy,TRANSE,"PHEVGSL","GSL",YTIME)$(TRANSETTECH(TRANSE,"PHEVGSL") $an(YTIME))= iResSpecificFuelConsCost(allCy,TRANSE,"GSL","GSL",YTIME);
iResSpecificFuelConsCost(allCy,TRANSE,"PHEVGSL","ELC",YTIME)$(TRANSETTECH(TRANSE,"PHEVGSL") $an(YTIME))= iResSpecificFuelConsCost(allCy,TRANSE,"ELC","ELC",YTIME);

iResSpecificFuelConsCost(allCy,TRANSE,"PHEVGDO","GDO",YTIME)$(TRANSETTECH(TRANSE,"PHEVGDO") $an(YTIME))= iResSpecificFuelConsCost(allCy,TRANSE,"GDO","GDO",YTIME);
iResSpecificFuelConsCost(allCy,TRANSE,"PHEVGDO","ELC",YTIME)$(TRANSETTECH(TRANSE,"PHEVGDO") $an(YTIME))= iResSpecificFuelConsCost(allCy,TRANSE,"ELC","ELC",YTIME);

iResSpecificFuelConsCost(allCy,TRANSE,"cHEVGDO","GDO",YTIME)$(TRANSETTECH(TRANSE,"cHEVGDO") $an(YTIME))= iResSpecificFuelConsCost(allCy,TRANSE,"GDO","GDO",YTIME);
iResSpecificFuelConsCost(allCy,TRANSE,"cHEVGsl","gsl",YTIME)$(TRANSETTECH(TRANSE,"cHEVGsl") $an(YTIME))= iResSpecificFuelConsCost(allCy,TRANSE,"Gsl","Gsl",YTIME);
table iPlugHybrFractOfMileage(ELSH_SET,YTIME)	 "Plug in hybrid fraction of mileage covered by electricity, residualls on GDP-Depnd car market ext (1)"
$ondelim
$include"./iPlugHybrFractOfMileage.csv"
$offdelim
;
iShareAnnMilePlugInHybrid(allCy,YTIME)$an(YTIME) = iPlugHybrFractOfMileage("ELSH",YTIME);
table iCapDataLoadFacEachTransp(TRANSE,TRANSUSE)	 "Capacity data and Load factor for each transportation mode (passenger or tonnes/vehicle)"
$ondelim
$include"./iCapDataLoadFacEachTransp.csv"
$offdelim
;
table iNewReg(allCy,YTIME) "new car registrations per year"
$ondelim
$include"./iNewReg.csv"
$offdelim
;

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
table iDataInstCapElecFuel(allCy,PGALL,PG1_set)	     "Installed capacity input (GW)"	
$ondelim
$include"./iDataInstCapElecFuel.csv"
$offdelim
;

iInstCapPast(allCy,PGALL,"2010") = iDataInstCapElecFuel(allCy,PGALL,"2010");
iInstCapPast(allCy,PGALL,"2015") = iDataInstCapElecFuel(allCy,PGALL,"2015");
iInstCapPast(allCy,PGALL,"2017") = iDataInstCapElecFuel(allCy,PGALL,"2017");


iInstCapPast(allCy,PGALL,"2011") = iInstCapPast(allCy,PGALL,"2010") +(iInstCapPast(allCy,PGALL,"2015")- iInstCapPast(allCy,PGALL,"2010"))/5 ;
iInstCapPast(allCy,PGALL,"2012") = iInstCapPast(allCy,PGALL,"2011") +(iInstCapPast(allCy,PGALL,"2015")- iInstCapPast(allCy,PGALL,"2010"))/5 ;
iInstCapPast(allCy,PGALL,"2013") = iInstCapPast(allCy,PGALL,"2012") +(iInstCapPast(allCy,PGALL,"2015")- iInstCapPast(allCy,PGALL,"2010"))/5 ;
iInstCapPast(allCy,PGALL,"2014") = iInstCapPast(allCy,PGALL,"2013") +(iInstCapPast(allCy,PGALL,"2015")- iInstCapPast(allCy,PGALL,"2010"))/5 ;
iInstCapPast(allCy,PGALL,"2016") = iInstCapPast(allCy,PGALL,"2015") +(iInstCapPast(allCy,PGALL,"2017")- iInstCapPast(allCy,PGALL,"2015"))/2 ;

table iEnvPolicies(allCy,POLICIES_SET,YTIME) "Environmental policies on emissions constraints  and subsidy on renewables (Mtn CO2)"
$ondelim
$include"./iEnvPolicies.csv"
$offdelim
;
table iDataPowGenCost(PGALL,PGECONCHAR) "Data for power generation costs (various)"
$ondelim
$include"./iDataPowGenCost.csv"
$offdelim
;
iCarbValYrExog(allCy,YTIME)$an(YTIME) = iEnvPolicies(allCy,"exogCV",YTIME);
table iMatrFactor(allCy,SBS,EF,YTIME)       "Maturity factor per technology and subsector (1)"
$ondelim
$include"./iMatrFactor.csv"
$offdelim
;
iMatrFactor(allCy,SBS,EF,YTIME) = iMatrFactor("MAR",SBS,EF,YTIME);                                          
** Industry
iShrNonSubElecInTotElecDem(allCy,INDSE)  = iIndChar(allCy,INDSE,"SHR_NSE");
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

iCapCostTech(runCy,TRANSE,EF,YTIME)  = iDataTransTech(TRANSE,EF,"IC",YTIME);

iFixOMCostTech(runCy,TRANSE,EF,YTIME) = iDataTransTech(TRANSE,EF,"FC",YTIME);

iVarCostTech(runCy,TRANSE,EF,YTIME) = iDataTransTech(TRANSE,EF,"VC",YTIME);

iTechLft(runCy,TRANSE,EF,YTIME) = iDataTransTech(TRANSE,EF,"LFT",YTIME);

iAvgVehCapLoadFac(runCy,TRANSE,TRANSUSE,YTIME) = iCapDataLoadFacEachTransp(TRANSE,TRANSUSE);


**  Industrial Sector

iCapCostTech(runCy,INDSE,EF,YTIME)$(ord(YTIME) eq TF-7) = iDataIndTechnology(INDSE,EF,"IC_05");
iCapCostTech(runCy,INDSE,EF,YTIME)$(ord(YTIME) eq TF+8) = iDataIndTechnology(INDSE,EF,"IC_25");
iCapCostTech(runCy,INDSE,EF,YTIME)$(ord(YTIME) eq TF+33) = iDataIndTechnology(INDSE,EF,"IC_50");

iFixOMCostTech(runCy,INDSE,EF,YTIME)$(ord(YTIME) eq TF-7) = iDataIndTechnology(INDSE,EF,"FC_05");
iFixOMCostTech(runCy,INDSE,EF,YTIME)$(ord(YTIME) eq TF+8) = iDataIndTechnology(INDSE,EF,"FC_25");
iFixOMCostTech(runCy,INDSE,EF,YTIME)$(ord(YTIME) eq TF+33) = iDataIndTechnology(INDSE,EF,"FC_50");

iVarCostTech(runCy,INDSE,EF,YTIME)$(ord(YTIME) eq TF-7) = iDataIndTechnology(INDSE,EF,"VC_05");
iVarCostTech(runCy,INDSE,EF,YTIME)$(ord(YTIME) eq TF+8) = iDataIndTechnology(INDSE,EF,"VC_25");
iVarCostTech(runCy,INDSE,EF,YTIME)$(ord(YTIME) eq TF+33) = iDataIndTechnology(INDSE,EF,"VC_50");

iUsfEneConvSubTech(runCy,INDSE,EF,YTIME)$(ord(YTIME) <= TF-7)    = iDataIndTechnology(INDSE,EF,"USC_05");
iUsfEneConvSubTech(runCy,INDSE,EF,YTIME)$(ord(YTIME) eq TF+8) = iDataIndTechnology(INDSE,EF,"USC_25");
iUsfEneConvSubTech(runCy,INDSE,EF,YTIME)$(ord(YTIME) eq TF+33) = iDataIndTechnology(INDSE,EF,"USC_50");

iTechLft(runCy,INDSE,EF,YTIME)$(ord(YTIME)>(ordfirst-8)) = iDataIndTechnology(INDSE,EF,"LFT");


**  Domestic Sector


iFixOMCostTech(runCy,DOMSE,EF,YTIME)$(ord(YTIME) eq TF-7)= iDataDomTech(DOMSE,EF,"FC_05");
iFixOMCostTech(runCy,DOMSE,EF,YTIME)$(ord(YTIME) eq TF+8) = iDataDomTech(DOMSE,EF,"FC_25");
iFixOMCostTech(runCy,DOMSE,EF,YTIME)$(ord(YTIME) eq TF+33)= iDataDomTech(DOMSE,EF,"FC_50");

iVarCostTech(runCy,DOMSE,EF,YTIME)$(ord(YTIME) eq TF-7)= iDataDomTech(DOMSE,EF,"VC_05");
iVarCostTech(runCy,DOMSE,EF,YTIME)$(ord(YTIME) eq TF+8) = iDataDomTech(DOMSE,EF,"VC_25");
iVarCostTech(runCy,DOMSE,EF,YTIME)$(ord(YTIME) eq TF+33)= iDataDomTech(DOMSE,EF,"VC_50");

iUsfEneConvSubTech(runCy,DOMSE,EF,YTIME)$(ord(YTIME) <= TF-7)= iDataDomTech(DOMSE,EF,"USC_05");
iUsfEneConvSubTech(runCy,DOMSE,EF,YTIME)$(ord(YTIME) eq TF+8) = iDataDomTech(DOMSE,EF,"USC_25");
iUsfEneConvSubTech(runCy,DOMSE,EF,YTIME)$(ord(YTIME) eq TF+33)= iDataDomTech(DOMSE,EF,"USC_50");

iTechLft(runCy,DOMSE,EF,YTIME)$(ord(YTIME)>(ordfirst-8))  = iDataDomTech(DOMSE,EF,"LFT");

$ontext
NETWORKPARAM(NETWSET,INDDOM,NETEF)$(NETTECH(INDDOM,NETEF))                               = NetEffect(NETWSET,NETEF,"OTH");
NETWORKPARAM(NETWSET,INDDOM,"STE1AH2F")$(NETTECH(INDDOM,"STE1AH2F"))                     = NetEffect(NETWSET,"H2F","OTH");

NETWORKPARAM(NETWSET,TRANSE,NETEF)$(NETTECH(TRANSE,NETEF))                               = NetEffect(NETWSET,NETEF,"TRA");
NETWORKPARAM(NETWSET,TRANSE,EF)$(NETTECH(TRANSE,EF)$PLUGIN(EF) )                         = NetEffect(NETWSET,"ELC","TRA");
$offtext
**  Non Energy Sector and Bunkers


iFixOMCostTech(runCy,NENSE,EF,YTIME)$(ord(YTIME) eq TF-7)= iDataNonEneSec(NENSE,EF,"FC_05");
iFixOMCostTech(runCy,NENSE,EF,YTIME)$(ord(YTIME) eq TF+8) = iDataNonEneSec(NENSE,EF,"FC_25");
iFixOMCostTech(runCy,NENSE,EF,YTIME)$(ord(YTIME) eq TF+33)= iDataNonEneSec(NENSE,EF,"FC_50");

iVarCostTech(runCy,NENSE,EF,YTIME)$(ord(YTIME) eq TF-7)= iDataNonEneSec(NENSE,EF,"VC_05");
iVarCostTech(runCy,NENSE,EF,YTIME)$(ord(YTIME) eq TF+8) = iDataNonEneSec(NENSE,EF,"VC_25");
iVarCostTech(runCy,NENSE,EF,YTIME)$(ord(YTIME) eq TF+33)= iDataNonEneSec(NENSE,EF,"VC_50");

iUsfEneConvSubTech(runCy,NENSE,EF,YTIME)$(ord(YTIME) <= TF-7)= iDataNonEneSec(NENSE,EF,"USC_05");
iUsfEneConvSubTech(runCy,NENSE,EF,YTIME)$(ord(YTIME) eq TF+8) = iDataNonEneSec(NENSE,EF,"USC_25");
iUsfEneConvSubTech(runCy,NENSE,EF,YTIME)$(ord(YTIME) eq TF+33)= iDataNonEneSec(NENSE,EF,"USC_50");

iTechLft(runCy,NENSE,EF,YTIME)$(ord(YTIME)>(ordfirst-8)) = iDataNonEneSec(NENSE,EF,"LFT");
display TF;

loop YTIME$((ord(YTIME) gt TF-8) $(ord(YTIME) lt TF+8)) do
         iCapCostTech(runCy,SBS,EF,YTIME)= (iCapCostTech(runCy,SBS,EF,"2025")-iCapCostTech(runCy,SBS,EF,"2010"))/20+iCapCostTech(runCy,SBS,EF,YTIME-1);
         iFixOMCostTech(runCy,SBS,EF,YTIME)= (iFixOMCostTech(runCy,SBS,EF,"2025")-iFixOMCostTech(runCy,SBS,EF,"2010"))/20+iFixOMCostTech(runCy,SBS,EF,YTIME-1);
         iVarCostTech(runCy,SBS,EF,YTIME)= (iVarCostTech(runCy,SBS,EF,"2025")-iVarCostTech(runCy,SBS,EF,"2010"))/20+iVarCostTech(runCy,SBS,EF,YTIME-1);
         iUsfEneConvSubTech(runCy,SBS,EF,YTIME)     = (iUsfEneConvSubTech(runCy,SBS,EF,"2025")-iUsfEneConvSubTech(runCy,SBS,EF,"2010"))/20+iUsfEneConvSubTech(runCy,SBS,EF,YTIME-1);
endloop;


loop YTIME$((ord(YTIME) gt TF+8) $(ord(YTIME) lt TF+84)) do
         iCapCostTech(runCy,SBS,EF,YTIME)= (iCapCostTech(runCy,SBS,EF,"2050")-iCapCostTech(runCy,SBS,EF,"2025"))/25+iCapCostTech(runCy,SBS,EF,YTIME-1);
         iFixOMCostTech(runCy,SBS,EF,YTIME)= (iFixOMCostTech(runCy,SBS,EF,"2050")-iFixOMCostTech(runCy,SBS,EF,"2025"))/25+iFixOMCostTech(runCy,SBS,EF,YTIME-1);
         iVarCostTech(runCy,SBS,EF,YTIME)= (iVarCostTech(runCy,SBS,EF,"2050")-iVarCostTech(runCy,SBS,EF,"2025"))/25+iVarCostTech(runCy,SBS,EF,YTIME-1);
         iUsfEneConvSubTech(runCy,SBS,EF,YTIME)     = (iUsfEneConvSubTech(runCy,SBS,EF,"2050")-iUsfEneConvSubTech(runCy,SBS,EF,"2025"))/25+iUsfEneConvSubTech(runCy,SBS,EF,YTIME-1);
endloop;


loop YTIME$((ord(YTIME) gt TF-12) $(ord(YTIME) lt TF+3)) do
          iUsfEneConvSubTech(runCy,SBS,EF,YTIME) = (iUsfEneConvSubTech(runCy,SBS,EF,"2025")-iUsfEneConvSubTech(runCy,SBS,EF,"2010"))/
          20+iUsfEneConvSubTech(runCy,SBS,EF,YTIME-1);
endloop;

loop YTIME$((ord(YTIME) gt TF+3) $(ord(YTIME) lt TF+84)) do
         iUsfEneConvSubTech(runCy,SBS,EF,YTIME)     = (iUsfEneConvSubTech(runCy,SBS,EF,"2050")-iUsfEneConvSubTech(runCy,SBS,EF,"2025"))/
         25+iUsfEneConvSubTech(runCy,SBS,EF,YTIME-1);
endloop;


**  Power Generation



table iDataTechLftPlaType(PGALL, PGECONCHAR) "Data for power generation costs (various)"
$ondelim
$include"./iDataTechLftPlaType.csv"
$offdelim
;
iTechLftPlaType(runCy,PGALL) = iDataTechLftPlaType(PGALL, "LFT");

*iCO2CaptRate(runCy,PGALL,YTIME)$(ord(YTIME)>(ordfirst-8))  =  iDataPowGenCost(PGALL,"CR");

iEffDHPlants(runCy,EFS,YTIME)$(ord(YTIME)>(ordfirst-8))  = sum(PGEFS$sameas(EFS,PGEFS),iParDHEfficiency(PGEFS,"2010"));


table iDataPlantEffByType(PGALL, YTIME)   "Data for plant efficiency per plant type"
$ondelim
$include "./iDataPlantEffByType.csv"
$offdelim
;

iPlantEffByType(runCy,PGALL,YTIME) = iDataPlantEffByType(PGALL, YTIME) ;

** CHP economic and technical data initialisation for electricity production
table iDataChpPowGen(EF,YTIME,CHPPGSET)   "Data for power generation costs (various)"
$ondelim
$include "./iDataChpPowGen.csv"
$offdelim
;
iInvCostChp(runCy,DSBS,CHP,YTIME) = iDataChpPowGen(CHP,"2010","IC");
iFixOMCostPerChp(runCy,DSBS,CHP,YTIME) = iDataChpPowGen(CHP,"2010","FC");
iVarCostChp(runCy,DSBS,CHP,YTIME) = iDataChpPowGen(CHP,"2010","VOM");
iLifChpPla(runCy,DSBS,CHP) = iDataChpPowGen(CHP,"2010","LFT");
iAvailRateChp(runCy,DSBS,CHP) = iDataChpPowGen(CHP,"2010","AVAIL");
iBoiEffChp(runCy,CHP,YTIME) = iDataChpPowGen(CHP,"2010","BOILEFF");

**  Policies for climate change and renewables


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
***iPlantEffByType(runCy,PGALL,YTIME)$(an(ytime) )= iPlantEffByType(runCy,PGALL,YTIME) / iEneProdRDscenarios(runCy,"pg",ytime);
***iEffDHPlants(runCy,EF,YTIME)$(an(ytime) )= iEffDHPlants(runCy,EF,YTIME) / iEneProdRDscenarios(runCy,"pg",ytime);
iElecIndex(runCy,YTIME) = 0.9;
*iRateLossesFinCons(allCy,EFS, YTIME)$(iFinEneCons(allCy,EFS,YTIME)>0 $(not an(ytime))) = iDistrLosses(allCy,EFS,YTIME) / iFinEneCons(allCy,EFS,YTIME);




