*' @title Prices Inputs
*' @code


*---
*' Fuel price pass-through elasticity, indexed (target, source): i08PriceTransElast(EFS,"CRO"),
*' i08PriceTransElast(EFS,"BMSWAS"). CRO rows use 0.4/0.8/0.2; BMSWAS rows
*' use 0.6 for biofuels and 1 for BMSWAS itself. Table = target rows x source cols.
*' GAMS param i08PriceTransElast <-> mrprom output file iPriceTransElast.csv.
table i08PriceTransElast(EF,EF)   "Fuel price pass-through elasticity: target (rows) -> source (cols)"
$ondelim
$include "iPriceTransElast.csv"
$offdelim
;
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
* Historical AFOLU values are common to the MAgPIE and GLOBIOM emulators.
* Future price and emission inputs remain backend-specific below.
$if not exist "./iAfoluLandCO2Hist.csv" $abort "Missing land-use emulator history input: iAfoluLandCO2Hist.csv"
$if not exist "./iAfoluAgriEmisHist.csv" $abort "Missing land-use emulator history input: iAfoluAgriEmisHist.csv"

* Scope: land-use-change CO2 emissions/removals, excluding indirect land CO2 and fire emissions.
table i08AfoluLandCO2Hist(allCy,EMTYPE,YTIME) "Historical land-use-change CO2 emissions/removals (Mt CO2/yr)"
$ondelim
$include "./iAfoluLandCO2Hist.csv"
$offdelim
;
table i08AfoluAgriEmisHist(allCy,EMTYPE,YTIME) "Common historical agriculture CH4/N2O (CH4 Mt; N2O kt /yr)"
$ondelim
$include "./iAfoluAgriEmisHist.csv"
$offdelim
;

abort$sum(YTIME$(DATAY(YTIME) and (YTIME.val < 2010 or YTIME.val > 2025)), 1)
  "Land-use emulator history covers 2010-2025; DATAY requests an unsupported year";

* Load the selected emulator's future price and AFOLU response tables.
$IFTHEN.emulatorInput %landUseEmulator% == globiom
$if not exist "./iBmswasSupplyCoef_globiom.csv" $abort "Missing GLOBIOM emulator input: iBmswasSupplyCoef_globiom.csv"
$if not exist "./iBmswasLandEmisCoef_globiom.csv" $abort "Missing GLOBIOM emulator input: iBmswasLandEmisCoef_globiom.csv"
$if not exist "./iBmswasAgriEmis_globiom.csv" $abort "Missing GLOBIOM emulator input: iBmswasAgriEmis_globiom.csv"
abort$(card(activeGlobiomScen) <> 1)
  "Invalid --emulatorCarbonPriceScenario: value is not in GLOBIOMSCEN.";

table i08BmswasSupplyCoefGlobiom(GLOBIOMSCEN,allCy,GLOBIOMSUPPLYCOEF,YTIME) "GLOBIOM biomass supply curve coefficients (P = a + b*Q^c)"
$ondelim
$include "./iBmswasSupplyCoef_globiom.csv"
$offdelim
;
table i08LandCO2CoefGlobiom(GLOBIOMSCEN,allCy,EMTYPE,GLOBIOMEMISCOEF,YTIME) "GLOBIOM land CO2 coefficients (Em = ea + eb*Q)"
$ondelim
$include "./iBmswasLandEmisCoef_globiom.csv"
$offdelim
;
table i08AgriEmisGlobiom(GLOBIOMSCEN,allCy,EMTYPE,YTIME) "GLOBIOM agriculture CH4/N2O (Q-independent direct values)"
$ondelim
$include "./iBmswasAgriEmis_globiom.csv"
$offdelim
;
$ELSEIF.emulatorInput %landUseEmulator% == magpie
$if not exist "./iBmswasBioPriceH12_magpie.csv" $abort "Missing MAgPIE emulator input: iBmswasBioPriceH12_magpie.csv"
$if not exist "./iBmswasLandEmisCoef_magpie.csv" $abort "Missing MAgPIE emulator input: iBmswasLandEmisCoef_magpie.csv"
$if not exist "./iBmswasAgriEmisCoef_magpie.csv" $abort "Missing MAgPIE emulator input: iBmswasAgriEmisCoef_magpie.csv"
abort$(card(activeMagpieScen) <> 1)
  "Invalid --emulatorCarbonPriceScenario: value is not in MAGPIESCEN.";

