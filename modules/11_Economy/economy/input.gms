*' @title Economy Inputs
*' @code

*' Parameters
table i11SubsiPerDemTech(allCy,DSBS,TECH,YTIME)	              "State demand technology support policy, expressed as a proportion factor of the available state grants (1)"
$ondelim
$include"./iSubsiPerDemTech.csv"
$offdelim
;
*---
$$ontext
table i11SubsiPerSupTech(allCy,STECH,YTIME)	              "State supply technology support policy, expressed as a proportion factor of the available state grants (1)"
$ondelim
$include"./iSubsiPerSupTech.csv"
$offdelim
;
$$offtext
*---