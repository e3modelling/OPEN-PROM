*' @title Transport module
*'
*' @description This is the Transport module.

*###################### R SECTION START (MODULETYPES) ##########################
$Ifi "%Transport%" == "legacy" $include "./modules/01_Transport/legacy/realization.gms"
$Ifi "%Transport%" == "simple" $include "./modules/01_Transport/simple/realization.gms"
*###################### R SECTION END (MODULETYPES) ############################
