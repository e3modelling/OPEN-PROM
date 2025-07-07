*' @title Prices Inputs
*' @code


*---
$IFTHEN %link2MAgPIE% == on
table iPricesMagpie(allCy,SBS,YTIME)	"Prices of biomass per subsector (k$2015/toe)"
$ondelim
$include "./iPrices_magpie.csv"
$offdelim
;
$ENDIF
*---
Parameters
i08DiffFuelsInSec(SBS)                   "Auxiliary parameter holding the number of different fuels in a sector"
i08WgtSecAvgPriFueCons(allCy,SBS,EF)	 "Weights for sector's average price, based on fuel consumption (1)"
i08VAT(allCy,YTIME)                      "VAT (value added tax) rates (1)"
i08HydrogenPri(allCy,SBS,YTIME)	      "Total Hydrogen Cost Per Sector (US$2015/toe)"
i08ElecIndex(allCy,YTIME)	           "Electricity Index (1)"
;
*---
loop SBS do
         i08DiffFuelsInSec(SBS) = 0;
         loop EF$(SECTTECH(SBS,EF) $(not plugin(EF)))  do
              i08DiffFuelsInSec(SBS) = i08DiffFuelsInSec(SBS)+1;
         endloop;
endloop;
*---
i08WgtSecAvgPriFueCons(runCy,TRANSE,EF)$(SECTTECH(TRANSE,EF) $(not plugin(EF)) ) = (imFuelConsPerFueSub(runCy,TRANSE,EF,"%fBaseY%") / imTotFinEneDemSubBaseYr(runCy,TRANSE,"%fBaseY%"))$imTotFinEneDemSubBaseYr(runCy,TRANSE,"%fBaseY%")
                                               + (1/i08DiffFuelsInSec(TRANSE))$(not imTotFinEneDemSubBaseYr(runCy,TRANSE,"%fBaseY%"));
*---
i08WgtSecAvgPriFueCons(runCy,NENSE,EF)$SECTTECH(NENSE,EF) = ( imFuelConsPerFueSub(runCy,NENSE,EF,"%fBaseY%") / imTotFinEneDemSubBaseYr(runCy,NENSE,"%fBaseY%") )$imTotFinEneDemSubBaseYr(runCy,NENSE,"%fBaseY%")
                                             + (1/i08DiffFuelsInSec(NENSE))$(not imTotFinEneDemSubBaseYr(runCy,NENSE,"%fBaseY%"));
*---
i08WgtSecAvgPriFueCons(runCy,INDDOM,EF)$(SECTTECH(INDDOM,EF)$(not sameas(EF,"ELC"))) = ( imFuelConsPerFueSub(runCy,INDDOM,EF,"%fBaseY%") / (imTotFinEneDemSubBaseYr(runCy,INDDOM,"%fBaseY%") - imFuelConsPerFueSub(runCy,INDDOM,"ELC","%fBaseY%")) )$( imTotFinEneDemSubBaseYr(runCy,INDDOM,"%fBaseY%") - imFuelConsPerFueSub(runCy,INDDOM,"ELC","%fBaseY%") )
                                                                        + (1/(i08DiffFuelsInSec(INDDOM)-1))$(not (imTotFinEneDemSubBaseYr(runCy,INDDOM,"%fBaseY%") - imFuelConsPerFueSub(runCy,INDDOM,"ELC","%fBaseY%")));
*---
* Rescaling the weights
i08WgtSecAvgPriFueCons(runCy,SBS,EF)$(SECTTECH(SBS,EF) $sum(ef2$SECTTECH(SBS,EF),i08WgtSecAvgPriFueCons(runCy,SBS,EF2))) = i08WgtSecAvgPriFueCons(runCy,SBS,EF)/sum(ef2$SECTTECH(SBS,EF),i08WgtSecAvgPriFueCons(runCy,SBS,EF2));
*---
* FIXME: Check if VAT (value added tax) rates are necessary for the model.
i08VAT(runCy, YTIME) = 0;
*---
* FIXME: i08HydrogenPri should be computed with mrprom
* author=giannou
i08HydrogenPri(runCy,SBS,YTIME)=4.3;
*---
i08ElecIndex(runCy,YTIME) = 0.9;
*---
imFuelPrice(runCy,SBS,EF,YTIME) = imFuelPrice(runCy,SBS,EF,YTIME)/1000; !! change units $15 -> k$15
*---