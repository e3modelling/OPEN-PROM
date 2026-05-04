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

*' Clear V03 variables for the next time step
option clear = V03Transfers;
option clear = V03ConsGrssInl;
option clear = V03ProdPrimary;
option clear = V03Imp;
option clear = V03Exp;
option clear = V03InpTotTransf;
option clear = V03OutTotTransf;

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
option clear = VmConsFinEneCountry;

*' Reseed V03 variables for all countries from stored parameters
V03Transfers.L(allCy,EFS,YTIME)$TIME(YTIME) = p03Transfers(allCy,EFS,YTIME);
V03ConsGrssInl.L(allCy,EFS,YTIME)$TIME(YTIME) = p03ConsGrssInl(allCy,EFS,YTIME);
V03ProdPrimary.L(allCy,EFS,YTIME)$TIME(YTIME) = p03ProdPrimary(allCy,EFS,YTIME);
V03Imp.L(allCy,EFS,YTIME)$TIME(YTIME) = p03Imp(allCy,EFS,YTIME);
V03Exp.L(allCy,EFS,YTIME)$TIME(YTIME) = p03Exp(allCy,EFS,YTIME);
V03InpTotTransf.L(allCy,SSBS,EFS,YTIME)$TIME(YTIME) = p03InpTotTransf(allCy,SSBS,EFS,YTIME);
V03OutTotTransf.L(allCy,SSBS,EFS,YTIME)$TIME(YTIME) = p03OutTotTransf(allCy,SSBS,EFS,YTIME);
VmConsFinEneCountry.L(allCy,EFS,YTIME)$TIME(YTIME) = p03ConsFinEneCountry(allCy,EFS,YTIME);
*---