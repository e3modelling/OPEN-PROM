*' @description This is the legacy realization of the PowerGeneration module.

*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "declarations" $include "./modules/04_PowerGeneration/legacy/declarations.gms"
$Ifi "%phase%" == "equations"    $include "./modules/04_PowerGeneration/legacy/equations.gms"
$Ifi "%phase%" == "preloop"      $include "./modules/04_PowerGeneration/legacy/preloop.gms"
$Ifi "%phase%" == "postsolve"    $include "./modules/04_PowerGeneration/legacy/postsolve.gms"
*######################## R SECTION END (PHASES) ###############################



