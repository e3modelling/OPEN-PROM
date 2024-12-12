*' @title INDUSTRY  - DOMESTIC - NON ENERGY USES - BUNKERS VARIABLES Preloop
*' @code

model openprom /

*' * INDUSTRY  - DOMESTIC - NON ENERGY USES - BUNKERS VARIABLES *
QConsElecNonSubIndTert              !! VConsElecNonSubIndTert(runCy,INDDOM,YTIME)
QConsRemSubEquipSubSec              !! VConsRemSubEquipSubSec(runCy,DSBS,EF,YTIME)
QDemFinSubFuelSubsec                !! VDemFinSubFuelSubsec(runCy,DSBS,YTIME)
qConsTotElecInd                     !! vConsTotElecInd(runCy,YTIME)
qDemFinSubFuelInd                   !! vDemFinSubFuelInd(runCy,YTIME)
QPriceElecInd                       !! VPriceElecInd(runCy,YTIME)
QConsFuel                           !! VConsFuel(runCy,DSBS,EF,YTIME)
QIndxElecIndPrices                  !! VIndxElecIndPrices(runCy,YTIME)
QPriceFuelSubsecCHP                 !! VPriceFuelSubsecCHP(runCy,DSBS,EF,YTIME)
QCostElecProdCHP                    !! VCostElecProdCHP(runCy,DSBS,CHP,YTIME)
QCostTech                           !! VCostTech(runCy,DSBS,rCon,EF,YTIME) 
QCostTechIntrm                      !! VCostTechIntrm(runCy,DSBS,rCon,EF,YTIME) 
QCostTechMatFac                     !! VCostTechMatFac(runCy,DSBS,rCon,EF,YTIME) 
QSortTechVarCost                    !! VSortTechVarCost(runCy,DSBS,rCon,YTIME)
QGapFinalDem                        !! VGapFinalDem(runCy,DSBS,YTIME)
QShareTechNewEquip                  !! VShareTechNewEquip(runCy,DSBS,EF,YTIME)
QConsFuelInclHP                     !! VConsFuelInclHP(runCy,DSBS,EF,YTIME)
QCostProdCHPDem                     !! VCostProdCHPDem(runCy,DSBS,CHP,YTIME)
QCostElcAvgProdCHP                  !! VCostElcAvgProdCHP(runCy,CHP,YTIME)
QCostVarAvgElecProd                 !! VCostVarAvgElecProd(runCy,CHP,YTIME)

/;

*'                *VARIABLE INITIALISATION*
*---
VCostTechIntrm.l(runCy,DSBS,rcon,EF,YTIME) = 0.1;
*---
VSortTechVarCost.l(runCy,DSBS,rCon,YTIME) = 0.00000001;
*---
VShareTechNewEquip.FX(runCy,DSBS,EF,YTIME)$(SECTTECH(DSBS,EF)$(not An(YTIME))) = 0;
*---