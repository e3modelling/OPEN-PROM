*' @title Economy Inputs
*' @code

*' Parameters
$$ontext
table i10SubsiPerDemTech(allCy,TECH,YTIME)	              "State demand technology support policy, expressed as a proportion of the available state grants (%)"
$ondelim
$include"./iSubsiPerDemTech.csv"
$offdelim
;
*---
table i10SubsiPerSupTech(allCy,STECH,YTIME)	              "State supply technology support policy, expressed as a proportion of the available state grants (%)"
$ondelim
$include"./iSubsiPerSupTech.csv"
$offdelim
;
$$offtext
*---