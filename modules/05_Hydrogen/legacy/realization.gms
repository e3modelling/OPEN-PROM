*' @description This is the legacy realization of the PowerGeneration module.

*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "declarations" $include "./modules/05_Hydrogen/legacy/declarations.gms"
$Ifi "%phase%" == "equations"    $include "./modules/05_Hydrogen/legacy/equations.gms"
$Ifi "%phase%" == "input"        $include "./modules/05_Hydrogen/legacy/input.gms"
$Ifi "%phase%" == "preloop"      $include "./modules/05_Hydrogen/legacy/preloop.gms"
$Ifi "%phase%" == "postsolve"    $include "./modules/05_Hydrogen/legacy/postsolve.gms"
*######################## R SECTION END (PHASES) ###############################