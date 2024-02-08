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
* FIXME: Drive the emission factors with mrprom
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
          scr
RWO.PC    0.0200641155285507
CHA.PC    0.0201531648401507
EGY.PC    0.0201531648401507
IND.PC    0.0201531648401507
MAR.PC    0.0201531648401507
USA.PC    0.0418811968705786
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
iSpeFuelConsCostBy(allCy,TRANSE,TTECH,EF) = iInitSpecFuelCons("MAR",TRANSE,TTECH,EF,"2017");

table iElaSub(allCy,DSBS)                           "Elasticities by subsectors (1)"
$ondelim
$include "./iElaSub.csv"
$offdelim
;
iElaSub(allCy,DSBS) = iElaSub("MAR",DSBS);
parameter iConsSizeDistHeat(conSet)               "Consumer sizes for district heating (1)" /smallest 0.425506805,
                                                                                             modal    0.595709528,
                                                                                             largest 0.833993339/;

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
table iSuppTransfInputPatFuel(EF,YTIME)            "Supplementary Parameter for the transformation input to patent fuel and briquetting plants,coke-oven plants,blast furnace plants and gas works (1)"
$ondelim
$include "./iSuppTransfInputPatFuel.csv"
$offdelim
; 
parameter iSupResRefCapacity(allCy,SUPOTH,YTIME)	           "Supplementary Parameter for the residual in refineries Capacity (1)";
iSupResRefCapacity(allCy,SUPOTH,YTIME) = 1;

table iSuppRefCapacity(allCy,SUPOTH,YTIME)	          "Supplementary Parameter for the residual in refineries Capacity (1)"
$ondelim
$include "./iSuppRefCapacity.csv"
$offdelim
;
parameter iSupTrnasfOutputRefineries(allCy,EF,YTIME)	     "Supplementary parameter for the transformation output from refineries (Mtoe)";
iSupTrnasfOutputRefineries(allCy,EF,YTIME) = 1;

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
parameter iImpExp(allCy,EFS,YTIME)	                 "Imports of exporting countries usually zero (1)" ;
iImpExp(allCy,EFS,YTIME)	= 0;

parameter iLoadFactorAdj(DSBS)	"Parameters for load factor adjustment iBaseLoadShareDem (1)" /
IS 	0.9,
NF 	0.92,
CH 	0.78,
BM 	0.81,
PP 	0.91,
FD 	0.61,
EN 	0.65,
TX 	0.6,
OE 	0.9,
OI 	0.59,
SE 	0.58,
AG 	0.45,
HOU	0.55,
PC 	0.43,
*PB 	0.43,
PT 	0.29,
*PN 	0.43,
PA 	0.43,
GU 	0.43,
GT 	0.29,
GN 	0.43,
BU 	0.43,
PCH	0.78,
NEN	0.78 / ;
iBaseLoadShareDem(allCy,DSBS,YTIME)$an(YTIME)  = iLoadFactorAdj(DSBS);
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
         BASE           SHR_NSE   SH_HPELC
RAS.IS   0.4397         0.7       0.00001
RAS.NF   0              0.95      0.00001
RAS.CH   0.1422         0.95      0.00001
RAS.BM   2.1062         0.95      0.00001
RAS.PP   0              0.95      0.00001
RAS.FD   0.6641         0.95      0.00001
RAS.TX   0.0638         0.95      0.00001
RAS.EN   1.6664         0.95      0.00001
RAS.OE   0.00000001     0.95      0.00001
RAS.OI   1.5161         0.95      0.00001
MAR.IS   0.4397         0.7       0.00001
MAR.NF   0              0.95      0.00001
MAR.CH   0.1422         0.95      0.00001
MAR.BM   2.1062         0.95      0.00001
MAR.PP   0              0.95      0.00001
MAR.FD   0.6641         0.95      0.00001
MAR.TX   0.0638         0.95      0.00001
MAR.EN   1.6664         0.95      0.00001
MAR.OE   0.00000001     0.95      0.00001
MAR.OI   1.5161         0.95      0.00001
;

iIndChar(allCy,INDSE,Indu_Scon_Set) = iIndCharData("MAR",INDSE,Indu_Scon_Set);
table iInitConsSubAndInitShaNonSubElec(DOMSE,Indu_Scon_Set)      "Initial Consumption per Subsector and Initial Shares of Non Substitutable Electricity in Total Electricity Demand (Mtoe)"
     BASE   SHR_NSE SH_HPELC
SE   1.8266 0.9     0.00001
HOU  11.511 0.9     0.00001
AG   0.2078 0.9     0.00001
;

