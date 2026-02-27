*' @title Equations of OPEN-PROMs Learning Curves module
*' @code

*' GENERAL INFORMATION

*' * Learning Curves module 

*' This equation implements the learning curve for wind and solar technologies with stopping mechanism.
*' The learning curve follows the equation: multiplier = (Cap_current / Cap_initial)^ε
*' where ε is calculated from learning rate: ε = log(1-LR)/log(2)
*' 
*' STOPPING MECHANISM: Only a fraction of costs are subject to learning curves.
*' - LearnableFraction: Technology-specific manufacturing costs that improve with experience
*' - FixedFraction: Basic materials, labor, installation costs that remain constant
*' - MinCostFraction: Absolute floor preventing unrealistic cost reductions
*'
*' The cost multiplier applies only to the learnable portion of total costs.
*' Final cost = [LearnableFraction × CostMultiplier + (1-LearnableFraction)] × InitialCost

*' Learning curve cost multiplier equation with numerical safeguards
*' Timing: Cost multiplier for YTIME based on capacity growth in previous period (YTIME-1 vs YTIME-2)
*' This reflects that learning happens from past experience and affects current period costs
*' Safeguards: Add small epsilon to denominator to avoid division by zero
Q10CostLC(LCTECH,YTIME)$(TIME(YTIME))..
    VmCostLC(LCTECH,YTIME)
        =E=
    ((V10CumCapGlobal(LCTECH,YTIME-1) + 1e-6) / (V10CumCapGlobal(LCTECH,YTIME-2) + 1e-6)) ** i10AlphaLC(LCTECH);

*' Global cumulative capacity tracking equation
*' Tracks total cumulative capacity installations since base year
*' Cumulative = Previous cumulative + New installations this period (converted MW to GW)
Q10CumCapGlobal(LCTECH,YTIME)$(TIME(YTIME))..
    V10CumCapGlobal(LCTECH,YTIME)
        =E=
    V10CumCapGlobal(LCTECH,YTIME-1) + 
    sum(allCy$(runCy(allCy)), V04NewCapElec(allCy,LCTECH,YTIME));

*' Private R&D flow definition.
*' - If private R&D is enabled, take exogenous path i10RDFundPrivate_exo.
*' - If disabled, force zero so no hidden contribution enters knowledge stock.
*' This keeps private-RD scenarios explicit and transparent.
Q10RDFundPrivate(allCy,RDTECH,YTIME)$(TIME(YTIME) and runCy(allCy))..
    V10RDFundPrivate(allCy,RDTECH,YTIME)
        =E=
$ifthen.pr "%EnablePrivateRD%" == "YES"
    i10RDFundPrivate_exo(allCy,RDTECH,YTIME)
$else.pr
    0
$endif.pr
;

*' State R&D flow definition.
*' - Preferred mode: map from subsidy machinery (VmSubsiRDTech) to ensure policy linkage.
*' - Fallback mode: use exogenous state R&D input for scenario experiments without
*'   subsidy-endogeneity.
*' Switching between these modes does not require equation edits, only flag changes.
Q10RDFundState(allCy,RDTECH,YTIME)$(TIME(YTIME) and runCy(allCy))..
    V10RDFundState(allCy,RDTECH,YTIME)
        =E=
$ifthen.sub "%RDLinkToSubsidies%" == "YES"
    VmSubsiRDTech(allCy,RDTECH,YTIME)
$else.sub
    i10RDFundState_exo(allCy,RDTECH,YTIME)
$endif.sub
;

*' Regional knowledge stock recursion:
*' K(c,i,t) = (1-dep_i)*K(c,i,t-1) + RD_state(c,i,t) + RD_private(c,i,t)
*' This equation is the core separation between regional R&D dynamics and global LBD.
*' Country-specific stock means policy and private efforts translate into local cost effects.
Q10RDStock(allCy,RDTECH,YTIME)$(TIME(YTIME) and runCy(allCy))..
    V10RDStock(allCy,RDTECH,YTIME)
        =E=
    (1 - i10KnowDep(RDTECH)) * V10RDStock(allCy,RDTECH,YTIME-1)
  + V10RDFundState(allCy,RDTECH,YTIME)
  + V10RDFundPrivate(allCy,RDTECH,YTIME);

*' Regional R&D multiplier equation in period-ratio form.
*' - Enabled mode: multiplier = (K(t-1)/K(t-2))^beta
*' - Disabled mode: multiplier = 1
*' Ratio form aligns with existing period-to-period multiplier style and avoids
*' introducing a new global reference normalization in the current architecture.
*' 1e-6 safeguards prevent division-by-zero in early periods or low-stock states.
Q10CostRD(allCy,RDTECH,YTIME)$(TIME(YTIME) and runCy(allCy))..
    V10CostRD(allCy,RDTECH,YTIME)
        =E=
$ifthen.rd "%EnableLearningBySearching%" == "YES"
    ((V10RDStock(allCy,RDTECH,YTIME-1) + 1e-6) / (V10RDStock(allCy,RDTECH,YTIME-2) + 1e-6)) ** i10BetaRD(RDTECH)
$else.rd
    1
$endif.rd
;

*' Core DAC CAPEX learning term equation
Q10CoreGrossCapDAC(DACTECH,YTIME)$(TIME(YTIME))..
    V10CoreGrossCapDAC(DACTECH,YTIME)
        =E=
    i06GrossCapDAC(DACTECH) *
    (sum(allCy$runCyL(allCy),V06CapCDR(allCy,DACTECH,YTIME-1)) + 1e-6) ** (log(0.97)/log(2));

*' Core DAC fixed O&M learning term equation
Q10CoreFixOandMDAC(DACTECH,YTIME)$(TIME(YTIME))..
    V10CoreFixOandMDAC(DACTECH,YTIME)
        =E=
    i06FixOandMDAC(DACTECH) *
    (sum(allCy$runCyL(allCy),V06CapCDR(allCy,DACTECH,YTIME-1)) + 1e-6) ** (log(0.97)/log(2));

*' Core DAC variable cost learning term equation
Q10CoreVarCostDAC(DACTECH,YTIME)$(TIME(YTIME))..
    V10CoreVarCostDAC(DACTECH,YTIME)
        =E=
    i06VarCostDAC(DACTECH) *
    (sum(allCy$runCyL(allCy),V06CapCDR(allCy,DACTECH,YTIME-1)) + 1e-6) ** (log(0.97)/log(2));