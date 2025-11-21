*' @description This is the heat realization of the Heat module.

*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "sets"         $include "./modules/09_Heat/heat/sets.gms"
$Ifi "%phase%" == "declarations" $include "./modules/09_Heat/heat/declarations.gms"
$Ifi "%phase%" == "equations"    $include "./modules/09_Heat/heat/equations.gms"
$Ifi "%phase%" == "input"        $include "./modules/09_Heat/heat/input.gms"
$Ifi "%phase%" == "preloop"      $include "./modules/09_Heat/heat/preloop.gms"
$Ifi "%phase%" == "postsolve"    $include "./modules/09_Heat/heat/postsolve.gms"
*######################## R SECTION END (PHASES) ###############################