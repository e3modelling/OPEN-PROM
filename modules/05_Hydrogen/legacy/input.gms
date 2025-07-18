*' @title Hydrogen input
*' @code

*---
table i05H2Production(ECONCHARHY,H2TECH,YTIME)	            "Data for Hydrogen production"
$ondelim
$include"./iH2Production.csv"
$offdelim
;
*---
table i05H2Parameters(allCy,ECONCHARHY)	                    "Data for Hydrogen Parameters"
$ondelim
$include"./iH2Parameters.csv"
$offdelim
;
*---
table i05H2InfrCapCosts(ECONCHARHY,INFRTECH,YTIME)	        "Data for Hydrogen Infrastructure Costs"
$ondelim
$include"./iH2InfrCapCosts.csv"
$offdelim
;
*---
i05H2Production(ECONCHARHY,"bgfl",YTIME) = i05H2Production(ECONCHARHY,"bgfls",YTIME);
*---
Parameters
i05WBLGammaH2Prod(allCy,YTIME)              "Parameter for acceptance in new investments used in weibull function in production shares"
i05ProdLftH2(H2TECH,YTIME)                  "Lifetime of hydrogen production technologies in years"
i05CaptRateH2Prod(allCy,H2TECH,YTIME)       "CO2 capture rate of hydrogen production technologies (for those which are equipped with CCS facility)"
i05H2Adopt(allCy,ARELAST,YTIME)             "Parameters controlling the speed and the year of taking off the transition to hydrogen economy"
i05TranspLftH2(INFRTECH,YTIME)              "Technical lifetime of infrastructure technologies"
i05CostCapH2Prod(allCy,H2TECH,YTIME)        "Capital cost of hydrogen production technologies in Euro per Nm3 of hydrogen"
i05CostFOMH2Prod(allCy,H2TECH,YTIME)        "Fixed operating and maintenance costs of hydrogen production technologies in Euro per Nm3 of hydrogen"
i05CostVOMH2Prod(allCy,H2TECH,YTIME)        "Variable operating and maintenance costs of hydrogen production technologies in Euro per toe of hydrogen"
i05AvailH2Prod(H2TECH,YTIME)                "Availability of hydrogen production technologies"
i05EffH2Prod(allCy,H2TECH,YTIME)            "Efficiency of hydrogen production technologies"
i05CostInvH2Transp(allCy,INFRTECH,YTIME)    "Investment cost of infrastructure technology"
                                                   !! - Turnpike pipeline in Euro per km
                                                   !! - Low pressure urban pipeline in Euro per km
                                                   !! - Medium pressure ring in Euro per km
                                                   !! - Service stations connection lines in Euro per km
                                                   !! - Gaseous hydrogen service stations in Euro per toe per year
