*' @title Hydrogen Declarations
*' @code

Variables
V05GapShareH2Tech1(allCy, H2TECH, YTIME)          "Shares of H2 production technologies in new market competition 1"
V05GapShareH2Tech2(allCy, H2TECH, YTIME)          "Shares of H2 production technologies in new market competition 2"
V05CapScrapH2ProdTech(allCy, H2TECH, YTIME)       "Decommissioning of capacity by H2 production technology"
V05PremRepH2Prod(allCy, H2TECH, YTIME)            "Premature replacement of H2 production technologies"
V05ScrapLftH2Prod(allCy, H2TECH, YTIME)           "Scrapping of equipment due to lifetime (normal scrapping)"
V05DemGapH2(allCy, YTIME)                         "Demand for H2 to be covered by new equipment in mtoe"
V05CostProdH2Tech(allCy, H2TECH, YTIME)           "Hydrogen production cost per technology in US$2015 per toe of hydrogen"
V05CostVarProdH2Tech(allCy, H2TECH, YTIME)        "Variable cost (including fuel cost) for hydrogen production by technology in US$2015 per toe"
V05ShareCCSH2Prod(allCy, H2TECH, YTIME)           "Share of CCS technology in the decision tree between CCS and no CCS"
V05ShareNoCCSH2Prod(allCy, H2TECH, YTIME)         "Share of technology without CCS in the decision tree between CCS and no CCS"
V05AcceptCCSH2Tech(allCy, YTIME)                  "Acceptance of investment in CCS technologies"
V05CostProdCCSNoCCSH2Prod(allCy, H2TECH, YTIME)   "Production cost of the composite technology with and without CCS in Euro per toe"
V05CaptRateH2(allCy,H2TECH,YTIME)                 "Capture rate of hydrogen production technologies"

*'                **Interdependent Variables**	
VmDemTotH2(allCy, YTIME)                          "Hydrogen production requirement in Mtoe for meeting final demand"
VmProdH2(allCy, H2TECH, YTIME)                    "Hydrogen Production by technology in Mtoe"
VmConsFuelTechH2Prod(allCy, H2TECH, EF, YTIME)    "Fuel consumption by hydrogen production technology in Mtoe"
VmDemSecH2(allCy, SBS, YTIME)                     "Demand for H2 by sector in mtoe"
VmCostAvgProdH2(allCy, YTIME)                     "Average production cost of hydrogen in Euro per toe"
VmConsFuelH2Prod(allCy, EF, YTIME)                "Total fuel consumption for hydrogen production in Mtoe"
;

Equations
Q05GapShareH2Tech1(allCy, H2TECH, YTIME)          "Equation for calculating the shares of technologies in hydrogen gap using Weibull equations 1"
Q05GapShareH2Tech2(allCy, H2TECH, YTIME)          "Equation for calculating the shares of technologies in hydrogen gap using Weibull equations 2"
Q05CapScrapH2ProdTech(allCy, H2TECH, YTIME)       "Equation for decommissioning of capacity by H2 production technology"
Q05PremRepH2Prod(allCy, H2TECH, YTIME)            "Equation for premature replacement of H2 production technologies"
Q05ScrapLftH2Prod(allCy, H2TECH, YTIME)           "Equation for scrapping of equipment due to lifetime (normal scrapping)"
Q05DemGapH2(allCy, YTIME)                         "Equation for gap in hydrogen demand"
Q05CostProdH2Tech(allCy, H2TECH, YTIME)           "Equation for hydrogen production cost per technology"
Q05CostVarProdH2Tech(allCy, H2TECH, YTIME)        "Equation for variable cost (including fuel cost) for hydrogen production by technology in Euro per toe"
Q05ShareCCSH2Prod(allCy, H2TECH, YTIME)           "Equation for share of CCS technology in the decision tree between CCS and no CCS"
Q05ShareNoCCSH2Prod(allCy, H2TECH, YTIME)         "Equation for share of technology without CCS in the decision tree between CCS and no CCS"
Q05AcceptCCSH2Tech(allCy, YTIME)                  "Equation for acceptance in CCS technologies"
Q05CostProdCCSNoCCSH2Prod(allCy, H2TECH, YTIME)   "Equation for calculating the production cost of the composite technology with and without CCS"
Q05CaptRateH2(allCy,H2TECH,YTIME)                 "Equation for capture rate of hydrogen production technologies"

*'                **Interdependent Equations**	
Q05DemTotH2(allCy, YTIME)                         "Equation for total hydrogen demand in a country in Mtoe"
Q05ProdH2(allCy, H2TECH, YTIME)                   "Equation for H2 production by technology"
Q05ConsFuelTechH2Prod(allCy, H2TECH, EF, YTIME)   "Equation for fuel consumption by technology for hydrogen production"
Q05DemSecH2(allCy, SBS, YTIME)                    "Equation for demand of H2 by sector in mtoe"
Q05CostAvgProdH2(allCy, YTIME)                    "Equation for average production cost of hydrogen in Euro per toe"
Q05ConsFuelH2Prod(allCy, EF, YTIME)               "Equation for total fuel consumption for hydrogen production"
;

Scalars
s05AreaStyle                                      "stylised area in km2" /3025/
s05SalesH2Station                                 "annual sales of a hydrogen service station in ktoe" /2.26/
s05LenH2StationConn                               "length of pipes connection service stations with the ring in km per station" /2/
s05DelivH2Turnpike                                "stylised annual hydrogen delivery in turnpike pipeline in ktoe" /275/
;
