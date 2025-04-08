*' @description This is the legacy realization of the Transport module.

*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "sets"         $include "./modules/01_Transport/legacy/sets.gms"
$Ifi "%phase%" == "declarations" $include "./modules/01_Transport/legacy/declarations.gms"
$Ifi "%phase%" == "equations"    $include "./modules/01_Transport/legacy/equations.gms"
$Ifi "%phase%" == "input"        $include "./modules/01_Transport/legacy/input.gms"
$Ifi "%phase%" == "preloop"      $include "./modules/01_Transport/legacy/preloop.gms"
$Ifi "%phase%" == "postsolve"    $include "./modules/01_Transport/legacy/postsolve.gms"
*######################## R SECTION END (PHASES) ###############################