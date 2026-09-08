*' @title Economy Inputs
*' @code

*' Parameters
table i11SubsiPerDemTechAvail(allCy,DSBS,TECH,YTIME)	              "State demand technology support policy, expressed as a proportion factor of the available state grants (1)"
$ondelim
$include"./iSubsiPerDemTech.csv"
$offdelim
;
parameter i11SubsiPerFuelAvail(allCy,SBS,EFS,YTIME);                             !!State fuel support policy, expressed as a proportion factor of the available state grants (1)"
i11SubsiPerFuelAvail(allCy,"H2P","ELC",YTIME) = 0.1;
i11SubsiPerFuelAvail(allCy,"HOU","ELC",YTIME) = 0.9;
*---
parameter i11SubsiPerSupTechAvail(allCy,PGALL,YTIME);                             !!State fuel support policy, expressed as a proportion factor of the available state grants (1)"
i11SubsiPerSupTechAvail(allCy,PGALL,YTIME) = 0;
i11SubsiPerSupTechAvail(allCy,"PGAWNO",YTIME) = 0;
*---
parameter i11SubsiShare(SubsiCat);                                      !!State support policy, expressed as a proportion factor of the available state grants (1)"
i11SubsiShare("Dem") = 0.8;
i11SubsiShare("PowGen") = 0.2;
i11SubsiShare("Fuel") = 0;
*---

$$ontext
table i11SubsiPerSupTech(allCy,STECH,YTIME)	              "State supply technology support policy, expressed as a proportion factor of the available state grants (1)"
$ondelim
$include"./iSubsiPerSupTech.csv"
$offdelim
;
$$offtext
*---