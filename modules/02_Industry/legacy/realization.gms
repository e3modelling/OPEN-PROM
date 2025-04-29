*' @title Industry realization
*' @code
*' @description This is the legacy realization of the Industry module.

*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "sets"         $include "./modules/02_Industry/legacy/sets.gms"
$Ifi "%phase%" == "declarations" $include "./modules/02_Industry/legacy/declarations.gms"
$Ifi "%phase%" == "equations"    $include "./modules/02_Industry/legacy/equations.gms"
$Ifi "%phase%" == "input"        $include "./modules/02_Industry/legacy/input.gms"
$Ifi "%phase%" == "preloop"      $include "./modules/02_Industry/legacy/preloop.gms"
$Ifi "%phase%" == "postsolve"    $include "./modules/02_Industry/legacy/postsolve.gms"
*######################## R SECTION END (PHASES) ###############################