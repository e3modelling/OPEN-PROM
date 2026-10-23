*' @title Equations of OPEN-PROMs INDUSTRY  - DOMESTIC - NON ENERGY USES - BUNKERS VARIABLES
*' @code

*' GENERAL INFORMATION

*' Industrial and domestic energy demand is divided (TO DO)

*' Equation format: "typical useful energy demand equation"
*' The main explanatory variables (drivers) are activity indicators (economic activity) and corresponding energy costs.
*' The type of "demand" is computed based on its past value, the ratio of the current and past activity indicators (with the corresponding elasticity), 
*' and the ratio of lagged energy costs (with the corresponding elasticities). This type of equation captures both short term and long term reactions to energy costs. 

!!FIXME: INDDOM does not contain NENSE. Should be added as separate equations, coupled to the corresponding energy service.
Q02EnergyService(allCy,INDDOM,IND_SERVS,YTIME)$(TIME(YTIME) and runCy(allCy))..
  V02EnergyService(allCy,INDDOM,IND_SERVS,YTIME)
      =E=
  i02CalibUsefulEnergy(allCy,INDDOM,YTIME) *
  V02EnergyService(allCy,INDDOM,IND_SERVS,YTIME-1) *
  imActv(YTIME,allCy,INDDOM);

Q02Capacity(allCy,INDDOM,IND_SERVS,INDITECH,YTIME)$(TIME(YTIME) and runCy(allCy) and INDDOMtoSERVS(INDDOM,IND_SERVS) and SERVStoTECH(IND_SERVS,INDITECH))..
  V02Capacity(allCy,INDDOM,IND_SERVS,INDITECH,YTIME)
      =E=
  V02Capacity(allCy,INDDOM,IND_SERVS,INDITECH,YTIME-1) * (1 - V02ScrpRate(allCy,INDDOM,IND_SERVS,INDITECH,YTIME)) +
  V02ShareTech(allCy,INDDOM,IND_SERVS,INDITECH,YTIME) * V02GapCapacity(allCy,INDDOM,IND_SERVS,YTIME);

