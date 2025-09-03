*' @description This is the legacy realization of the Industry module.

*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "sets"         $include "./modules/02_Industry/technology/sets.gms"
$Ifi "%phase%" == "declarations" $include "./modules/02_Industry/technology/declarations.gms"
$Ifi "%phase%" == "equations"    $include "./modules/02_Industry/technology/equations.gms"
$Ifi "%phase%" == "input"        $include "./modules/02_Industry/technology/input.gms"
$Ifi "%phase%" == "preloop"      $include "./modules/02_Industry/technology/preloop.gms"
$Ifi "%phase%" == "postsolve"    $include "./modules/02_Industry/technology/postsolve.gms"
*######################## R SECTION END (PHASES) ###############################