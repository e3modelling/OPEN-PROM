* ---
* Iron and Steel Module: Input Data

* Exogenous input for total steel production demand (in Mt of steel).

iProdHistIS(allCy, ISTECH_HIST, YTIME);
$ondelim
$include "./iProdHistIS.csv"
$offdelim
;

* This table contain annual steel demand projections 
Parameter iProdDemandIS(allCy, YTIME);
$ondelim
$include "./iProdDemandIS.csv"
$offdelim
;

* Historical capacity factor for existing technologies in the base year (e.g., 2019).
Parameter iCapFacBaseYrIS(allCy, ISTECH_HIST, YTIME);
$ondelim
$include "./iCapFacBaseYrIS.csv"
$offdelim
;



*table iSpecFuelConsIS(allCy,ISTECH_ALL,EF)
*$ondelim
*$include"./iSpecFuelConsIS.csv"
*$offdelim
*;

*table iSpecFuelConsIS_New(allCy,ISTECH_NEW,EF,YTIME);
*$ondelim
*$include"./iSpecFuelConsIS_New.csv"
*$offdelim
*;


* This table provides the the decommissioning of historical plants for each ywar
*table iAgeDistDecomIS(YTIME_OFFSET, ISTECH_HIST)
*$ondelim
*$include"./iAgeDistDecomIS.csv"
*$offdelim
*;


* Elasticity of substitution/choice sensitivity in technology adoption (not unit).
* This parameter determines how strongly cost differences influence the adoption of new technologies. Need to check the values for logit-like models; 
Parameter iEIS_ChoiceSensitivity(allCy);
iEIS_ChoiceSensitivity(allCy) = 0.001; ! Example  value: need to be adjust this based on desired market behavior or calibration, need to check if it is needed to be defined a tech level.

;* Capital Costs for Iron and Steel Technologies (e.g., kEuro per Mt/year of capacity).
* This table should contain capital costs for both historical and new technologies over the simulation period.
Parameter iCapCosIS(allCy,ISTECH_ALL,YTIME);
$ondelim
$include "./iCapCosIS.csv"
$offdelim
;

* Fixed Operation & Maintenance (O&M) Costs for Iron and Steel Plants (e.g., kEuro per Mt/year of capacity).
* These costs are incurred regardless of the production level.
Parameter iFixOMCostIS(allCy,ISTECH_ALL,YTIME);
$ondelim
$include "./iFixOMCostIS.csv"
$offdelim
;

* Variable Operation & Maintenance (O&M) Costs for Iron and Steel Plants (e.g., kEuro per Mt of steel).
* These costs are directly proportional to the amount of steel produced.
Parameter iVarOMCostIS(allCy,ISTECH_ALL,YTIME);
$ondelim
$include "./iVarOMCostIS.csv"
$offdelim
;

* Technical Lifetime per Iron and Steel plant type (in years).
* This parameter defines the expected operational duration of different steel production technologies.
Parameter iTechLftIS(allCy,ISTECH_ALL);
$ondelim
$include "./iTechLftIS.csv"
$offdelim
;

* Plant Availability Rate (unitless).
* This parameter indicates the fraction of total time that a plant is operational and available for production.
Parameter iAvailRateIS(ISTECH_ALL,YTIME);
$ondelim
$include "./iAvailRateIS.csv"
$offdelim
;

* CO2 Emission Factor by Fuel (tCO2 per Mtoe).
* This table specifies the amount of carbon dioxide emitted per unit of energy consumed from each fuel type.
* ---
* The parameter 'iCo2EmFacIS' is defined locally 
* For the final merge with OPEN-PROM, this local definition must be deleted.
* All equations (e.g., QISTotProdCost, QEmissionsIS) should then be updated to use
* the main model's central parameter: 'imCo2EmiFac(allCy,"IS",EF,YTIME)'.
* ---
Parameter iCo2EmFacIS(allCy,EF,YTIME);
$ondelim
$include "./iCo2EmFacIS.csv"
$offdelim
;

* CO2 Capture Rate for specific technologies (unitless).
* This parameter indicates the percentage of CO2 emissions that can be captured by technologies equipped with Carbon Capture and Storage (CCS). Defaults to 0 if not explicitly defined.
Parameter imCO2CaptRate(allCy,ISTECH_ALL,YTIME);
imCO2CaptRate(allCy,ISTECH_ALL,YTIME) = 0; ! Default value: 0% capture if not specified in an input file.
;