table i08BmswasPriceH12Magpie(MAGPIESCEN,MAGPIEH12REG,MAGPIEPRICEFIELD,YTIME) "MAgPIE H12 BMSWAS absolute-price fit and effective-2G-Q domain"
$ondelim
$include "./iBmswasBioPriceH12_magpie.csv"
$offdelim
;
parameter i08Bioenergy2GWeightMagpie(EFS) "Fuel weights in MAgPIE effective 2G biomass Q"
  / BMSWAS 0.4
    BGSL   0.6
    BKRS   0.6
    BGAS   0.6 /;

* Scope: land-use-change CO2 emissions/removals, excluding indirect land CO2 and fire emissions.
table i08LandCO2CoefMagpie(MAGPIESCEN,allCy,EMTYPE,MAGPIEEMISCOEF,YTIME) "MAgPIE land-use-change CO2 coefficients against H12 effective 2G biomass Q"
$ondelim
$include "./iBmswasLandEmisCoef_magpie.csv"
$offdelim
;
table i08AgriEmisCoefMagpie(MAGPIESCEN,allCy,EMTYPE,MAGPIEEMISCOEF,YTIME) "MAgPIE agriculture CH4/N2O coefficients against regional effective 2G biomass Q"
$ondelim
$include "./iBmswasAgriEmisCoef_magpie.csv"
$offdelim
;

* Validate all MAgPIE scenarios, regions, and years loaded into the model.
abort$sum((MAGPIESCEN,MAGPIEH12REG,YTIME),
  (i08BmswasPriceH12Magpie(MAGPIESCEN,MAGPIEH12REG,"qmin",YTIME) < 0)
  or
  (i08BmswasPriceH12Magpie(MAGPIESCEN,MAGPIEH12REG,"qmax",YTIME)
   <= i08BmswasPriceH12Magpie(MAGPIESCEN,MAGPIEH12REG,"qmin",YTIME))
  or
  (i08BmswasPriceH12Magpie(MAGPIESCEN,MAGPIEH12REG,"pa",YTIME)
   + i08BmswasPriceH12Magpie(MAGPIESCEN,MAGPIEH12REG,"pb",YTIME)
     * i08BmswasPriceH12Magpie(MAGPIESCEN,MAGPIEH12REG,"qmin",YTIME)
   + i08BmswasPriceH12Magpie(MAGPIESCEN,MAGPIEH12REG,"pc",YTIME)
     * sqr(i08BmswasPriceH12Magpie(MAGPIESCEN,MAGPIEH12REG,"qmin",YTIME)) <= 0)
  or
  (i08BmswasPriceH12Magpie(MAGPIESCEN,MAGPIEH12REG,"pa",YTIME)
   + i08BmswasPriceH12Magpie(MAGPIESCEN,MAGPIEH12REG,"pb",YTIME)
     * i08BmswasPriceH12Magpie(MAGPIESCEN,MAGPIEH12REG,"qmax",YTIME)
   + i08BmswasPriceH12Magpie(MAGPIESCEN,MAGPIEH12REG,"pc",YTIME)
     * sqr(i08BmswasPriceH12Magpie(MAGPIESCEN,MAGPIEH12REG,"qmax",YTIME)) <= 0)
) "Invalid or incomplete MAgPIE H12 native-price fits";

abort$sum(allCy$(
  resCy(allCy) and sum(MAGPIEH12REG$mapMagpieH12Cy(MAGPIEH12REG,allCy), 1) <> 1
), 1)
  "MAgPIE H12 mapping must cover every OP39 research region exactly once";

abort$sum((MAGPIESCEN,allCy,YTIME)$resCy(allCy),
  sum(MAGPIEEMISCOEF,
    abs(i08LandCO2CoefMagpie(MAGPIESCEN,allCy,"CO2LandUse",MAGPIEEMISCOEF,YTIME))
  ) = 0
) "Incomplete MAgPIE land-CO2 coefficients: expected 4 scenarios x OP39 x 2010-2100";

abort$sum((MAGPIESCEN,allCy,EMTYPE,YTIME)$(
  resCy(allCy) and
  (sameas(EMTYPE,"CH4LandUse") or sameas(EMTYPE,"N2OLandUse"))
),
  sum(MAGPIEEMISCOEF,
    abs(i08AgriEmisCoefMagpie(MAGPIESCEN,allCy,EMTYPE,MAGPIEEMISCOEF,YTIME))
  ) = 0
) "Incomplete MAgPIE agriculture coefficients: expected CH4/N2O for 4 scenarios x OP39 x 2010-2100";

* MAgPIE emission coefficients cover the OP39 research regions.
abort$sum(runCy$(not resCy(runCy)), 1)
  "MAgPIE emulator coefficients cover OP39 only; remove unsupported runCy elements (for example ELL/RWO)";
$ENDIF.emulatorInput
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
