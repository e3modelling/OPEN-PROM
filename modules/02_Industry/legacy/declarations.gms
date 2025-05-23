*' @title INDUSTRY  - DOMESTIC - NON ENERGY USES - BUNKERS EQUATIONS Declarations
*' @code

Equations
*' ***  INDUSTRY  - DOMESTIC - NON ENERGY USES - BUNKERS EQUATIONS
QIndxElecIndPrices(allCy,YTIME)                            "Compute Electricity index - a function of industry price - Estimate"
QCostElecProdCHP(allCy,DSBS,CHP,YTIME)                     "Compute electricity production cost per CHP plant and demand sector"
QCostTech(allCy,DSBS,rCon,EF,YTIME)                        "Compute technology cost"
QCostTechIntrm(allCy,DSBS,rCon,EF,YTIME)                   "Compute intermediate technology cost"
QCostTechMatFac(allCy,DSBS,rCon,EF,YTIME)                  "Compute the technology cost including the maturity factor per technology and subsector"
QSortTechVarCost(allCy,DSBS,rCon,YTIME)                    "Compute Technology sorting based on variable cost"
QGapFinalDem(allCy,DSBS,YTIME)                             "Compute the gap in final demand of industry, tertiary, non-energy uses and bunkers"
QShareTechNewEquip(allCy,DSBS,EF,YTIME)                    "Compute technology share in new equipment"
QCostProdCHPDem(allCy,DSBS,CHP,YTIME)                      "Compute  variable including fuel electricity production cost per CHP plant and demand sector "

*'                **Interdependent Equations**
QConsFuel(allCy,DSBS,EF,YTIME)                             "Compute fuel consumption"
QConsElecNonSubIndTert(allCy,INDDOM,YTIME)	               "Compute non-substituable electricity consumption in Industry and Tertiary"
*qConsTotElecInd(allCy,YTIME)                              "Compute Consumption of electricity in industrial sectors"
QDemFinSubFuelSubsec(allCy,DSBS,YTIME)                     "Compute total final demand (of substitutable fuels) per subsector"
*qDemFinSubFuelInd(allCy,YTIME)                            "Copmpute total final demand (of substitutable fuels) in industrial sectors"
QConsFuelInclHP(allCy,DSBS,EF,YTIME)                       "Equation for fuel consumption in Mtoe (including heat from heatpumps)"
QConsRemSubEquipSubSec(allCy,DSBS,EF,YTIME)	               "Equation for consumption of remaining substitutble equipment"
QCostElcAvgProdCHP(allCy,CHP,YTIME)                        "Compute Average Electricity production cost per CHP plant"
QCostVarAvgElecProd(allCy,CHP,YTIME)                       "Compute Average variable including fuel electricity production cost per CHP plant"
;

Variables
*' ***  INDUSTRY  - DOMESTIC - NON ENERGY USES - BUNKERS VARIABLES
VIndxElecIndPrices(allCy,YTIME)                            "Electricity index - a function of industry price - Estimate (1)"
VCostElecProdCHP(allCy,DSBS,CHP,YTIME)                     "Electricity production cost per CHP plant and demand sector (US$2015/KWh)"
VCostTech(allCy,DSBS,rCon,EF,YTIME)                        "Technology cost (KUS$2015/toe)"
VCostTechIntrm(allCy,DSBS,rcon,EF,YTIME)                   "Intermediate technology cost (KUS$2015/toe)"
VCostTechMatFac(allCy,DSBS,rCon,EF,YTIME)                  "Technology cost including maturity factor (KUS$2015/toe)"
VSortTechVarCost(allCy,DSBS,rCon,YTIME)                    "Technology sorting based on variable cost (1)"
VGapFinalDem(allCy,DSBS,YTIME)                             "Final demand gap to be filed by new technologies (Mtoe)"
VShareTechNewEquip(allCy,DSBS,EF,YTIME)                    "Technology share in new equipment (1)"
VCostProdCHPDem(allCy,DSBS,CHP,YTIME)                      "Variable including fuel electricity production cost per CHP plant and demand sector (US$2015/KWh)"

*'                **Interdependent Variables**
VConsFuel(allCy,DSBS,EF,YTIME)                             "Consumption of fuels in each demand subsector, excluding heat from heatpumps (Mtoe)"
VConsElecNonSubIndTert(allCy,DSBS,YTIME)                   "Consumption of non-substituable electricity in Industry and Tertiary (Mtoe)"
*vConsTotElecInd(allCy,YTIME)                              "Total Consumption of Electricity in industrial sectors (Mtoe)"
VDemFinSubFuelSubsec(allCy,DSBS,YTIME)                     "Total final demand (of substitutable fuels) per subsector (Mtoe)"
*vDemFinSubFuelInd(allCy,YTIME)                            "Total final demand (of substitutable fuels) in industrial sectors (Mtoe)"
VConsFuelInclHP(allCy,DSBS,EF,YTIME)                       "Consumption of fuels in each demand subsector including heat from heatpumps (Mtoe)"
VConsRemSubEquipSubSec(allCy,DSBS,EF,YTIME)                "Consumption of remaining substitutable equipment (Mtoe)"
VCostElcAvgProdCHP(allCy,CHP,YTIME)                        "Average Electricity production cost per CHP plant (US$2015/KWh)"
VCostVarAvgElecProd(allCy,CHP,YTIME)                       "Average variable including fuel electricity production cost per CHP plant (US$2015/KWh)"
;