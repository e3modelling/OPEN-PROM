*' @description This is the legacy realization of the PowerGeneration module.

*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "declarations" $include "./modules/04_RestOfEnergy/legacy/declarations.gms"
$Ifi "%phase%" == "equations"    $include "./modules/04_RestOfEnergy/legacy/equations.gms"
$Ifi "%phase%" == "preloop"      $include "./modules/04_RestOfEnergy/legacy/preloop.gms"
$Ifi "%phase%" == "postsolve"    $include "./modules/04_RestOfEnergy/legacy/postsolve.gms"
*######################## R SECTION END (PHASES) ###############################


