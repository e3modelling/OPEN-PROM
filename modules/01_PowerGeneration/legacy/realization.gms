*' @description This is the legacy realization of the PowerGeneration module.

*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "declarations" $include "C:/Users/Plessias/OPEN-PROM/modules/01_PowerGeneration/legacy/declarations.gms"
$Ifi "%phase%" == "equations"    $include "C:/Users/Plessias/OPEN-PROM/modules/01_PowerGeneration/legacy/equations.gms"
$Ifi "%phase%" == "preloop"      $include "C:/Users/Plessias/OPEN-PROM/modules/01_PowerGeneration/legacy/preloop.gms"
$Ifi "%phase%" == "postsolve"    $include "C:/Users/Plessias/OPEN-PROM/modules/01_PowerGeneration/legacy/postsolve.gms"
*######################## R SECTION END (PHASES) ###############################



