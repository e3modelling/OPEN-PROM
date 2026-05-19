*' @description Climate-impact overlay realization (IAM-COMPACT project).

*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "sets"         $include "./modules/12_ClimateImpact/iam_compact/sets.gms"
$Ifi "%phase%" == "declarations" $include "./modules/12_ClimateImpact/iam_compact/declarations.gms"
$Ifi "%phase%" == "input"        $include "./modules/12_ClimateImpact/iam_compact/input.gms"
*######################## R SECTION END (PHASES) ###############################
