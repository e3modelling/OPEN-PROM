*' @title Hydrogen input
*' @code

*---
table iH2Production(ECONCHARHY,H2TECH,YTIME)	              "Data for Hydrogen production"
$ondelim
$include"./iH2Production.csv"
$offdelim
;
*---
table iH2Parameters(allCy,ECONCHARHY)	                      "Data for Hydrogen Parameters"
$ondelim
$include"./iH2Parameters.csv"
$offdelim
;
*---
table iH2InfrCapCosts(ECONCHARHY,INFRTECH,YTIME)	          "Data for Hydrogen Infrastructure Costs"
$ondelim
$include"./iH2InfrCapCosts.csv"
$offdelim
;
*---
iH2Production(ECONCHARHY,"bgfl",YTIME) = iH2Production(ECONCHARHY,"bgfls",YTIME);
*---
Parameters
iWBLGammaH2Prod(allCy,YTIME)            "Parameter for acceptance in new investments used in weibull function in production shares"
iProdLftH2(H2TECH,YTIME)                "Lifetime of hydrogen production technologies in years"
iCaptRateH2Prod(allCy,H2TECH,YTIME)     "CO2 capture rate of hydrogen production technologies (for those which are equipped with CCS facility)"
iH2Adopt(allCy,ARELAST,YTIME)           "Parameters controlling the speed and the year of taking off the transition to hydrogen economy"
iTranspLftH2(INFRTECH,YTIME)            "Technical lifetime of infrastructure technologies"
iCostCapH2Prod(allCy,H2TECH,YTIME)      "Capital cost of hydrogen production technologies in Euro per Nm3 of hydrogen"
iCostFOMH2Prod(allCy,H2TECH,YTIME)      "Fixed operating and maintenance costs of hydrogen production technologies in Euro per Nm3 of hydrogen"
iCostVOMH2Prod(allCy,H2TECH,YTIME)      "Variable operating and maintenance costs of hydrogen production technologies in Euro per toe of hydrogen"
iAvailH2Prod(H2TECH,YTIME)              "Availability of hydrogen production technologies"
iEffH2Prod(allCy,H2TECH,YTIME)          "Efficiency of hydrogen production technologies"
iCostInvH2Transp(allCy,INFRTECH,YTIME)  "Investment cost of infrastructure technology"
                                                   !! - Turnpike pipeline in Euro per km
                                                   !! - Low pressure urban pipeline in Euro per km
                                                   !! - Medium pressure ring in Euro per km
                                                   !! - Service stations connection lines in Euro per km
                                                   !! - Gaseous hydrogen service stations in Euro per toe per year
