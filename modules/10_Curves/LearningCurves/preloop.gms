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
*---
*' Initialize cumulative capacity with historical data from base year only
*' Sum installed capacity across all countries for learning curve technologies
*' Keep units consistent: imInstCapPastNonCHP is in GW, V10CumCapGlobal should be in GW to match V04NewCapElec
p10CumCapGlobal(LCTECH,"2010") = sum(allCy$(runCy(allCy)), imInstCapPastNonCHP(allCy,LCTECH,"2010"));
p10CumCapGlobal(LCTECH,"2011") = p10CumCapGlobal.L(LCTECH,"2010") + sum(allCy$(runCy(allCy)), imInstCapPastNonCHP(allCy,LCTECH,"2011"));
p10CumCapGlobal(LCTECH,"2012") = p10CumCapGlobal.L(LCTECH,"2011") + sum(allCy$(runCy(allCy)), imInstCapPastNonCHP(allCy,LCTECH,"2012"));
p10CumCapGlobal(LCTECH,"2013") = p10CumCapGlobal.L(LCTECH,"2012") + sum(allCy$(runCy(allCy)), imInstCapPastNonCHP(allCy,LCTECH,"2013"));
p10CumCapGlobal(LCTECH,"2014") = p10CumCapGlobal.L(LCTECH,"2013") + sum(allCy$(runCy(allCy)), imInstCapPastNonCHP(allCy,LCTECH,"2014"));
p10CumCapGlobal(LCTECH,"2015") = p10CumCapGlobal.L(LCTECH,"2014") + sum(allCy$(runCy(allCy)), imInstCapPastNonCHP(allCy,LCTECH,"2015"));
p10CumCapGlobal(LCTECH,"2016") = p10CumCapGlobal.L(LCTECH,"2015") + sum(allCy$(runCy(allCy)), imInstCapPastNonCHP(allCy,LCTECH,"2016"));
p10CumCapGlobal(LCTECH,"2017") = p10CumCapGlobal.L(LCTECH,"2016") + sum(allCy$(runCy(allCy)), imInstCapPastNonCHP(allCy,LCTECH,"2017"));
p10CumCapGlobal(LCTECH,"2018") = p10CumCapGlobal.L(LCTECH,"2017") + sum(allCy$(runCy(allCy)), imInstCapPastNonCHP(allCy,LCTECH,"2018"));
p10CumCapGlobal(LCTECH,"2019") = p10CumCapGlobal.L(LCTECH,"2018") + sum(allCy$(runCy(allCy)), imInstCapPastNonCHP(allCy,LCTECH,"2019"));
p10CumCapGlobal(LCTECH,"2020") = p10CumCapGlobal.L(LCTECH,"2019") + sum(allCy$(runCy(allCy)), imInstCapPastNonCHP(allCy,LCTECH,"2020"));
p10CumCapGlobal(LCTECH,"2021") = p10CumCapGlobal.L(LCTECH,"2020") + sum(allCy$(runCy(allCy)), imInstCapPastNonCHP(allCy,LCTECH,"2021"));
p10CumCapGlobal(LCTECH,"2022") = p10CumCapGlobal.L(LCTECH,"2021") + sum(allCy$(runCy(allCy)), imInstCapPastNonCHP(allCy,LCTECH,"2022"));
p10CumCapGlobal(LCTECH,"2023") = p10CumCapGlobal.L(LCTECH,"2022") + sum(allCy$(runCy(allCy)), imInstCapPastNonCHP(allCy,LCTECH,"2023"));
p10CumCapGlobal(LCTECH,"%fBaseY%") = p10CumCapGlobal.L(LCTECH,"2023") + sum(allCy$(runCy(allCy)), imInstCapPastNonCHP(allCy,LCTECH,"%fBaseY%"));

V10CumCapGlobal.FX(LCTECH,"%fBaseY%") = p10CumCapGlobal(LCTECH,"%fBaseY%")
*---

*'                *PARAMETER INITIALISATION FOR RECURSIVE LAGS*

pmCostLC(LCTECH,YTIME) = VmCostLC.L(LCTECH,YTIME);
p10CumCapGlobal(LCTECH,YTIME) = V10CumCapGlobal.L(LCTECH,YTIME);