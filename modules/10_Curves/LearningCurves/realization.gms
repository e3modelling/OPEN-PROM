*' @description This is the heat realization of the Heat module.

*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "sets"         $include "./modules/10_Curves/LearningCurves/sets.gms"
$Ifi "%phase%" == "declarations" $include "./modules/10_Curves/LearningCurves/declarations.gms"
$Ifi "%phase%" == "equations"    $include "./modules/10_Curves/LearningCurves/equations.gms"
$Ifi "%phase%" == "input"        $include "./modules/10_Curves/LearningCurves/input.gms"
$Ifi "%phase%" == "preloop"      $include "./modules/10_Curves/LearningCurves/preloop.gms"
$Ifi "%phase%" == "postsolve"    $include "./modules/10_Curves/LearningCurves/postsolve.gms"
*######################## R SECTION END (PHASES) ###############################