iEffH2Transp(allCy,INFRTECH,YTIME)      "Efficiency of hydrogen transportation per infrastructure technology"
iConsSelfH2Transp(allCy,INFRTECH,YTIME) "Self consumption of infrastructure technology rate"
iAvailRateH2Transp(INFRTECH,YTIME)      "Availability rate of infrastructure technology"
iCostInvVOMH2(INFRTECH,YTIME)           "Annual variable O&M cost as percentage of total investment cost"
iCostInvFOMH2(INFRTECH,YTIME)           "Annual fixed O&M cost as percentage of total investment cost"
iPipeH2Transp(INFRTECH,YTIME)           "Kilometers of pipelines required per toe of delivered hydrogen (based on stylized model)"
iKmFactH2Transp(allCy,INFRTECH)         "Km needed for a given infrastructure assuming that its required infrastructure has been arleady installed"
iPolH2AreaMax(allCy)                    "Policy parameter defining the percentage of the country area supplied by hydrogen at the end of the horizon period [0...1]"
iHabAreaCountry(allCy)                  "Inhabitable land in a country"
iEffNetH2Transp(allCy,INFRTECH,YTIME)   "Total efficiency of the distribution network until the <infrtech> node"
iCostAvgWeight(allCy,YTIME)             "Weight for pricing in average cost or in marginal cost"
;
*---
iWBLGammaH2Prod(runCy,YTIME) = 4;
*---
iProdLftH2(H2TECH,YTIME)=iH2Production("LFT",H2TECH,YTIME);
*---
iCaptRateH2Prod(runCy,H2TECH,YTIME)=iH2Production("CR",H2TECH,YTIME);
*---
iH2Adopt(runCy,"b",YTIME)=iH2Parameters(runCy,"B");
iH2Adopt(runCy,"mid",YTIME)=iH2Parameters(runCy,"mid");
*---
iTranspLftH2(INFRTECH,YTIME)=iH2InfrCapCosts("LFT",INFRTECH,YTIME);
*---
iCostCapH2Prod(runCy,H2TECH,YTIME)=iH2Production("IC",H2TECH,YTIME);
*---
iCostFOMH2Prod(runCy,H2TECH,YTIME)=iH2Production("FC",H2TECH,YTIME);
*---
iCostVOMH2Prod(runCy,H2TECH,YTIME)=iH2Production("VC",H2TECH,YTIME);
*---
iAvailH2Prod(H2TECH,YTIME)=iH2Production("AVAIL",H2TECH,YTIME);
*---
iEffH2Prod(runCy,H2TECH,YTIME)=iH2Production("EFF",H2TECH,YTIME);
*---
iCostInvH2Transp(runCy,INFRTECH,YTIME)=iH2InfrCapCosts("IC",INFRTECH,YTIME);
*---
iEffH2Transp(runCy,INFRTECH,YTIME)=iH2InfrCapCosts("EFF",INFRTECH,YTIME);
*---
iConsSelfH2Transp(runCy,INFRTECH,YTIME)=iH2InfrCapCosts("SELF",INFRTECH,YTIME);
*---
iAvailRateH2Transp(INFRTECH,YTIME)=iH2InfrCapCosts("AVAIL",INFRTECH,YTIME);
*---
iCostInvFOMH2(INFRTECH,YTIME)=iH2InfrCapCosts("FC",INFRTECH,YTIME);
*---
iCostInvVOMH2(INFRTECH,YTIME)=iH2InfrCapCosts("VC",INFRTECH,YTIME);
*---
iPipeH2Transp(INFRTECH,YTIME) =  iH2InfrCapCosts("H2KMTOE",INFRTECH,YTIME);
*---
iKmFactH2Transp(runCy,INFRTECH) = sum(ECONCHARHY$INFRTECHLAB(INFRTECH,ECONCHARHY), iH2Parameters(runCy,ECONCHARHY));
*---
iPolH2AreaMax(runCy) = iH2Parameters(runCy,"MAXAREA");
*---
iHabAreaCountry(runCy) = iH2Parameters(runCy,"AREA");
*---
iEffNetH2Transp(runCy,INFRTECH,YTIME) = iEffH2Transp(runCy,INFRTECH,YTIME)*(1-iConsSelfH2Transp(runCy,INFRTECH,YTIME));
*---
loop H2EFFLOOP do
  loop INFRTECH2$H2NETWORK(INFRTECH2,H2EFFLOOP) do
         iEffNetH2Transp(runCy,H2EFFLOOP,YTIME) =  iEffNetH2Transp(runCy,INFRTECH2,YTIME)*iEffH2Transp(runCy,H2EFFLOOP,YTIME);
  endloop;
endloop;
*---
iCostAvgWeight(runCy,YTIME) = 1;
loop YTIME$(An(YTIME)) do
         iCostAvgWeight(runCy,YTIME) = -1/19+iCostAvgWeight(runCy,YTIME-1);
endloop;
*---
$ontext
*        Calibration parameters
parameter iWBLShareH2Prod(allCy,H2TECH,YTIME)             "Parameter for controlling the weibull function for calculating the shares in new market";
parameter iWBLPremRepH2Prod(allCy,H2TECH,YTIME)           "Parameter for controlling the premature replacement of technology";
$offtext
*---