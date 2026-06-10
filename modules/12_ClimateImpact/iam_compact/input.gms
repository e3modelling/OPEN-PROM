*' @title ClimateImpact (iam_compact) inputs & overlays
*' @code

*=============================================================================
* USER KNOBS  (set per scenario; per-scenario values + full rationale live in
*              runs/IAM-COMPACT-R2/*.md and *.html)
*-----------------------------------------------------------------------------
* Gating / windows:
*   iamCompactScenario   permanent|limit  CF+CAPEX window (perm 2020.. , limit 2040-2069)
*   iamCompactCapex      on|off           CAPEX overlay (Part 2.1)
*   iamCompactCf         on|off           capacity-factor overlay (Part 2.2)
*   iamCompactCapBound   on|off           column-D cap (D1=on / D4=off); $setGlobal
* Feasibility levers (act ONLY when iamCompactCapBound==on, i.e. the D1 variants):
*   iamCompactCapStartY  year     cap binds only over [year,2069]; slack before (phase-in)
*   iamCompactRenBoost   x        renewable maturity multiplier             (Part 5)
*   iamCompactRenFloor   frac     per-country renewable maturity floor      (Part 5)
*   iamCompactSatCoef    9|<9     RES saturation steepness for SATRELAX12 (Part 6); 9=off
*   iamCompactBoostStartY auto|year  override the renewable pre-ramp start  (Part 5)
* Cooling demand (Part 1): switch HD-D1/HD-D4 via the $include filename.
*
* ESCALATION -- the 9 scenarios needed no more than: cap phase-in 2047, boost x2 +
*   floor 0.5, saturation 9->7 (limit-D1 only), long pre-ramp from 2020 (20_10_Limit
*   only). If a still-harder case stays infeasible, push further in roughly this order
*   of increasing distortion: SatCoef lower (toward 3) -> BoostStartY earlier -> loosen
*   the cap (later CapStartY, or ramp its onset, or exempt a country). All of these were
*   explored; none beyond the above was needed here.
*=============================================================================
$setLocal  iamCompactScenario limit
$setLocal  iamCompactCapex    on
$setLocal  iamCompactCf       on
$setGlobal iamCompactCapBound off
$setLocal  iamCompactCapStartY 2047
$setLocal  iamCompactRenBoost 2
$setLocal  iamCompactRenFloor 0.5
$setLocal  iamCompactSatCoef  9
$setLocal  iamCompactBoostStartY auto


*=============================================================================
* Part 1 - Extra cooling electricity demand. Switch HD-D1/HD-D4 via the $include.
*=============================================================================
table i12ExtraCoolingElectricityDemand(allCy, DSBS, YTIME)  "Climate-impact extra cooling electricity demand for HOU/SE (Mtoe/yr)"
$ondelim
$include "./parameters/iExtraCoolingElectricityDemand_HD-D4.csv"
$offdelim
;


*=============================================================================
* Part 2 - Tech impacts (CAPEX + CF). Shared window resolved from iamCompactScenario.
*=============================================================================
$ifthen.scen "%iamCompactScenario%" == "permanent"
$setLocal CIYmin 2020
$setLocal CIYmax 2100
$elseif.scen "%iamCompactScenario%" == "limit"
$setLocal CIYmin 2040
$setLocal CIYmax 2069
$endif.scen


*--- Part 2.1 CAPEX overlay (protocol col H/I): shocked PG +20%, all other techs +10% ---
$ifthen.cxapply "%iamCompactCapex%" == "on"

i04GrossCapCosSubRen(runCy, PGALL, YTIME)$((YTIME.val >= %CIYmin% and YTIME.val <= %CIYmax%)
        and (CFTECHMAP12(PGALL,'hydro') or CFTECHMAP12(PGALL,'thermo'))) =
    i04GrossCapCosSubRen(runCy, PGALL, YTIME) * 1.20;

i04GrossCapCosSubRen(runCy, PGALL, YTIME)$((YTIME.val >= %CIYmin% and YTIME.val <= %CIYmax%)
        and (not (CFTECHMAP12(PGALL,'hydro') or CFTECHMAP12(PGALL,'thermo')))) =
    i04GrossCapCosSubRen(runCy, PGALL, YTIME) * 1.10;

imCapCostTech(runCy, TRANSE, TECH, YTIME)$(YTIME.val >= %CIYmin% and YTIME.val <= %CIYmax%) =
    imCapCostTech(runCy, TRANSE, TECH, YTIME) * 1.10;
imCapCostTech(runCy, INDSE,  TECH, YTIME)$(YTIME.val >= %CIYmin% and YTIME.val <= %CIYmax%) =
    imCapCostTech(runCy, INDSE,  TECH, YTIME) * 1.10;
imCapCostTech(runCy, DOMSE,  TECH, YTIME)$(YTIME.val >= %CIYmin% and YTIME.val <= %CIYmax%) =
    imCapCostTech(runCy, DOMSE,  TECH, YTIME) * 1.10;
i09CostInvCostSteProd(TSTEAM, YTIME)$(YTIME.val >= %CIYmin% and YTIME.val <= %CIYmax%) =
    i09CostInvCostSteProd(TSTEAM, YTIME) * 1.10;
i05CostInvH2Transp(runCy, INFRTECH, YTIME)$(YTIME.val >= %CIYmin% and YTIME.val <= %CIYmax%) =
    i05CostInvH2Transp(runCy, INFRTECH, YTIME) * 1.10;

$endif.cxapply


*--- Part 2.2 Capacity-factor overlay: region x tech-group delta on i04AvailRate.
*    permanent applies P1 (2020-2039) + P2 (2040-2069); limit applies P2 only. ---
$ifthen.cfapply "%iamCompactCf%" == "on"

$setLocal CFP1Ymin 2020
$setLocal CFP1Ymax 2039
$setLocal CFP2Ymin 2040
$setLocal CFP2Ymax 2069

table i12CFDelta(CFMACRO12, CFTECHGRP12, CFPERIOD12)  "Climate-impact CF delta (multiplicative fraction)"
              hydro.P1   hydro.P2   thermo.P1   thermo.P2
   NA          0.002     -0.022     -0.05       -0.13
   SA         -0.031     -0.055     -0.02       -0.07
   EU         -0.007     -0.042     -0.08       -0.15
   AF          0.004     -0.009     -0.05       -0.18
   AS         -0.031     -0.030     -0.03       -0.08
;

$ifthen.cfp1 "%iamCompactScenario%" == "permanent"
i04AvailRate(runCy, PGALL, YTIME)$(YTIME.val >= %CFP1Ymin% and YTIME.val <= %CFP1Ymax%) =
    min(1.0, max(0.0,
        i04AvailRate(runCy, PGALL, YTIME) *
        (1 + sum((CFMACRO12, CFTECHGRP12)$(CFPROMMACRO12(runCy, CFMACRO12) and CFTECHMAP12(PGALL, CFTECHGRP12)),
                 i12CFDelta(CFMACRO12, CFTECHGRP12, "P1")))
    ));
$endif.cfp1

i04AvailRate(runCy, PGALL, YTIME)$(YTIME.val >= %CFP2Ymin% and YTIME.val <= %CFP2Ymax%) =
    min(1.0, max(0.0,
        i04AvailRate(runCy, PGALL, YTIME) *
        (1 + sum((CFMACRO12, CFTECHGRP12)$(CFPROMMACRO12(runCy, CFMACRO12) and CFTECHMAP12(PGALL, CFTECHGRP12)),
                 i12CFDelta(CFMACRO12, CFTECHGRP12, "P2")))
    ));

$endif.cfapply


*=============================================================================
* Part 4 - Column-D cap RHS (aggregate shocked-tech additions).
*   i12CapBoundAggD2 = HD_D2's per-region/year total additions of the shocked techs
*   (hydro+thermo). The cap equation Q12CapBoundAgg (equations.gms) is slack where this
*   is huge. Binds only over [iamCompactCapStartY, 2069]: slack before (phase-in, so the
*   early-transition years let renewables ramp) and after (CF recovers, Part 5/6 off).
*   Build the per-tech table: scripts/tools/extract_i12CapBoundD2.py
*=============================================================================
i12CapBoundAggD2(allCy, YTIME) = 1e7;

$ifthen.capbnd "%iamCompactCapBound%" == "on"
table i12CapBoundD2(allCy, PGALL, YTIME)  "HD_D2 Current-Trends capacity additions per shocked tech (GW/yr)"
$ondelim
$include "./parameters/i12CapBoundD2.csv"
$offdelim
;
i12CapBoundAggD2(allCy, YTIME)$(YTIME.val >= %iamCompactCapStartY% and YTIME.val <= 2069) =
    sum(PGALL$(CFTECHMAP12(PGALL,'hydro') or CFTECHMAP12(PGALL,'thermo')),
        i12CapBoundD2(allCy, PGALL, YTIME));
$endif.capbnd


*=============================================================================
* Part 5 - Renewable maturity boost + per-country floor (only with the cap, D1).
*   For the scalable renewables RENBOOST12 (PGSOL/PGAWND/PGAWNO) that HAVE a base,
*   inside the boost window:
*     m := min(10, max( m*RenBoost , RenFloor * <country's strongest RENBOOST12 peak m> ))
*   i.e. a multiplier where there is a real base, plus a per-country floor relative to
*   that country's OWN strongest renewable (so one country never inflates another's).
*   Window-peak is used so a tech that declines late still counts as "has resource";
*   techs with no base (m<=1e-3) are left untouched (never manufacture an absent one).
*=============================================================================
$ifthen.boost "%iamCompactCapBound%" == "on"

*--- boost window = CF-cut span (perm 2020-2069 / limit 2040-2069); optional
*    per-scenario start override via iamCompactBoostStartY ("auto" = the default) ---
$ifthen.bwin "%iamCompactScenario%" == "permanent"
$setLocal BoostYmin 2020
$elseif.bwin "%iamCompactScenario%" == "limit"
$setLocal BoostYmin 2040
$endif.bwin
$setLocal BoostYmax 2069
$ifthen.bstart not "%iamCompactBoostStartY%" == "auto"
$setLocal BoostYmin %iamCompactBoostStartY%
$endif.bstart

parameter m12TechPeak(allCy, PGALL) "per-(country,tech) peak boosted-renewable maturity over the window";
parameter m12RefRenMat(allCy)       "country's peak boosted-renewable maturity over the window (floor reference)";
m12TechPeak(runCy, RENBOOST12) = smax(YTIME$(YTIME.val >= %BoostYmin% and YTIME.val <= %BoostYmax%),
                                      i04MatFacPlaAvailCap(runCy, RENBOOST12, YTIME));
m12RefRenMat(runCy) = smax(RENBOOST12, m12TechPeak(runCy, RENBOOST12));

i04MatFacPlaAvailCap(runCy, RENBOOST12, YTIME)$(
        (YTIME.val >= %BoostYmin%) and (YTIME.val <= %BoostYmax%)
        and (m12TechPeak(runCy, RENBOOST12) > 1e-3)
    ) = min(10, max(
            i04MatFacPlaAvailCap(runCy, RENBOOST12, YTIME) * %iamCompactRenBoost%,
            %iamCompactRenFloor% * m12RefRenMat(runCy)
        ));


*=============================================================================
* Part 6 - Relax RES saturation steepness for the SATRELAX12 countries inside the
*   boost window (i04ShareSatSteep 9 -> iamCompactSatCoef). A flatter sigmoid keeps RES
*   attractive at the high penetration the cap forces, where maturity alone (already
*   clamped) is not enough. SatCoef=9 => no-op. (Q04ShareSatPG / i04ShareSatSteep are
*   defined in 04_PowerGeneration/simple.)
*=============================================================================
i04ShareSatSteep(runCy, YTIME)$(
        SATRELAX12(runCy)
        and (YTIME.val >= %BoostYmin%) and (YTIME.val <= %BoostYmax%)
    ) = %iamCompactSatCoef%;

$endif.boost
