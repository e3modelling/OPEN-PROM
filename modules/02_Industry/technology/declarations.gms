*' @title INDUSTRY  - DOMESTIC - NON ENERGY USES - BUNKERS EQUATIONS Declarations
*' @code

Equations
*' ***  INDUSTRY  - DOMESTIC - NON ENERGY USES - BUNKERS EQUATIONS
Q02DemSubUsefulSubsec(allCy,DSBS,YTIME)                    "Compute Demand for useful substitutable energy demand in each subsector"
Q02RemEquipCapTechSubsec(allCy,DSBS,ITECH,YTIME)           "Compute Remaining Equipment Capacity per Technology in each subsector (substitutable)"
Q02DemUsefulSubsecRemTech(allCy,DSBS,YTIME)                "Compute Useful energy demand (substitutable) covered by remaining equipment"
Q02GapUsefulDemSubsec(allCy,DSBS,YTIME)                    "Compute gap in useful energy demand per subsector"
Q02CapCostTech(allCy,DSBS,ITECH,YTIME)                     "Compute capital cost of each technology per subsector (final)"
Q02VarCostTech(allCy,DSBS,ITECH,YTIME)                     "Compute variable cost of each technology per subsector (final)"
Q02CostTech(allCy,DSBS,ITECH,YTIME)                        "Compute total cost of each technology per subsector (useful)"
Q02ShareTechNewEquipUseful(allCy,DSBS,ITECH,YTIME)         "Compute share of each technology in gap of useful energy"
Q02EquipCapTechSubsec(allCy,DSBS,ITECH,YTIME)              "Compute equipment capacity of each technology in each subsector"
Q02UsefulElecNonSubIndTert(allCy,DSBS,YTIME)               "Compute non-substitutable useful electricity"
Q02FinalElecNonSubIndTert(allCy,DSBS,YTIME)                "Compute final energy of non-substitutable electricity"

Q02IndxElecIndPrices(allCy,YTIME)                          "Compute Electricity index - a function of industry price - Estimate"
Q02CostElecProdCHP(allCy,DSBS,CHP,YTIME)                   "Compute Cost of electricity production by CHP - NEEDED?"
Q02IndAvrEffFinalUseful(allCy,DSBS,YTIME)                  "Average Efficiency" 
Q02PremScrpIndu(allCy,DSBS,ITECH,YTIME)                    "premature scrapping"
Q02RatioRem(allCy,DSBS,ITECH,YTIME)
*'                **Interdependent Equations**
Q02ConsFuel(allCy,DSBS,EF,YTIME)                           "Compute fuel consumption of fuels in each subsector"
Q02CostElcAvgProdCHP(allCy,CHP,YTIME)                      "Compute Average Electricity production cost per CHP plant - NEEDED?"
;

Variables
*' ***  INDUSTRY  - DOMESTIC - NON ENERGY USES - BUNKERS VARIABLES
V02DemSubUsefulSubsec(allCy,DSBS,YTIME)                    "Demand for useful substitutable energy demand in each subsector"
V02RemEquipCapTechSubsec(allCy,DSBS,ITECH,YTIME)           "Remaining Equipment Capacity per Technology in each subsector (substitutable)"
V02DemUsefulSubsecRemTech(allCy,DSBS,YTIME)                "Useful energy demand (substitutable) covered by remaining equipment"
V02GapUsefulDemSubsec(allCy,DSBS,YTIME)                    "gap in useful energy demand per subsector (Mtoe)"
V02CapCostTech(allCy,DSBS,ITECH,YTIME)                     "capital cost of each technology per subsector (final)"
V02VarCostTech(allCy,DSBS,ITECH,YTIME)                    "variable cost of each technology per subsector (final)"
V02CostTech(allCy,DSBS,ITECH,YTIME)                        "total cost of each technology per subsector (useful)"
V02ShareTechNewEquipUseful(allCy,DSBS,ITECH,YTIME)         "share of each technology in gap of useful energy"
V02EquipCapTechSubsec(allCy,DSBS,ITECH,YTIME)              "equipment capacity of each technology in each subsector"
V02UsefulElecNonSubIndTert(allCy,DSBS,YTIME)               "non-substitutable useful electricity"
V02FinalElecNonSubIndTert(allCy,DSBS,YTIME)                "final energy of non-substitutable electricity"

V02IndxElecIndPrices(allCy,YTIME)                          "Electricity index - a function of industry price - Estimate"
V02CostElecProdCHP(allCy,DSBS,CHP,YTIME)                   "Cost of electricity production by CHP - NEEDED?"
V02IndAvrEffFinalUseful(allCy,DSBS,YTIME)                  "Average Efficiency" 
V02PremScrpIndu(allCy,DSBS,ITECH,YTIME)                    "premature scrapping"
V02RatioRem(allCy,DSBS,ITECH,YTIME)
*'                **Interdependent Variables**
VmConsFuel(allCy,DSBS,EF,YTIME)                            "fuel consumption of fuels in each subsector"
VmCostElcAvgProdCHP(allCy,CHP,YTIME)                       "Average Electricity production cost per CHP plant - NEEDED?"
;