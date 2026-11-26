*' @title Equations of OPEN-PROMs Agriculture module
*' @code

*' GENERAL INFORMATION

*' Equation format: "typical useful energy demand equation"
*' The main explanatory variables (drivers) are activity indicators (economic activity) and corresponding energy costs.
*' The type of "demand" is computed based on its past value, the ratio of the current and past activity indicators (with the corresponding elasticity), 
*' and the ratio of lagged energy costs (with the corresponding elasticities). This type of equation captures both short term and long term reactions to energy costs. 

*' * Commodities module
* We need another driver for food crops: 1st generation biofuels.


Q14Exp(allCy,MATERIALS,YTIME)$(TIME(YTIME) $runCy(allCy))..
    V14Exp(allCy,MATERIALS,YTIME)
      =E=
    i14ratioMaterialExports(allCy,MATERIALS,"%fBaseY%") *
    SUM(runCy2,V14Imp(runCy2,MATERIALS,YTIME-1));

Q14Imp(allCy,MATERIALS,YTIME)$(TIME(YTIME) $runCy(allCy))..
    V14Imp(allCy,MATERIALS,YTIME)
        =E=
    i14ratioMaterialImports(allCy,MATERIALS,YTIME) * 
    SUM(IND_SERVS,
      V14DemandMaterials(allCy,IND_SERVS,MATERIALS,YTIME)
    );

Q14NetTradeMaterials(allCy,MATERIALS,YTIME)$(TIME(YTIME)$runCy(allCy))..
    V14NetTradeMaterials(allCy,MATERIALS,YTIME)
        =E=
    V14Imp(allCy,MATERIALS,YTIME) -
    V14Exp(allCy,MATERIALS,YTIME);

Q14InputMaterials(allCy,IND_SERVS,MATERIALS,YTIME)$(TIME(YTIME) and runCy(allCy))..
    V14DemandMaterials(allCy,IND_SERVS,MATERIALS,YTIME)
        =E=
    SUM(INDITECH,
      i02ratioMaterialCons(IND_SERVS,INDITECH,MATERIALS) *
      V02Capacity(allCy,"IS",IND_SERVS,INDITECH,YTIME)
    ) +
    SUM((IS_TRANSF,IS_TRANSF_TECH)$IS_TRANSFtoIS_TRANSF_TECH(IS_TRANSF,IS_TRANSF_TECH),
      i02ratioMaterialCons(IND_SERVS,IS_TRANSF_TECH,MATERIALS) *
      V03Cap(allCy,IS_TRANSF,IS_TRANSF_TECH,YTIME)
    );

Q14CostAvgCommodities(allCy,COMMODITIES,YTIME)$(TIME(YTIME)$runCy(allCy))..
    V14CostAvgCommodities(allCy,COMMODITIES,YTIME)
      =E=
    SUM((IND_SERVS,INDITECH)$(SERVStoTECH(IND_SERVS,INDITECH)$COMMStoINDSERVS(COMMODITIES,IND_SERVS)$SERVStoTECH(IND_SERVS,INDITECH)),
      V02CostTotal(allCy,"IS",IND_SERVS,INDITECH,YTIME) * (V02Capacity(allCy,"IS",IND_SERVS,INDITECH,YTIME) + 1e-6)
    ) /
    SUM((IND_SERVS,INDITECH)$(SERVStoTECH(IND_SERVS,INDITECH)$COMMStoINDSERVS(COMMODITIES,IND_SERVS)$SERVStoTECH(IND_SERVS,INDITECH)),
      V02Capacity(allCy,"IS",IND_SERVS,INDITECH,YTIME) + 1e-6
    );
$ontext
    SUM((IND_SERVS,INDITECH)$(SERVStoTECH(IND_SERVS,INDITECH)$COMMStoINDSERVS(COMMODITIES,IND_SERVS)$SERVStoTECH(IND_SERVS,INDITECH)),
      V02CostTotal(allCy,"IS",IND_SERVS,INDITECH,YTIME) * (V02Capacity(allCy,"IS",IND_SERVS,INDITECH,YTIME) + 1e-6)
    ) /
    SUM((IND_SERVS,INDITECH)$(SERVStoTECH(IND_SERVS,INDITECH)$COMMStoINDSERVS(COMMODITIES,IND_SERVS)$SERVStoTECH(IND_SERVS,INDITECH)),
      V02Capacity(allCy,"IS",IND_SERVS,INDITECH,YTIME) + 1e-6
    );
$offtext