*' @title Hydrogen Declarations
*' @code

Parameters

iLftH2PROD(H2TECH)                              "Lifetime of hydrogen production technologies in years"
iCostCapH2Prod(CYall,H2TECH,YTIME)              "Capital cost of hydrogen production technologies in Euro per Nm3 of hydrogen"
iCostFOMH2Prod(CYall,H2TECH,YTIME)              "Fixed operating and maintenance costs of hydrogen production technologies in Euro per Nm3 of hydrogen"
iAvailH2Prod(H2TECH,YTIME)                      "Availability of hydrogen production technologies"
iCostVOMH2Prod(CYall,H2TECH,YTIME)              "Variable operating and maintenance costs of hydrogen production technologies in Euro per toe of hydrogen"
iEffH2Prod(CYall,H2TECH,YTIME)                  "Efficiency of hydrogen production technologies"
iCaptRateH2Prod(CYall,H2TECH,YTIME)             "CO2 capture rate of hydrogen production technologies (for those which are equipped with CCS facility)"

$ontext
*        Calibration parameters
iWBLShareH2Prod(CYall,H2TECH,YTIME)            Parameter for controlling the weibull function for calculating the shares in new market
iWBLGammaH2Prod(CYall,YTIME)                   Parameter for acceptance in new investments used in weibull function in production shares
iWBLPremRepH2Prod(CYall,H2TECH,YTIME)          Parameter for controlling the premature replacement of technology
$offtext

*        Infrastructure parameters

iPolH2AreaMax(CYall)                           "Policy parameter defining the percentage of the country area supplied by hydrogen at the end of the horizon period [0...1]"
iHabAreaCountry(CYall)                         "Inhabitable land in a country"
iH2Adopt(CYall,ARELAST,YTIME)                  "Parameters controlling the speed and the year of taking off the transition to hydrogen economy"
iEffH2Transp(CYall,INFRTECH,YTIME)             "Efficiency of hydrogen transportation per infrastructure technology"
iConsSelfH2Transp(CYall,INFRTECH,YTIME)        "Self consumption of infrastructure technology rate"
iEffNetH2Transp(CYall,INFRTECH,YTIME)          "Total efficiency of the distribution network until the <infrtech> node"
iPipeH2Transp(INFRTECH)                        "Kilometers of pipelines required per toe of delivered hydrogen (based on stylized model)"
iKmFactH2Transp(CYall,INFRTECH)                "Km needed for a given infrastructure assuming that its required infrastructure has been arleady installed"
iCostInvH2Transp(CYall,INFRTECH,YTIME)         "Investment cost of infrastructure technology"
                                                   !! - Turnpike pipeline in Euro per km
                                                   !! - Low pressure urban pipeline in Euro per km
                                                   !! - Medium pressure ring in Euro per km
                                                   !! - Service stations connection lines in Euro per km
                                                   !! - Gaseous hydrogen service stations in Euro per toe per year
iTranspLftH2(INFRTECH)                         "Technical lifetime of infrastructure technologies"
iAvailRateH2Transp(INFRTECH,YTIME)             "Availability rate of infrastructure technology"
iCostInvFOMH2(INFRTECH,YTIME)                  "Annual fixed O&M cost as percentage of total investment cost"
iCostInvVOMH2(INFRTECH,YTIME)                  "Annual variable O&M cost as percentage of total investment cost"
iCostAvgWeight(CYALL,YTIME)                    "Weight for pricing in average cost or in marginal cost"
;

iWBL_Gamma_H2PROD(CYall,YTIME) = 4;

Equations

;

Variables

;

Scalar

iAreaStyle                                     "stylised area in km2" /3025/
iSales_H2Station                               "annual sales of a hydrogen service station in ktoe" /2.26/
iLen_H2StationConn                             "length of pipes connection service stations with the ring in km per station" /2/
iDeliv_H2Turnpike                              "stylised annual hydrogen delivery in turnpike pipeline in ktoe" /275/
;
