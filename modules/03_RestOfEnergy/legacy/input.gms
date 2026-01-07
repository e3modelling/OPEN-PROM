*' @title RestOfEnergy Inputs
*' @code

*---
table i03DataGrossInlCons(allCy,EF,YTIME)	      "Data for Gross Inland Conusmption (Mtoe)"
$ondelim
$include"./iDataGrossInlCons.csv"
$offdelim
;
*---
table i03DataOwnConsEne(allCy,SSBS,EFS,YTIME)	      "Data for Consumption of Energy Branch (Mtoe)"
$ondelim
$include"./iDataOwnConsEne.csv"
$offdelim
;
*---
table i03SuppTransfers(allCy,EFS,YTIME)	          "Supplementary Parameter for Transfers (Mtoe)"
$ondelim
$include"./iSuppTransfers.csv"
$offdelim
;
*---
table i03PrimProd(allCy,EFS,YTIME)	              "Primary Production (Mtoe)"
$ondelim
$include"./iPrimProd.csv"
$offdelim
;
*---
table i03SuppRatePrimProd(allCy,EF,YTIME)	      "Supplementary Parameter for iRatePrimProd (1)"	
$ondelim
$include"./iSuppRatePrimProd.csv"
$offdelim
;
*---
table i03ElcNetImpShare(allCy,SUPOTH,YTIME)	      "Ratio of electricity imports in total final demand (1)"
$ondelim
$include "./iElcNetImpShare.csv"
$offdelim
;
*---
table i03OutTotTransfProcess(allCy,SSBS,EFS,YTIME)	      "Total transformation output of supply sectors (Mtoe)"	
$ondelim
$include"./iOutTransfProcess.csv"
$offdelim
;
*---
table i03InpTotTransfProcess(allCy,SSBS,EFS,YTIME)	      "Total transformation input of supply sectors (Mtoe)"	
$ondelim
$include"./iInpTransfProcess.csv"
$offdelim
;
*---
table i03InpCHPTransfProcess(allCy,EFS,YTIME)	      ""	
$ondelim
$include"./iInpCHPTransfProcess.csv"
$offdelim
;
*---
table i03OutCHPTransfProcess(allCy,EFS,YTIME)	      ""	
$ondelim
$include"./iOutCHPTransfProcess.csv"
$offdelim
;
*---
table i03InpDHPTransfProcess(allCy,EFS,YTIME)	      ""	
$ondelim
$include"./iInpDHPTransfProcess.csv"
$offdelim
;
*---
table i03OutDHPTransfProcess(allCy,EFS,YTIME)	      ""	
$ondelim
$include"./iOutDHPTransfProcess.csv"
$offdelim
;
*---
table i03RateEneBranCons(allCy,SSBS,EFS,YTIME)	      "Rate of Energy Branch Consumption over total transformation output (1)"
$ondelim
$include"./iRatioBranchOwnCons.csv"
$offdelim
;
*---
parameter i03NatGasPriProElst(allCy)	          "Natural Gas primary production elasticity related to gross inland consumption (1)" /
$ondelim
$include "./iNatGasPriProElst.csv"
$offdelim
/;
*---
parameter i03PolDstrbtnLagCoeffPriOilPr(kpdl)	  "Polynomial Distribution Lag Coefficients for primary oil production (1)"
/
a1 1.666706504,
a2 1.333269594,
a3 1.000071707,
a4 0.666634797,
a5 0.33343691
/;
*---

Parameters
i03SupTrnasfOutputRefineries(allCy,EF,YTIME)	  "Supplementary parameter for the transformation output from refineries (Mtoe)"
i03SupResRefCapacity(allCy,SUPOTH,YTIME)	      "Supplementary Parameter for the residual in refineries Capacity (1)"
i03TotEneBranchCons(allCy,EF,YTIME)	              "Total Energy Branch Consumption (Mtoe)"
*i03RefCapacity(allCy,YTIME)	                      "Refineries Capacity (Million Barrels/day)"
i03FeedTransfr(allCy,EFS,YTIME)	                  "Feedstocks in Transfers (Mtoe)"
i03ResTransfOutputRefineries(allCy,EF,YTIME)      "Residual in Transformation Output from Refineries (Mtoe)"
i03RatePriProTotPriNeeds(allCy,EF,YTIME)	      "Rate of Primary Production in Total Primary Needs (1)"	
i03ResHcNgOilPrProd(allCy,EF,YTIME)	              "Residuals for Hard Coal, Natural Gas and Oil Primary Production (1)"
i03RatioImpFinElecDem(allCy,YTIME)	              "Ratio of imports in final electricity demand (1)"	
;
*---
i03SupResRefCapacity(runCy,SUPOTH,YTIME) = 1;
*---
i03SupTrnasfOutputRefineries(runCy,EF,YTIME) = 1;
*---
i03TotEneBranchCons(runCy,EFS,YTIME) = SUM(SSBS,i03DataOwnConsEne(runCy,SSBS,EFS,YTIME));
*---
i03FeedTransfr(runCy,EFS,YTIME) = i03SuppTransfers(runCy,EFS,YTIME);
*---
*i03ResRefCapacity(runCy,YTIME) = i03SupResRefCapacity(runCy,"REF_CAP_RES",YTIME);
*---
i03ResTransfOutputRefineries(runCy,EFS,YTIME) = i03SupTrnasfOutputRefineries(runCy,EFS,YTIME);
*---
i03RateEneBranCons(runCy,SSBS,EFS,YTIME)$AN(YTIME) = i03RateEneBranCons(runCy,SSBS,EFS,"%fBaseY%");
*---
i03RatePriProTotPriNeeds(runCy,EFS,YTIME) = i03SuppRatePrimProd(runCy,EFS,"%fBaseY%");
*---
i03ResHcNgOilPrProd(runCy,"HCL",YTIME)$an(YTIME)   = i03SupResRefCapacity(runCy,"HCL_PPROD",YTIME);
i03ResHcNgOilPrProd(runCy,"NGS",YTIME)$an(YTIME)   = i03SupResRefCapacity(runCy,"NGS_PPROD",YTIME);
i03ResHcNgOilPrProd(runCy,"CRO",YTIME)$an(YTIME)   = i03SupResRefCapacity(runCy,"OIL_PPROD",YTIME);
*---
i03RatioImpFinElecDem(runCy,YTIME)$an(YTIME) = i03ElcNetImpShare(runCy,"ELC_IMP",YTIME);
*---
imRateLossesFinCons(runCy,EFS,YTIME) = 
[
  imDistrLosses(runCy,EFS,YTIME) /
  (sum(DSBS, imFuelConsPerFueSub(runCy,DSBS,EFS,YTIME)) + i03PrimProd(runCy,"CRO",YTIME)$sameas("CRO",EFS))
]$(sum(DSBS, imFuelConsPerFueSub(runCy,DSBS,EFS,YTIME)) + i03PrimProd(runCy,"CRO",YTIME)$sameas("CRO",EFS));
imRateLossesFinCons(runCy,EFS,YTIME)$AN(YTIME) = imRateLossesFinCons(runCy,EFS,"%fBaseY%");