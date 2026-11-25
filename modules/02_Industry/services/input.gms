*' @title Industry Inputs
*' @code
*---
table i02Capacity(allCy,INDDOM,IND_SERVS,INDITECH,YTIME)	      ""	
$ondelim
$include"./iProductionIS.csv"
$offdelim
;
*---
table i02IndCosts(TECH,*,YTIME)	      "Costs for industry technologies (Capex, Opex, OM) in billion $2015/ Million tonnes of steel"	
$ondelim
$include"./iIndustryCosts.csv"
$offdelim
;
*---
table i02FuelConsICT(allCy,ICTSCEN,SSPSCEN,YTIME)             "Electrity demand of Data centers and infrastructure (Mtoe)"
$ondelim
$include "./iFuelConsICT.csv"
$offdelim
;
*---
table i02ISTransfOutEF(allCy,IS_TRANSF,EF,YTIME)	      ""	
$ondelim
$include"./iOutFullTransfProcess.csv"
$offdelim
;
*---
table i02FuelConsPerService(allCy,INDDOM,IND_SERVS,EF,YTIME)	      ""	
$ondelim
$include"./IDataFuelConsPerService.csv"
$offdelim
;
* FIXME: EAF for PRIM_STEEL includes DRI-EAF Energy consumption. Needs disaggregation (mrprom)
*---
table i02SFC(allCy,INDDOM,IND_SERVS,INDITECH,EF,YTIME)	      "Specific fuel consumption of industry technologies (mtoe/mtoe or mtoe/Million tonnes of steel)"	
$ondelim
$include"./iDataIndustrySFC.csv"
$offdelim
;

parameter i02EffImprovement(TECH)      "Eff improvement per year"/
EAF 0.005
BOF 0.003
CONVDRI 0.005
CONVDRICCS 0.005
GREENDRI 0.006
COKEOV 0.002
BF 0.003
/;

** EFF improvement
i02SFC(allCy,INDDOM,IND_SERVS,INDITECH,EF,YTIME)$(ord(YTIME) < 42 and not DATAY(YTIME)) = 
i02SFC(allCy,INDDOM,IND_SERVS,INDITECH,EF,"%fBaseY%") * 
(1-i02EffImprovement(INDITECH)) ** (2010 + ord(YTIME) - %fBaseY% - 1);
i02SFC(allCy,INDDOM,IND_SERVS,INDITECH,EF,YTIME)$(ord(YTIME) >= 42) = i02SFC(allCy,INDDOM,IND_SERVS,INDITECH,EF,"2050");
*---
table i02ISTransfInEF(allCy,IS_TRANSF,EF,YTIME)	      ""	
$ondelim
$include"./iInpFullTransfProcess.csv"
$offdelim
;
*---
table i02OwnEnergyTransf(allCy,IS_TRANSF,EF,YTIME)	      ""	
$ondelim
$include"./IDataOwnEnergyTransf.csv"
$offdelim
;
*---
$IFTHEN.calib %Calibration% == off
*$ontext
table i02ScaleEndogScrap(allCy,DSBS,TECH,YTIME)       "Scale parameter for endogenous scrapping applied to the sum of full costs (1)"
$ondelim
$include"./iScaleEndogScrap.csv"
$offdelim
;
*$offtext
*---
table i02CalibUsefulEnergy(allCy,INDDOM,YTIME)      "Calibration parameter for useful energy (1)"
$ondelim
$include"./iCalibUsefulEnergy.csv"
$offdelim
;
*---
$ELSE.calib
variable i02ScaleEndogScrap(allCy,INDDOM,INDITECH,YTIME)        "Scale parameter for endogenous scrapping applied to the sum of full costs (1)";
variable i02CalibUsefulEnergy(allCy,INDDOM,YTIME);

i02ScaleEndogScrap.LO(runCy,INDDOM,INDITECH,YTIME) = 0.01;                                      
i02ScaleEndogScrap.UP(runCy,INDDOM,INDITECH,YTIME) = 10;
i02ScaleEndogScrap.L(runCy,INDDOM,INDITECH,YTIME) = 1;
i02ScaleEndogScrap.FX(runCy,INDDOM,INDITECH,YTIME)$(not CALIB_DSBS(INDDOM)) = 1;
*i02ScaleEndogScrap.FX(runCy,INDDOM,INDITECH,YTIME)$(DATAY(YTIME) or not SECTTECH(INDDOM,INDITECH)) = 0;

