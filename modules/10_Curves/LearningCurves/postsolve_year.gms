*' Clear variables and equations (outside country loop — preserves no bounds for next year)
option clear = VmCostLC;
option clear = V10CumCapGlobal;

option clear = Q10CostLC;
option clear = Q10CumCapGlobal;

*' Re-apply critical bounds (outside country loop)
VmCostLC.LO(LCTECH,YTIME+1) = 0.1;
VmCostLC.UP(LCTECH,YTIME+1) = 2.0;

*' Initialize variable levels from previous period parameter
VmCostLC.L(LCTECH,YTIME+1) = pmCostLC(LCTECH,YTIME);
V10CumCapGlobal.L(LCTECH,YTIME+1) = p10CumCapGlobal(LCTECH,YTIME);
