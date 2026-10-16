*' @description This is the legacy realization of the Industry module.

*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "sets"         $include "./modules/02_Industry/services/sets.gms"
$Ifi "%phase%" == "declarations" $include "./modules/02_Industry/services/declarations.gms"
$Ifi "%phase%" == "equations"    $include "./modules/02_Industry/services/equations.gms"
$Ifi "%phase%" == "input"        $include "./modules/02_Industry/services/input.gms"
$Ifi "%phase%" == "preloop"      $include "./modules/02_Industry/services/preloop.gms"
$Ifi "%phase%" == "postsolve"    $include "./modules/02_Industry/services/postsolve.gms"
*######################## R SECTION END (PHASES) ###############################