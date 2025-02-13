*' @description This is the legacy realization of the PowerGeneration module.

*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "declarations" $include "./modules/07_Prices/legacy/declarations.gms"
$Ifi "%phase%" == "equations"    $include "./modules/07_Prices/legacy/equations.gms"
$Ifi "%phase%" == "preloop"      $include "./modules/07_Prices/legacy/preloop.gms"
$Ifi "%phase%" == "postsolve"    $include "./modules/07_Prices/legacy/postsolve.gms"
*######################## R SECTION END (PHASES) ###############################



