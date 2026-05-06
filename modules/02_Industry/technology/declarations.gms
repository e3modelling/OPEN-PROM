*' @title INDUSTRY  - DOMESTIC - NON ENERGY USES - BUNKERS EQUATIONS Declarations
*' @code

Parameters
i02ExogDemOfBiomass(allCy,DSBS,YTIME)	                   "Demand of tranditional biomass defined exogenously ()"
$IF NOT %Calibration% == Calibration i02ElastNonSubElec(allCy,DSBS,ETYPES,YTIME)                   "Elasticities of Non Substitutable Electricity (1)"
i02util(allCy,DSBS,ITECH,YTIME)                            "Utilization rate of technology"
i02numtechnologiesUsingEF(DSBS,EF)                         "Number of technologues using an energy form"     
imCO2CaptRateIndustry(allCy,ITECH,YTIME)	               "Industry CO2 capture rate (1)"
i02ScaleEndogScrap(DSBS)                            "Scale parameter for endogenous scrapping applied to the sum of full costs (1)"
i02ShareBlend(allCy,DSBS,ITECH,EF,YTIME)                   "Share of each energy form in a technology"
i02ShareElcHP(allCy,DSBS,YTIME)                            "Share of final electricity consumption of HeatPumps in substitutable electricity consumption (1)"

p02DemSubUsefulSubsec(allCy,DSBS,YTIME)                    "Stored useful substitutable energy demand for solved years"
p02GapUsefulDemSubsec(allCy,DSBS,YTIME)                    "Stored useful energy demand gap for solved years"
p02RemEquipCapTechSubsec(allCy,DSBS,ITECH,YTIME)           "Stored remaining equipment capacity by technology for solved years"
p02DemUsefulSubsecRemTech(allCy,DSBS,YTIME)                "Stored useful demand covered by remaining equipment for solved years"
p02EquipCapTechSubsec(allCy,DSBS,ITECH,YTIME)              "Stored equipment capacity by technology for solved years"
p02CapCostTech(allCy,DSBS,ITECH,YTIME)                     "Stored capital cost by technology for solved years"
p02VarCostTech(allCy,DSBS,ITECH,YTIME)                     "Stored variable cost by technology for solved years"
p02CostTech(allCy,DSBS,ITECH,YTIME)                        "Stored total cost by technology for solved years"
p02ShareTechNewEquipUseful(allCy,DSBS,ITECH,YTIME)         "Stored technology shares in new useful energy equipment for solved years"
p02UsefulElecNonSubIndTert(allCy,DSBS,YTIME)               "Stored useful non-substitutable electricity for solved years"
p02FinalElecNonSubIndTert(allCy,DSBS,YTIME)                "Stored final non-substitutable electricity for solved years"
p02IndxElecIndPrices(allCy,TCHP,YTIME)                     "Stored electricity index for solved years"
p02IndAvrEffFinalUseful(allCy,DSBS,YTIME)                  "Stored average final/useful efficiency for solved years"
p02PremScrpIndu(allCy,DSBS,ITECH,YTIME)                    "Stored premature scrapping by technology for solved years"
p02RatioRem(allCy,DSBS,ITECH,YTIME)                        "Stored remaining-capacity ratio by technology for solved years"
p02ConsFuel(allCy,DSBS,EF,YTIME)                           "Stored fuel consumption by subsector and fuel for solved years"
;

Equations
*' ***  INDUSTRY  - DOMESTIC - NON ENERGY USES - BUNKERS EQUATIONS
Q02DemSubUsefulSubsec(allCy,DSBS,YTIME)                    "Compute Demand for useful substitutable energy demand in each subsector"
Q02RemEquipCapTechSubsec(allCy,DSBS,ITECH,YTIME)           "Compute Remaining Equipment Capacity per Technology in each subsector (substitutable)"
Q02DemUsefulSubsecRemTech(allCy,DSBS,YTIME)                "Compute Useful energy demand (substitutable) covered by remaining equipment"
Q02GapUsefulDemSubsec(allCy,DSBS,YTIME)                    "Compute gap in useful energy demand per subsector"
Q02CapCostTech(allCy,DSBS,ITECH,YTIME)                     "Compute capital cost of each technology per subsector (final)"
!!Q02CapCostTech1(allCy,DSBS,ITECH,YTIME)
Q02VarCostTech(allCy,DSBS,ITECH,YTIME)                     "Compute variable cost of each technology per subsector (final)"
Q02CostTech(allCy,DSBS,ITECH,YTIME)                        "Compute total cost of each technology per subsector (useful)"
Q02ShareTechNewEquipUseful(allCy,DSBS,ITECH,YTIME)         "Compute share of each technology in gap of useful energy"
Q02EquipCapTechSubsec(allCy,DSBS,ITECH,YTIME)              "Compute equipment capacity of each technology in each subsector"
Q02UsefulElecNonSubIndTert(allCy,DSBS,YTIME)               "Compute non-substitutable useful electricity"
Q02FinalElecNonSubIndTert(allCy,DSBS,YTIME)                "Compute final energy of non-substitutable electricity"

Q02IndxElecIndPrices(allCy,TCHP,YTIME)                          "Compute Electricity index - a function of industry price - Estimate"
Q02IndAvrEffFinalUseful(allCy,DSBS,YTIME)                  "Average Efficiency" 
Q02PremScrpIndu(allCy,DSBS,ITECH,YTIME)                    "premature scrapping"
Q02RatioRem(allCy,DSBS,ITECH,YTIME)
*'                **Interdependent Equations**
Q02ConsFuel(allCy,DSBS,EF,YTIME)                           "Compute fuel consumption of fuels in each subsector"
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
!!V02CapCostTech1(allCy,DSBS,ITECH,YTIME)
V02ShareTechNewEquipUseful(allCy,DSBS,ITECH,YTIME)         "share of each technology in gap of useful energy"
V02EquipCapTechSubsec(allCy,DSBS,ITECH,YTIME)              "equipment capacity of each technology in each subsector"
V02UsefulElecNonSubIndTert(allCy,DSBS,YTIME)               "non-substitutable useful electricity"
V02FinalElecNonSubIndTert(allCy,DSBS,YTIME)                "final energy of non-substitutable electricity"

V02IndxElecIndPrices(allCy,TCHP,YTIME)                          "Electricity index - a function of industry price - Estimate"
V02IndAvrEffFinalUseful(allCy,DSBS,YTIME)                  "Average Efficiency" 
V02PremScrpIndu(allCy,DSBS,ITECH,YTIME)                    "premature scrapping"
V02RatioRem(allCy,DSBS,ITECH,YTIME)
*'                **Interdependent Variables**
VmConsFuel(allCy,DSBS,EF,YTIME)                            "fuel consumption of fuels in each subsector"
;