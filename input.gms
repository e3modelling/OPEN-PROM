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
iUsfEnergy(allCy,SBS,EF,TEA,YTIME) = iUsfEneConvSubTech(SBS,EF,YTIME);
table iElaSub(allCy,DSBS)                           "Elasticities by subsectors"
$ondelim$include "./iElaSub.csv"
$offdelim
;
table iConsSizeDistHeat(allCy,conSet)                "Consumer sizes for district heating"
$ondelim$include "./iConsSizeDistHeat.csv"
$offdelim
;
*Calculation of consumer size groups and their distribution function
iNcon(TRANSE)$(sameas(TRANSE,"PC") or sameas(TRANSE,"GU")) = 10; !! 11 different consumer size groups for cars and trucks
iNcon(TRANSE)$(not (sameas(TRANSE,"PC") or sameas(TRANSE,"GU"))) = 1; !! 2 different consumer size groups for inland navigation, trains, busses and aviation
iNcon(INDSE) = 10; !! 11 different consumer size groups for industrial sectors
iNcon(DOMSE) = 10; !! 11 different consumer size groups for domestic and tertiary sectors
iNcon(NENSE) = 10; !! 11 different consumer size groups for non energy uses
iNcon("BU") = 2;   !! ... except bunkers .


* 11 vehicle mileage groups
* 0.952 turned out to be a (constant) ratio between modal and average mileage through iterations in Excel

iAnnSmallCons(runCy,"PC") = 0.5 * 0.952 * iTransChar(runCy,"KM_VEH","2010") * 1000 * 1E-6;
iAnnConsLargCons(runCy,"PC") = 4 * 0.952 * iTransChar(runCy,"KM_VEH","2010") * 1000 * 1E-6;
iAnnConsModCons(runCy,"PC") = 0.952 * iTransChar(runCy,"KM_VEH","2010") * 1000 * 1E-6;

* modal value is assumed to be 2 tonnes/vehicle, min = 1/3*modal and max = 10*modal tkm.
* 0.706 is the constant ratio of modal/average tkm through iterations in Excel
iAnnSmallCons(runCy,"GU") = 0.5 * 0.706 * iTransChar(runCy,"KM_VEH_TRUCK","2010")* 1000 * 2 / 3  * 1E-6;
iAnnConsLargCons(runCy,"GU") = 4 * 0.706 * iTransChar(runCy,"KM_VEH_TRUCK","2010") * 1000 * 2 * 10  * 1E-6;
iAnnConsModCons(runCy,"GU") = 0.706 * iTransChar(runCy,"KM_VEH_TRUCK","2010") * 1000 * 2  * 1E-6;

* Size will not play a role in buses, trains, ships and aircraft
* Following values are given only for the sake of uniformity, but iDisFunConSize is not really calculated for non-road transport!

iAnnSmallCons(runCy,"PA") = 40000 * 50 * 1E-6;
iAnnConsLargCons(runCy,"PA") = 800000 * 300 * 1E-6;
iAnnConsModCons(runCy,"PA") = 400000 * 100 * 1E-6;

*iAnnSmallCons(runCy,"PB") = 20000 * 5 * 1E-6;
*iAnnConsLargCons(runCy,"PB") = 200000 * 50 * 1E-6;
*iAnnConsModCons(runCy,"PB") = 50000* 15 * 1E-6;

iAnnSmallCons(runCy,"PT") = 50000 * 50 * 1E-6;
iAnnConsLargCons(runCy,"PT") = 400000 * 500 * 1E-6;
iAnnConsModCons(runCy,"PT") = 200000 * 150 * 1e-6;

iAnnSmallCons(runCy,"GT") = 50000 * 20 * 1E-6;
iAnnConsLargCons(runCy,"GT") = 400000 * 500 * 1E-6;
iAnnConsModCons(runCy,"GT") = 200000 * 200 * 1e-6;

*iAnnSmallCons(runCy,"PN") = 10000 * 50 * 1E-6;
*iAnnConsLargCons(runCy,"PN") = 100000 * 500 * 1E-6;
*iAnnConsModCons(runCy,"PN") = 50000 * 100 * 1e-6;

iAnnSmallCons(runCy,"GN") = 10000 * 20 * 1E-6;
iAnnConsLargCons(runCy,"GN") = 100000 * 1000 * 1E-6;
iAnnConsModCons(runCy,"GN") = 50000 * 300 * 1e-6;

iAnnSmallCons(runCy,INDSE) = 0.2  ;
iAnnConsLargCons(runCy,INDSE) = 0.9 ;
* assuming an average utilisation rate of 0.6 for iron & steel and 0.5 for other industry (see iterations in Excel):
iAnnConsModCons(runCy,"IS") = 0.587;
iAnnConsModCons(runCy,INDSE)$(not sameas(INDSE,"IS")) = 0.487;

iAnnSmallCons(runCy,DOMSE) = iConsSizeDistHeat(runCy,"smallest")  ;
iAnnConsLargCons(runCy,DOMSE) = iConsSizeDistHeat(runCy,"largest") ;
iAnnConsModCons(runCy,DOMSE) = iConsSizeDistHeat(runCy,"modal");

iAnnSmallCons(runCy,NENSE) = 0.2  ;
iAnnConsLargCons(runCy,NENSE) = 0.9 ;
* assuming an average utilisation rate of 0.5 for non-energy uses:
iAnnConsModCons(runCy,NENSE) = 0.487 ;

iAnnSmallCons(runCy,"BU") = 0.2 ;
iAnnConsLargCons(runCy,"BU") = 1 ;
iAnnConsModCons(runCy,"BU") = 0.5 ;

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
                 Power(log(iAnnConsModCons(runCy,DSBS)/iAnnSmallCons(runCy,DSBS)),ord(rCon)-1)
                 *
                 Power(log(iAnnConsLargCons(runCy,DSBS)/iAnnConsModCons(runCy,DSBS)),iNcon(DSBS)-(ord(rCon)-1))
                 /
                (Power(log(iAnnConsLargCons(runCy,DSBS)/iAnnSmallCons(runCy,DSBS)),iNcon(DSBS)) )
                *
                iAnnSmallCons(runCy,DSBS)*(iAnnConsLargCons(runCy,DSBS)/iAnnSmallCons(runCy,DSBS))**((ord(rCon)-1)/iNcon(DSBS))
;
     ENDLOOP;
ENDLOOP;