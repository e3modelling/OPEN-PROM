*' @description This is the legacy realization of the Transport module.

*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "sets"         $include "./modules/01_Transport/simple/sets.gms"
$Ifi "%phase%" == "declarations" $include "./modules/01_Transport/simple/declarations.gms"
$Ifi "%phase%" == "equations"    $include "./modules/01_Transport/simple/equations.gms"
$Ifi "%phase%" == "input"        $include "./modules/01_Transport/simple/input.gms"
$Ifi "%phase%" == "preloop"      $include "./modules/01_Transport/simple/preloop.gms"
$Ifi "%phase%" == "postsolve"    $include "./modules/01_Transport/simple/postsolve.gms"
*######################## R SECTION END (PHASES) ###############################