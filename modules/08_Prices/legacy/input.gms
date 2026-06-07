*' @title Prices Inputs
*' @code


*---
$IFTHEN %softLinkMAgPIE% == on
table iPricesMagpie(allCy,SBS,YTIME)	"Prices of biomass per subsector (k$2015/toe)"
$ondelim
$include "./iPrices_magpie.csv"
$offdelim
;
$ENDIF
*---
$IFTHEN %bmswasPriceMode% == curve
* Coefficient tables are generated per emulator source by mrprom into ./data as
* iBmswas{Supply,Emis}Coef_<source>.csv; %landUseEmulator% (globiom/magpie) picks the active one.
table imBmswasSupplyCoef(GHGSCEN,allCy,COEF,YTIME) "Land-use emulator biomass supply curve coefficients (P = a + b*Q^c)"
$ondelim
$include "./iBmswasSupplyCoef_%landUseEmulator%.csv"
$offdelim
;
table imBmswasEmisCoef(GHGSCEN,allCy,EMTYPE,ECOEF,YTIME) "Land-use emulator land-use emission curve coefficients (Em = ea + eb*Q + ec*Q^2)"
$ondelim
$include "./iBmswasEmisCoef_%landUseEmulator%.csv"
$offdelim
;
$ENDIF
*---
parameter i08PriceCrudeOil(YTIME) /
$ondelim
$include "CrudeOilPrice.csv"
$offdelim
/;
*---
Parameters
i08DiffFuelsInSec(SBS)                    "Auxiliary parameter holding the number of different fuels in a sector"
i08WgtSecAvgPriFueCons(allCy,SBS,EF)	    "Weights for sector's average price, based on fuel consumption (1)"
i08VAT(allCy,YTIME)                       "VAT (value added tax) rates (1)"
;
*---
loop SBS do
         i08DiffFuelsInSec(SBS) = 0;
         loop EF$(SECtoEF(SBS,EF))  do
              i08DiffFuelsInSec(SBS) = i08DiffFuelsInSec(SBS)+1;
         endloop;
endloop;
*---
i08WgtSecAvgPriFueCons(runCy,TRANSE,EF)$SECtoEF(TRANSE,EF) = (imFuelCons(runCy,TRANSE,EF,"%fBaseY%") / imTotFinEneDemSubBaseYr(runCy,TRANSE,"%fBaseY%"))$imTotFinEneDemSubBaseYr(runCy,TRANSE,"%fBaseY%")
                                               + (1/i08DiffFuelsInSec(TRANSE))$(not imTotFinEneDemSubBaseYr(runCy,TRANSE,"%fBaseY%"));
*---
i08WgtSecAvgPriFueCons(runCy,NENSE,EF)$SECtoEF(NENSE,EF) = ( imFuelCons(runCy,NENSE,EF,"%fBaseY%") / imTotFinEneDemSubBaseYr(runCy,NENSE,"%fBaseY%") )$imTotFinEneDemSubBaseYr(runCy,NENSE,"%fBaseY%")
                                             + (1/i08DiffFuelsInSec(NENSE))$(not imTotFinEneDemSubBaseYr(runCy,NENSE,"%fBaseY%"));
*---
i08WgtSecAvgPriFueCons(runCy,INDDOM,EF)$(SECtoEF(INDDOM,EF)) = 
(
  (imFuelCons(runCy,INDDOM,EF,"%fBaseY%") - (imShrNonSubElecInTotElecDem(runCy,INDDOM) * imFuelCons(runCy,INDDOM,"ELC","%fBaseY%"))$ELCEF(EF)) / 
  (imTotFinEneDemSubBaseYr(runCy,INDDOM,"%fBaseY%") - imShrNonSubElecInTotElecDem(runCy,INDDOM) * imFuelCons(runCy,INDDOM,"ELC","%fBaseY%")) 
)$(imTotFinEneDemSubBaseYr(runCy,INDDOM,"%fBaseY%") - imShrNonSubElecInTotElecDem(runCy,INDDOM) * imFuelCons(runCy,INDDOM,"ELC","%fBaseY%"))
+ (1/i08DiffFuelsInSec(INDDOM))$(not imTotFinEneDemSubBaseYr(runCy,INDDOM,"%fBaseY%") - imShrNonSubElecInTotElecDem(runCy,INDDOM) * imFuelCons(runCy,INDDOM,"ELC","%fBaseY%"));
*---
i08WgtSecAvgPriFueCons(runCy,CDR,EF)$SECtoEF(CDR,EF) = 1 / sum(EF2$SECtoEF(CDR,EF2), 1);
*---
* Rescaling the weights
i08WgtSecAvgPriFueCons(runCy,SBS,EF)$(SECtoEF(SBS,EF) $sum(ef2$SECtoEF(SBS,EF),i08WgtSecAvgPriFueCons(runCy,SBS,EF2))) = i08WgtSecAvgPriFueCons(runCy,SBS,EF)/sum(ef2$SECtoEF(SBS,EF),i08WgtSecAvgPriFueCons(runCy,SBS,EF2));
*---
* FIXME: Check if VAT (value added tax) rates are necessary for the model.
i08VAT(runCy, YTIME) = 0;
*---
imFuelPrice(runCy,SBS,"CRO",YTIME) = i08PriceCrudeOil(YTIME);
*---