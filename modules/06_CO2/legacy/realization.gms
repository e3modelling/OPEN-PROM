*' @description This is the legacy realization of the CO2 module.

*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "sets"         $include "./modules/06_CO2/legacy/sets.gms"
$Ifi "%phase%" == "declarations" $include "./modules/06_CO2/legacy/declarations.gms"
$Ifi "%phase%" == "equations"    $include "./modules/06_CO2/legacy/equations.gms"
$Ifi "%phase%" == "input"        $include "./modules/06_CO2/legacy/input.gms"
$Ifi "%phase%" == "preloop"      $include "./modules/06_CO2/legacy/preloop.gms"
$Ifi "%phase%" == "postsolve"    $include "./modules/06_CO2/legacy/postsolve.gms"
*######################## R SECTION END (PHASES) ###############################