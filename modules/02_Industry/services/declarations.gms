*' @title INDUSTRY  - DOMESTIC - NON ENERGY USES EQUATIONS Declarations
*' @code
parameter
imCO2CaptRateIndustry(allCy,INDITECH,YTIME)
!!i02DataShareBlend(allCy,INDDOM,IND_SERVS,INDITECH,EF,YTIME)
i02DataEnergyService(allCy,INDDOM,IND_SERVS,YTIME)
i02ratioTransfInputIS(allCy,IS_TRANSF,EFS,YTIME)
i02ratioOwnEnergyTransfIS(allCy,IS_TRANSF,EFS,YTIME)
;

Equations
*' ***  INDUSTRY  - DOMESTIC - NON ENERGY USES - BUNKERS EQUATIONS
Q02EnergyService(allCy,INDDOM,IND_SERVS,YTIME)
Q02Capacity(allCy,INDDOM,IND_SERVS,INDITECH,YTIME)
Q02GapCapacity(allCy,INDDOM,IND_SERVS,YTIME)
Q02CostVariable(allCy,INDDOM,IND_SERVS,INDITECH,YTIME)
Q02CostTotal(allCy,INDDOM,IND_SERVS,INDITECH,YTIME)
Q02ScrpRate(allCy,INDDOM,IND_SERVS,INDITECH,YTIME)
Q02ShareTech(allCy,INDDOM,IND_SERVS,INDITECH,YTIME)
Q02ConsFuel(allCy,INDDOM,IND_SERVS,EF,YTIME)
Q02ISTransfOutEF(allCy,IS_TRANSF,EFS,YTIME)
Q02ISTransfInEF(allCy,IS_TRANSF,EFS,YTIME)
Q02CostCapital(allCy,INDDOM,IND_SERVS,INDITECH,YTIME)
Q02ISownEnergyTransf(allCy,IS_TRANSF,EFS,YTIME)
Q02ScrpRatePrem(allCy,INDDOM,IND_SERVS,INDITECH,YTIME)
;

Variables
*' ***  INDUSTRY  - DOMESTIC - NON ENERGY USES - BUNKERS VARIABLES
V02EnergyService(allCy,INDDOM,IND_SERVS,YTIME)
V02Capacity(allCy,INDDOM,IND_SERVS,INDITECH,YTIME)         "Capacity of technologies in the industry sector (Million tonnes of steel for IS)"
V02GapCapacity(allCy,INDDOM,IND_SERVS,YTIME)
V02CostVariable(allCy,INDDOM,IND_SERVS,INDITECH,YTIME)     "Variable cost of technologies in the industry sector (k$/Million tonnes of steel for IS)"
V02CostTotal(allCy,INDDOM,IND_SERVS,INDITECH,YTIME)        "Total cost of technologies in the industry sector (k$/Million tonnes for IS)"
V02ScrpRate(allCy,INDDOM,IND_SERVS,INDITECH,YTIME)
V02ShareTech(allCy,INDDOM,IND_SERVS,INDITECH,YTIME)
V02ConsFuel(allCy,INDDOM,IND_SERVS,EF,YTIME)               "Fuel consumption in the industry sector (Mtoe)"
V02ISTransfOutEF(allCy,IS_TRANSF,EFS,YTIME)                "Output of energy transfer processes in the industry sector (Mtoe)"
V02ISTransfInEF(allCy,IS_TRANSF,EFS,YTIME)                 "Input of energy transfer processes in the industry sector (Mtoe)"
V02CostCapital(allCy,INDDOM,IND_SERVS,INDITECH,YTIME)      "Capital cost of technologies in the industry sector (k$/Million tonnes for IS)"
V02ISownEnergyTransf(allCy,IS_TRANSF,EFS,YTIME)            "Own energy consumption of energy transfer processes in the industry sector (Mtoe)"
V02ScrpRatePrem(allCy,INDDOM,IND_SERVS,INDITECH,YTIME)
;