iShrHeatPumpElecCons(allCy,INDSE) = iIndChar(allCy,INDSE,"SH_HPELC");
iShrHeatPumpElecCons(allCy,DOMSE) = iInitConsSubAndInitShaNonSubElec(DOMSE,"SH_HPELC");
iExogDemOfBiomass(allCy,DOMSE,YTIME) = 0;
iElastCO2Seq(allCy,CO2SEQELAST) = iCO2SeqData(CO2SEQELAST,"%fBaseY%");
iRatioImpFinElecDem(runCy,YTIME)$an(YTIME) = iSuppRefCapacity(runCy,"ELC_IMP",YTIME);
iFuelExprts(runCy,EFS,YTIME) = iSuppExports(runCy,EFS,YTIME);
iRatePriProTotPriNeeds(runCy,PPRODEF,YTIME) = iSuppRatePrimProd(runCy,PPRODEF,YTIME);
iResHcNgOilPrProd(runCy,"HCL",YTIME)$an(YTIME)   = iSupResRefCapacity(runCy,"HCL_PPROD",YTIME);
iResHcNgOilPrProd(runCy,"NGS",YTIME)$an(YTIME)   = iSupResRefCapacity(runCy,"NGS_PPROD",YTIME);
iResHcNgOilPrProd(runCy,"CRO",YTIME)$an(YTIME)   = iSupResRefCapacity(runCy,"OIL_PPROD",YTIME);
iFeedTransfr(runCy,EFS,YTIME) = iSuppTransfers(runCy,EFS,YTIME);
iRateEneBranCons(allCy,EFS,YTIME)= iSupRateEneBranCons(allCy,EFS,YTIME);
iResTransfOutputRefineries(runCy,EFS,YTIME) = iSupTrnasfOutputRefineries(runCy,EFS,YTIME);;
iRefCapacity(runCy,YTIME)= iSuppRefCapacity(runCy,"REF_CAP",YTIME);
iResRefCapacity(runCy,YTIME) = iSupResRefCapacity(runCy,"REF_CAP_RES",YTIME);
iTransfInpGasworks(runCy,EFS,YTIME)= iSuppTransfInputPatFuel(EFS,YTIME);

parameter iLoadFactorAdjMxm(VARIOUS_LABELS)    "Parameter for load factor adjustment iMxmLoadFacElecDem (1)" /
AMAXBASE 3,
MAXLOADSH 0.45 / ;
iBslCorrection(allCy,YTIME)$an(YTIME) = iLoadFactorAdjMxm("AMAXBASE");
iMxmLoadFacElecDem(allCy,YTIME)$an(YTIME) = iLoadFactorAdjMxm("MAXLOADSH");
parameter iPolDstrbtnLagCoeffPriOilPr(kpdl)	  "Polynomial Distribution Lag Coefficients for primary oil production (1)"/
a1 1.666706504,
a2 1.333269594,
a3 1.000071707,
a4 0.666634797,
a5 0.33343691 /;

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

table iResTotCapMxmLoad(allCy,PGRES,YTIME)              "Residuals for total capacity and maximum load (1)"	
$ondelim
$include"./iResTotCapMxmLoad.csv"
$offdelim
;
iResMargTotAvailCap(allCy,PGRES,YTIME)$an(YTIME) = iResTotCapMxmLoad(allCy,PGRES,YTIME);

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

table iGrossCapCosSubRen(PGALL,YTIME)             "Gross Capital Cost per Plant Type with subsidy for renewables (kEuro2005/KW)"
$ondelim
$include"./iGrossCapCosSubRen.csv"
$offdelim
;
iGrossCapCosSubRen(PGALL,YTIME) = iGrossCapCosSubRen(PGALL,YTIME)/1000;
loop(PGALL,YTIME)$AN(YTIME) DO
         abort $(iGrossCapCosSubRen(PGALL,YTIME)<0) "CAPITAL COST IS NEGATIVE", iGrossCapCosSubRen
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

parameter iScaleEndogScrap(PGALL) "Scale parameter for endogenous scrapping applied to the sum of full costs (1)";
iScaleEndogScrap(PGALL) = 0.035;

table iDecomPlants(allCy,PGALL,YTIME)	            "Decomissioning Plants (MW)"
$ondelim
$include"./iDecomPlants.csv"
$offdelim
;

iPlantDecomSched(allCy,PGALL,YTIME) = iDecomPlants(allCy,PGALL,YTIME);

table iInvPlants(allCy,PGALL,YTIME)	            "Investment Plants (MW)"
$ondelim
$include"./iInvPlants.csv"
$offdelim
;
iDecInvPlantSched(allCy,PGALL,YTIME) = iInvPlants(allCy,PGALL,YTIME);

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

table iMatFacPlaAvailCap(allCy,PGALL,YTIME)	 "Maturity factor related to plant available capacity (1)"
$ondelim
$include"./iMatFacPlaAvailCap.csv"
$offdelim
;

