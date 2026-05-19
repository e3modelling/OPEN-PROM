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
*' Scenario sub-switch:
*'   permanent / limit / no_impact toggle lives at the top of iam_compact/input.gms
*'   ($setLocal iamCompactScenario).
*'
*' Cooling demand HD-D1 / HD-D4 toggle (based on CHILLED scenarios): manually edit the $include filename in iam_compact/input.gms Part 3.
*'  - HD-D1_Derailment: scenario - projected; Quantitle - 95
*'  - HD-D4_Inertia: scenario - DLS; Quantile - 95

*###################### R SECTION START (MODULETYPES) ##########################
$Ifi "%ClimateImpact%" == "iam_compact" $include "./modules/12_ClimateImpact/iam_compact/realization.gms"
*###################### R SECTION END (MODULETYPES) ############################
