*' @description This is the legacy realization of the Prices module.

*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "sets"         $include "./modules/08_Prices/legacy/sets.gms"
$Ifi "%phase%" == "declarations" $include "./modules/08_Prices/legacy/declarations.gms"
$Ifi "%phase%" == "equations"    $include "./modules/08_Prices/legacy/equations.gms"
$Ifi "%phase%" == "input"        $include "./modules/08_Prices/legacy/input.gms"
$Ifi "%phase%" == "preloop"      $include "./modules/08_Prices/legacy/preloop.gms"
$Ifi "%phase%" == "postsolve"    $include "./modules/08_Prices/legacy/postsolve.gms"
*######################## R SECTION END (PHASES) ###############################