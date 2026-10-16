*' @title Equations of OPEN-PROMs INDUSTRY  - DOMESTIC - NON ENERGY USES - BUNKERS VARIABLES
*' @code

*' GENERAL INFORMATION

*' Industrial and domestic energy demand is divided (TO DO)

*' Equation format: "typical useful energy demand equation"
*' The main explanatory variables (drivers) are activity indicators (economic activity) and corresponding energy costs.
*' The type of "demand" is computed based on its past value, the ratio of the current and past activity indicators (with the corresponding elasticity), 
*' and the ratio of lagged energy costs (with the corresponding elasticities). This type of equation captures both short term and long term reactions to energy costs. 

Q02EnergyService(allCy,INDDOM,IND_SERVS,YTIME)$(TIME(YTIME) and runCy(allCy))..
  V02EnergyService(allCy,INDDOM,IND_SERVS,YTIME)
      =E=
  V02EnergyService(allCy,INDDOM,IND_SERVS,YTIME-1) *
  imActv(YTIME,allCy,INDDOM);

Q02Capacity(allCy,INDDOM,IND_SERVS,INDITECH,YTIME)$(TIME(YTIME) and runCy(allCy) and INDDOMtoSERVS(INDDOM,IND_SERVS) and SERVStoTECH(IND_SERVS,INDITECH))..
  V02Capacity(allCy,INDDOM,IND_SERVS,INDITECH,YTIME)
      =E=
  V02Capacity(allCy,INDDOM,IND_SERVS,INDITECH,YTIME-1) * (1 - V02ScrpRate(allCy,INDDOM,IND_SERVS,INDITECH,YTIME)) +
  V02ShareTech(allCy,INDDOM,IND_SERVS,INDITECH,YTIME) *  V02GapCapacity(allCy,INDDOM,IND_SERVS,YTIME);

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

Q02CostFuel(allCy,INDDOM,IND_SERVS,INDITECH,YTIME)$(TIME(YTIME) and INDDOMtoSERVS(INDDOM,IND_SERVS) and SERVStoTECH(IND_SERVS,INDITECH) and runCy(allCy))..
  V02CostFuel(allCy,INDDOM,IND_SERVS,INDITECH,YTIME)
      =E=
  1;

Q02CostTotal(allCy,INDDOM,IND_SERVS,INDITECH,YTIME)$(TIME(YTIME) and INDDOMtoSERVS(INDDOM,IND_SERVS) and SERVStoTECH(IND_SERVS,INDITECH) and runCy(allCy))..
  V02CostTotal(allCy,INDDOM,IND_SERVS,INDITECH,YTIME)
      =E=
  V02CostFuel(allCy,INDDOM,IND_SERVS,INDITECH,YTIME) + 1e-6;

Q02ScrpRate(allCy,INDDOM,IND_SERVS,INDITECH,YTIME)$(TIME(YTIME) and runCy(allCy) and INDDOMtoSERVS(INDDOM,IND_SERVS) and SERVStoTECH(IND_SERVS,INDITECH))..
    V02ScrpRate(allCy,INDDOM,IND_SERVS,INDITECH,YTIME)
        =E=
    1 - (1 - 1 / 20);

Q02ShareTech(allCy,INDDOM,IND_SERVS,INDITECH,YTIME)$(TIME(YTIME) and runCy(allCy) and INDDOMtoSERVS(INDDOM,IND_SERVS) and SERVStoTECH(IND_SERVS,INDITECH))..
    V02ShareTech(allCy,INDDOM,IND_SERVS,INDITECH,YTIME)
      =E=
    V02CostTotal(allCy,INDDOM,IND_SERVS,INDITECH,YTIME-1) ** (-1) /
    SUM(INDITECH2$(INDDOMtoSERVS(INDDOM,IND_SERVS) and SERVStoTECH(IND_SERVS,INDITECH2)),
      V02CostTotal(allCy,INDDOM,IND_SERVS,INDITECH2,YTIME-1) ** (-1)
    );

Q02ConsFuel(allCy,INDDOM,IND_SERVS,EF,YTIME)$(TIME(YTIME) and runCy(allCy) and INDDOMtoSERVS(INDDOM,IND_SERVS) and IND_SERVStoEF(IND_SERVS,EF))..
    V02ConsFuel(allCy,INDDOM,IND_SERVS,EF,YTIME)
        =E=
    SUM(INDITECH$(INDDOMtoSERVS(INDDOM,IND_SERVS) and SERVStoTECH(IND_SERVS,INDITECH) and INDITECHTOEF(INDITECH,EF)),
      V02Capacity(allCy,INDDOM,IND_SERVS,INDITECH,YTIME) *
      i02SpecificFuelConsData(allCy,INDDOM,IND_SERVS,INDITECH,"%fBaseY%") *
      i02DataShareBlend(allCy,INDDOM,IND_SERVS,INDITECH,EF,"%fBaseY%")
    );