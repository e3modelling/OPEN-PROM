* ---
* Iron and Steel Module: Input Data and Parameters
* TABLE keyword needes to be checked for data loaded from CSVs,



* DATA LOADED FROM EXTERNAL CSV FILES 


* --- Demand and Historical Production Inputs ---
Table iProdDemandIS(allCy, YTIME) "Exogenous annual steel demand projections (Mt)";
$ondelim
$include "./iProdDemandIS.csv"
$offdelim

* Historical production and capacity factor, used to calculate the initial capacity stock once.
Table iProdHistIS(allCy, ISTECH_HIST, YTIME) "Historical annual steel production (Mt)";
$ondelim
$include "./iProdHistIS.csv"
$offdelim

Table iCapFacBaseYrIS(allCy, ISTECH_HIST, YTIME) "Historical capacity factor in the base year";
$ondelim
$include "./iCapFacBaseYrIS.csv"
$offdelim


* Decommissioning Schedule Input 
* External Calculation. It provides the exact amount of historical capacity to decommission each year.
Table iDecomScheduleIS(allCy, ISTECH_HIST, YTIME) "Exogenous decommissioning schedule (Mt/year)";
$ondelim
$include "./iDecomScheduleIS.csv"
$offdelim


* Technology Cost and Performance Inputs 
Table iCapCosIS(allCy,ISTECH_ALL,YTIME) "Capital Cost for new technology routes (kEuro/Mt/year capacity)";
$ondelim
$include "./iCapCosIS.csv"
$offdelim

Table iFixOMCostIS(allCy,ISTECH_ALL,YTIME) "Fixed O&M Cost per new technology type (kEuro/Mt/year capacity)";
$ondelim
$include "./iFixOMCostIS.csv"
$offdelim

Table iVarOMCostIS(allCy,ISTECH_ALL,YTIME) "Variable O&M Cost per Plant Type (kEuro/Mt of steel)";
$ondelim
$include "./iVarOMCostIS.csv"
$offdelim

Table iTechLftIS(allCy,ISTECH_ALL) "Technical Lifetime per plant type (years)";
$ondelim
$include "./iTechLftIS.csv"
$offdelim

Table iAvailRateIS(ISTECH_ALL,YTIME) "Plant availability rate (unitless)";
$ondelim
$include "./iAvailRateIS.csv"
$offdelim


* Emissions. this needs to be eliminated once the module is linked to the entire industry
Table iCo2EmFacIS(allCy,EF,YTIME) "CO2 Emission Factor by Fuel (tCO2 per Mtoe)";
$ondelim
$include "./iCo2EmFacIS.csv"
$offdelim
;




Parameter iInitialCapacityTotal(allCy, ISTECH_HIST) "Total installed capacity in base year (Mt)"; * This parameter will hold the total capacity stock in the base year.

* This calculation runs once during model setup. It sums up all historical vintages (calculated from production and capacity factor) to get the total stock value
* needed for the recursive capacity equation.
iInitialCapacityTotal(allCy, ISTECH_HIST) =
    sum(YrHist$(YrHist.val <= %fBaseY%),
        iProdHistIS(allCy, ISTECH_HIST, YrHist) / iCapFacBaseYrIS(allCy, ISTECH_HIST, YrHist)
    );


* Elasticity of substitution/choice sensitivity in technology adoption.
Parameter iEIS_ChoiceSensitivity(allCy) "Elasticity of substitution for technology choice";
iEIS_ChoiceSensitivity(allCy) = 0.001; * Example value, needs calibration.


* CO2 Capture Rate for specific technologies.
Parameter imCO2CaptRate(allCy,ISTECH_ALL,YTIME) "CO2 Capture Rate (unitless)";
imCO2CaptRate(allCy,ISTECH_ALL,YTIME) = 0; * Default value: 0% capture.


* Maturity factor for new technologies.
Parameter iMatFacTechProd(allCy,ISTECH_ALL,YTIME) "Maturity factor on cost for new technologies";
iMatFacTechProd(allCy,ISTECH_ALL,YTIME) = 1; * Default value: No cost adjustment.


* Scale parameter for endogenous scrapping.
Parameter iScaleEndogScrapIS(ISTECH_HIST) "Scale parameter for endogenous scrapping sensitivity";
iScaleEndogScrapIS(ISTECH_HIST) = 0.035; * Example default value.