*' @title Hydrogen input
*' @code

*---
table iH2Production(allCy,EF,YTIME)	 "Data for Hydrogen production"
$ondelim
$include"./iH2Production.csv"
$offdelim
;
*---
table iH2Parameters(allCy,EF,YTIME)	 "Data for Hydrogen Parameters"
$ondelim
$include"./iH2Parameters.csv"
$offdelim
;
*---
table iH2InfrastructureCapCosts(allCy,EF,YTIME)	 "Data for Hydrogen Infrastructure Costs"
$ondelim
$include"./iH2InfrastructureCapCosts.csv"
$offdelim
;
*---
parameter iWBLGammaH2Prod(allCy,YTIME)           "Parameter for acceptance in new investments used in weibull function in production shares";
iWBLGammaH2Prod(runCy,YTIME) = 4;
*---
parameter iProdLftH2(H2TECH)                     "Lifetime of hydrogen production technologies in years";
iProdLftH2(H2TECH)=iH2Production(H2TECH,"LFT");
*---
parameter iCaptRateH2Prod(allCy,H2TECH,YTIME)    "CO2 capture rate of hydrogen production technologies (for those which are equipped with CCS facility)";
iCaptRateH2Prod(runCy,H2TECH,YTIME)=iH2Production(H2TECH,"CR");
*---
parameter iH2Adopt(allCy,ARELAST,YTIME)          "Parameters controlling the speed and the year of taking off the transition to hydrogen economy";
iH2Adopt(runCy,"b",YTIME)=iH2Parameters(runCy,"b");
iH2Adopt(runCy,"mid",YTIME)=iH2Parameters(runCy,"mid");
*---
parameter iTranspLftH2(INFRTECH)                 "Technical lifetime of infrastructure technologies";
iTranspLftH2(INFRTECH)=iH2InfrastructureCapCosts(INFRTECH,"LFT");
*---
parameter iCostCapH2Prod(allCy,H2TECH,YTIME)     "Capital cost of hydrogen production technologies in Euro per Nm3 of hydrogen";
iCostCapH2Prod(runCy,H2TECH,"2000")=iH2Production(H2TECH,"IC_00");
iCostCapH2Prod(runCy,H2TECH,"2025")=iH2Production(H2TECH,"IC_25");
iCostCapH2Prod(runCy,H2TECH,"2050")=iH2Production(H2TECH,"IC_50");
iCostCapH2Prod(runCy,H2TECH,YTIME1)=(iCostCapH2Prod(runCy,H2TECH,"2025")-iCostCapH2Prod(runCy,H2TECH,"2000"))/(2025-2000)*(YTIME1.VAL-2000)+iCostCapH2Prod(runCy,H2TECH,"2000");
iCostCapH2Prod(runCy,H2TECH,YTIME2)=(iCostCapH2Prod(runCy,H2TECH,"2050")-iCostCapH2Prod(runCy,H2TECH,"2025"))/(2050-2025)*(YTIME2.VAL-2025)+iCostCapH2Prod(runCy,H2TECH,"2025");
*---
parameter iCostFOMH2Prod(allCy,H2TECH,YTIME)     "Fixed operating and maintenance costs of hydrogen production technologies in Euro per Nm3 of hydrogen";
iCostFOMH2Prod(runCy,H2TECH,"2000")=iH2Production(H2TECH,"FC_00");
iCostFOMH2Prod(runCy,H2TECH,"2025")=iH2Production(H2TECH,"FC_25");
iCostFOMH2Prod(runCy,H2TECH,"2050")=iH2Production(H2TECH,"FC_50");
iCostFOMH2Prod(runCy,H2TECH,YTIME1)=(iCostFOMH2Prod(runCy,H2TECH,"2025")-iCostFOMH2Prod(runCy,H2TECH,"2000"))/(2025-2000)*(YTIME1.VAL-2000)+iCostFOMH2Prod(runCy,H2TECH,"2000");
iCostFOMH2Prod(runCy,H2TECH,YTIME2)=(iCostFOMH2Prod(runCy,H2TECH,"2050")-iCostFOMH2Prod(runCy,H2TECH,"2025"))/(2050-2025)*(YTIME2.VAL-2025)+iCostFOMH2Prod(runCy,H2TECH,"2025");
*---
parameter iCostVOMH2Prod(allCy,H2TECH,YTIME)     "Variable operating and maintenance costs of hydrogen production technologies in Euro per toe of hydrogen";
iCostVOMH2Prod(runCy,H2TECH,"2000")=iH2Production(H2TECH,"VC_00");
iCostVOMH2Prod(runCy,H2TECH,"2025")=iH2Production(H2TECH,"VC_25");
iCostVOMH2Prod(runCy,H2TECH,"2050")=iH2Production(H2TECH,"VC_50");
iCostVOMH2Prod(runCy,H2TECH,YTIME1)=(iCostVOMH2Prod(runCy,H2TECH,"2025")-iCostVOMH2Prod(runCy,H2TECH,"2000"))/(2025-2000)*(YTIME1.VAL-2000)+iCostVOMH2Prod(runCy,H2TECH,"2000");
iCostVOMH2Prod(runCy,H2TECH,YTIME2)=(iCostVOMH2Prod(runCy,H2TECH,"2050")-iCostVOMH2Prod(runCy,H2TECH,"2025"))/(2050-2025)*(YTIME2.VAL-2025)+iCostVOMH2Prod(runCy,H2TECH,"2025");
*---
parameter iAvailH2Prod(H2TECH,YTIME)             "Availability of hydrogen production technologies";
iAvailH2Prod(H2TECH,"2000")=iH2Production(H2TECH,"AVAIL_00");
iAvailH2Prod(H2TECH,"2025")=iH2Production(H2TECH,"AVAIL_25");
iAvailH2Prod(H2TECH,"2050")=iH2Production(H2TECH,"AVAIL_50");
iAvailH2Prod(H2TECH,YTIME1)=(iAvailH2Prod(H2TECH,"2025")-iAvailH2Prod(H2TECH,"2000"))/(2025-2000)*(YTIME1.VAL-2000)+iAvailH2Prod(H2TECH,"2000");
iAvailH2Prod(H2TECH,YTIME2)=(iAvailH2Prod(H2TECH,"2050")-iAvailH2Prod(H2TECH,"2025"))/(2050-2025)*(YTIME2.VAL-2025)+iAvailH2Prod(H2TECH,"2025");
*---
parameter iEffH2Prod(allCy,H2TECH,YTIME)         "Efficiency of hydrogen production technologies";
iEffH2Prod(runCy,H2TECH,"2000")=iH2Production(H2TECH,"EFF_00");
iEffH2Prod(runCy,H2TECH,"2025")=iH2Production(H2TECH,"EFF_25");
iEffH2Prod(runCy,H2TECH,"2050")=iH2Production(H2TECH,"EFF_50");
iEffH2Prod(runCy,H2TECH,YTIME1)=(iEffH2Prod(runCy,H2TECH,"2025")-iEffH2Prod(runCy,H2TECH,"2000"))/(2025-2000)*(YTIME1.VAL-2000)+iEffH2Prod(runCy,H2TECH,"2000");
iEffH2Prod(runCy,H2TECH,YTIME2)=(iEffH2Prod(runCy,H2TECH,"2050")-iEffH2Prod(runCy,H2TECH,"2025"))/(2050-2025)*(YTIME2.VAL-2025)+iEffH2Prod(runCy,H2TECH,"2025");
*---
parameter iCostInvH2Transp(allCy,INFRTECH,YTIME)  "Investment cost of infrastructure technology";
                                                   !! - Turnpike pipeline in Euro per km
                                                   !! - Low pressure urban pipeline in Euro per km
                                                   !! - Medium pressure ring in Euro per km
                                                   !! - Service stations connection lines in Euro per km
                                                   !! - Gaseous hydrogen service stations in Euro per toe per year