Q02GapCapacity(allCy,INDDOM,IND_SERVS,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
  V02GapCapacity(allCy,INDDOM,IND_SERVS,YTIME)
    =E=
  (
    V02EnergyService(allCy,INDDOM,IND_SERVS,YTIME) - 
    V02EnergyService(allCy,INDDOM,IND_SERVS,YTIME-1) +
    SUM(INDITECH$SERVStoTECH(IND_SERVS,INDITECH),
      V02Capacity(allCy,INDDOM,IND_SERVS,INDITECH,YTIME-1) * V02ScrpRate(allCy,INDDOM,IND_SERVS,INDITECH,YTIME)
    ) +
    SQRT(SQR(
      V02EnergyService(allCy,INDDOM,IND_SERVS,YTIME) - 
      V02EnergyService(allCy,INDDOM,IND_SERVS,YTIME-1) +
      SUM(INDITECH$SERVStoTECH(IND_SERVS,INDITECH),
        V02Capacity(allCy,INDDOM,IND_SERVS,INDITECH,YTIME-1) * V02ScrpRate(allCy,INDDOM,IND_SERVS,INDITECH,YTIME)
      )
    ))
  ) / 2 + 1e-6;

Q02CostCapital(allCy,INDDOM,IND_SERVS,INDITECH,YTIME)$(TIME(YTIME) and INDDOMtoSERVS(INDDOM,IND_SERVS) and SERVStoTECH(IND_SERVS,INDITECH) and runCy(allCy))..
  V02CostCapital(allCy,INDDOM,IND_SERVS,INDITECH,YTIME)
      =E=
  1; !!FIXME: Add costs

Q02CostVariable(allCy,INDDOM,IND_SERVS,INDITECH,YTIME)$(TIME(YTIME) and INDDOMtoSERVS(INDDOM,IND_SERVS) and SERVStoTECH(IND_SERVS,INDITECH) and runCy(allCy))..
  V02CostVariable(allCy,INDDOM,IND_SERVS,INDITECH,YTIME)
      =E=
  SUM(EFS$INDITECHTOEF(INDITECH,EFS),
    (
      VmPriceFinal(allCy,INDDOM,EFS,YTIME) + !!FIXME: Calculate proper prices for BFG,COKE,COG that include the transf process
      imCO2CaptRateIndustry(allCy,INDITECH,YTIME) * VmCstCO2SeqCsts(allCy,YTIME) * 1e-3 * imCo2EmiFac(allCy,INDDOM,EFS,YTIME) +
      (1-imCO2CaptRateIndustry(allCy,INDITECH,YTIME)) * 1e-3 * VmPriceCarbon(allCy,INDDOM,EFS,YTIME-1) * imCo2EmiFac(allCy,INDDOM,EFS,YTIME)
    ) * i02SFC(allCy,INDDOM,IND_SERVS,INDITECH,EFS,"%fBaseY%")
  );
  !!FIXME: imVarCostTech(allCy,INDDOM,INDITECH,YTIME) / sUnitToKUnit;

Q02CostTotal(allCy,INDDOM,IND_SERVS,INDITECH,YTIME)$(TIME(YTIME) and INDDOMtoSERVS(INDDOM,IND_SERVS) and SERVStoTECH(IND_SERVS,INDITECH) and runCy(allCy))..
  V02CostTotal(allCy,INDDOM,IND_SERVS,INDITECH,YTIME)
      =E=
  V02CostVariable(allCy,INDDOM,IND_SERVS,INDITECH,YTIME) + 
  V02CostCapital(allCy,INDDOM,IND_SERVS,INDITECH,YTIME);

Q02ScrpRate(allCy,INDDOM,IND_SERVS,INDITECH,YTIME)$(TIME(YTIME) and runCy(allCy) and INDDOMtoSERVS(INDDOM,IND_SERVS) and SERVStoTECH(IND_SERVS,INDITECH))..
    V02ScrpRate(allCy,INDDOM,IND_SERVS,INDITECH,YTIME)
        =E=
    1 - (1 - 1 / 20) * !!FIXME: replace hard-coded lifetime
    (1-V02ScrpRatePrem(allCy,INDDOM,IND_SERVS,INDITECH,YTIME));

Q02ShareTech(allCy,INDDOM,IND_SERVS,INDITECH,YTIME)$(TIME(YTIME) and runCy(allCy) and INDDOMtoSERVS(INDDOM,IND_SERVS) and SERVStoTECH(IND_SERVS,INDITECH))..
    V02ShareTech(allCy,INDDOM,IND_SERVS,INDITECH,YTIME)
      =E=
    V02CostTotal(allCy,INDDOM,IND_SERVS,INDITECH,YTIME-1) ** (-2) /
    SUM(INDITECH2$(INDDOMtoSERVS(INDDOM,IND_SERVS) and SERVStoTECH(IND_SERVS,INDITECH2)),
      V02CostTotal(allCy,INDDOM,IND_SERVS,INDITECH2,YTIME-1) ** (-2)
    );

Q02ConsFuel(allCy,INDDOM,IND_SERVS,EF,YTIME)$(TIME(YTIME) and runCy(allCy) and INDDOMtoSERVS(INDDOM,IND_SERVS) and IND_SERVStoEF(IND_SERVS,EF))..
    V02ConsFuel(allCy,INDDOM,IND_SERVS,EF,YTIME)
        =E=
      !!FIXME: Check fuel consumption.
    SUM(INDITECH$(INDDOMtoSERVS(INDDOM,IND_SERVS) and SERVStoTECH(IND_SERVS,INDITECH) and INDITECHTOEF(INDITECH,EF)),
      V02Capacity(allCy,INDDOM,IND_SERVS,INDITECH,YTIME) *
      i02SFC(allCy,INDDOM,IND_SERVS,INDITECH,EF,"%fBaseY%") !!FIXME: Check the SFC. Add SFC for new techs (H2EAF, EAF if applicable)
    );

Q02ISTransfOutEF(allCy,IS_TRANSF,EFS,YTIME)$(TIME(YTIME) and runCy(allCy) and IS_TRANSF_OUT(IS_TRANSF,EFS))..
    V02ISTransfOutEF(allCy,IS_TRANSF,EFS,YTIME)
        =E=
    V03ConsGrssInl(allCy,EFS,YTIME) - VmImpNetEneBrnch(allCy,EFS,YTIME);

Q02ISTransfInEF(allCy,IS_TRANSF,EFS,YTIME)$(TIME(YTIME) and runCy(allCy))..
    V02ISTransfInEF(allCy,IS_TRANSF,EFS,YTIME)
        =E=
    i02ratioTransfInputIS(allCy,IS_TRANSF,EFS,"%fBaseY%") *
    SUM(EFS2$IS_TRANSF_OUT(IS_TRANSF,EFS2),
      V02ISTransfOutEF(allCy,IS_TRANSF,EFS2,YTIME)
    );

Q02ISownEnergyTransf(allCy,IS_TRANSF,EFS,YTIME)$(TIME(YTIME) and runCy(allCy))..
    V02ISownEnergyTransf(allCy,IS_TRANSF,EFS,YTIME)
        =E=
    0*i02ratioOwnEnergyTransfIS(allCy,IS_TRANSF,EFS,"%fBaseY%") * !!FIXME remove 0: May lead to infeasibility 
    SUM(EFS2$IS_TRANSF_OUT(IS_TRANSF,EFS2),
      V02ISTransfOutEF(allCy,IS_TRANSF,EFS2,YTIME)
    );

Q02ScrpRatePrem(allCy,INDDOM,IND_SERVS,INDITECH,YTIME)$(TIME(YTIME)$runCy(allCy)$INDDOMtoSERVS(INDDOM,IND_SERVS)$SERVStoTECH(IND_SERVS,INDITECH))..
    V02ScrpRatePrem(allCy,INDDOM,IND_SERVS,INDITECH,YTIME)
        =E=
    0; !! FIXME