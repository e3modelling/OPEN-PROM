*' @title RestOfEnergy Inputs
*' @code

*---
table i03DataGrossInlCons(allCy,EFS,YTIME)	      "Data for Gross Inland Conusmption (Mtoe)"
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
table i03FeedTransfr(allCy,EFS,YTIME)	          "Feedstocks in Transfers (Mtoe)"
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
i03FeedTransfr(allCy,EFS,YTIME) = 0; !!FIXME: i03DataGrossInlCons must be correct to use transfers
*--
* FIXME:
* IEA TES doesn't sum up to each data, due to incorrect transformation input mappings. 
* Author: mmadianos
i03DataGrossInlCons(allCy,EFS,YTIME)$DATAY(YTIME) =
sum(DSBS, imFuelConsPerFueSub(allCy,DSBS,EFS,YTIME)) +
SUM(SSBS,
  i03DataOwnConsEne(allCy,SSBS,EFS,YTIME) -
  i03InpTotTransfProcess(allCy,SSBS,EFS,YTIME)
) +
imDistrLosses(allCy,EFS,YTIME) -
i03FeedTransfr(allCy,EFS,YTIME);
*(imFuelTrade(allCy,"IMPORTS",EFS,YTIME) - imFuelTrade(allCy,"EXPORTS",EFS,YTIME));
*---
i03RateImpGrossInlCons(allCy,EFS,YTIME)$DATAY(YTIME) = 
(
  (imFuelTrade(allCy,"IMPORTS",EFS,YTIME) - imFuelTrade(allCy,"EXPORTS",EFS,YTIME)) / 
  i03DataGrossInlCons(allCy,EFS,YTIME)
)$i03DataGrossInlCons(allCy,EFS,YTIME);
i03RateImpGrossInlCons(allCy,EFS,YTIME) = max(-1000, min(1, i03RateImpGrossInlCons(allCy,EFS,YTIME))); !! Ensure it is in [-1,1]
i03RateImpGrossInlCons(allCy,EFS,YTIME) = round(i03RateImpGrossInlCons(allCy,EFS,YTIME), 4);
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
i03SupResRefCapacity(runCy,SUPOTH,YTIME) = 1;
*---
i03SupTrnasfOutputRefineries(runCy,EF,YTIME) = 1;
*---
i03DataOwnConsEne(runCy,SSBS,EFS,YTIME)$(i03DataOwnConsEne(runCy,SSBS,EFS,YTIME) < 1e-4) = 0;
*---
i03TotEneBranchCons(runCy,EFS,YTIME) = SUM(SSBS,i03DataOwnConsEne(runCy,SSBS,EFS,YTIME));
*---
*i03ResRefCapacity(runCy,YTIME) = i03SupResRefCapacity(runCy,"REF_CAP_RES",YTIME);
*---
i03ResTransfOutputRefineries(runCy,EFS,YTIME) = i03SupTrnasfOutputRefineries(runCy,EFS,YTIME);
*---
i03RateEneBranCons(runCy,SSBS,EFS,YTIME)$AN(YTIME) = i03RateEneBranCons(runCy,SSBS,EFS,"%fBaseY%");
i03RateEneBranCons(runCy,SSBS,EFS,YTIME)$(i03RateEneBranCons(runCy,SSBS,EFS,YTIME)  < 1e-6) = 0;
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
*---
i03RatioPrimaryFuels(runCy,EFS,YTIME)$DATAY(YTIME) = 
(
  i03PrimProd(runCy,EFS,YTIME) / 
  (i03PrimProd(runCy,EFS,YTIME) + SUM(SSBS,i03OutTotTransfProcess(runCy,SSBS,EFS,YTIME)))
)$(i03PrimProd(runCy,EFS,YTIME) + SUM(SSBS,i03OutTotTransfProcess(runCy,SSBS,EFS,YTIME))) +
(
  SUM(runCyL,i03PrimProd(runCyL,EFS,YTIME)) / 
  (SUM(runCyL,i03PrimProd(runCyL,EFS,YTIME)) + SUM(runCyL,SUM(SSBS,i03OutTotTransfProcess(runCyL,SSBS,EFS,YTIME))) + 1e-6)
)$(not i03PrimProd(runCy,EFS,YTIME) + SUM(SSBS,i03OutTotTransfProcess(runCy,SSBS,EFS,YTIME)));
i03RatioPrimaryFuels(runCy,EFS,YTIME) = round(i03RatioPrimaryFuels(runCy,EFS,YTIME), 3);
*---
i03InputEffSupply(runCy,SSBS,EFS,YTIME)$DATAY(YTIME) = 
(
  -i03InpTotTransfProcess(runCy,SSBS,EFS,YTIME) / 
  SUM(EFS2, i03OutTotTransfProcess(runCy,SSBS,EFS2,YTIME))
)$SUM(EFS2, i03OutTotTransfProcess(runCy,SSBS,EFS2,YTIME)) +
(
  -SUM(runCyL,i03InpTotTransfProcess(runCyL,SSBS,EFS,YTIME)) / 
  (SUM((runCyL,EFS2),i03OutTotTransfProcess(runCyL,SSBS,EFS2,YTIME)) + 1e-6)
)$(not SUM(EFS2, i03OutTotTransfProcess(runCy,SSBS,EFS2,YTIME)));