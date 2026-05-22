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

*' Re-apply preloop bounds for all active countries (outside country loop)
$include "./modules/03_RestOfEnergy/legacy/preloop.gms"

*' Initialize variable levels from previous period parameter
V03ConsGrssInl.L(runCy,EFS,YTIME) = p03ConsGrssInl(runCy,EFS,YTIME-1);
V03Transfers.L(runCy,EFS,YTIME) = p03Transfers(runCy,EFS,YTIME-1);
V03ProdPrimary.L(runCy,EFS,YTIME) = p03ProdPrimary(runCy,EFS,YTIME-1);
V03Exp.L(runCy,EFS,YTIME) = p03Exp(runCy,EFS,YTIME-1);
V03Imp.L(runCy,EFS,YTIME) = p03Imp(runCy,EFS,YTIME-1);
VmImpNetEneBrnch.L(runCy,EFS,YTIME) = pmImpNetEneBrnch(runCy,EFS,YTIME-1);
VmConsFiEneSec.L(runCy,SSBS,EFS,YTIME) = pmConsFiEneSec(runCy,SSBS,EFS,YTIME-1);
VmConsFinEneCountry.L(runCy,EFS,YTIME) = pmConsFinEneCountry(runCy,EFS,YTIME-1);
VmConsFinNonEne.L(runCy,EFS,YTIME) = pmConsFinNonEne(runCy,EFS,YTIME-1);
VmLossesDistr.L(runCy,EFS,YTIME) = pmLossesDistr(runCy,EFS,YTIME-1);
V03InpTotTransf.L(runCy,SSBS,EFS,YTIME) = p03InpTotTransf(runCy,SSBS,EFS,YTIME-1);
V03OutTotTransf.L(runCy,SSBS,EFS,YTIME) = p03OutTotTransf(runCy,SSBS,EFS,YTIME-1);
