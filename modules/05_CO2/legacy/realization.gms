*' @description This is the legacy realization of the PowerGeneration module.

*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "declarations" $include "./modules/05_CO2/legacy/declarations.gms"
$Ifi "%phase%" == "equations"    $include "./modules/05_CO2/legacy/equations.gms"
$Ifi "%phase%" == "preloop"      $include "./modules/05_CO2/legacy/preloop.gms"
$Ifi "%phase%" == "postsolve"    $include "./modules/05_CO2/legacy/postsolve.gms"
*######################## R SECTION END (PHASES) ###############################



