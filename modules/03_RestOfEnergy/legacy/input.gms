*' @title RestOfEnergy Inputs
*' @code

*---
table i03SuppRefCapacity(allCy,SUPOTH,YTIME)	  "Supplementary Parameter for the residual in refineries Capacity (1)"
$ondelim
$include "./iSuppRefCapacity.csv"
$offdelim
;
*---
table i03DataTransfOutputRef(allCy,EF,YTIME)	  "Data for Other transformation output  (Mtoe)"
$ondelim
$include"./iDataTransfOutputRef.csv"
$offdelim
;
*---
table i03DataGrossInlCons(allCy,EF,YTIME)	      "Data for Gross Inland Conusmption (Mtoe)"
$ondelim
$include"./iDataGrossInlCons.csv"
$offdelim
;
*---
table i03DataConsEneBranch(allCy,EF,YTIME)	      "Data for Consumption of Energy Branch (Mtoe)"
$ondelim
$include"./iDataConsEneBranch.csv"
$offdelim
;
*---
table i03DataTotTransfInputRef(allCy,EF,YTIME)	  "Total Transformation Input in Refineries (Mtoe)"
$ondelim
$include"./iDataTotTransfInputRef.csv"
$offdelim
;
*---
table i03SuppTransfers(allCy,EFS,YTIME)	          "Supplementary Parameter for Transfers (Mtoe)"
$ondelim
$include"./iSuppTransfers.csv"
$offdelim
;
*---
table i03SuppPrimProd(allCy,PPRODEF,YTIME)	      "Supplementary Parameter for Primary Production (Mtoe)"
$ondelim
$include"./iSuppPrimProd.csv"
$offdelim
;
*---
table i03InpTransfTherm(allCy,EFS,YTIME)          "Historic data of VmInpTransfTherm (Transformation input to thermal power plants) (Mtoe)"
$ondelim
$include"./iInpTransfTherm.csv"
$offdelim
;
*---
table i03SupRateEneBranCons(allCy,EF,YTIME)	      "Rate of Energy Branch Consumption over total transformation output of i03RateEneBranCons (1)"
$ondelim
$include"./iSupRateEneBranCons.csv"
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
parameter i03ParDHEffData(PGEFS)                  "Parameter of  district heating Efficiency (1)" 
/
HCL		  0.76,
LGN		  0.75,
GDO		  0.78,
RFO		  0.78,
OLQ		  0.78,
NGS		  0.8,
OGS		  0.78,
BMSWAS    0.76 
/;
*---

