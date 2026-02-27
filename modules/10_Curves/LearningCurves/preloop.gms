*' @title Learning Curves module Preloop
*' @code

*'                *VARIABLE INITIALISATION*

*---
*' Set bounds for cost multiplier with conservative values to avoid max() function
*' Lower bound set to prevent excessive cost reductions while ensuring solver compatibility
*' Using simple conservative bound instead of complex max() calculation
*' Cost = (LearnableFraction * CostMultiplier + (1-LearnableFraction)) * InitialCost
VmCostLC.LO(LCTECH,YTIME) = 0.1;   !! Conservative 10% minimum cost multiplier (90% max reduction)
VmCostLC.UP(LCTECH,YTIME) = 2.0;   !! Allow some cost increase for numerical stability
*' Initialize cost multiplier to 1.0 for base year (no cost reduction initially)
VmCostLC.FX(LCTECH,"%fBaseY%") = 1.0;

*' Regional R&D multiplier bounds mirror VmCostLC bounds for consistency.
*' Keeping a conservative lower bound avoids extreme one-step cost collapses in
*' aggressive scenarios while still allowing meaningful cost reductions.
V10CostRD.LO(runCy,RDTECH,YTIME) = 0.1;
V10CostRD.UP(runCy,RDTECH,YTIME) = 2.0;

*' Base-year anchor for R&D multiplier.
*' This guarantees no immediate discontinuity at model start and preserves baseline
*' calibration when R&D rates/funding are zero.
V10CostRD.FX(runCy,RDTECH,"%fBaseY%") = 1.0;

*' Knowledge-stock initialization strategy:
*' - Set strictly positive lower bound to maintain numerical robustness in ratio equations.
*' - Seed historical years with fixed value 1 so early-period multipliers remain neutral
*'   unless explicit R&D inflows are introduced.
*' - This avoids adding a separate historical R&D dataset in this first implementation.
V10RDStock.LO(runCy,RDTECH,YTIME) = 1e-6;
V10RDStock.L(runCy,RDTECH,YTIME) = 1;
V10RDStock.FX(runCy,RDTECH,"2010") = 1;
V10RDStock.FX(runCy,RDTECH,"2011") = 1;
V10RDStock.FX(runCy,RDTECH,"2012") = 1;
V10RDStock.FX(runCy,RDTECH,"2013") = 1;
V10RDStock.FX(runCy,RDTECH,"2014") = 1;
V10RDStock.FX(runCy,RDTECH,"2015") = 1;
V10RDStock.FX(runCy,RDTECH,"2016") = 1;
V10RDStock.FX(runCy,RDTECH,"2017") = 1;
V10RDStock.FX(runCy,RDTECH,"2018") = 1;
V10RDStock.FX(runCy,RDTECH,"2019") = 1;
V10RDStock.FX(runCy,RDTECH,"2020") = 1;
V10RDStock.FX(runCy,RDTECH,"2021") = 1;
V10RDStock.FX(runCy,RDTECH,"2022") = 1;
V10RDStock.FX(runCy,RDTECH,"%fBaseY%") = 1;
*---
*' Initialize cumulative capacity with historical data from base year only
*' Sum installed capacity across all countries for learning curve technologies
*' Keep units consistent: imInstCapPastNonCHP is in GW, V10CumCapGlobal should be in GW to match V04NewCapElec
V10CumCapGlobal.FX(LCTECH,"2010") = sum(allCy$(runCy(allCy)), imInstCapPastNonCHP(allCy,LCTECH,"2010"));
V10CumCapGlobal.FX(LCTECH,"2011") = V10CumCapGlobal.L(LCTECH,"2010") + sum(allCy$(runCy(allCy)), imInstCapPastNonCHP(allCy,LCTECH,"2011"));
V10CumCapGlobal.FX(LCTECH,"2012") = V10CumCapGlobal.L(LCTECH,"2011") + sum(allCy$(runCy(allCy)), imInstCapPastNonCHP(allCy,LCTECH,"2012"));
V10CumCapGlobal.FX(LCTECH,"2013") = V10CumCapGlobal.L(LCTECH,"2012") + sum(allCy$(runCy(allCy)), imInstCapPastNonCHP(allCy,LCTECH,"2013"));
V10CumCapGlobal.FX(LCTECH,"2014") = V10CumCapGlobal.L(LCTECH,"2013") + sum(allCy$(runCy(allCy)), imInstCapPastNonCHP(allCy,LCTECH,"2014"));
V10CumCapGlobal.FX(LCTECH,"2015") = V10CumCapGlobal.L(LCTECH,"2014") + sum(allCy$(runCy(allCy)), imInstCapPastNonCHP(allCy,LCTECH,"2015"));
V10CumCapGlobal.FX(LCTECH,"2016") = V10CumCapGlobal.L(LCTECH,"2015") + sum(allCy$(runCy(allCy)), imInstCapPastNonCHP(allCy,LCTECH,"2016"));
V10CumCapGlobal.FX(LCTECH,"2017") = V10CumCapGlobal.L(LCTECH,"2016") + sum(allCy$(runCy(allCy)), imInstCapPastNonCHP(allCy,LCTECH,"2017"));
V10CumCapGlobal.FX(LCTECH,"2018") = V10CumCapGlobal.L(LCTECH,"2017") + sum(allCy$(runCy(allCy)), imInstCapPastNonCHP(allCy,LCTECH,"2018"));
V10CumCapGlobal.FX(LCTECH,"2019") = V10CumCapGlobal.L(LCTECH,"2018") + sum(allCy$(runCy(allCy)), imInstCapPastNonCHP(allCy,LCTECH,"2019"));
V10CumCapGlobal.FX(LCTECH,"2020") = V10CumCapGlobal.L(LCTECH,"2019") + sum(allCy$(runCy(allCy)), imInstCapPastNonCHP(allCy,LCTECH,"2020"));
V10CumCapGlobal.FX(LCTECH,"2021") = V10CumCapGlobal.L(LCTECH,"2020") + sum(allCy$(runCy(allCy)), imInstCapPastNonCHP(allCy,LCTECH,"2021"));
V10CumCapGlobal.FX(LCTECH,"2022") = V10CumCapGlobal.L(LCTECH,"2021") + sum(allCy$(runCy(allCy)), imInstCapPastNonCHP(allCy,LCTECH,"2022"));
V10CumCapGlobal.FX(LCTECH,"%fBaseY%") = V10CumCapGlobal.L(LCTECH,"2022") + sum(allCy$(runCy(allCy)), imInstCapPastNonCHP(allCy,LCTECH,"%fBaseY%"));
*---