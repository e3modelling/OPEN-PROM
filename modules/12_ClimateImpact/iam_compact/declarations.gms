*' @title ClimateImpact (iam_compact) declarations
*' @code
*' Most data parameters in this realization are declared inline with `table` in
*' input.gms. The aggregate capacity-bound parameter and equation are declared
*' here (unconditionally, so the equation symbol exists for `model openprom /all/`);
*' the equation is defined in equations.gms and switched on/off via the RHS
*' parameter i12CapBoundAggD2 (huge = slack when iamCompactCapBound == off).

parameter
  i12CapBoundAggD2(allCy, YTIME)  "HD_D2 Current-Trends total additions of shocked techs (GW/yr), aggregate upper bound"
;

equation
  Q12CapBoundAgg(allCy, YTIME)    "Aggregate cap: total shocked-tech additions <= HD_D2 Current-Trends total (protocol col D)"
;