i05EffH2Transp(allCy,INFRTECH,YTIME)        "Efficiency of hydrogen transportation per infrastructure technology"
i05ConsSelfH2Transp(allCy,INFRTECH,YTIME)   "Self consumption of infrastructure technology rate"
i05AvailRateH2Transp(INFRTECH,YTIME)        "Availability rate of infrastructure technology"
i05CostInvVOMH2(INFRTECH,YTIME)             "Annual variable O&M cost as percentage of total investment cost"
i05CostInvFOMH2(INFRTECH,YTIME)             "Annual fixed O&M cost as percentage of total investment cost"
i05PipeH2Transp(INFRTECH,YTIME)             "Kilometers of pipelines required per toe of delivered hydrogen (based on stylized model)"
i05KmFactH2Transp(allCy,INFRTECH)           "Km needed for a given infrastructure assuming that its required infrastructure has been arleady installed"
i05PolH2AreaMax(allCy)                      "Policy parameter defining the percentage of the country area supplied by hydrogen at the end of the horizon period [0...1]"
i05HabAreaCountry(allCy)                    "Inhabitable land in a country"
i05EffNetH2Transp(allCy,INFRTECH,YTIME)     "Total efficiency of the distribution network until the <infrtech> node"
i05CostAvgWeight(allCy,YTIME)               "Weight for pricing in average cost or in marginal cost"
;
*---
i05WBLGammaH2Prod(runCy,YTIME) = 4;
*---
i05ProdLftH2(H2TECH,YTIME) = i05H2Production("LFT",H2TECH,YTIME);
*---
i05CaptRateH2Prod(runCy,H2TECH,YTIME) = i05H2Production("CR",H2TECH,YTIME);
*---
i05H2Adopt(runCy,"b",YTIME)   = i05H2Parameters(runCy,"B");
i05H2Adopt(runCy,"mid",YTIME) = i05H2Parameters(runCy,"mid");
*---
i05TranspLftH2(INFRTECH,YTIME) = i05H2InfrCapCosts("LFT",INFRTECH,YTIME);
*---
i05CostCapH2Prod(runCy,H2TECH,YTIME) = i05H2Production("IC",H2TECH,YTIME);
*---
i05CostFOMH2Prod(runCy,H2TECH,YTIME) = i05H2Production("FC",H2TECH,YTIME);
*---
i05CostVOMH2Prod(runCy,H2TECH,YTIME) = i05H2Production("VC",H2TECH,YTIME);
*---
i05AvailH2Prod(H2TECH,YTIME) = i05H2Production("AVAIL",H2TECH,YTIME);
*---
i05EffH2Prod(runCy,H2TECH,YTIME) = i05H2Production("EFF",H2TECH,YTIME);
*---
i05CostInvH2Transp(runCy,INFRTECH,YTIME) = i05H2InfrCapCosts("IC",INFRTECH,YTIME);
*---
i05EffH2Transp(runCy,INFRTECH,YTIME) = i05H2InfrCapCosts("EFF",INFRTECH,YTIME);
*---
i05ConsSelfH2Transp(runCy,INFRTECH,YTIME) = i05H2InfrCapCosts("SELF",INFRTECH,YTIME);
*---
i05AvailRateH2Transp(INFRTECH,YTIME) = i05H2InfrCapCosts("AVAIL",INFRTECH,YTIME);
*---
i05CostInvFOMH2(INFRTECH,YTIME) = i05H2InfrCapCosts("FC",INFRTECH,YTIME);
*---
i05CostInvVOMH2(INFRTECH,YTIME) = i05H2InfrCapCosts("VC",INFRTECH,YTIME);
*---
i05PipeH2Transp(INFRTECH,YTIME) =  i05H2InfrCapCosts("H2KMTOE",INFRTECH,YTIME);
*---
i05KmFactH2Transp(runCy,INFRTECH) = sum(ECONCHARHY$INFRTECHLAB(INFRTECH,ECONCHARHY), i05H2Parameters(runCy,ECONCHARHY));
*---
i05PolH2AreaMax(runCy) = i05H2Parameters(runCy,"MAXAREA");
*---
i05HabAreaCountry(runCy) = i05H2Parameters(runCy,"AREA");
*---
i05EffNetH2Transp(runCy,INFRTECH,YTIME) = i05EffH2Transp(runCy,INFRTECH,YTIME)*(1-i05ConsSelfH2Transp(runCy,INFRTECH,YTIME));
*---
loop H2EFFLOOP do
  loop INFRTECH2$H2NETWORK(INFRTECH2,H2EFFLOOP) do
         i05EffNetH2Transp(runCy,H2EFFLOOP,YTIME) =  i05EffNetH2Transp(runCy,INFRTECH2,YTIME)*i05EffH2Transp(runCy,H2EFFLOOP,YTIME);
  endloop;
endloop;
*---
i05CostAvgWeight(runCy,YTIME) = 1;
loop YTIME$(An(YTIME)) do
         i05CostAvgWeight(runCy,YTIME) = -1/19+i05CostAvgWeight(runCy,YTIME-1);
endloop;
*---