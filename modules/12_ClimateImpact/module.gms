*' @title ClimateImpact module
*'
*' @description Overlay climate-change impacts onto technology parameters:
*'   * Technology CAPEX uplift (electricity +20%, others +10%) -
*'     year window selected by sub-scenario
*'   * Power-generation capacity factor adjustment
*'     (region- and tech-group-specific multiplicative delta)
*'   * HOU/SE sector extra cooling electricity demand
*'
*' Realizations:
*'   * "iam_compact": IAM-COMPACT project's climate-impact assumptions
*'   * "off":         module disabled, baseline run (entire module skipped)
*'
*' Sub-switches (all at the top of iam_compact/input.gms):
*'   $setLocal iamCompactScenario {permanent|limit}
*'       Shared time window for the tech-impact overlays (CAPEX, CF).
*'   $setLocal iamCompactCapex    {on|off}
*'       Toggle the CAPEX overlay (Part 2.1) independently.
*'   $setLocal iamCompactCf       {on|off}
*'       Toggle the capacity factor overlay (Part 2.2) independently.
*'
*' Cooling demand (Part 1 in iam_compact/input.gms) is always loaded.
*' HD-D1 / HD-D4 (CHILLED scenarios) is swapped by editing the $include filename:
*'   - HD-D1_Derailment: scenario - projected; Quantile - 95
*'   - HD-D4_Inertia:    scenario - DLS;       Quantile - 95

*###################### R SECTION START (MODULETYPES) ##########################
$Ifi "%ClimateImpact%" == "iam_compact" $include "./modules/12_ClimateImpact/iam_compact/realization.gms"
*###################### R SECTION END (MODULETYPES) ############################
