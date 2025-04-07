*' @description This is the legacy realization of the Emissions module.

*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "declarations" $include "./modules/07_Emissions/legacy/declarations.gms"
$Ifi "%phase%" == "equations"    $include "./modules/07_Emissions/legacy/equations.gms"
$Ifi "%phase%" == "input"        $include "./modules/07_Emissions/legacy/input.gms"
$Ifi "%phase%" == "preloop"      $include "./modules/07_Emissions/legacy/preloop.gms"
$Ifi "%phase%" == "postsolve"    $include "./modules/07_Emissions/legacy/postsolve.gms"
*######################## R SECTION END (PHASES) ###############################



