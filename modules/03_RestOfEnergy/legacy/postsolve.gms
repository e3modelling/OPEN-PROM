*' @title REST OF ENERGY BALANCE SECTORS postsolve
* Fix values of variables for the next time step

* Rest Of Energy Module

*---
p03Transfers(runCyL,EFS,YTIME)$TIME(YTIME) = V03Transfers.L(runCyL,EFS,YTIME)$TIME(YTIME);
p03ConsGrssInl(runCyL,EFS,YTIME)$TIME(YTIME) = V03ConsGrssInl.L(runCyL,EFS,YTIME)$TIME(YTIME);
p03InpTotTransf(runCyL,SSBS,EFS,YTIME)$TIME(YTIME) = V03InpTotTransf.L(runCyL,SSBS,EFS,YTIME)$TIME(YTIME);
p03OutTotTransf(runCyL,SSBS,EFS,YTIME)$TIME(YTIME) = V03OutTotTransf.L(runCyL,SSBS,EFS,YTIME)$TIME(YTIME);
p03Imp(runCyL,EFS,YTIME)$TIME(YTIME) = V03Imp.L(runCyL,EFS,YTIME)$TIME(YTIME);
p03ProdPrimary(runCyL,EFS,YTIME)$TIME(YTIME) = V03ProdPrimary.L(runCyL,EFS,YTIME)$TIME(YTIME);
p03Exp(runCyL,EFS,YTIME)$TIME(YTIME) = V03Exp.L(runCyL,EFS,YTIME)$TIME(YTIME);
pmImpNetEneBrnch(runCyL,EFS,YTIME)$TIME(YTIME) = VmImpNetEneBrnch.L(runCyL,EFS,YTIME)$TIME(YTIME);
pmConsFiEneSec(runCyL,SSBS,EFS,YTIME)$TIME(YTIME) = VmConsFiEneSec.L(runCyL,SSBS,EFS,YTIME)$TIME(YTIME);
pmLossesDistr(runCyL,EFS,YTIME)$TIME(YTIME) = VmLossesDistr.L(runCyL,EFS,YTIME)$TIME(YTIME);
pmFinalEnergy(runCyL,DSBS,EFS,YTIME)$TIME(YTIME) = VmFinalEnergy.L(runCyL,DSBS,EFS,YTIME)$TIME(YTIME);

*---