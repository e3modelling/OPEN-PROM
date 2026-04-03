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
i08WgtSecAvgPriFueCons(runCy,TRANSE,EF)$SECtoEF(TRANSE,EF) = (imFuelConsPerFueSub(runCy,TRANSE,EF,"%fBaseY%") / imTotFinEneDemSubBaseYr(runCy,TRANSE,"%fBaseY%"))$imTotFinEneDemSubBaseYr(runCy,TRANSE,"%fBaseY%")
                                               + (1/i08DiffFuelsInSec(TRANSE))$(not imTotFinEneDemSubBaseYr(runCy,TRANSE,"%fBaseY%"));
*---
i08WgtSecAvgPriFueCons(runCy,NENSE,EF)$SECtoEF(NENSE,EF) = ( imFuelConsPerFueSub(runCy,NENSE,EF,"%fBaseY%") / imTotFinEneDemSubBaseYr(runCy,NENSE,"%fBaseY%") )$imTotFinEneDemSubBaseYr(runCy,NENSE,"%fBaseY%")
                                             + (1/i08DiffFuelsInSec(NENSE))$(not imTotFinEneDemSubBaseYr(runCy,NENSE,"%fBaseY%"));
*---
i08WgtSecAvgPriFueCons(runCy,INDDOM,EF)$(SECtoEF(INDDOM,EF)) = 
(
  (imFuelConsPerFueSub(runCy,INDDOM,EF,"%fBaseY%") - (imShrNonSubElecInTotElecDem(runCy,INDDOM) * imFuelConsPerFueSub(runCy,INDDOM,"ELC","%fBaseY%"))$ELCEF(EF)) / 
  (imTotFinEneDemSubBaseYr(runCy,INDDOM,"%fBaseY%") - imShrNonSubElecInTotElecDem(runCy,INDDOM) * imFuelConsPerFueSub(runCy,INDDOM,"ELC","%fBaseY%")) 
)$(imTotFinEneDemSubBaseYr(runCy,INDDOM,"%fBaseY%") - imShrNonSubElecInTotElecDem(runCy,INDDOM) * imFuelConsPerFueSub(runCy,INDDOM,"ELC","%fBaseY%"))
+ (1/i08DiffFuelsInSec(INDDOM))$(not imTotFinEneDemSubBaseYr(runCy,INDDOM,"%fBaseY%") - imShrNonSubElecInTotElecDem(runCy,INDDOM) * imFuelConsPerFueSub(runCy,INDDOM,"ELC","%fBaseY%"));
*---
i08WgtSecAvgPriFueCons(runCy,CDR,EF)$SECtoEF(CDR,EF) = 1 / sum(EF2$SECtoEF(CDR,EF2), 1);
*---
* Rescaling the weights
i08WgtSecAvgPriFueCons(runCy,SBS,EF)$(SECtoEF(SBS,EF) $sum(ef2$SECtoEF(SBS,EF),i08WgtSecAvgPriFueCons(runCy,SBS,EF2))) = i08WgtSecAvgPriFueCons(runCy,SBS,EF)/sum(ef2$SECtoEF(SBS,EF),i08WgtSecAvgPriFueCons(runCy,SBS,EF2));
*---
* FIXME: Check if VAT (value added tax) rates are necessary for the model.
i08VAT(runCy, YTIME) = 0;
*---
imFuelPrice(runCy,SBS,EF,YTIME) = imFuelPrice(runCy,SBS,EF,YTIME)/1000; !! change units $15 -> k$15
imFuelPrice(runCy,"BU","KRS",YTIME) = imFuelPrice(runCy,"PA","KRS",YTIME);
imFuelPrice(runCy,"PG","GSL",YTIME) = imFuelPrice(runCy,"OI","GSL",YTIME);
imFuelPrice(runCy,"PG","KRS",YTIME) = imFuelPrice(runCy,"OI","KRS",YTIME);
imFuelPrice(runCy,SBS,"BGDO",YTIME) = imFuelPrice(runCy,SBS,"GDO",YTIME);
imFuelPrice(runCy,SBS,"BGSL",YTIME) = imFuelPrice(runCy,SBS,"GSL",YTIME);
imFuelPrice(runCy,SBS,"BKRS",YTIME) = imFuelPrice(runCy,SBS,"KRS",YTIME);
imFuelPrice(runCy,CDR,EF,YTIME)$SECtoEF(CDR,EF) = imFuelPrice(runCy,"OI",EF,YTIME);
imFuelPrice(runCy,"PG","OLQ",YTIME) = imFuelPrice(runCy,"PG","GDO",YTIME);
imFuelPrice(runCy,"PG","LPG",YTIME) = imFuelPrice(runCy,"OI","LPG",YTIME);
imFuelPrice(runCy,DOMSE,"GSL",YTIME) = imFuelPrice(runCy,"OI","GSL",YTIME);
imFuelPrice(runCy,DOMSE,"BGSL",YTIME) = imFuelPrice(runCy,"OI","BGSL",YTIME);
imFuelPrice(runCy,DOMSE,"LGN",YTIME) = imFuelPrice(runCy,"OI","LGN",YTIME);
imFuelPrice(runCy,DOMSE,"OLQ",YTIME) = imFuelPrice(runCy,"OI","OLQ",YTIME);
imFuelPrice(runCy,DOMSE,"RFO",YTIME) = imFuelPrice(runCy,"OI","RFO",YTIME);
imFuelPrice(runCy,"SE","GDO",YTIME) = imFuelPrice(runCy,"OI","GDO",YTIME);
imFuelPrice(runCy,"SE","BGDO",YTIME) = imFuelPrice(runCy,"OI","BGDO",YTIME);
imFuelPrice(runCy,"SE","BMSWAS",YTIME) = imFuelPrice(runCy,"AG","BMSWAS",YTIME);
imFuelPrice(runCy,"BU","NGS",YTIME) = imFuelPrice(runCy,"OI","NGS",YTIME);
imFuelPrice(runCy,"BU","GSL",YTIME) = imFuelPrice(runCy,"OI","GSL",YTIME);
imFuelPrice(runCy,"BU","BGSL",YTIME) = imFuelPrice(runCy,"OI","BGSL",YTIME);
*---