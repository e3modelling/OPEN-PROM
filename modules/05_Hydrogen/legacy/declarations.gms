*' @title Hydrogen Declarations
*' @code

Parameters
iProdLftH2(H2TECH)                               "Lifetime of hydrogen production technologies in years"
iCostCapH2Prod(CYall,H2TECH,YTIME)               "Capital cost of hydrogen production technologies in Euro per Nm3 of hydrogen"
iCostFOMH2Prod(CYall,H2TECH,YTIME)               "Fixed operating and maintenance costs of hydrogen production technologies in Euro per Nm3 of hydrogen"
iAvailH2Prod(H2TECH,YTIME)                       "Availability of hydrogen production technologies"
iCostVOMH2Prod(CYall,H2TECH,YTIME)               "Variable operating and maintenance costs of hydrogen production technologies in Euro per toe of hydrogen"
iEffH2Prod(CYall,H2TECH,YTIME)                   "Efficiency of hydrogen production technologies"
iCaptRateH2Prod(CYall,H2TECH,YTIME)              "CO2 capture rate of hydrogen production technologies (for those which are equipped with CCS facility)"

$ontext
*        Calibration parameters
iWBLShareH2Prod(CYall,H2TECH,YTIME)             "Parameter for controlling the weibull function for calculating the shares in new market"
iWBLPremRepH2Prod(CYall,H2TECH,YTIME)           "Parameter for controlling the premature replacement of technology"
$offtext

*'                **Infrastructure parameters**

iPolH2AreaMax(CYall)                            "Policy parameter defining the percentage of the country area supplied by hydrogen at the end of the horizon period [0...1]"
iHabAreaCountry(CYall)                          "Inhabitable land in a country"
iH2Adopt(CYall,ARELAST,YTIME)                   "Parameters controlling the speed and the year of taking off the transition to hydrogen economy"
iEffH2Transp(CYall,INFRTECH,YTIME)              "Efficiency of hydrogen transportation per infrastructure technology"
iConsSelfH2Transp(CYall,INFRTECH,YTIME)         "Self consumption of infrastructure technology rate"
iEffNetH2Transp(CYall,INFRTECH,YTIME)           "Total efficiency of the distribution network until the <infrtech> node"
iPipeH2Transp(INFRTECH)                         "Kilometers of pipelines required per toe of delivered hydrogen (based on stylized model)"
iKmFactH2Transp(CYall,INFRTECH)                 "Km needed for a given infrastructure assuming that its required infrastructure has been arleady installed"
iCostInvH2Transp(CYall,INFRTECH,YTIME)          "Investment cost of infrastructure technology"
                                                   !! - Turnpike pipeline in Euro per km
                                                   !! - Low pressure urban pipeline in Euro per km
                                                   !! - Medium pressure ring in Euro per km
                                                   !! - Service stations connection lines in Euro per km
                                                   !! - Gaseous hydrogen service stations in Euro per toe per year
iTranspLftH2(INFRTECH)                          "Technical lifetime of infrastructure technologies"
iAvailRateH2Transp(INFRTECH,YTIME)              "Availability rate of infrastructure technology"
iCostInvFOMH2(INFRTECH,YTIME)                   "Annual fixed O&M cost as percentage of total investment cost"
iCostInvVOMH2(INFRTECH,YTIME)                   "Annual variable O&M cost as percentage of total investment cost"
iCostAvgWeight(CYALL,YTIME)                     "Weight for pricing in average cost or in marginal cost"
;

Variables
VGapShareH2Tech1(CYall, H2TECH, YTIME)          "Shares of H2 production technologies in new market competition 1"
VGapShareH2Tech2(CYall, H2TECH, YTIME)          "Shares of H2 production technologies in new market competition 2"
VProdH2(CYall, H2TECH, YTIME)                   "Hydrogen Production by technology in Mtoe"
VCapScrapH2ProdTech(CYall, H2TECH, YTIME)       "Decommissioning of capacity by H2 production technology"
VPremRepH2Prod(CYall, H2TECH, YTIME)            "Premature replacement of H2 production technologies"
VScrapLftH2Prod(CYall, H2TECH, YTIME)           "Scrapping of equipment due to lifetime (normal scrapping)"
VDemTotH2(CYall, SBS, YTIME)                    "Demand for H2 by sector in mtoe"
VDemGapH2(CYall, YTIME)                         "Demand for H2 to be covered by new equipment in mtoe"
VCostProdH2Tech(CYall, H2TECH, YTIME)           "Hydrogen production cost per technology in Euro per toe of hydrogen"
VCostVarProdH2Tech(CYall, H2TECH, YTIME)        "Variable cost (including fuel cost) for hydrogen production by technology in Euro per toe"
VShareCCSH2Prod(CYall, H2TECH, YTIME)           "Share of CCS technology in the decision tree between CCS and no CCS"
VShareNoCCSH2Prod(CYall, H2TECH, YTIME)         "Share of technology without CCS in the decision tree between CCS and no CCS"
VAcceptCCSH2Tech(CYall, YTIME)                  "Acceptance of investment in CCS technologies"
VConsFuelH2Prod(CYall, EF, YTIME)               "Total fuel consumption for hydrogen production in Mtoe"
VConsFuelTechH2Prod(CYall, H2TECH, EF, YTIME)   "Fuel consumption by hydrogen production technology in Mtoe"
VCostProdCCSNoCCSH2Prod(CYall, H2TECH, YTIME)   "Production cost of the composite technology with and without CCS in Euro per toe"
VCostAvgProdH2(CYall, YTIME)                    "Average production cost of hydrogen in Euro per toe"

