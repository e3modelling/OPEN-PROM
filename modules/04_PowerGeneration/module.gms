*' @title PowerGeneration module
*'
*' @description This is the PowerGeneration module.

*###################### R SECTION START (MODULETYPES) ##########################
$Ifi "%PowerGeneration%" == "legacy" $include "./modules/04_PowerGeneration/legacy/realization.gms"
$Ifi "%PowerGeneration%" == "simple" $include "./modules/04_PowerGeneration/simple/realization.gms"
*###################### R SECTION END (MODULETYPES) ############################