i02CalibUsefulEnergy.LO(runCy,INDDOM,YTIME) = -0.05;  
i02CalibUsefulEnergy.UP(runCy,INDDOM,YTIME) = 0.05;  
i02CalibUsefulEnergy.FX(runCy,INDDOM,YTIME)$DATAY(YTIME) = 0;
i02CalibUsefulEnergy.FX(runCy,INDDOM,YTIME)$(not CALIB_DSBS(INDDOM)) = 0;
*---
table t02SharesFuelBuildings(allCy,DSBS,EFS,YTIME)    "Targets for share of new passenger cars"
$ondelim
$include "../targets/tSharesFuelBuildings.csv"
$offdelim
;

table t02SharesFuelINDSE(allCy,DSBS,EFS,YTIME)    "Targets for share of new passenger cars"
$ondelim
$include "../targets/tSharesINDSE.csv"
$offdelim
;

table t02FinalEnergyDOMSE(allCy,DSBS,YTIME)    "Targets for share of new passenger cars"
$ondelim
$include "../targets/tProjectionsFuelBuildings.csv"
$offdelim
;

table t02FinalEnergyINDSE(allCy,DSBS,YTIME)    "Targets for share of new passenger cars"
$ondelim
$include "../targets/tProjectionsINDSE.csv"
$offdelim
;
$ENDIF.calib
*---
parameter i02ratioMaterialCons(IND_SERVS,TECH,MATERIALS)      "Material consumption: (ton/ton of steel)"/ !!From EU-CHINA BRIGDE DATA
PRIM_STEEL.EAF.SPNGIRN 0.99
PRIM_STEEL.EAF.SCRAP 0.19
SEC_STEEL.EAF.SCRAP 1.10
PRIM_STEEL.BOF.PIGIRON 0.9
PRIM_STEEL.BOF.SCRAP 0.19
PRIM_STEEL.BOF.IRONORE 0.01
PRIM_STEEL.BF.IRONORE 1.5891
PRIM_STEEL.CONVDRI.IRONORE 1.38
PRIM_STEEL.CONVDRICCS.IRONORE 1.38
PRIM_STEEL.GREENDRI.IRONORE 1.38
/;

parameter i02ratioFuelConsPerMaterial(IS_TRANSF,MATERIALS,EFS)      "Fuel consumption per output material: (Mtoe/Mton of material)"/ !!From EU-CHINA BRIGDE DATA
DRI.SPNGIRN.NGS 0.199
DRI.SPNGIRN.ELC 0.005
/;
*---
imTotFinEneDemSubBaseYr(runCy,DSBS,YTIME)  = sum(EF$SECtoEF(DSBS,EF),imFuelCons(runCy,DSBS,EF,YTIME));
*---
imCO2CaptRateIndustry(runCy,CCSITECH,YTIME) = 0.9;
*---
i02DataEnergyService(runCy,INDDOM,IND_SERVS,YTIME)$(INDDOMtoSERVS(INDDOM,IND_SERVS)) = SUM(INDITECH,i02Capacity(runCy,INDDOM,IND_SERVS,INDITECH,YTIME));
*---
imCapCostTech(runCy,"IS",INDITECH,YTIME) = i02IndCosts(INDITECH,'Capex',YTIME); 
*---
imFixOMCostTech(runCy,"IS",INDITECH,YTIME) = i02IndCosts(INDITECH,'Fix',YTIME);  !!Units for other industries than IS needs to be checked to remove sUnitToKUnit
*--
imVarCostTech(runCy,"IS",INDITECH,YTIME)= i02IndCosts(INDITECH,'Opex',YTIME);  !!Units for other industries than IS needs to be checked to remove sUnitToKUnit
*--
VmLft.FX(runCy,INDSE,INDITECH,YTIME)=imDataIndTechnology(INDSE,INDITECH,"LFT");
VmLft.FX(runCy,INDSE,INDITECH,YTIME)$(sameas("TGEO",INDITECH) or sameas("TSOL",INDITECH) or sameas("TH2F",INDITECH)) = 25; !!FIX ME: revisit this

