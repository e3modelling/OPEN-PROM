*' @title ClimateImpact (iam_compact) inputs & overlays
*' @code

*=============================================================================
* === USER KNOBS ===
*
* Three independent dials:
*
* (a) iamCompactScenario   --  shared time window for tech impacts (Part 2)
*       permanent  -> 2020-2100 window (CAPEX) ; CF deltas in P1 (2020-2039) and P2 (2040-2069)
*       limit      -> 2040-2069 window (CAPEX) ; CF delta only in P2 (P1 outside the window)
*
* (b) iamCompactCapex      --  toggle the CAPEX overlay (Part 2.1) independently
*       on   -> apply
*       off  -> skip (anything other than "on" is treated as off)
*
* (c) iamCompactCf         --  toggle the capacity factor overlay (Part 2.2) independently
*       on   -> apply
*       off  -> skip
*
* The two tech-impact toggles are mutually independent: you can run CAPEX only,
* CF only, both, or neither. When at least one is on, the time window comes from
* iamCompactScenario.
*
* Cooling demand (Part 1) is always loaded; it has no toggle here. Switch HD-D1
* and HD-D4 by editing the $include filename in Part 1.
*=============================================================================
$setLocal iamCompactScenario limit
$setLocal iamCompactCapex    on
$setLocal iamCompactCf       on


*=============================================================================
* Part 1 - Extra cooling electricity demand (i12ExtraCoolingElectricityDemand)
*   Always loaded. Switch HD-D1 / HD-D4: edit the $include filename below.
*=============================================================================
table i12ExtraCoolingElectricityDemand(allCy, DSBS, YTIME)  "Climate-impact extra cooling electricity demand for HOU/SE (Mtoe/yr)"
$ondelim
$include "./parameters/iExtraCoolingElectricityDemand_HD-D4.csv"
$offdelim
;


*=============================================================================
* Part 2 - Climate impact on technologies (CAPEX + CF)
*   Two sub-parts are individually gated by iamCompactCapex / iamCompactCf,
*   but share the same time window resolved from iamCompactScenario.
*=============================================================================
*--- Resolve scenario into a shared time window ---
$ifthen.scen "%iamCompactScenario%" == "permanent"
$setLocal CIYmin 2020
$setLocal CIYmax 2100
$elseif.scen "%iamCompactScenario%" == "limit"
$setLocal CIYmin 2040
$setLocal CIYmax 2069
$endif.scen


*-----------------------------------------------------------------------------
* Part 2.1 - CAPEX overlay  (gated by iamCompactCapex)
*   Electricity (PG plants): +20%
*   Transport / Industry / Domestic / CHP / Hydrogen infrastructure: +10%
*-----------------------------------------------------------------------------
$ifthen.cxapply "%iamCompactCapex%" == "on"

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


*-----------------------------------------------------------------------------
* Part 2.2 - Capacity factor overlay  (gated by iamCompactCf)
*   Region- and tech-group-specific multiplicative delta on i04AvailRate.
*   permanent applies both P1 (2020-2039) and P2 (2040-2069);
*   limit applies only P2 (P1 lies outside the limit window).
*-----------------------------------------------------------------------------
$ifthen.cfapply "%iamCompactCf%" == "on"

*--- Two fixed period windows ---
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

*--- Apply Period-1 delta (only in permanent; limit window starts at 2040) ---
$ifthen.cfp1 "%iamCompactScenario%" == "permanent"
i04AvailRate(runCy, PGALL, YTIME)$(YTIME.val >= %CFP1Ymin% and YTIME.val <= %CFP1Ymax%) =
    min(1.0, max(0.0,
        i04AvailRate(runCy, PGALL, YTIME) *
        (1 + sum((CFMACRO12, CFTECHGRP12)$(CFPROMMACRO12(runCy, CFMACRO12) and CFTECHMAP12(PGALL, CFTECHGRP12)),
                 i12CFDelta(CFMACRO12, CFTECHGRP12, "P1")))
    ));
$endif.cfp1

*--- Apply Period-2 delta (in both permanent and limit) ---
i04AvailRate(runCy, PGALL, YTIME)$(YTIME.val >= %CFP2Ymin% and YTIME.val <= %CFP2Ymax%) =
    min(1.0, max(0.0,
        i04AvailRate(runCy, PGALL, YTIME) *
        (1 + sum((CFMACRO12, CFTECHGRP12)$(CFPROMMACRO12(runCy, CFMACRO12) and CFTECHMAP12(PGALL, CFTECHGRP12)),
                 i12CFDelta(CFMACRO12, CFTECHGRP12, "P2")))
    ));

$endif.cfapply
