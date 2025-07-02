* ---
* Iron and Steel Module: Declarations
* This file defines the equations and variables for the Iron and Steel sector model.



* EQUATIONS
Equations
* Costing and Scrapping Equations 
QISAnnCapCost(allCy,ISTECH_ALL,YTIME)          "Calculates the annualized capital cost for IS technologies"
QISTotProdCost(allCy,ISTECH_ALL,YTIME)         "Calculates the total production cost per unit of steel"
QIndxEndogScrapIS(allCy,ISTECH_HIST,YTIME)     "Computes the endogenous scrapping index for historical plants"

* Historical and New Capacity/Activity Equations
QAvailCapISHist(allCy,ISTECH_HIST,YTIME)       "Recursively calculates the available capacity of historical plants"
QActivityISHist(allCy,ISTECH_HIST,YTIME)       "Limits the activity of historical plants to their available capacity"
QISInvCostTech(allCy,ISTECH_ALL,YTIME)         "Defines the 'attractiveness' (inverse cost) of each technology"
QGapISCapacity(allCy,YTIME)                    "Calculates the capacity gap to be filled by new investments"
QNewInstalledCapacityIS(allCy,ISTECH_ALL,YTIME)"Calculates the newly installed capacity for each technology"
QAvailCapISNew(allCy,ISTECH_NEW,YTIME)         "Calculates the total available capacity of new technologies"
QActivityISNew(allCy,ISTECH_NEW,YTIME)         "Limits the activity of new plants to their available capacity"

* Overall Sector Balance and Factor Equations 
QTotActivityIS(allCy,YTIME)                    "Calculates the total steel production from all technologies"
QBalanceActDemandIS(allCy,YTIME)               "Ensures total production meets the exogenous steel demand"
QCapFacIS(allCy,ISTECH_ALL,YTIME)              "Calculates the capacity factor for each technology"

* Fuel Consumption and Emissions Equations 
QFuelConsISHist(allCy,ISTECH_HIST,EF,YTIME)    "Calculates fuel consumption for historical technologies"
QFuelConsISNew(allCy,ISTECH_NEW,EF,YTIME)      "Calculates fuel consumption for new technologies"
QTotFuelConsIS(allCy,EF,YTIME)                 "Computes the total fuel demand for the Iron and Steel sector"
QEmissionsIS(allCy,EF,YTIME)                   "Calculates CO2 emissions associated with fuel consumption"

* Investment Equation 
QInvestISNew(allCy,ISTECH_NEW,YTIME)           "Calculates the investment required for new technologies"
;


* VARIABLES

Variables
*  Cost and Competitiveness Variables 
VISAnnCapCost                                  "Annualized Capital Cost for IS Technologies (kEuro/Mt/year)"
VISTotProdCost                                 "Total Production Cost per unit of Steel (kEuro/Mt)"
VIndxEndogScrapIS                              "Endogenous Scrapping Index for Historical IS Technologies (0-1)"
VISInvCostTech                                 "Attractiveness (inverse cost) of each IS technology"

* Capacity and Production (Activity) Variables 
VAvailCapISHist(allCy, ISTECH_HIST, YTIME)     "Available capacity of historical technologies (Mt)"
VAvailCapISNew(allCy, ISTECH_NEW, YTIME)       "Available capacity of new technologies (Mt)"
VGapISCapacity                                 "Capacity Gap in IS Sector to be filled by new investment (Mt/year)"
VNewInstalledCapacityIS                        "Newly Installed IS Production Capacity (Mt/year)"
VTotActivityIS                                 "Total Steel Activity (Production) from all technologies (Mt)"
VActivityISHist                                "Actual Activity (Production) from Historical IS Technologies (Mt)"
VActivityISNew                                 "Actual Activity (Production) from New IS Technologies (Mt)"
VCapFacIS                                      "Capacity Factor for IS Technologies (unitless)"

*  Fuel, Emissions, and Investment Variables 
VFuelConsISHist(allCy,ISTECH_HIST,EF,YTIME)    "Fuel consumption for historical technologies"
VFuelConsISNew(allCy,ISTECH_NEW,EF,YTIME)      "Fuel consumption for new technologies"
VTotFuelConsIS(allCy,EF,YTIME)                 "Total fuel demand for the sector"
VEmissionsIS(allCy,EF,YTIME)                   "CO2 emissions from the sector"
VInvestISNew(allCy,ISTECH_NEW,YTIME)           "Investment for new technologies"
;



* INTERDEPENDENT EQUATIONS

* (Placeholder )



* INTERDEPENDENT VARIABLES

* (Placeholder)