$setglobal phase %1
$onrecurse
*######################## R SECTION START (MODULES) ############################
$include "./modules/01_PowerGeneration/module.gms";
$include "./modules/02_Transport/module.gms";
$include "./modules/03_Industry/module.gms";
$include "./modules/04_RestOfEnergy/module.gms";
$include "./modules/05_CO2/module.gms";
$include "./modules/06_Emissions/module.gms";
$include "./modules/07_Prices/module.gms";
*######################## R SECTION END (MODULES) ##############################
$offrecurse
