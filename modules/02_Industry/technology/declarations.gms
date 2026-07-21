*' @title INDUSTRY  - DOMESTIC - NON ENERGY USES - BUNKERS EQUATIONS Declarations
*' @code

Parameters
i02ExogDemOfBiomass(allCy,DSBS,YTIME)	                   "Demand of tranditional biomass defined exogenously ()"
$IF NOT %Calibration% == Calibration i02ElastNonSubElec(allCy,DSBS,ETYPES,YTIME)                   "Elasticities of Non Substitutable Electricity (1)"
i02util(allCy,DSBS,ITECH,YTIME)                            "Utilization rate of technology"
i02numtechnologiesUsingEF(DSBS,EF)                         "Number of technologues using an energy form"     
imCO2CaptRateIndustry(allCy,ITECH,YTIME)	               "Industry CO2 capture rate (1)"
i02ShareBlend(allCy,DSBS,ITECH,EF,YTIME)                   "Share of each energy form in a technology"
i02ShareElcHP(allCy,DSBS,YTIME)                            "Share of final electricity consumption of HeatPumps in substitutable electricity consumption (1)"
i02INDSpecificEnergyIntensity(allCy,DSBS,ITECH,YTIME)      "Specific energy intensity of each technology in each subsector (Mtoe/Million tons) - used only for IS"
i02CapFactor(allCy,DSBS,ITECH,YTIME)                       "Capacity factor of each technology in each subsector (1) - used only for IS"
i02ShareFeed(allCy,DSBS,ITECH,EF,YTIME)                     "Share of feedstock in each technology in each subsector (1) - used only for IS" 
imCo2EmiFacFeed(allCy,DSBS,EF,YTIME)                        "CO2 emission factor of feedstock in each subsector (tCO2/toe) - used only for IS" !!to define
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
Q02ConsFuelShare(allCy,DSBS,EF,YTIME)
Q02ConsFuelSum(allCy,DSBS,YTIME)
;

Variables
*' ***  INDUSTRY  - DOMESTIC - NON ENERGY USES - BUNKERS VARIABLES
V02DemSubUsefulSubsec(allCy,DSBS,YTIME)                    "Demand for useful substitutable energy demand in each subsector (Mtoe - Million tons for IS)"
V02RemEquipCapTechSubsec(allCy,DSBS,ITECH,YTIME)           "Remaining Equipment Capacity per Technology in each subsector (substitutable) (Mtoe/y - Million tons/y for IS)"
V02DemUsefulSubsecRemTech(allCy,DSBS,YTIME)                "Useful energy demand (substitutable) covered by remaining equipment (Mtoe - Million tons for IS)"
V02GapUsefulDemSubsec(allCy,DSBS,YTIME)                    "gap in useful energy demand per subsector ((Mtoe - Million tons for IS)"
V02CapCostTech(allCy,DSBS,ITECH,YTIME)                     "capital cost of each technology per subsector (final) (k$/toe - $/tons for IS)"
V02VarCostTech(allCy,DSBS,ITECH,YTIME)                     "variable cost of each technology per subsector (final) (k$/toe - $/tons for IS)"
V02CostTech(allCy,DSBS,ITECH,YTIME)                        "total cost of each technology per subsector (useful) (k$/toe - $/tons for IS)"
!!V02CapCostTech1(allCy,DSBS,ITECH,YTIME)
V02ShareTechNewEquipUseful(allCy,DSBS,ITECH,YTIME)         "share of each technology in gap of useful energy (1)"
V02EquipCapTechSubsec(allCy,DSBS,ITECH,YTIME)              "equipment capacity of each technology in each subsector  (Mtoe/y - Million tons/y for IS)"
V02UsefulElecNonSubIndTert(allCy,DSBS,YTIME)               "non-substitutable useful electricity (Mtoe)"
V02FinalElecNonSubIndTert(allCy,DSBS,YTIME)                "final energy of non-substitutable electricity (Mtoe)"

V02IndxElecIndPrices(allCy,TCHP,YTIME)                     "Electricity index - a function of industry price - Estimate (k$/toe)"
V02IndAvrEffFinalUseful(allCy,DSBS,YTIME)                  "Average Efficiency (1)" 
V02PremScrpIndu(allCy,DSBS,ITECH,YTIME)                    "premature scrapping (1)"
V02RatioRem(allCy,DSBS,ITECH,YTIME)
*'                **Interdependent Variables**
VmConsFuel(allCy,DSBS,EF,YTIME)                            "fuel consumption of fuels in each subsector (Mtoe)"
VmConsFuelShare(allCy,DSBS,EF,YTIME)                       "share of each fuel in total fuel consumption of each subsector (1)"
VmConsFuelSum(allCy,DSBS,YTIME)                            "total fuel consumption of each subsector (Mtoe)"      
;