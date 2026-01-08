$setglobal phase %1
$onrecurse
*######################## R SECTION START (MODULES) ############################
$include "./modules/01_Transport/module.gms";
$include "./modules/02_Industry/module.gms";
$include "./modules/03_RestOfEnergy/module.gms";
$include "./modules/04_PowerGeneration/module.gms";
$include "./modules/05_Hydrogen/module.gms";
$include "./modules/06_CO2/module.gms";
$include "./modules/07_Emissions/module.gms";
$include "./modules/08_Prices/module.gms";
$include "./modules/09_Heat/module.gms";
$include "./modules/11_Economy/module.gms";
*######################## R SECTION END (MODULES) ##############################
$offrecurse