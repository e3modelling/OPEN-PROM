*' @title Hydrogen module
*'
*' @description This is the Hydrogen module.

*###################### R SECTION START (MODULETYPES) ##########################
$Ifi "%Hydrogen%" == "legacy" $include "./modules/05_Hydrogen/legacy/realization.gms"
$Ifi "%Hydrogen%" == "simple" $include "./modules/05_Hydrogen/simple/realization.gms"
*###################### R SECTION END (MODULETYPES) ############################