*' @description This is the legacy realization of the Industry module.

*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "sets"         $include "./modules/02_Industry/legacyISDevelopment/sets.gms"
$Ifi "%phase%" == "declarations" $include "./modules/02_Industry/legacyISDevelopment/declarations.gms"
$Ifi "%phase%" == "equations"    $include "./modules/02_Industry/legacyISDevelopment/equations.gms"
$Ifi "%phase%" == "input"        $include "./modules/02_Industry/legacyISDevelopment/input.gms"
$Ifi "%phase%" == "preloop"      $include "./modules/02_Industry/legacyISDevelopment/preloop.gms"
$Ifi "%phase%" == "postsolve"    $include "./modules/02_Industry/legacyISDevelopment/postsolve.gms"
*######################## R SECTION END (PHASES) ###############################