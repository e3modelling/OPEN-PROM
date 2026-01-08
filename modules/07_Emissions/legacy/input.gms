*' @title Emissions Inputs
*' @code

*---

table i07DataCh4N2OFMAC(allCy,E07SrcMacAbate,E07MAC,YTIME)           "Marginal abatement cost curve (MACC) data for non-CO₂ emission sources"
$ondelim
$include"./iDataCh4N2OFgasesMAC.csv"
$offdelim
;
*---
table i07DataCh4N2OFEmis(allCy,E07SrcMacAbate,YTIME)                   "Baseline non-CO₂ emissions by source (Mt-CO2e for CH4, N2O, kt-CO2e for F-gases) - SSP2"
$ondelim
$include"./iDataCh4N2OFgasesEmissions.csv"
$offdelim
;

* Delete MAC files
* For Windows
$if %system.filesys% == MSNT $call 'del ".\data\iDataCh4N2OFgasesMAC.csv"'

* For Linux / macOS
$if %system.filesys% == UNIX $call 'rm "./data/iDataCh4N2OFgasesMAC.csv"'