* Maturity factor related to plant production/cost for new technologies (unitless).
* This acts as a fixed multiplier on the cost of new technologies. A value of 1 means no adjustment; a value < 1 means a cost reduction (e.g., due to inherent maturity advantages).
Parameter iMatFacTechProd(allCy,ISTECH_ALL,YTIME);
iMatFacTechProd(allCy,ISTECH_ALL,YTIME) = 1; ! Default value: No cost adjustment due to maturity unless specified otherwise.
;

* Scale parameter for endogenous scrapping.
* This parameter controls the sensitivity of old plants to premature decommissioning based on their economic performance relative to newer/cheaper alternatives.
Parameter iScaleEndogScrapIS(ISTECH_HIST);
iScaleEndogScrapIS(ISTECH_HIST) = 0.035; ! Example default value, typically calibrated based on historical scrapping trends.
;


*The TOTAL installed capacity in the base year/historical years 
iInitialCapISHist(allCy, ISTECH_HIST, AGE) "Initial capacity by age in base year"

iProdHistIS(allCy, ISTECH_HIST, YTIME)
    "Historical annual steel production (in Mt of steel) for each existing Iron and Steel route BF-BOF, DR-EAF, scrap-EAF, country, and year. This input is also used to calculate the initial installed capacity of historical plants.";

    iProdDemandIS(allCy, YTIME)
        "Exogenous input representing the future projections of the annual total steel production demanded (in Mt of steel) for each country and simulation year. "

    iSpecFuelConsIS_Hisr(allCy,ISTECH_HIST,EF)
    "Specific Fuel Consumption for Historical Iron and Steel Technologies of the existing routes BF-BOF, DR-EAF, scrap-EAF, this is calculated outside of the model based on the energy balance of the country, the production and the disaggregation in the main existing routes (Mtoe/Mt of steel).

     iSpecFuelConsIS_New(allCy,ISTECH_NEW,EF,YTIME)
    "Specific Fuel Consumption for New Iron and Steel Technologies (Mtoe/Mt of steel)";

    iCapFacBaseYrIS(allCy, ISTECH_HIST, YTIME)
        "Historical capacity factor for existing Iron and Steel technologies in the base year. This is used to calculate the initial installed capacity from historical production data"

    iEIS_ChoiceSensitivity(allCy)
        "Elasticity of substitution/choice sensitivity in Iron and Steel technology adoption (unitless). This parameter controls the steepness of the technology adoption curve: higher values lead to more cost-sensitive choices (closer to pure cost minimization), while lower values introduce more inertia and gradual adoption of new technologies."
    
    iCapCosIS(allCy,ISTECH_ALL,YTIME)
        "Capital Cost for the new technology routes (kEuro/Mt/year capacity)"
    
    iFixOMCostIS(allCy,ISTECH_ALL,YTIME)
        "Fixed O&M Gross Cost per new technology type (kEuro/Mt/year capacity). This parameter covers operational and maintenance costs that do not vary with the production volume."
    
    iVarOMCostIS(allCy,ISTECH_ALL,YTIME)
        "Variable O&M Cost per Plant Type (kEuro/Mt of steel). This parameter covers operational and maintenance costs that vary directly with the production volume."
    
    iTechLftIS(allCy,ISTECH_ALL)
        "Technical Lifetime per plant type (years). This parameter defines the expected operational lifespan of each technology routes (existing and new)."
    
    iAvailRateIS(ISTECH_ALL,YTIME)
        "Plant availability rate (unitless). This parameter reflects the fraction of time a plant is available for operation, accounting for maintenance, outages, etc."
    
    iCo2EmFacIS(allCy,EF,YTIME)
        "CO2 Emission Factor by Fuel (tCO2/Mtoe). This parameter quantifies the amount of CO2 emitted per unit of fuel consumed.This should be linked to the main module"
    
    imCO2CaptRate(allCy,ISTECH_ALL,YTIME)
        "CO2 Capture Rate for specific technology (unitless). This parameter indicates the efficiency of CO2 capture technologies."
    
    iMatFacTechProd(allCy,ISTECH_ALL,YTIME)
        "Maturity factor related to plant production/cost for new technologies (unitless). In this version, it isan input multiplier for the cost, reflecting any initial cost advantage/disadvantage due to maturity status."
    
    iScaleEndogScrapIS(ISTECH_HIST)
        "Scale parameter for endogenous scrapping applied to the sum of full costs (unitless). This parameter defines the sensitivity of historical technologies to premature decommissioning based on economic competitiveness. This should be developed in the medium term: e.g knowing and having data on the investment cycles in iron and steel"
    ;
