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
option clear = VmConsFinEneCountry;
option clear = VmConsFinNonEne;
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
option clear = Q03ConsFinEneCountry;
option clear = Q03ConsFinNonEne;
option clear = Q03LossesDistr;

*' Re-apply critical bounds for all active countries (outside country loop)
V03ConsGrssInl.LO(runCy,EFS,YTIME) = 0;
V03ProdPrimary.LO(runCy,EFS,YTIME) = 0;
V03Imp.LO(runCy,EFS,YTIME) = 0;
V03Exp.LO(runCy,EFS,YTIME) = 0;
VmConsFiEneSec.LO(runCy,SSBS,EFS,YTIME) = 0;
VmLossesDistr.LO(runCy,EFS,YTIME) = 0;
V03OutTotTransf.LO(runCy,SSBS,EFS,YTIME) = 0;
V03InpTotTransf.LO(runCy,SSBS,EFS,YTIME) = 0;
VmConsFinEneCountry.LO(runCy,EFS,YTIME) = 0;

*' Initialize variable levels from previous period parameter
V03ConsGrssInl.L(runCyL,EFS,YTIME+1) = p03ConsGrssInl(runCy,EFS,YTIME);
V03Transfers.L(runCyL,EFS,YTIME+1) = p03Transfers(runCy,EFS,YTIME);
V03ProdPrimary.L(runCyL,EFS,YTIME+1) = p03ProdPrimary(runCy,EFS,YTIME);
V03Exp.L(runCyL,EFS,YTIME+1) = p03Exp(runCy,EFS,YTIME);
V03Imp.L(runCyL,EFS,YTIME+1) = p03Imp(runCy,EFS,YTIME);
VmImpNetEneBrnch.L(runCyL,EFS,YTIME+1) = pmImpNetEneBrnch(runCy,EFS,YTIME);
VmConsFiEneSec.L(runCyL,SSBS,EFS,YTIME+1) = pmConsFiEneSec(runCy,SSBS,EFS,YTIME);
VmConsFinEneCountry.L(runCyL,EFS,YTIME+1) = pmConsFinEneCountry(runCy,EFS,YTIME);
VmConsFinNonEne.L(runCyL,EFS,YTIME+1) = pmConsFinNonEne(runCy,EFS,YTIME);
VmLossesDistr.L(runCyL,EFS,YTIME+1) = pmLossesDistr(runCy,EFS,YTIME);
V03InpTotTransf.L(runCyL,SSBS,EFS,YTIME+1) = p03InpTotTransf(runCy,SSBS,EFS,YTIME);
V03OutTotTransf.L(runCyL,SSBS,EFS,YTIME+1) = p03OutTotTransf(runCy,SSBS,EFS,YTIME);