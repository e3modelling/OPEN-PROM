*' @title REST OF ENERGY BALANCE SECTORS postsolve
* Store values of variables as parameters for the next time step

* Rest Of Energy Module

*---
* Store snapshot values
p03Transfers(runCyL,EFS,YTIME)$TIME(YTIME) = V03Transfers.L(runCyL,EFS,YTIME)$TIME(YTIME);
p03ConsFinEneCountry(runCyL,EFS,YTIME)$TIME(YTIME) = VmConsFinEneCountry.L(runCyL,EFS,YTIME)$TIME(YTIME);
p03Imp(runCyL,EFS,YTIME)$TIME(YTIME) = V03Imp.L(runCyL,EFS,YTIME)$TIME(YTIME);
p03ConsGrssInl(runCyL,EFS,YTIME)$TIME(YTIME) = V03ConsGrssInl.L(runCyL,EFS,YTIME)$TIME(YTIME);
p03ProdPrimary(runCyL,EFS,YTIME)$TIME(YTIME) = V03ProdPrimary.L(runCyL,EFS,YTIME)$TIME(YTIME);
p03Exp(runCyL,EFS,YTIME)$TIME(YTIME) = V03Exp.L(runCyL,EFS,YTIME)$TIME(YTIME);
p03InpTotTransf(runCyL,SSBS,EFS,YTIME)$TIME(YTIME) = V03InpTotTransf.L(runCyL,SSBS,EFS,YTIME)$TIME(YTIME);
p03OutTotTransf(runCyL,SSBS,EFS,YTIME)$TIME(YTIME) = V03OutTotTransf.L(runCyL,SSBS,EFS,YTIME)$TIME(YTIME);
p03ImpNetEneBrnch(runCyL,EFS,YTIME)$TIME(YTIME) = VmImpNetEneBrnch.L(runCyL,EFS,YTIME)$TIME(YTIME);
p03ConsFiEneSec(runCyL,SSBS,EFS,YTIME)$TIME(YTIME) = VmConsFiEneSec.L(runCyL,SSBS,EFS,YTIME)$TIME(YTIME);
p03ConsFinNonEne(runCyL,EFS,YTIME)$TIME(YTIME) = VmConsFinNonEne.L(runCyL,EFS,YTIME)$TIME(YTIME);
p03LossesDistr(runCyL,EFS,YTIME)$TIME(YTIME) = VmLossesDistr.L(runCyL,EFS,YTIME)$TIME(YTIME);

*' Clear V03 variables for the next time step
option clear = V03Transfers;
option clear = V03ConsGrssInl;
option clear = V03ProdPrimary;
option clear = V03Imp;
option clear = V03Exp;
option clear = V03InpTotTransf;
option clear = V03OutTotTransf;
option clear = VmImpNetEneBrnch;
option clear = VmConsFiEneSec;
option clear = VmConsFinEneCountry;
option clear = VmConsFinNonEne;
option clear = VmLossesDistr;

*' Clear equations for the next time step
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