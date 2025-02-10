*' @description This is the legacy realization of the PowerGeneration module.

*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "declarations" $include "./modules/06_Emissions/legacy/declarations.gms"
$Ifi "%phase%" == "equations"    $include "./modules/06_Emissions/legacy/equations.gms"
$Ifi "%phase%" == "preloop"      $include "./modules/06_Emissions/legacy/preloop.gms"
$Ifi "%phase%" == "postsolve"    $include "./modules/06_Emissions/legacy/postsolve.gms"
*######################## R SECTION END (PHASES) ###############################