*'                **Infrastructure Parameters**

VH2InfrArea(CYall, YTIME)                       "Number of stylised areas covered by H2 infrastructure"
VDelivH2InfrTech(CYall, INFRTECH, YTIME)        "Hydrogen delivered by infrastructure technology in Mtoe"
VInvNewReqH2Infra(CYall, INFRTECH, YTIME)       "New infrastructure requirements in Mtoe of delivered hydrogen"
VCostInvTechH2Infr(CYall, INFRTECH, YTIME)      "Required capacity to meet the new infrastructure requirements"
                                                    !! - km of pipelines
                                                    !! - number of service stations
VCostInvCummH2Transp(CYall, INFRTECH, YTIME)    "Investment cost of infrastructure by technology in Million Euros (MEuro) for meeting the new infrastructure requirements"
VH2Pipe(CYall, INFRTECH, YTIME)                 "Average cost of infrastructure Euro per toe"
VCostTechH2Infr(CYall, INFRTECH, YTIME)         "Marginal cost by infrastructure technology in Euro"
VTariffH2Infr(CYall, INFRTECH, YTIME)           "Tarrif paid by the final consumer for using the specific infrastructure technology in Euro per toe annual"
VPriceH2Infr(CYall, SBS, YTIME)                 "Hydrogen distribution and storage price paid by final consumer in Euro per toe annual"
VCostTotH2(CYall, SBS, YTIME)                   "Total Hydrogen Cost Per Sector in Euro per toe"

*' *** Miscellaneous
VDemH2Req(CYall, YTIME)                         "Hydrogen production requirement in Mtoe for meeting final demand"
VProdCapH2Tech(CYall, H2TECH, YTIME)            "Production capacity by H2 production technology"
;

Equations
QDemTotH2(CYall, YTIME)                         "Equation for total hydrogen demand in a country in Mtoe"
QCapScrapH2ProdTech(CYall, H2TECH, YTIME)       "Equation for decommissioning of capacity by H2 production technology"
QPremRepH2Prod(CYall, H2TECH, YTIME)            "Equation for premature replacement of H2 production technologies"
QScrapLftH2Prod(CYall, H2TECH, YTIME)           "Equation for scrapping of equipment due to lifetime (normal scrapping)"
QDemGapH2(CYall, YTIME)                         "Equation for gap in hydrogen demand"
QCostProdH2Tech(CYall, H2TECH, YTIME)           "Equation for hydrogen production cost per technology"
QCostVarProdH2Tech(CYall, H2TECH, YTIME)        "Equation for variable cost (including fuel cost) for hydrogen production by technology in Euro per toe"
QShareCCSH2Prod(CYall, H2TECH, YTIME)           "Equation for share of CCS technology in the decision tree between CCS and no CCS"
QShareNoCCSH2Prod(CYall, H2TECH, YTIME)         "Equation for share of technology without CCS in the decision tree between CCS and no CCS"
QAcceptCCSH2Tech(CYall, YTIME)                  "Equation for acceptance in CCS technologies"
QCostProdCCSNoCCSH2Prod(CYall, H2TECH, YTIME)   "Equation for calculating the production cost of the composite technology with and without CCS"
QGapShareH2Tech1(CYall, H2TECH, YTIME)          "Equation for calculating the shares of technologies in hydrogen gap using Weibull equations 1"
QGapShareH2Tech2(CYall, H2TECH, YTIME)          "Equation for calculating the shares of technologies in hydrogen gap using Weibull equations 2"
QConsFuelTechH2Prod(CYall, H2TECH, EF, YTIME)   "Equation for fuel consumption by technology for hydrogen production"
QConsFuelH2Prod(CYall, EF, YTIME)               "Equation for total fuel consumption for hydrogen production"
QProdH2(CYall, H2TECH, YTIME)                   "Equation for H2 production by technology"
QCostAvgProdH2(CYall, YTIME)                    "Equation for average production cost of hydrogen in Euro per toe"

*'                **Infrastructure Equations**
QH2InfrArea(CYall, YTIME)                       "Equation for infrastructure area"
QDelivH2InfrTech(CYall, INFRTECH, YTIME)        "Equation for hydrogen delivered by infrastructure technology in Mtoe"
QInvNewReqH2Infra(CYall, INFRTECH, YTIME)       "Equation for calculating the new requirements in infrastructure in Mtoe"
QCostInvTechH2Infr(CYall, INFRTECH, YTIME)      "Equation for infrastructure investment cost in Euro by technology"
QCostInvCummH2Transp(CYall, INFRTECH, YTIME)    "Equation for cumulative investment cost by infrastructure technology"
QH2Pipe(CYall, INFRTECH, YTIME)                 "Equation for km per pipeline"
QCostTechH2Infr(CYall, INFRTECH, YTIME)         "Equation for marginal cost by infrastructure technology in Euro"
QTariffH2Infr(CYall, INFRTECH, YTIME)           "Equation for calculating the tariff paid by the final consumer for using the specific infrastructure technology"
QPriceH2Infr(CYall, SBS, YTIME)                 "Equation for calulcating the hydrogen storage and distribution price by final consumer"
QCostTotH2(CYall, SBS, YTIME)                   "Equation of total hydrogen cost Per Sector"
;

Scalars
sAreaStyle                                     "stylised area in km2" /3025/
sSalesH2Station                                "annual sales of a hydrogen service station in ktoe" /2.26/
sLenH2StationConn                              "length of pipes connection service stations with the ring in km per station" /2/
sDelivH2Turnpike                               "stylised annual hydrogen delivery in turnpike pipeline in ktoe" /275/
;