iCostInvH2Transp(runCy,INFRTECH,"2000")=iH2InfrastructureCapCosts(INFRTECH,"IC_00");
iCostInvH2Transp(runCy,INFRTECH,"2025")=iH2InfrastructureCapCosts(INFRTECH,"IC_25");
iCostInvH2Transp(runCy,INFRTECH,"2050")=iH2InfrastructureCapCosts(INFRTECH,"IC_50");
iCostInvH2Transp(runCy,INFRTECH,YTIME1)=(iCostInvH2Transp(runCy,INFRTECH,"2025")-iCostInvH2Transp(runCy,INFRTECH,"2000"))/(2025-2000)*(YTIME1.VAL-2000)+iCostInvH2Transp(runCy,INFRTECH,"2000");
iCostInvH2Transp(runCy,INFRTECH,YTIME2)=(iCostInvH2Transp(runCy,INFRTECH,"2050")-iCostInvH2Transp(runCy,INFRTECH,"2025"))/(2050-2025)*(YTIME2.VAL-2025)+iCostInvH2Transp(runCy,INFRTECH,"2025");
*---
parameter iEffH2Transp(allCy,INFRTECH,YTIME)      "Efficiency of hydrogen transportation per infrastructure technology";
iEffH2Transp(runCy,INFRTECH,"2000")=iH2InfrastructureCapCosts(INFRTECH,"EFF_00");
iEffH2Transp(runCy,INFRTECH,"2025")=iH2InfrastructureCapCosts(INFRTECH,"EFF_25");
iEffH2Transp(runCy,INFRTECH,"2050")=iH2InfrastructureCapCosts(INFRTECH,"EFF_50");
iEffH2Transp(runCy,INFRTECH,YTIME1)=(iEffH2Transp(runCy,INFRTECH,"2025")-iEffH2Transp(runCy,INFRTECH,"2000"))/(2025-2000)*(YTIME1.VAL-2000)+iEffH2Transp(runCy,INFRTECH,"2000");
iEffH2Transp(runCy,INFRTECH,YTIME2)=(iEffH2Transp(runCy,INFRTECH,"2050")-iEffH2Transp(runCy,INFRTECH,"2025"))/(2050-2025)*(YTIME2.VAL-2025)+iEffH2Transp(runCy,INFRTECH,"2025");
*---
parameter iConsSelfH2Transp(allCy,INFRTECH,YTIME)  "Self consumption of infrastructure technology rate";
iConsSelfH2Transp(runCy,INFRTECH,"2000")=iH2InfrastructureCapCosts(INFRTECH,"SELF_00");
iConsSelfH2Transp(runCy,INFRTECH,"2025")=iH2InfrastructureCapCosts(INFRTECH,"SELF_25");
iConsSelfH2Transp(runCy,INFRTECH,"2050")=iH2InfrastructureCapCosts(INFRTECH,"SELF_50");
iConsSelfH2Transp(runCy,INFRTECH,YTIME1)=(iConsSelfH2Transp(runCy,INFRTECH,"2025")-iConsSelfH2Transp(runCy,INFRTECH,"2000"))/(2025-2000)*(YTIME1.VAL-2000)+iConsSelfH2Transp(runCy,INFRTECH,"2000");
iConsSelfH2Transp(runCy,INFRTECH,YTIME2)=(iConsSelfH2Transp(runCy,INFRTECH,"2050")-iConsSelfH2Transp(runCy,INFRTECH,"2025"))/(2050-2025)*(YTIME2.VAL-2025)+iConsSelfH2Transp(runCy,INFRTECH,"2025");
*---
parameter iAvailRateH2Transp(INFRTECH,YTIME)       "Availability rate of infrastructure technology";
iAvailRateH2Transp(INFRTECH,"2000")=iH2InfrastructureCapCosts(INFRTECH,"AVAIL_00");
iAvailRateH2Transp(INFRTECH,"2025")=iH2InfrastructureCapCosts(INFRTECH,"AVAIL_25");
iAvailRateH2Transp(INFRTECH,"2050")=iH2InfrastructureCapCosts(INFRTECH,"AVAIL_50");
iAvailRateH2Transp(INFRTECH,YTIME1)=(iAvailRateH2Transp(INFRTECH,"2025")-iAvailRateH2Transp(INFRTECH,"2000"))/(2025-2000)*(YTIME1.VAL-2000)+iAvailRateH2Transp(INFRTECH,"2000");
iAvailRateH2Transp(INFRTECH,YTIME2)=(iAvailRateH2Transp(INFRTECH,"2050")-iAvailRateH2Transp(INFRTECH,"2025"))/(2050-2025)*(YTIME2.VAL-2025)+iAvailRateH2Transp(INFRTECH,"2025");
*---
parameter iCostInvFOMH2(INFRTECH,YTIME)            "Annual fixed O&M cost as percentage of total investment cost";
iCostInvFOMH2(INFRTECH,"2000")=iH2InfrastructureCapCosts(INFRTECH,"FC_00");
iCostInvFOMH2(INFRTECH,"2025")=iH2InfrastructureCapCosts(INFRTECH,"FC_25");
iCostInvFOMH2(INFRTECH,"2050")=iH2InfrastructureCapCosts(INFRTECH,"FC_50");
iCostInvFOMH2(INFRTECH,YTIME1)=(iCostInvFOMH2(INFRTECH,"2025")-iCostInvFOMH2(INFRTECH,"2000"))/(2025-2000)*(YTIME1.VAL-2000)+iCostInvFOMH2(INFRTECH,"2000");
iCostInvFOMH2(INFRTECH,YTIME2)=(iCostInvFOMH2(INFRTECH,"2050")-iCostInvFOMH2(INFRTECH,"2025"))/(2050-2025)*(YTIME2.VAL-2025)+iCostInvFOMH2(INFRTECH,"2025");
*---
parameter iCostInvVOMH2(INFRTECH,YTIME)            "Annual variable O&M cost as percentage of total investment cost";
iCostInvVOMH2(INFRTECH,"2000")=iH2InfrastructureCapCosts(INFRTECH,"VC_00");
iCostInvVOMH2(INFRTECH,"2025")=iH2InfrastructureCapCosts(INFRTECH,"VC_25");
iCostInvVOMH2(INFRTECH,"2050")=iH2InfrastructureCapCosts(INFRTECH,"VC_50");
iCostInvVOMH2(INFRTECH,YTIME1)=(iCostInvVOMH2(INFRTECH,"2025")-iCostInvVOMH2(INFRTECH,"2000"))/(2025-2000)*(YTIME1.VAL-2000)+iCostInvVOMH2(INFRTECH,"2000");
iCostInvVOMH2(INFRTECH,YTIME2)=(iCostInvVOMH2(INFRTECH,"2050")-iCostInvVOMH2(INFRTECH,"2025"))/(2050-2025)*(YTIME2.VAL-2025)+iCostInvVOMH2(INFRTECH,"2025");
*---
parameter iPipeH2Transp(INFRTECH)                   "Kilometers of pipelines required per toe of delivered hydrogen (based on stylized model)";
iPipeH2Transp(INFRTECH) =  iH2InfrastructureCapCosts(INFRTECH,"H2KMTOE");