iMatFacPlaAvailCap(allCy,CCS,YTIME)$an(YTIME)  =0;

* FIXME: Temporarily setting maturity factors related to plant dispatching equal to 1.
* author=derevirn
iMatureFacPlaDisp(allCy,PGALL,YTIME)$an(YTIME) = 1;
iCO2CaptRate(runCy,PGALL,YTIME) = 0; 

parameter iMxmShareChpElec "Maximum share of CHP electricity in a country (1)";
iMxmShareChpElec(runCy,YTIME) = 0.1;

iEffValueInEuro(allCy,SBS,YTIME)=0;
table iContrElecPrice(allCy,ELCPCHAR,YTIME)	 "Parameters controlling electricity price (1)"
$ondelim
$include"./iContrElecPrice.csv"
$offdelim
;
* FIXME: Values will be pinned down during model calibration, using MAR values for now
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

iGrosInlCons(allCy,EFS,YTIME) = iDataGrossInlCons(allCy,EFS,YTIME);
iGrossInConsNoEneBra(runCy,EFS,YTIME) = iGrosInlCons(runCy,EFS,YTIME) + iTotEneBranchCons(runCy,EFS,YTIME)$EFtoEFA(EFS,"LQD")
                                               - iTotEneBranchCons(runCy,EFS,YTIME)$(not EFtoEFA(EFS,"LQD"));

iPeakBsLoadBy(allCy,PGLOADTYPE) = sum(tfirst, iDataElecSteamGen(allCy,PGLOADTYPE,tfirst));

parameter iDataElecAndSteamGen(allCy,CHP,YTIME)	 "Data releated to electricity and steam generation";
iDataElecAndSteamGen(allCy,CHP,YTIME) = 0 ;
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


iWgtSecAvgPriFueCons(runCy,TRANSE,EF)$(SECTTECH(TRANSE,EF) $(not plugin(EF)) ) = (iFuelConsPerFueSub(runCy,TRANSE,EF,"%fBaseY%") / iTotFinEneDemSubBaseYr(runCy,TRANSE,"%fBaseY%"))$iTotFinEneDemSubBaseYr(runCy,TRANSE,"%fBaseY%")
                                               + (1/iDiffFuelsInSec(TRANSE))$(not iTotFinEneDemSubBaseYr(runCy,TRANSE,"%fBaseY%"));

iWgtSecAvgPriFueCons(runCy,NENSE,EF)$SECTTECH(NENSE,EF) = ( iFuelConsPerFueSub(runCy,NENSE,EF,"%fBaseY%") / iTotFinEneDemSubBaseYr(runCy,NENSE,"%fBaseY%") )$iTotFinEneDemSubBaseYr(runCy,NENSE,"%fBaseY%")
                                             + (1/iDiffFuelsInSec(NENSE))$(not iTotFinEneDemSubBaseYr(runCy,NENSE,"%fBaseY%"));


iWgtSecAvgPriFueCons(runCy,INDDOM,EF)$(SECTTECH(INDDOM,EF)$(not sameas(EF,"ELC"))) = ( iFuelConsPerFueSub(runCy,INDDOM,EF,"%fBaseY%") / (iTotFinEneDemSubBaseYr(runCy,INDDOM,"%fBaseY%") - iFuelConsPerFueSub(runCy,INDDOM,"ELC","%fBaseY%")) )$( iTotFinEneDemSubBaseYr(runCy,INDDOM,"%fBaseY%") - iFuelConsPerFueSub(runCy,INDDOM,"ELC","%fBaseY%") )
                                                                        + (1/(iDiffFuelsInSec(INDDOM)-1))$(not (iTotFinEneDemSubBaseYr(runCy,INDDOM,"%fBaseY%") - iFuelConsPerFueSub(runCy,INDDOM,"ELC","%fBaseY%")));



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

table iResTranspFuelConsSubTech(allCy,TRANSE,EF,YTIME)	 "Residual Transport on Specific Fuel Consumption per Subsector and Technology (1)"
$ondelim
$include"./iResTranspFuelConsSubTech.csv"
$offdelim
;
table iPlugHybrFractOfMileage(ELSH_SET,YTIME)	 "Plug in hybrid fraction of mileage covered by electricity, residualls on GDP-Depnd car market ext (1)"
$ondelim
$include"./iPlugHybrFractOfMileage.csv"
$offdelim
;
iShareAnnMilePlugInHybrid(allCy,YTIME)$an(YTIME) = iPlugHybrFractOfMileage("ELSH",YTIME);
table iCapDataLoadFacEachTransp(TRANSE,TRANSUSE)	 "Capacity data and Load factor for each transportation mode (passenger or tonnes/vehicle)"
     Cap  LF
