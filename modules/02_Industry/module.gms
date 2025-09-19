*' @title Industry module
*'
*' @description This is the Industry module.

*###################### R SECTION START (MODULETYPES) ##########################
$Ifi "%Industry%" == "legacy" $include "./modules/02_Industry/legacy/realization.gms"
$Ifi "%Industry%" == "technology" $include "./modules/02_Industry/technology/realization.gms"
*###################### R SECTION END (MODULETYPES) ############################
