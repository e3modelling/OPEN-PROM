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


* This table provides the age distribution for decommissioning historical plants.
*table iAgeDistDecomIS(YTIME_OFFSET, ISTECH_HIST)
*$ondelim
*$include"./iAgeDistDecomIS.csv"
*$offdelim
*;


* Elasticity of substitution/choice sensitivity in technology adoption (not unit).
* This parameter determines how strongly cost differences influence the adoption of new technologies. Need to check:A value of 1.0-5.0 is common for logit-like models; higher values imply greater sensitivity to cost.
Parameter iEIS_ChoiceSensitivity(allCy);
iEIS_ChoiceSensitivity(allCy) = 2.0; ! Example default value: You can adjust this based on desired market behavior or calibration.

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
* FUTURE INTEGRATION NOTE
* The parameter 'iCo2EmFacIS' is defined locally for standalone development.
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

