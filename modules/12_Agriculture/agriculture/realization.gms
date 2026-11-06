*' @description This is the agriculture realization of the agriculture module.

*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "sets"         $include "./modules/12_Agriculture/agriculture/sets.gms"
$Ifi "%phase%" == "declarations" $include "./modules/12_Agriculture/agriculture/declarations.gms"
$Ifi "%phase%" == "equations"    $include "./modules/12_Agriculture/agriculture/equations.gms"
$Ifi "%phase%" == "input"        $include "./modules/12_Agriculture/agriculture/input.gms"
$Ifi "%phase%" == "preloop"      $include "./modules/12_Agriculture/agriculture/preloop.gms"
$Ifi "%phase%" == "postsolve"    $include "./modules/12_Agriculture/agriculture/postsolve.gms"
*######################## R SECTION END (PHASES) ###############################