parameter iKmFactH2Transp(allCy,INFRTECH)           "Km needed for a given infrastructure assuming that its required infrastructure has been arleady installed";
iKmFactH2Transp(runCy,INFRTECH) = sum(alllabels$INFRTECHLAB(INFRTECH,alllabels), iH2Parameters(runCy,alllabels));

parameter iPolH2AreaMax(allCy)                      "Policy parameter defining the percentage of the country area supplied by hydrogen at the end of the horizon period [0...1]";
iPolH2AreaMax(runCy) = iH2Parameters(runCy,"MAXAREA");

parameter iHabAreaCountry(allCy)                    "Inhabitable land in a country";
iHabAreaCountry(runCy) = iH2Parameters(runCy,"AREA");
*---
parameter iEffNetH2Transp(allCy,INFRTECH,YTIME)     "Total efficiency of the distribution network until the <infrtech> node";
iEffNetH2Transp(runCy,INFRTECH,YTIME) = iEffH2Transp(runCy,INFRTECH,YTIME)*(1-iConsSelfH2Transp(runCy,INFRTECH,YTIME));
*---
loop H2EFFLOOP do
  loop INFRTECH2$H2NETWORK(INFRTECH2,H2EFFLOOP) do
         iEffNetH2Transp(runCy,H2EFFLOOP,YTIME) =  iEffNetH2Transp(runCy,INFRTECH2,YTIME)*iEffH2Transp(runCy,H2EFFLOOP,YTIME);
  endloop;
endloop;
*---
parameter iCostAvgWeight(allCy,YTIME)                "Weight for pricing in average cost or in marginal cost";
iCostAvgWeight(runCy,YTIME) = 1;
loop YTIME$(An(YTIME) $(not sameas("2006",YTIME))) do
         iCostAvgWeight(runCy,YTIME) = -1/19+iCostAvgWeight(runCy,YTIME-1);
endloop;
*---
$ontext
*        Calibration parameters
parameter iWBLShareH2Prod(allCy,H2TECH,YTIME)             "Parameter for controlling the weibull function for calculating the shares in new market";
parameter iWBLPremRepH2Prod(allCy,H2TECH,YTIME)           "Parameter for controlling the premature replacement of technology";
$offtext
*---