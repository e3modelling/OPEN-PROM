*' @title INDUSTRY  - DOMESTIC - NON ENERGY USES - BUNKERS EQUATIONS Declarations
*' @code

Equations
*' ***  INDUSTRY  - DOMESTIC - NON ENERGY USES - BUNKERS EQUATIONS
Q02IndxElecIndPrices(allCy,YTIME)                          "Compute Electricity index - a function of industry price - Estimate"
Q02CostElecProdCHP(allCy,DSBS,CHP,YTIME)                   "Compute electricity production cost per CHP plant and demand sector"
Q02CostTech(allCy,DSBS,rCon,EF,YTIME)                      "Compute technology cost"
Q02CostTechIntrm(allCy,DSBS,rCon,EF,YTIME)                 "Compute intermediate technology cost"
Q02CostTechMatFac(allCy,DSBS,rCon,EF,YTIME)                "Compute the technology cost including the maturity factor per technology and subsector"
Q02SortTechVarCost(allCy,DSBS,rCon,YTIME)                  "Compute Technology sorting based on variable cost"
Q02GapFinalDem(allCy,DSBS,YTIME)                           "Compute the gap in final demand of industry, tertiary, non-energy uses and bunkers"
Q02ShareTechNewEquip(allCy,DSBS,EF,YTIME)                  "Compute technology share in new equipment"
Q02CostProdCHPDem(allCy,DSBS,CHP,YTIME)                    "Compute  variable including fuel electricity production cost per CHP plant and demand sector "

*'                **Interdependent Equations**
Q02ConsFuel(allCy,DSBS,EF,YTIME)                           "Compute fuel consumption"
Q02ConsElecNonSubIndTert(allCy,INDDOM,YTIME)	           "Compute non-substituable electricity consumption in Industry and Tertiary"
*q02ConsTotElecInd(allCy,YTIME)                            "Compute Consumption of electricity in industrial sectors"
Q02DemFinSubFuelSubsec(allCy,DSBS,YTIME)                   "Compute total final demand (of substitutable fuels) per subsector"
*q02DemFinSubFuelInd(allCy,YTIME)                          "Copmpute total final demand (of substitutable fuels) in industrial sectors"
Q02ConsFuelInclHP(allCy,DSBS,EF,YTIME)                     "Equation for fuel consumption in Mtoe (including heat from heatpumps)"
Q02ConsRemSubEquipSubSec(allCy,DSBS,EF,YTIME)	           "Equation for consumption of remaining substitutble equipment"
Q02CostElcAvgProdCHP(allCy,CHP,YTIME)                      "Compute Average Electricity production cost per CHP plant"
Q02CostVarAvgElecProd(allCy,CHP,YTIME)                     "Compute Average variable including fuel electricity production cost per CHP plant"
;

Variables
*' ***  INDUSTRY  - DOMESTIC - NON ENERGY USES - BUNKERS VARIABLES
V02IndxElecIndPrices(allCy,YTIME)                          "Electricity index - a function of industry price - Estimate (1)"
V02CostElecProdCHP(allCy,DSBS,CHP,YTIME)                   "Electricity production cost per CHP plant and demand sector (US$2015/KWh)"
V02CostTech(allCy,DSBS,rCon,EF,YTIME)                      "Technology cost (KUS$2015/toe)"
V02CostTechIntrm(allCy,DSBS,rcon,EF,YTIME)                 "Intermediate technology cost (KUS$2015/toe)"
V02CostTechMatFac(allCy,DSBS,rCon,EF,YTIME)                "Technology cost including maturity factor (KUS$2015/toe)"
V02SortTechVarCost(allCy,DSBS,rCon,YTIME)                  "Technology sorting based on variable cost (1)"
V02GapFinalDem(allCy,DSBS,YTIME)                           "Final demand gap to be filed by new technologies (Mtoe)"
V02ShareTechNewEquip(allCy,DSBS,EF,YTIME)                  "Technology share in new equipment (1)"
V02CostProdCHPDem(allCy,DSBS,CHP,YTIME)                    "Variable including fuel electricity production cost per CHP plant and demand sector (US$2015/KWh)"

*'                **Interdependent Variables**
MVConsFuel(allCy,DSBS,EF,YTIME)                            "Consumption of fuels in each demand subsector, excluding heat from heatpumps (Mtoe)"
MVConsElecNonSubIndTert(allCy,DSBS,YTIME)                  "Consumption of non-substituable electricity in Industry and Tertiary (Mtoe)"
*MvConsTotElecInd(allCy,YTIME)                             "Total Consumption of Electricity in industrial sectors (Mtoe)"
MVDemFinSubFuelSubsec(allCy,DSBS,YTIME)                    "Total final demand (of substitutable fuels) per subsector (Mtoe)"
*MvDemFinSubFuelInd(allCy,YTIME)                           "Total final demand (of substitutable fuels) in industrial sectors (Mtoe)"
MVConsFuelInclHP(allCy,DSBS,EF,YTIME)                      "Consumption of fuels in each demand subsector including heat from heatpumps (Mtoe)"
MVConsRemSubEquipSubSec(allCy,DSBS,EF,YTIME)               "Consumption of remaining substitutable equipment (Mtoe)"
MVCostElcAvgProdCHP(allCy,CHP,YTIME)                       "Average Electricity production cost per CHP plant (US$2015/KWh)"
MVCostVarAvgElecProd(allCy,CHP,YTIME)                      "Average variable including fuel electricity production cost per CHP plant (US$2015/KWh)"
;