display imUsfEneConvSubTech, VmLft.L,imDisc,imCapCostTech;

$ontext
i02SpecificFuelConsData(runCy,INDDOM,IND_SERVS,INDITECH,YTIME)$(DATAY(YTIME) and INDDOMtoSERVS(INDDOM,IND_SERVS) or SERVStoTECH(IND_SERVS,INDITECH)) = 1;
i02SpecificFuelConsData(runCy,INDDOM,IND_SERVS,INDITECH,YTIME)$(DATAY(YTIME) and INDDOMtoSERVS(INDDOM,IND_SERVS) or SERVStoTECH(IND_SERVS,INDITECH)) = 
(i02SpecificFuelConsData(runCy,INDDOM,IND_SERVS,INDITECH,YTIME) / i02DataEnergyService(runCy,INDDOM,IND_SERVS,YTIME) *
SUM((INDITECH2,EFS)$(INDDOMtoSERVS(INDDOM,IND_SERVS) and SERVStoTECH(IND_SERVS,INDITECH2) and INDITECHTOEF(INDITECH2,EFS)),
  i02FuelConsPerService(runCy,INDDOM,IND_SERVS,EFS,YTIME) / i02SpecificFuelConsData(runCy,INDDOM,IND_SERVS,INDITECH2,YTIME)
)
)$(i02DataEnergyService(runCy,INDDOM,IND_SERVS,YTIME) and SUM(EFS,i02FuelConsPerService(runCy,INDDOM,IND_SERVS,EFS,YTIME))) +
1e-6;
$offtext
*---
*i02Capacity(runCy,INDDOM,IND_SERVS,INDITECH,YTIME)$(DATAY(YTIME) and INDDOMtoSERVS(INDDOM,IND_SERVS) and SERVStoTECH(IND_SERVS,INDITECH)) = SUM(EFS$INDITECHTOEF(INDITECH,EFS), i02FuelConsPerService(runCy,INDDOM,IND_SERVS,EFS,YTIME)) / i02SpecificFuelConsData(runCy,INDDOM,IND_SERVS,INDITECH,YTIME);
*---
$ontext
i02DataShareBlend(runCy,INDDOM,IND_SERVS,INDITECH,EF,YTIME)$(DATAY(YTIME) and INDDOMtoSERVS(INDDOM,IND_SERVS) and SERVStoTECH(IND_SERVS,INDITECH) and INDITECHTOEF(INDITECH,EF)) = 
(i02FuelConsPerService(runCy,INDDOM,IND_SERVS,EF,YTIME) + 1e-6) /
SUM(EF2$(INDDOMtoSERVS(INDDOM,IND_SERVS) or SERVStoTECH(IND_SERVS,INDITECH) and INDITECHTOEF(INDITECH,EF2)),
    i02FuelConsPerService(runCy,INDDOM,IND_SERVS,EF2,YTIME) + 1e-6
);
$offtext
*---
i03DataCap(runCy,IS_TRANSF,IS_TRANSF_TECH,YTIME)$(DATAY(YTIME) and IS_TRANSFtoIS_TRANSF_TECH(IS_TRANSF,IS_TRANSF_TECH) and not sameas("GREENDRI",IS_TRANSF_TECH) and not sameas("CONVDRICCS",IS_TRANSF_TECH)) = 
SUM((INDITECH,MATERIALS)$IS_TRANSF_OUT_MATERIAL(IS_TRANSF,MATERIALS),
  i02ratioMaterialCons("PRIM_STEEL",INDITECH,MATERIALS) *
  i02Capacity(runCy,"IS","PRIM_STEEL",INDITECH,YTIME)
);
*---
i02ratioTransfInputIS(runCy,IS_TRANSF,IS_TRANSF_TECH,EFS,YTIME)$DATAY(YTIME) =
(
  -i02ISTransfInEF(runCy,IS_TRANSF,EFS,YTIME) / 
  i03DataCap(runCy,IS_TRANSF,IS_TRANSF_TECH,YTIME)
)$i03DataCap(runCy,IS_TRANSF,IS_TRANSF_TECH,YTIME) +
(
  -SUM(runCy2,i02ISTransfInEF(runCy2,IS_TRANSF,EFS,YTIME)) /
  SUM(runCy2,i03DataCap(runCy2,IS_TRANSF,IS_TRANSF_TECH,YTIME))
)$(not i03DataCap(runCy,IS_TRANSF,IS_TRANSF_TECH,YTIME) and (SUM(runCy2,i03DataCap(runCy2,IS_TRANSF,IS_TRANSF_TECH,YTIME)) > 0));
* Handle the case where there is capacity but no historical fuel
i02ratioTransfInputIS(runCy,IS_TRANSF,IS_TRANSF_TECH,EFS,YTIME)$(DATAY(YTIME) and (i03DataCap(runCy,IS_TRANSF,IS_TRANSF_TECH,YTIME) > 0) and (SUM(EFS2,i02ISTransfInEF(runCy,IS_TRANSF,EFS2,YTIME)) = 0)) =
-SUM(runCy2,i02ISTransfInEF(runCy2,IS_TRANSF,EFS,YTIME)) /
SUM(runCy2,i03DataCap(runCy2,IS_TRANSF,IS_TRANSF_TECH,YTIME));
*---
i02ratioOwnEnergyTransfIS(runCy,IS_TRANSF,IS_TRANSF_TECH,EFS,YTIME)$DATAY(YTIME) = 
(
  i02OwnEnergyTransf(runCy,IS_TRANSF,EFS,YTIME) / 
  i03DataCap(runCy,IS_TRANSF,IS_TRANSF_TECH,YTIME)
)$i03DataCap(runCy,IS_TRANSF,IS_TRANSF_TECH,YTIME) +
(
  SUM(runCy2,i02OwnEnergyTransf(runCy2,IS_TRANSF,EFS,YTIME)) /
  SUM(runCy2,i03DataCap(runCy2,IS_TRANSF,IS_TRANSF_TECH,YTIME))
)$(not i03DataCap(runCy,IS_TRANSF,IS_TRANSF_TECH,YTIME) and (SUM(runCy2,i03DataCap(runCy2,IS_TRANSF,IS_TRANSF_TECH,YTIME)) > 0)) +
(
  6.6 * 0.02388 * i05H2Production("INOUT_ELC","weg",YTIME)
)$(sameas("GREENDRI",IS_TRANSF_TECH) and sameas("DRI",IS_TRANSF) and sameas("ELC",EFS));

