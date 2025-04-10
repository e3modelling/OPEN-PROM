*' @title Prices Inputs
*' @code

*---
table iFuelPrice(allCy,SBS,EF,YTIME)	 "Prices of fuels per subsector (k$2015/toe)"
$ondelim
$include"./iFuelPrice.csv"
$offdelim
;
*---
Parameters
iDiffFuelsInSec(SBS)                     "Auxiliary parameter holding the number of different fuels in a sector"
iWgtSecAvgPriFueCons(allCy,SBS,EF)	      "Weights for sector's average price, based on fuel consumption (1)"
iVAT(allCy,YTIME)                        "VAT (value added tax) rates (1)"
iHydrogenPri(allCy,SBS,YTIME)	           "Total Hydrogen Cost Per Sector (US$2015/toe)"
iElecIndex(allCy,YTIME)	                "Electricity Index (1)"
;
*---
loop SBS do
         iDiffFuelsInSec(SBS) = 0;
         loop EF$(SECTTECH(SBS,EF) $(not plugin(EF)))  do
              iDiffFuelsInSec(SBS) = iDiffFuelsInSec(SBS)+1;
         endloop;
endloop;
*---
iWgtSecAvgPriFueCons(runCy,TRANSE,EF)$(SECTTECH(TRANSE,EF) $(not plugin(EF)) ) = (iFuelConsPerFueSub(runCy,TRANSE,EF,"%fBaseY%") / iTotFinEneDemSubBaseYr(runCy,TRANSE,"%fBaseY%"))$iTotFinEneDemSubBaseYr(runCy,TRANSE,"%fBaseY%")
                                               + (1/iDiffFuelsInSec(TRANSE))$(not iTotFinEneDemSubBaseYr(runCy,TRANSE,"%fBaseY%"));
*---
iWgtSecAvgPriFueCons(runCy,NENSE,EF)$SECTTECH(NENSE,EF) = ( iFuelConsPerFueSub(runCy,NENSE,EF,"%fBaseY%") / iTotFinEneDemSubBaseYr(runCy,NENSE,"%fBaseY%") )$iTotFinEneDemSubBaseYr(runCy,NENSE,"%fBaseY%")
                                             + (1/iDiffFuelsInSec(NENSE))$(not iTotFinEneDemSubBaseYr(runCy,NENSE,"%fBaseY%"));
*---
iWgtSecAvgPriFueCons(runCy,INDDOM,EF)$(SECTTECH(INDDOM,EF)$(not sameas(EF,"ELC"))) = ( iFuelConsPerFueSub(runCy,INDDOM,EF,"%fBaseY%") / (iTotFinEneDemSubBaseYr(runCy,INDDOM,"%fBaseY%") - iFuelConsPerFueSub(runCy,INDDOM,"ELC","%fBaseY%")) )$( iTotFinEneDemSubBaseYr(runCy,INDDOM,"%fBaseY%") - iFuelConsPerFueSub(runCy,INDDOM,"ELC","%fBaseY%") )
                                                                        + (1/(iDiffFuelsInSec(INDDOM)-1))$(not (iTotFinEneDemSubBaseYr(runCy,INDDOM,"%fBaseY%") - iFuelConsPerFueSub(runCy,INDDOM,"ELC","%fBaseY%")));
*---
* Rescaling the weights
iWgtSecAvgPriFueCons(runCy,SBS,EF)$(SECTTECH(SBS,EF) $sum(ef2$SECTTECH(SBS,EF),iWgtSecAvgPriFueCons(runCy,SBS,EF2))) = iWgtSecAvgPriFueCons(runCy,SBS,EF)/sum(ef2$SECTTECH(SBS,EF),iWgtSecAvgPriFueCons(runCy,SBS,EF2));
*---
* FIXME: Check if VAT (value added tax) rates are necessary for the model.
iVAT(runCy, YTIME) = 0;
*---
* FIXME: iHydrogenPri should be computed with mrprom
* author=giannou
iHydrogenPri(runCy,SBS,YTIME)=4.3;
*---
iElecIndex(runCy,YTIME) = 0.9;
*---
iFuelPrice(runCy,SBS,EF,YTIME) = iFuelPrice(runCy,SBS,EF,YTIME)/1000; !! change units $15 -> k$15
*---