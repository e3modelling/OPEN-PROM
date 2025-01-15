*' @description This is the legacy realization of the PowerGeneration module.

*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "declarations" $include "./modules/02_Transport/legacy/declarations.gms"
$Ifi "%phase%" == "equations"    $include "./modules/02_Transport/legacy/equations.gms"
$Ifi "%phase%" == "preloop"      $include "./modules/02_Transport/legacy/preloop.gms"
$Ifi "%phase%" == "postsolve"    $include "./modules/02_Transport/legacy/postsolve.gms"
*######################## R SECTION END (PHASES) ###############################



