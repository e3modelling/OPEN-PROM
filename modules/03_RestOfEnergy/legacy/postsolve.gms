*' @title REST OF ENERGY BALANCE SECTORS postsolve
* Fix values of variables for the next time step

* Rest Of Energy Module

*---
p03Transfers(runCyL,EFS,YTIME)$TIME(YTIME) = V03Transfers.L(runCyL,EFS,YTIME)$TIME(YTIME);
pmConsFinEneCountry(runCyL,EFS,YTIME)$TIME(YTIME) = VmConsFinEneCountry.L(runCyL,EFS,YTIME)$TIME(YTIME);
p03ConsGrssInl(runCyL,EFS,YTIME)$TIME(YTIME) = V03ConsGrssInl.L(runCyL,EFS,YTIME)$TIME(YTIME);
p03InpTotTransf(runCyL,SSBS,EFS,YTIME)$TIME(YTIME) = V03InpTotTransf.L(runCyL,SSBS,EFS,YTIME)$TIME(YTIME);
p03OutTotTransf(runCyL,SSBS,EFS,YTIME)$TIME(YTIME) = V03OutTotTransf.L(runCyL,SSBS,EFS,YTIME)$TIME(YTIME);
p03Imp(runCyL,EFS,YTIME)$TIME(YTIME) = V03Imp.L(runCyL,EFS,YTIME)$TIME(YTIME);
p03ProdPrimary(runCyL,EFS,YTIME)$TIME(YTIME) = V03ProdPrimary.L(runCyL,EFS,YTIME)$TIME(YTIME);
p03Exp(runCyL,EFS,YTIME)$TIME(YTIME) = V03Exp.L(runCyL,EFS,YTIME)$TIME(YTIME);
pmImpNetEneBrnch(runCyL,EFS,YTIME)$TIME(YTIME) = VmImpNetEneBrnch.L(runCyL,EFS,YTIME)$TIME(YTIME);
pmConsFiEneSec(runCyL,SSBS,EFS,YTIME)$TIME(YTIME) = VmConsFiEneSec.L(runCyL,SSBS,EFS,YTIME)$TIME(YTIME);
pmConsFinNonEne(runCyL,EFS,YTIME)$TIME(YTIME) = VmConsFinNonEne.L(runCyL,EFS,YTIME)$TIME(YTIME);
pmLossesDistr(runCyL,EFS,YTIME)$TIME(YTIME) = VmLossesDistr.L(runCyL,EFS,YTIME)$TIME(YTIME);
*---

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
*---
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