PC   2    
*PB  40   0.4
PT   300  0.4
*PN  300  0.5
PA   180  0.65
GU   5    0.7
GT   600  0.8
GN   1500 0.9 
;
table iNewReg(allCy,YTIME) "new car registrations per year"
$ondelim
$include"./iNewReg.csv"
$offdelim
;

iUtilRateChpPlants(allCy,CHP,YTIME) = 0.5;

**                   Power Generation
table iInstCapPast(allCy,PGALL,YTIME)        "Installed capacity past (GW)"
$ondelim
$include"./iInstCapPast.csv"
$offdelim
;
display iInstCapPast;
table iEnvPolicies(allCy,POLICIES_SET,YTIME) "Environmental policies on emissions constraints  and subsidy on renewables (Mtn CO2)"
$ondelim
$include"./iEnvPolicies.csv"
$offdelim
;

iCarbValYrExog(allCy,YTIME)$an(YTIME) = iEnvPolicies(allCy,"exogCV",YTIME);
table iMatrFactor(allCy,SBS,EF,YTIME)       "Maturity factor per technology and subsector (1)"
$ondelim
$include"./iMatrFactor.csv"
$offdelim
;
* FIXME: Specify maturity factors for each country, instead of assigning MAR values
iMatrFactor(allCy,SBS,EF,YTIME) = iMatrFactor("MAR",SBS,EF,YTIME);                                          
** Industry
iShrNonSubElecInTotElecDem(allCy,INDSE)  = iIndChar(allCy,INDSE,"SHR_NSE");
iShrNonSubElecInTotElecDem(allCy,INDSE)$(iShrNonSubElecInTotElecDem(allCy,INDSE)>0.98) = 0.98;
**Domestic - Tertiary
iShrNonSubElecInTotElecDem(allCy,DOMSE) = iInitConsSubAndInitShaNonSubElec(DOMSE,"SHR_NSE");
iShrNonSubElecInTotElecDem(allCy,DOMSE)$(iShrNonSubElecInTotElecDem(allCy,DOMSE)>0.98) = 0.98;
**   Macroeconomic


**  Transport Sector
iCapCostTech(runCy,TRANSE,EF,YTIME) = iDataTransTech(TRANSE,EF,"IC",YTIME);
iFixOMCostTech(runCy,TRANSE,EF,YTIME) = iDataTransTech(TRANSE,EF,"FC",YTIME);
iVarCostTech(runCy,TRANSE,EF,YTIME) = iDataTransTech(TRANSE,EF,"VC",YTIME);
iTechLft(runCy,TRANSE,EF,YTIME) = iDataTransTech(TRANSE,EF,"LFT",YTIME);
iAvgVehCapLoadFac(runCy,TRANSE,TRANSUSE,YTIME) = iCapDataLoadFacEachTransp(TRANSE,TRANSUSE);

**  Industrial Sector
iCapCostTech(runCy,INDSE,EF,YTIME) = iDataIndTechnology(INDSE,EF,"IC");
iFixOMCostTech(runCy,INDSE,EF,YTIME) = iDataIndTechnology(INDSE,EF,"FC");
iVarCostTech(runCy,INDSE,EF,YTIME) = iDataIndTechnology(INDSE,EF,"VC");
iUsfEneConvSubTech(runCy,INDSE,EF,YTIME)  = iDataIndTechnology(INDSE,EF,"USC");
iTechLft(runCy,INDSE,EF,YTIME) = iDataIndTechnology(INDSE,EF,"LFT");

**  Domestic Sector
iFixOMCostTech(runCy,DOMSE,EF,YTIME) = iDataDomTech(DOMSE,EF,"FC");
iVarCostTech(runCy,DOMSE,EF,YTIME) = iDataDomTech(DOMSE,EF,"VC");
iUsfEneConvSubTech(runCy,DOMSE,EF,YTIME) = iDataDomTech(DOMSE,EF,"USC");
iTechLft(runCy,DOMSE,EF,YTIME) = iDataDomTech(DOMSE,EF,"LFT");

**  Non Energy Sector and Bunkers
iFixOMCostTech(runCy,NENSE,EF,YTIME)= iDataNonEneSec(NENSE,EF,"FC");
iVarCostTech(runCy,NENSE,EF,YTIME) = iDataNonEneSec(NENSE,EF,"VC");
iUsfEneConvSubTech(runCy,NENSE,EF,YTIME) = iDataNonEneSec(NENSE,EF,"USC");
iTechLft(runCy,NENSE,EF,YTIME) = iDataNonEneSec(NENSE,EF,"LFT");

**  Power Generation
table iDataTechLftPlaType(PGALL, PGECONCHAR) "Data for power generation costs (various)"
$ondelim
$include"./iDataTechLftPlaType.csv"
$offdelim
;
iTechLftPlaType(runCy,PGALL) = iDataTechLftPlaType(PGALL, "LFT");

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