* Handle the case where there is capacity but no historical fuel
i02ratioOwnEnergyTransfIS(runCy,IS_TRANSF,IS_TRANSF_TECH,EFS,YTIME)$(DATAY(YTIME) and (i03DataCap(runCy,IS_TRANSF,IS_TRANSF_TECH,YTIME) > 0) and (SUM(EFS2,i02OwnEnergyTransf(runCy,IS_TRANSF,EFS2,YTIME)) = 0)) =
SUM(runCy2,i02OwnEnergyTransf(runCy2,IS_TRANSF,EFS,YTIME)) /
SUM(runCy2,i03DataCap(runCy2,IS_TRANSF,IS_TRANSF_TECH,YTIME));

* Add extra consumption for CCS 
i02ratioOwnEnergyTransfIS(runCy,"DRI","CONVDRICCS",EFS,YTIME) = i02ratioOwnEnergyTransfIS(runCy,"DRI","CONVDRI",EFS,YTIME) + 0.00573$sameas("ELC",EFS);

* Efficiency improvements
i02ratioOwnEnergyTransfIS(runCy,IS_TRANSF,IS_TRANSF_TECH,EFS,YTIME)$(ord(YTIME) < 42 and not DATAY(YTIME)) = 
i02ratioOwnEnergyTransfIS(runCy,IS_TRANSF,IS_TRANSF_TECH,EFS,"%fBaseY%") *
(1-i02EffImprovement(IS_TRANSF_TECH)) ** (2010 + ord(YTIME) - %fBaseY% - 1);
i02ratioOwnEnergyTransfIS(runCy,IS_TRANSF,IS_TRANSF_TECH,EFS,YTIME)$(ord(YTIME) >= 42) = i02ratioOwnEnergyTransfIS(runCy,IS_TRANSF,IS_TRANSF_TECH,EFS,"2050");

