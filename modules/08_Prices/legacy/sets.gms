*' @title Prices Sets
*' @code

Sets
*' GLOBIOM emulator dimensions.
GLOBIOMSCEN "GLOBIOM fixed land-use carbon-price rows"
/ GHG000, GHG010, GHG020, GHG050, GHG100 /

activeGlobiomScen(GLOBIOMSCEN) "Selected GLOBIOM emulator scenario"

GLOBIOMSUPPLYCOEF "GLOBIOM power-law supply-curve coefficients"
/ a, b, c /

GLOBIOMEMISCOEF "GLOBIOM linear land-CO2 coefficients"
/ ea, eb /

*' MAgPIE emulator dimensions.
MAGPIESCEN "MAgPIE policy-trajectory rows"
/ Npi_Default, NDC_LTT, '2C', '1p5C' /

activeMagpieScen(MAGPIESCEN) "Selected MAgPIE emulator scenario"

MAGPIEH12REG "MAgPIE H12 regions"
/ CAZ, CHA, EUR, IND, JPN, LAM, MEA, NEU, OAS, REF, SSA, USA /

mapMagpieH12Cy(MAGPIEH12REG,allCy) "MAgPIE H12 region to OPEN-PROM region mapping"

MAGPIEPRICEFIELD "MAgPIE H12 price coefficients and fitted quantity domain"
/ pa, pb, pc, qmin, qmax /

MAGPIEEMISCOEF "MAgPIE land and agriculture emission coefficients"
/ ea, eb, ec /
;

mapMagpieH12Cy("EUR",allCy)$EU28(allCy) = yes;
mapMagpieH12Cy(MAGPIEH12REG,allCy)$(sameas(MAGPIEH12REG,allCy)) = yes;
activeGlobiomScen(GLOBIOMSCEN) = sameas(GLOBIOMSCEN,"%emulatorCarbonPriceScenario%");
activeMagpieScen(MAGPIESCEN) = sameas(MAGPIESCEN,"%emulatorCarbonPriceScenario%");
