*' @description This is the commodities realization of the commodities module.

*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "sets"         $include "./modules/14_Commodities/commodities/sets.gms"
$Ifi "%phase%" == "declarations" $include "./modules/14_Commodities/commodities/declarations.gms"
$Ifi "%phase%" == "equations"    $include "./modules/14_Commodities/commodities/equations.gms"
$Ifi "%phase%" == "input"        $include "./modules/14_Commodities/commodities/input.gms"
$Ifi "%phase%" == "preloop"      $include "./modules/14_Commodities/commodities/preloop.gms"
$Ifi "%phase%" == "postsolve"    $include "./modules/14_Commodities/commodities/postsolve.gms"
*######################## R SECTION END (PHASES) ###############################