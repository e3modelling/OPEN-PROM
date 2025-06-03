*' @title RestOfEnergy Inputs
*' @code

*---
table iSuppRefCapacity(allCy,SUPOTH,YTIME)	          "Supplementary Parameter for the residual in refineries Capacity (1)"
$ondelim
$include "./iSuppRefCapacity.csv"
$offdelim
;
*---
table iDataTransfOutputRef(allCy,EF,YTIME)	    "Data for Other transformation output  (Mtoe)"
$ondelim
$include"./iDataTransfOutputRef.csv"
$offdelim
;
*---
table iDataGrossInlCons(allCy,EF,YTIME)	 "Data for Gross Inland Conusmption (Mtoe)"
$ondelim
$include"./iDataGrossInlCons.csv"
$offdelim
;
*---
table iDataConsEneBranch(allCy,EF,YTIME)	 "Data for Consumption of Energy Branch (Mtoe)"
$ondelim
$include"./iDataConsEneBranch.csv"
$offdelim
;
*---
table iDataTotTransfInputRef(allCy,EF,YTIME)	 "Total Transformation Input in Refineries (Mtoe)"
$ondelim
$include"./iDataTotTransfInputRef.csv"
$offdelim
;
*---
table iSuppTransfers(allCy,EFS,YTIME)	                "Supplementary Parameter for Transfers (Mtoe)"
$ondelim
$include"./iSuppTransfers.csv"
$offdelim
;
*---
table iSuppPrimProd(allCy,PPRODEF,YTIME)	          "Supplementary Parameter for Primary Production (Mtoe)"
$ondelim
$include"./iSuppPrimProd.csv"
$offdelim
;
*---
table iInpTransfTherm(allCy,EFS,YTIME) "Historic data of VMInpTransfTherm (Transformation input to thermal power plants) (Mtoe)"
$ondelim
$include"./iInpTransfTherm.csv"
$offdelim
;
*---
table iSupRateEneBranCons(allCy,EF,YTIME)	          "Rate of Energy Branch Consumption over total transformation output of iRateEneBranCons (1)"
$ondelim
$include"./iSupRateEneBranCons.csv"
$offdelim
;
*---
table iSuppRatePrimProd(allCy,EF,YTIME)	              "Supplementary Parameter for iRatePrimProd (1)"	
$ondelim
$include"./iSuppRatePrimProd.csv"
$offdelim
;
*---
table iPriceFuelsInt(WEF,YTIME)                "International Fuel Prices ($2015/toe)"
$ondelim
$include"./iPriceFuelsInt.csv"
$offdelim
;
*---
table iElcNetImpShare(allCy,SUPOTH,YTIME)	          "Ratio of electricity imports in total final demand (1)"
$ondelim
$include "./iElcNetImpShare.csv"
$offdelim
;
*---
parameter iNatGasPriProElst(allCy)	          "Natural Gas primary production elasticity related to gross inland consumption (1)" /
$ondelim
$include "./iNatGasPriProElst.csv"
$offdelim
/;
*---
parameter iPolDstrbtnLagCoeffPriOilPr(kpdl)	  "Polynomial Distribution Lag Coefficients for primary oil production (1)"/
a1 1.666706504,
a2 1.333269594,
a3 1.000071707,
a4 0.666634797,
a5 0.33343691 /;
*---
Parameters
iParDHEfficiency(PGEFS,YTIME)                     "Parameter of  district heating Efficiency for all years (1)"
iSupTrnasfOutputRefineries(allCy,EF,YTIME)	      "Supplementary parameter for the transformation output from refineries (Mtoe)"
iSupResRefCapacity(allCy,SUPOTH,YTIME)	          "Supplementary Parameter for the residual in refineries Capacity (1)"
iTransfInputRef(allCy,EF,YTIME)	                  "Transformation Input in Refineries (Mtoe)"
iTotEneBranchCons(allCy,EF,YTIME)	              "Total Energy Branch Consumption (Mtoe)"
iTransfOutputRef(allCy,EF,YTIME)	              "Transformation Output from Refineries (Mtoe)"
iRefCapacity(allCy,YTIME)	                      "Refineries Capacity (Million Barrels/day)"
iGrosInlCons(allCy,EF,YTIME)	                  "Gross Inland Consumtpion (Mtoe)"
iGrossInConsNoEneBra(allCy,EF,YTIME)	          "Gross Inland Consumption,excluding energy branch (Mtoe)"
iFeedTransfr(allCy,EFS,YTIME)	                  "Feedstocks in Transfers (Mtoe)"
iFuelPriPro(allCy,EF,YTIME)                 	  "Fuel Primary Production (Mtoe)"
iEffDHPlants(allCy,EF,YTIME)                      "Efficiency of District Heating Plants (1)"
iResRefCapacity(allCy,YTIME)	                  "Residual in Refineries Capacity (1)"
iResTransfOutputRefineries(allCy,EF,YTIME)        "Residual in Transformation Output from Refineries (Mtoe)"
iRateEneBranCons(allCy,EF,YTIME)	              "Rate of Energy Branch Consumption over total transformation output (1)"
iRatePriProTotPriNeeds(allCy,EF,YTIME)	          "Rate of Primary Production in Total Primary Needs (1)"	
iResHcNgOilPrProd(allCy,EF,YTIME)	              "Residuals for Hard Coal, Natural Gas and Oil Primary Production (1)"
iRatioImpFinElecDem(allCy,YTIME)	              "Ratio of imports in final electricity demand (1)"	
iElecImp(allCy,YTIME)	                          "Electricity Imports (1)"
iInpTransfTherm(allCy,EFS,YTIME)                  "Historic data of VMInpTransfTherm (Transformation input to thermal power plants) (Mtoe)"
;
*---
iSupResRefCapacity(runCy,SUPOTH,YTIME) = 1;
*---
iSupTrnasfOutputRefineries(runCy,EF,YTIME) = 1;
*---
iParDHEfficiency(PGEFS,YTIME) = imParDHEffData(PGEFS) ;
*---
iTransfInputRef(runCy,EFS,YTIME)$(not An(YTIME)) = iDataTotTransfInputRef(runCy,EFS,YTIME);
*---
iTotEneBranchCons(runCy,EFS,YTIME) = iDataConsEneBranch(runCy,EFS,YTIME);
*---
iTransfOutputRef(runCy,EFS,YTIME)$(not An(YTIME)) = iDataTransfOutputRef(runCy,EFS,YTIME);
*---
iRefCapacity(runCy,YTIME)= iSuppRefCapacity(runCy,"REF_CAP",YTIME);
*---
iGrosInlCons(runCy,EFS,YTIME) = iDataGrossInlCons(runCy,EFS,YTIME);
iGrossInConsNoEneBra(runCy,EFS,YTIME) = iGrosInlCons(runCy,EFS,YTIME) + iTotEneBranchCons(runCy,EFS,YTIME)$EFtoEFA(EFS,"LQD")
                                               - iTotEneBranchCons(runCy,EFS,YTIME)$(not EFtoEFA(EFS,"LQD"));
