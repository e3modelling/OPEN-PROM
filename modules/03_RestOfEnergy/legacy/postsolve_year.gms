*' Clear variables and equations (outside country loop — preserves no bounds for next year)
option clear = V03InpTotTransf;
option clear = V03OutTotTransf;
option clear = V03Transfers;
option clear = V03ConsGrssInl;
option clear = V03ProdPrimary;
option clear = V03Exp;
option clear = V03Imp;
option clear = VmImpNetEneBrnch;
option clear = VmConsFiEneSec;
option clear = VmLossesDistr;

option clear = Q03InpTotTransf;
option clear = Q03OutTotTransf;
option clear = Q03Transfers;
option clear = Q03ConsGrssInl;
option clear = Q03ProdPrimary;
option clear = Q03Exp;
option clear = Q03Imp;
option clear = Q03ImpNetEneBrnch;
option clear = Q03ConsFiEneSec;
option clear = Q03LossesDistr;

*' Re-apply critical bounds for all active countries (outside country loop)
V03ConsGrssInl.LO(runCyL,EFS,YTIME+1) = 0;
V03ProdPrimary.LO(runCyL,EFS,YTIME+1) = 0;
V03Imp.LO(runCyL,EFS,YTIME+1) = 0;
V03Exp.LO(runCyL,EFS,YTIME+1) = 0;
VmConsFiEneSec.LO(runCyL,SSBS,EFS,YTIME+1) = 0;
VmLossesDistr.LO(runCyL,EFS,YTIME+1) = 0;
V03OutTotTransf.LO(runCyL,SSBS,EFS,YTIME+1) = 0;
V03InpTotTransf.LO(runCyL,SSBS,EFS,YTIME+1) = 0;

*' Initialize variable levels from previous period parameter
V03ConsGrssInl.L(runCyL,EFS,YTIME+1) = p03ConsGrssInl(runCyL,EFS,YTIME);
V03Transfers.L(runCyL,EFS,YTIME+1) = p03Transfers(runCyL,EFS,YTIME);
V03ProdPrimary.L(runCyL,EFS,YTIME+1) = p03ProdPrimary(runCyL,EFS,YTIME);
V03Exp.L(runCyL,EFS,YTIME+1) = p03Exp(runCyL,EFS,YTIME);
V03Imp.L(runCyL,EFS,YTIME+1) = p03Imp(runCyL,EFS,YTIME);
VmImpNetEneBrnch.L(runCyL,EFS,YTIME+1) = pmImpNetEneBrnch(runCyL,EFS,YTIME);
VmConsFiEneSec.L(runCyL,SSBS,EFS,YTIME+1) = pmConsFiEneSec(runCyL,SSBS,EFS,YTIME);
VmLossesDistr.L(runCyL,EFS,YTIME+1) = pmLossesDistr(runCyL,EFS,YTIME);
V03InpTotTransf.L(runCyL,SSBS,EFS,YTIME+1) = p03InpTotTransf(runCyL,SSBS,EFS,YTIME);
V03OutTotTransf.L(runCyL,SSBS,EFS,YTIME+1) = p03OutTotTransf(runCyL,SSBS,EFS,YTIME);
