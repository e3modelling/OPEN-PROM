*' @description This is the legacy realization of the RestOfEnergy module.

*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "declarations" $include "./modules/03_RestOfEnergy/legacy/declarations.gms"
$Ifi "%phase%" == "equations"    $include "./modules/03_RestOfEnergy/legacy/equations.gms"
$Ifi "%phase%" == "input"        $include "./modules/03_RestOfEnergy/legacy/input.gms"
$Ifi "%phase%" == "preloop"      $include "./modules/03_RestOfEnergy/legacy/preloop.gms"
$Ifi "%phase%" == "postsolve"    $include "./modules/03_RestOfEnergy/legacy/postsolve.gms"
*######################## R SECTION END (PHASES) ###############################