Parameters
i03ParDHEfficiency(PGEFS,YTIME)                   "Parameter of  district heating Efficiency for all years (1)"
i03SupTrnasfOutputRefineries(allCy,EF,YTIME)	  "Supplementary parameter for the transformation output from refineries (Mtoe)"
i03SupResRefCapacity(allCy,SUPOTH,YTIME)	      "Supplementary Parameter for the residual in refineries Capacity (1)"
i03TransfInputRef(allCy,EF,YTIME)	              "Transformation Input in Refineries (Mtoe)"
i03TotEneBranchCons(allCy,EF,YTIME)	              "Total Energy Branch Consumption (Mtoe)"
i03TransfOutputRef(allCy,EF,YTIME)	              "Transformation Output from Refineries (Mtoe)"
i03RefCapacity(allCy,YTIME)	                      "Refineries Capacity (Million Barrels/day)"
i03GrosInlCons(allCy,EF,YTIME)	                  "Gross Inland Consumtpion (Mtoe)"
i03GrossInConsNoEneBra(allCy,EF,YTIME)	          "Gross Inland Consumption,excluding energy branch (Mtoe)"
i03FeedTransfr(allCy,EFS,YTIME)	                  "Feedstocks in Transfers (Mtoe)"
i03FuelPriPro(allCy,EF,YTIME)                 	  "Fuel Primary Production (Mtoe)"
i03EffDHPlants(allCy,EF,YTIME)                    "Efficiency of District Heating Plants (1)"
i03ResRefCapacity(allCy,YTIME)	                  "Residual in Refineries Capacity (1)"
i03ResTransfOutputRefineries(allCy,EF,YTIME)      "Residual in Transformation Output from Refineries (Mtoe)"
i03RateEneBranCons(allCy,EF,YTIME)	              "Rate of Energy Branch Consumption over total transformation output (1)"
i03RatePriProTotPriNeeds(allCy,EF,YTIME)	      "Rate of Primary Production in Total Primary Needs (1)"	
i03ResHcNgOilPrProd(allCy,EF,YTIME)	              "Residuals for Hard Coal, Natural Gas and Oil Primary Production (1)"
i03RatioImpFinElecDem(allCy,YTIME)	              "Ratio of imports in final electricity demand (1)"	
i03ElecImp(allCy,YTIME)	                          "Electricity Imports (1)"
i03InpTransfTherm(allCy,EFS,YTIME)                "Historic data of VmInpTransfTherm (Transformation input to thermal power plants) (Mtoe)"
;
*---
i03SupResRefCapacity(runCy,SUPOTH,YTIME) = 1;
*---
i03SupTrnasfOutputRefineries(runCy,EF,YTIME) = 1;
*---
i03ParDHEfficiency(PGEFS,YTIME) = i03ParDHEffData(PGEFS);
*---
i03TransfInputRef(runCy,EFS,YTIME)$(not An(YTIME)) = i03DataTotTransfInputRef(runCy,EFS,YTIME);
*---
i03TotEneBranchCons(runCy,EFS,YTIME) = i03DataConsEneBranch(runCy,EFS,YTIME);
*---
i03TransfOutputRef(runCy,EFS,YTIME)$(not An(YTIME)) = i03DataTransfOutputRef(runCy,EFS,YTIME);
*---
i03RefCapacity(runCy,YTIME) = i03SuppRefCapacity(runCy,"REF_CAP",YTIME);
*---
i03GrosInlCons(runCy,EFS,YTIME) = i03DataGrossInlCons(runCy,EFS,YTIME);
i03GrossInConsNoEneBra(runCy,EFS,YTIME) = i03GrosInlCons(runCy,EFS,YTIME) + i03TotEneBranchCons(runCy,EFS,YTIME)$EFtoEFA(EFS,"LQD")
                                        - i03TotEneBranchCons(runCy,EFS,YTIME)$(not EFtoEFA(EFS,"LQD"));
*---
i03FeedTransfr(runCy,EFS,YTIME) = i03SuppTransfers(runCy,EFS,YTIME);
*---
i03FuelPriPro(runCy,PPRODEF,YTIME) = i03SuppPrimProd(runCy,PPRODEF,YTIME);
*---
i03EffDHPlants(runCy,EFS,YTIME)$(ord(YTIME)>(ordfirst-8))  = sum(PGEFS$sameas(EFS,PGEFS),i03ParDHEfficiency(PGEFS,"2010"));
*---
i03ResRefCapacity(runCy,YTIME) = i03SupResRefCapacity(runCy,"REF_CAP_RES",YTIME);
*---
i03ResTransfOutputRefineries(runCy,EFS,YTIME) = i03SupTrnasfOutputRefineries(runCy,EFS,YTIME);
*---
i03RateEneBranCons(runCy,EFS,YTIME) = i03SupRateEneBranCons(runCy,EFS,YTIME);
*---
i03RatePriProTotPriNeeds(runCy,PPRODEF,YTIME) = i03SuppRatePrimProd(runCy,PPRODEF,YTIME);
*---
i03ResHcNgOilPrProd(runCy,"HCL",YTIME)$an(YTIME)   = i03SupResRefCapacity(runCy,"HCL_PPROD",YTIME);
i03ResHcNgOilPrProd(runCy,"NGS",YTIME)$an(YTIME)   = i03SupResRefCapacity(runCy,"NGS_PPROD",YTIME);
i03ResHcNgOilPrProd(runCy,"CRO",YTIME)$an(YTIME)   = i03SupResRefCapacity(runCy,"OIL_PPROD",YTIME);
*---
i03RatioImpFinElecDem(runCy,YTIME)$an(YTIME) = i03ElcNetImpShare(runCy,"ELC_IMP",YTIME);
*---
i03ElecImp(runCy,YTIME) = 0;
*---