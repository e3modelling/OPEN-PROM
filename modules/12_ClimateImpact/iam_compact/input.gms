*' @title ClimateImpact (iam_compact) inputs & overlays
*' @code

*=============================================================================
* === USER KNOB: CAPEX scenario ===
*   permanent  -> CAPEX uplift applied 2020-2100
*   limit      -> CAPEX uplift applied only in 2040-2069
*   no_impact  -> CAPEX overlay skipped entirely (CF + cooling still active)
* (CF overlay and cooling demand are NOT affected by this switch.)
*=============================================================================
$setLocal iamCompactScenario limit


*=============================================================================
* Part 1 - CAPEX overlay
*=============================================================================
*--- Resolve scenario into a CAPEX year window ---
$ifthen.scen "%iamCompactScenario%" == "permanent"
$setLocal CIYmin 2020
$setLocal CIYmax 2100
$elseif.scen "%iamCompactScenario%" == "limit"
$setLocal CIYmin 2040
$setLocal CIYmax 2069
$endif.scen

*--- Apply CAPEX overlay (no_impact skips this whole block at compile time) ---
$ifthen.cxapply not "%iamCompactScenario%" == "no_impact"

*--- Electricity (PG plants): +20% ---
i04GrossCapCosSubRen(runCy, PGALL, YTIME)$(YTIME.val >= %CIYmin% and YTIME.val <= %CIYmax%) =
    i04GrossCapCosSubRen(runCy, PGALL, YTIME) * 1.20;

*--- Transport / Industry / Domestic: +10% ---
imCapCostTech(runCy, TRANSE, TECH, YTIME)$(YTIME.val >= %CIYmin% and YTIME.val <= %CIYmax%) =
    imCapCostTech(runCy, TRANSE, TECH, YTIME) * 1.10;
imCapCostTech(runCy, INDSE,  TECH, YTIME)$(YTIME.val >= %CIYmin% and YTIME.val <= %CIYmax%) =
    imCapCostTech(runCy, INDSE,  TECH, YTIME) * 1.10;
imCapCostTech(runCy, DOMSE,  TECH, YTIME)$(YTIME.val >= %CIYmin% and YTIME.val <= %CIYmax%) =
    imCapCostTech(runCy, DOMSE,  TECH, YTIME) * 1.10;

*--- CHP / industrial steam plants: +10% ---
i09CostInvCostSteProd(TSTEAM, YTIME)$(YTIME.val >= %CIYmin% and YTIME.val <= %CIYmax%) =
    i09CostInvCostSteProd(TSTEAM, YTIME) * 1.10;

*--- Hydrogen infrastructure: +10% ---
i05CostInvH2Transp(runCy, INFRTECH, YTIME)$(YTIME.val >= %CIYmin% and YTIME.val <= %CIYmax%) =
    i05CostInvH2Transp(runCy, INFRTECH, YTIME) * 1.10;

$endif.cxapply


*=============================================================================
* Part 2 - Capacity factor overlay (i04AvailRate)
*=============================================================================
*--- Two fixed period windows (both scenarios share these) ---
$setLocal CFP1Ymin 2020
$setLocal CFP1Ymax 2039
$setLocal CFP2Ymin 2040
$setLocal CFP2Ymax 2069

*--- Multiplicative delta table (macro region x tech-group x period) ---
table i12CFDelta(CFMACRO12, CFTECHGRP12, CFPERIOD12)  "Climate-impact CF delta (multiplicative fraction)"
              hydro.P1   hydro.P2   thermo.P1   thermo.P2
   NA          0.002     -0.022     -0.05       -0.13
   SA         -0.031     -0.055     -0.02       -0.07
   EU         -0.007     -0.042     -0.08       -0.15
   AF          0.004     -0.009     -0.05       -0.18
   AS         -0.031     -0.030     -0.03       -0.08
;

*--- Apply Period-1 delta ---
i04AvailRate(runCy, PGALL, YTIME)$(YTIME.val >= %CFP1Ymin% and YTIME.val <= %CFP1Ymax%) =
    min(1.0, max(0.0,
        i04AvailRate(runCy, PGALL, YTIME) *
        (1 + sum((CFMACRO12, CFTECHGRP12)$(CFPROMMACRO12(runCy, CFMACRO12) and CFTECHMAP12(PGALL, CFTECHGRP12)),
                 i12CFDelta(CFMACRO12, CFTECHGRP12, "P1")))
    ));

*--- Apply Period-2 delta ---
i04AvailRate(runCy, PGALL, YTIME)$(YTIME.val >= %CFP2Ymin% and YTIME.val <= %CFP2Ymax%) =
    min(1.0, max(0.0,
        i04AvailRate(runCy, PGALL, YTIME) *
        (1 + sum((CFMACRO12, CFTECHGRP12)$(CFPROMMACRO12(runCy, CFMACRO12) and CFTECHMAP12(PGALL, CFTECHGRP12)),
                 i12CFDelta(CFMACRO12, CFTECHGRP12, "P2")))
    ));

* Years outside [%CFP1Ymin%, %CFP2Ymax%]: neither $ condition matches,
* i04AvailRate keeps its original OPEN-PROM value.


*=============================================================================
* Part 3 - Extra cooling electricity demand (i12ExtraCoolingElectricityDemand)
*   Switch HD-D1 / HD-D4: edit the $include filename below.
*=============================================================================
table i12ExtraCoolingElectricityDemand(allCy, DSBS, YTIME)  "Climate-impact extra cooling electricity demand for HOU/SE (Mtoe/yr)"
$ondelim
$include "./parameters/iExtraCoolingElectricityDemand_HD-D4.csv"
$offdelim
;