*---
iFeedTransfr(runCy,EFS,YTIME) = iSuppTransfers(runCy,EFS,YTIME);
*---
iFuelPriPro(runCy,PPRODEF,YTIME) = iSuppPrimProd(runCy,PPRODEF,YTIME);
*---
iEffDHPlants(runCy,EFS,YTIME)$(ord(YTIME)>(ordfirst-8))  = sum(PGEFS$sameas(EFS,PGEFS),iParDHEfficiency(PGEFS,"2010"));
*---
iResRefCapacity(runCy,YTIME) = iSupResRefCapacity(runCy,"REF_CAP_RES",YTIME);
*---
iResTransfOutputRefineries(runCy,EFS,YTIME) = iSupTrnasfOutputRefineries(runCy,EFS,YTIME);
*---
iRateEneBranCons(runCy,EFS,YTIME)= iSupRateEneBranCons(runCy,EFS,YTIME);
*---
iRatePriProTotPriNeeds(runCy,PPRODEF,YTIME) = iSuppRatePrimProd(runCy,PPRODEF,YTIME);
*---
iResHcNgOilPrProd(runCy,"HCL",YTIME)$an(YTIME)   = iSupResRefCapacity(runCy,"HCL_PPROD",YTIME);
iResHcNgOilPrProd(runCy,"NGS",YTIME)$an(YTIME)   = iSupResRefCapacity(runCy,"NGS_PPROD",YTIME);
iResHcNgOilPrProd(runCy,"CRO",YTIME)$an(YTIME)   = iSupResRefCapacity(runCy,"OIL_PPROD",YTIME);
*---
iRatioImpFinElecDem(runCy,YTIME)$an(YTIME) = iElcNetImpShare(runCy,"ELC_IMP",YTIME);
*---
iElecImp(runCy,YTIME)=0;
*---