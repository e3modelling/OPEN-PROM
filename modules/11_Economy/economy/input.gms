*' @title Economy Inputs
*' @code

*' Parameters
table i11SubsiPerDemTechAvail(allCy,DSBS,TECH,YTIME)	              "State demand technology support policy, expressed as a proportion factor of the available state grants (1)"
$ondelim
$include"./iSubsiPerDemTech.csv"
$offdelim
;
*---
*' Minimal RD policy-share template (PG/DAC rows).
*'
*' Purpose:
*' - Provide a dedicated, easy-to-scenario-manage share input for the RD subsidy bridge
*'   without changing the existing broader demand-tech subsidy table.
*'
*' Construction logic (template defaults):
*' - Start from zero for all RDTECH entries.
*' - Copy PG row shares for LCTECH entries (solar/wind RD technologies).
*' - Copy DAC row shares for DACTECH entries (DAC RD technologies).
*'
*' This gives a minimal, transparent split between power-generation RD and DAC RD,
*' while keeping full backward compatibility with current policy input files.
Parameter i11SubsiPerRDTech(allCy,RDTECH,YTIME) "State R&D policy share by country/technology/year (1)";

i11SubsiPerRDTech(allCy,RDTECH,YTIME) = 0;
i11SubsiPerRDTech(allCy,RDTECH,YTIME)$LCTECH(RDTECH) = i11SubsiPerDemTechAvail(allCy,"PG",RDTECH,YTIME);
i11SubsiPerRDTech(allCy,RDTECH,YTIME)$DACTECH(RDTECH) = i11SubsiPerDemTechAvail(allCy,"DAC",RDTECH,YTIME);
*---
$$ontext
table i11SubsiPerSupTech(allCy,STECH,YTIME)	              "State supply technology support policy, expressed as a proportion factor of the available state grants (1)"
$ondelim
$include"./iSubsiPerSupTech.csv"
$offdelim
;
$$offtext
*---