*' @description This is the heat realization of the Heat module.

*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "sets"         $include "./modules/10_Economy/economy/sets.gms"
$Ifi "%phase%" == "declarations" $include "./modules/10_Economy/economy/declarations.gms"
$Ifi "%phase%" == "equations"    $include "./modules/10_Economy/economy/equations.gms"
$Ifi "%phase%" == "input"        $include "./modules/10_Economy/economy/input.gms"
$Ifi "%phase%" == "preloop"      $include "./modules/10_Economy/economy/preloop.gms"
$Ifi "%phase%" == "postsolve"    $include "./modules/10_Economy/economy/postsolve.gms"
*######################## R SECTION END (PHASES) ###############################