*' @description This is the legacy realization of the PowerGeneration module.

*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "sets"         $include "./modules/04_PowerGeneration/simple/sets.gms"
$Ifi "%phase%" == "declarations" $include "./modules/04_PowerGeneration/simple/declarations.gms"
$Ifi "%phase%" == "equations"    $include "./modules/04_PowerGeneration/simple/equations.gms"
$Ifi "%phase%" == "input"        $include "./modules/04_PowerGeneration/simple/input.gms"
$Ifi "%phase%" == "preloop"      $include "./modules/04_PowerGeneration/simple/preloop.gms"
$Ifi "%phase%" == "postsolve"    $include "./modules/04_PowerGeneration/simple/postsolve.gms"
*######################## R SECTION END (PHASES) ###############################