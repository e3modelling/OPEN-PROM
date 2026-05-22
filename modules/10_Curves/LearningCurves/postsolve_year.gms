*' Clear variables and equations (outside country loop — preserves no bounds for next year)
option clear = VmCostLC;
option clear = V10CumCapGlobal;

option clear = Q10CostLC;
option clear = Q10CumCapGlobal;

*' Re-apply preloop bounds for all active countries (outside country loop)
$include "./modules/10_Curves/LearningCurves/preloop.gms"

*' Initialize variable levels from previous period parameter
VmCostLC.L(LCTECH,YTIME+1) = pmCostLC(LCTECH,YTIME-1);
V10CumCapGlobal.L(LCTECH,YTIME+1) = p10CumCapGlobal(LCTECH,YTIME-1);
