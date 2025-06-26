*' @title Prices Inputs
*' @code

*---
Parameters
i08DiffFuelsInSec(SBS)                       "Auxiliary parameter holding the number of different fuels in a sector"
i08WgtSecAvgPriFueCons(allCy,SBS,EF,YTIME)	"Weights for sector's average price, based on fuel consumption (1) for each year"
i08VAT(allCy,YTIME)                          "VAT (value added tax) rates (1)"
i08HydrogenPri(allCy,SBS,YTIME)	          "Total Hydrogen Cost Per Sector (US$2015/toe)"
i08ElecIndex(allCy,YTIME)	               "Electricity Index (1)"
;
*---
loop SBS do
         i08DiffFuelsInSec(SBS) = 0;
         loop EF$(SECTTECH(SBS,EF) $(not plugin(EF)))  do
              i08DiffFuelsInSec(SBS) = i08DiffFuelsInSec(SBS)+1;
         endloop;
endloop;
*---
i08WgtSecAvgPriFueCons(runCy,TRANSE,EF,YTIME)$(SECTTECH(TRANSE,EF) $(not plugin(EF)) ) = (imFuelConsPerFueSub(runCy,TRANSE,EF,YTIME-1) / imTotFinEneDemSubBaseYr(runCy,TRANSE,YTIME-1))$imTotFinEneDemSubBaseYr(runCy,TRANSE,YTIME-1)
                                               + (1/i08DiffFuelsInSec(TRANSE))$(not imTotFinEneDemSubBaseYr(runCy,TRANSE,YTIME-1));
*---
i08WgtSecAvgPriFueCons(runCy,NENSE,EF,YTIME)$SECTTECH(NENSE,EF) = ( imFuelConsPerFueSub(runCy,NENSE,EF,YTIME-1) / imTotFinEneDemSubBaseYr(runCy,NENSE,YTIME-1) )$imTotFinEneDemSubBaseYr(runCy,NENSE,YTIME-1)
                                             + (1/i08DiffFuelsInSec(NENSE))$(not imTotFinEneDemSubBaseYr(runCy,NENSE,YTIME-1));
*---
i08WgtSecAvgPriFueCons(runCy,INDDOM,EF,YTIME)$(SECTTECH(INDDOM,EF)) = ( imFuelConsPerFueSub(runCy,INDDOM,EF,YTIME-1) / (imTotFinEneDemSubBaseYr(runCy,INDDOM,YTIME-1) - imFuelConsPerFueSub(runCy,INDDOM,"ELC",YTIME-1)) )$( imTotFinEneDemSubBaseYr(runCy,INDDOM,YTIME-1) - imFuelConsPerFueSub(runCy,INDDOM,"ELC",YTIME-1) )
                                                                        + (1/(i08DiffFuelsInSec(INDDOM)-1))$(not (imTotFinEneDemSubBaseYr(runCy,INDDOM,YTIME-1) - imFuelConsPerFueSub(runCy,INDDOM,"ELC",YTIME-1)));
*---
* Rescaling the weights
i08WgtSecAvgPriFueCons(runCy,SBS,EF,YTIME)$(SECTTECH(SBS,EF) $sum(ef2$SECTTECH(SBS,EF),i08WgtSecAvgPriFueCons(runCy,SBS,EF2,YTIME))) = i08WgtSecAvgPriFueCons(runCy,SBS,EF,YTIME)/sum(ef2$SECTTECH(SBS,EF),i08WgtSecAvgPriFueCons(runCy,SBS,EF2,YTIME));
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