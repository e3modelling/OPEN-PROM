*' @title REST OF ENERGY BALANCE SECTORS Preloop
*' @code

model openprom /

*' * REST OF ENERGY BALANCE SECTORS *
QConsFinEneCountry                  !! VConsFinEneCountry(runCy,EFS,YTIME)
qConsTotFinEne                      !! vConsTotFinEne(YTIME)
QConsFinNonEne                      !! VConsFinNonEne(runCy,EFS,YTIME)
QLossesDistr                        !! VLossesDistr(runCy,EFS,YTIME)
QOutTransfDhp                       !! VOutTransfDhp(runCy,STEAM,YTIME)
QTransfInputDHPlants                !! VTransfInputDHPlants(runCy,EFS,YTIME)
QCapRef                             !! VCapRef(runCy,YTIME)
QOutTransfRefSpec                   !! VOutTransfRefSpec(runCy,EFS,YTIME)
QInputTransfRef                     !! VInputTransfRef(runCy,"CRO",YTIME)
QOutTransfNuclear                   !! VOutTransfNuclear(runCy,"ELC",YTIME)
QInpTransfNuclear                   !! VInpTransfNuclear(runCy,"NUC",YTIME)
QInpTransfTherm                     !! VInpTransfTherm(runCy,PGEF,YTIME)
QOutTransfTherm                     !! VOutTransfTherm(runCy,TOCTEF,YTIME)
QInpTotTransf                       !! VInpTotTransf(runCy,EFS,YTIME)
QOutTotTransf                       !! VOutTotTransf(runCy,EFS,YTIME)
QTransfers                          !! VTransfers(runCy,EFS,YTIME)
QConsGrssInlNotEneBranch            !! VConsGrssInlNotEneBranch(runCy,EFS,YTIME)
QConsGrssInl                        !! VConsGrssInl(runCy,EFS,YTIME)            
QProdPrimary                        !! VProdPrimary(runCy,PPRODEF,YTIME)
QExp                                !! VExp(runCy,EFS,YTIME)
QImp                                !! VImp(runCy,EFS,YTIME)
QImpNetEneBrnch                     !! VImpNetEneBrnch(runCy,EFS,YTIME)
QConsFiEneSec                       !! VConsFiEneSec(runCy,EFS,YTIME)

/;

*'                *VARIABLE INITIALISATION*
*---
VCapRef.l(runCy,YTIME)=0.1;
VCapRef.FX(runCy,YTIME)$(not An(YTIME)) = iRefCapacity(runCy,YTIME);
*---
VOutTransfRefSpec.l(runCy,EFS,YTIME)=0.1;
VOutTransfRefSpec.FX(runCy,EFS,YTIME)$(EFtoEFA(EFS,"LQD") $(not An(YTIME))) = iTransfOutputRef(runCy,EFS,YTIME);
VOutTransfRefSpec.FX(runCy,EFS,YTIME)$(not EFtoEFA(EFS,"LQD")) = 0;
*---
VConsGrssInlNotEneBranch.l(runCy,EFS,YTIME)=0.1;
VConsGrssInlNotEneBranch.FX(runCy,EFS,YTIME)$(not An(YTIME)) = iGrossInConsNoEneBra(runCy,EFS,YTIME);
*---
VOutTransfTherm.FX(runCy,EFS,YTIME)$(not TOCTEF(EFS)) = 0;
*---
VInputTransfRef.FX(runCy,"CRO",YTIME)$(not An(YTIME)) = iTransfInputRef(runCy,"CRO",YTIME);
VInputTransfRef.FX(runCy,EFS,YTIME)$(not sameas("CRO",EFS)) = 0;
*---
VConsGrssInl.FX(runCy,EFS,YTIME)$(not An(YTIME)) = iGrosInlCons(runCy,EFS,YTIME);
*---
VTransfers.FX(runCy,EFS,YTIME)$(not An(YTIME)) = iFeedTransfr(runCy,EFS,YTIME);
*---
VProdPrimary.FX(runCy,PPRODEF,YTIME)$(not An(YTIME)) = iFuelPriPro(runCy,PPRODEF,YTIME);
*---
VImp.FX(runCy,"NGS",YTIME)$(not An(YTIME)) = iFuelImports(runCy,"NGS",YTIME);
VImp.FX(runCy,EFS,YTIME)$(not IMPEF(EFS)) = 0;
*---
VExp.FX(runCy,EFS,YTIME)$(not An(YTIME)) = iFuelExprts(runCy,EFS,YTIME);
VExp.FX(runCy,"NGS",YTIME)$(not An(YTIME)) = iFuelExprts(runCy,"NGS",YTIME);
VExp.FX(runCy,EFS,YTIME)$(not IMPEF(EFS)) = 0;
*---
VOutTransfDhp.FX(runCy,EFS,YTIME)$(not STEAM(EFS)) = 0;
*---
VOutTransfNuclear.FX(runCy,EFS,YTIME)$(not sameas("ELC",EFS)) = 0;
*---
VInpTransfNuclear.FX(runCy,EFS,YTIME)$(not sameas("NUC",EFS)) = 0;
*---