i02ratioTransfInputIS(runCy,IS_TRANSF,IS_TRANSF_TECH,EFS,YTIME)$(ord(YTIME) < 42 and not DATAY(YTIME)) = 
i02ratioTransfInputIS(runCy,IS_TRANSF,IS_TRANSF_TECH,EFS,"%fBaseY%") *
(1-i02EffImprovement(IS_TRANSF_TECH)) ** (2010 + ord(YTIME) - %fBaseY% - 1);
i02ratioTransfInputIS(runCy,IS_TRANSF,IS_TRANSF_TECH,EFS,YTIME)$(ord(YTIME) >= 42) = i02ratioTransfInputIS(runCy,IS_TRANSF,IS_TRANSF_TECH,EFS,"2050");
*---
i02InputMaterials(runCy,IND_SERVS,MATERIALS,YTIME) = 
SUM(INDITECH,
  i02ratioMaterialCons(IND_SERVS,INDITECH,MATERIALS) *
  i02Capacity(runCy,"IS",IND_SERVS,INDITECH,YTIME)
) +
SUM((IS_TRANSF,IS_TRANSF_TECH)$IS_TRANSFtoIS_TRANSF_TECH(IS_TRANSF,IS_TRANSF_TECH),
  i02ratioMaterialCons(IND_SERVS,IS_TRANSF_TECH,MATERIALS) *
  i03DataCap(runCy,IS_TRANSF,IS_TRANSF_TECH,YTIME)
);
*---
i03DataCostVariable(runCy,IS_TRANSF,IS_TRANSF_TECH,YTIME)$(DATAY(YTIME) and IS_TRANSFtoIS_TRANSF_TECH(IS_TRANSF,IS_TRANSF_TECH)) =
sum(EF$IS_TRANSF_TECHtoEF(IS_TRANSF_TECH,EF), 
  (i02ratioTransfInputIS(runCy,IS_TRANSF,IS_TRANSF_TECH,EF,"%fBaseY%") + i02ratioOwnEnergyTransfIS(runCy,IS_TRANSF,IS_TRANSF_TECH,EF,"%fBaseY%")) *
  (
    imFuelPrice(runCy,"IS",EF,YTIME) +
    !!imCaptRateCO2(IS_TRANSF_TECH) * i06ElastCO2Seq(runCy,"seq_min") * 1e-3 * (imCo2EmiFac(runCy,"PG",EF,YTIME) + 4.17$sameas("BMSWAS", EF)) +
    (1-imCaptRateCO2(IS_TRANSF_TECH)) * 1e-3 * imCo2EmiFac(runCy,"PG",EF,YTIME) * iCarbValYrExog(runCy,YTIME)
  )
) +
i02IndCosts(IS_TRANSF_TECH,'Opex',YTIME) +
SUM(MATERIALS,
  i02ratioMaterialCons("PRIM_STEEL",IS_TRANSF_TECH,MATERIALS) *
  iPriceMaterial(runCy,MATERIALS)
);
*---
iPriceMaterial(runCy,"SPNGIRN") = i02IndCosts("CONVDRI",'Capex',"%fBaseY%") * imCGI(runCy,"%fBaseY%") + i02IndCosts("CONVDRI",'Fix',"%fBaseY%") + i03DataCostVariable(runCy,"DRI","CONVDRI","%fBaseY%");
iPriceMaterial(runCy,"PIGIRON") = i02IndCosts("BF",'Capex',"%fBaseY%") * imCGI(runCy,"%fBaseY%") + i02IndCosts("BF",'Fix',"%fBaseY%") + i03DataCostVariable(runCy,"BLASTFUR","BF","%fBaseY%");
*---
i02EnergyPremium("SPNGIRN","ELC") = 0.01027;