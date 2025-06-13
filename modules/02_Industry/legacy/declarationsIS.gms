* ---
* Iron and Steel Module: Declarations
* This section defines all the sets, variables, and parameters used within the Iron and Steel sector model.
* ---



Variables
    VISAnnCapCost           "Annualized Capital Cost for Iron and Steel Technologies (kEuro/Mt/year of capacity). 
    VISTotProdCost          "Total Production Cost per unit of Steel (kEuro/Mt of steel). This comprehensive variable includes capital, fixed O&M, variable O&M, fuel, and CO2 costs"
    VIndxEndogScrapIS       "Endogenous Scrapping Index for Historical Iron and Steel Technologies (0-1). This index quantifies the likelihood or fraction of old capacity being decommissioned prematurely due to economic non-competitiveness."
    VInitialCapISHist       "Initial Installed Capacity for Historical Iron and Steel Technologies in base year (Mt/year). This represents the inferred operational capacity of existing plants at the model's starting point."
    VISInvCostTech          "Inverse cost of each Iron and Steel technology (unitless) as defined in the general industry models. A higher value indicates greater desirability for new capacity installation."
    VGapISCapacity          "Capacity Gap in Iron and Steel Sector (Mt/year). This variable identifies the difference between projected steel demand and the available production capacity, indicating the need for new investments."
    VNewInstalledCapacityIS "Newly Installed Iron and Steel Production Capacity (Mt/year). This represents the new production capacity added by the model in response to the capacity gap, allocated based on technology attractiveness."
    VTotActivityIS          "Total Steel Activity (Production) from all technologies (Mt). This variable aggregates the actual steel output from both historical and new technologies."
    VCapFacIS               "Capacity Factor for Iron and Steel Technologies (unitless). This output variable measures the utilization rate of installed capacity, calculated as actual production divided by available capacity."
    VActivityISHist         "Actual Activity (Production) from Historical Iron and Steel Technologies (Mt). This variable represents the real output of existing plants, limited by their available capacity."
    VActivityISNew          "Actual Activity (Production) from New Iron and Steel Technologies (Mt). This variable represents the real output of newly installed plants, limited by their available capacity."
    ;

Parameters
iProdHistIS(allCy, ISTECH_HIST, YTIME)
    "Historical annual steel production (in Mt of steel) for each existing Iron and Steel route, country, and year. This input is used to infer the initial installed capacity of historical plants.";

    iProdDemandIS(allCy, YTIME)
        "Exogenous input representing the annual total steel production demanded (in Mt of steel) for each country and simulation year. This parameter is a primary driver for the model's capacity expansion."

    iSpecFuelConsIS_Hisr(allCy,ISTECH_HIST,EF)
    "Specific Fuel Consumption for Historical Iron and Steel Technologies of the existing technologies, this is calculated outside of the model based on the energy balance of the country, the production and the disaggregation in the main existing routes (Mtoe/Mt of steel).

     iSpecFuelConsIS_New(allCy,ISTECH_NEW,EF,YTIME)
    "Specific Fuel Consumption for New Iron and Steel Technologies (Mtoe/Mt of steel). At the moment we can use a fix valued over the years.";

    iCapFacBaseYrIS(allCy, ISTECH_HIST, YTIME)
        "Historical capacity factor for existing Iron and Steel technologies in the base year. This input is used to infer the initial installed capacity from historical production data, providing a practical basis for model initialization."

    iEIS_ChoiceSensitivity(allCy)
        "Elasticity of substitution/choice sensitivity in Iron and Steel technology adoption (unitless). This parameter controls the steepness of the technology adoption curve: higher values lead to more cost-sensitive choices (closer to pure cost minimization), while lower values introduce more inertia and gradual adoption of new technologies."
    
    iCapCosIS(allCy,ISTECH_ALL,YTIME)
        "Gross Capital Cost per Plant Type (e.g. kEuro/Mt/year capacity). This parameter represents the upfront investment cost for each technology."
    
    iFixOMCostIS(allCy,ISTECH_ALL,YTIME)
        "Fixed O&M Gross Cost per Plant Type (e.g. kEuro/Mt/year capacity). This parameter covers operational and maintenance costs that do not vary with the production volume."
    
    iVarOMCostIS(allCy,ISTECH_ALL,YTIME)
        "Variable O&M Cost per Plant Type (e.g. kEuro/Mt of steel). This parameter covers operational and maintenance costs that vary directly with the production volume."
    
    iTechLftIS(allCy,ISTECH_ALL)
        "Technical Lifetime per plant type (years). This parameter defines the expected operational lifespan of each technology."
    
    iAvailRateIS(ISTECH_ALL,YTIME)
        "Plant availability rate (unitless, e.g. 0.85). This parameter reflects the fraction of time a plant is available for operation, accounting for maintenance, outages, etc."
    
    iCo2EmFacIS(allCy,EF,YTIME)
        "CO2 Emission Factor by Fuel (tCO2/Mtoe). This parameter quantifies the amount of CO2 emitted per unit of fuel consumed."
    
    imCO2CaptRate(allCy,ISTECH_ALL,YTIME)
        "CO2 Capture Rate for specific technology (unitless). This parameter indicates the efficiency of CO2 capture technologies."
    
    iMatFacTechProd(allCy,ISTECH_ALL,YTIME)
        "Maturity factor related to plant production/cost for new technologies (unitless). In this version, it's an input multiplier for the cost, reflecting any initial cost advantage/disadvantage due to maturity status."
    
    iScaleEndogScrapIS(ISTECH_HIST)
        "Scale parameter for endogenous scrapping applied to the sum of full costs (unitless). This parameter tunes the sensitivity of historical technologies to premature decommissioning based on economic competitiveness."
    ;

