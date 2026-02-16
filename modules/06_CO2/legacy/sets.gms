*' @title CO2 Sets
*' @code

sets
*---
$ontext
DACTECHEF(EF)               "Fuels used in DAC technologies"
/
ngs
elc
/

DACTECHEFtoEF(DACTECH,EF)   "Mapping between DAC technologies and fuels"
/
(HTDAC).ngs
(HTDAC,LTDAC,EWDAC).elc
/
$offtext
*---
CO2CAPTECH           "Carbon capture subsectors" /
PG
H2P
DAC
IND
/

CDR(DSBS)    "CDR subsectors" /
DAC
EW
/