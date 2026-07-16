*' @title CO2 Inputs
*' @code

*---
parameter i06CO2SeqData(CO2SEQELAST)	        "Data for CO2 sequestration (1)"
/
POT	1445,
sig_a 5,
sig_b	0.9,
seq_min 20,
seq_max 900
/ ;

parameter i06MatFacCDR(CDRTECH)                 "Maturity factor of CDR technology expressing its elasticity in implementation regarding its financial sustainability"
/
HTDAC	0.40,
H2DAC   0.5,
LTDAC	1,
TEW	    1
/ ;

parameter i06CapexCDR(CDRTECH)                  "CAPEX of each CDR technology ($/tCO2)"
/
HTDAC	250,
H2DAC   1100
LTDAC	1100,
TEW	400
/ ;

parameter i06CapexCDRMin(CDRTECH)               "Minimum possible CAPEX of each CDR technology affected by learning curve ($/tCO2)"
/
HTDAC	120,
H2DAC	68,
LTDAC	68,
TEW	68
/ ;

parameter i06FixCostCDR(CDRTECH)                "Fixed and O&M costs of each CDR technology ($/tCO2)"
/
HTDAC	72,
H2DAC	80,
LTDAC	180,
TEW	600
/ ;

parameter i06FixCostCDRMin(CDRTECH)             "Minimum possible Fixed and O&M costs of each CDR technology affected by learning curve ($/tCO2)"
/
HTDAC	40,
H2DAC	40,
LTDAC	30,
TEW	30
/ ;

parameter i06VarCostCDRMin(CDRTECH)                 "Minimum possible Variable and carbon storage costs of each CDR technology affected by learning curve ($/tCO2)"
/
HTDAC	75,
H2DAC	94,
LTDAC	250,
TEW	130
/ ;

parameter i06VarCostCDR(CDRTECH)                    "Variable and carbon storage costs of each CDR technology ($/tCO2)"
/
HTDAC	90,
H2DAC	115,
LTDAC	306,
TEW	200
/ ;

parameter i06SubsiCDR(CDRTECH)                    "Subsidy factor applied to the carbon price"
/
HTDAC	1,
H2DAC	1.8,
LTDAC	1.8,
TEW	1.8
/ ;

parameter i06LftExpCDR(CDRTECH)                 "Lifetime of each CDR technology (years)"
/
HTDAC	25,
H2DAC	25,
LTDAC	20,
TEW	15
/ ;

parameter i06ElNeedsCDR(CDRTECH)                "Specific electricity needs of CDR technologies (toe/tCO2)"
/
HTDAC	0.0234,
H2DAC	0.0234,
LTDAC	0.0315,
TEW	0.0186
/ ;

parameter i06HeatNeedsCDR(CDRTECH)               "Specific heat needs of CDR technologies (toe/tCO2)"
/
HTDAC	0.234,
H2DAC	0.234,
LTDAC	0.127,
TEW	0.148
/ ;

parameter i06SchedNewCapCDR(allCy,CDRTECH,YTIME)        "Scheduled new CDR capacity" /
!!NEU.LTDAC.2027  4e4,    !!Removr – Mongstad pilot / industrial‑scale projects
!!NEU.LTDAC.2026  4e4,    !!Orca (Climeworks + Carbfix) + Mammoth (Climeworks + Carbfix)
!!NEU.LTDAC.2028  1e5,    !!Removr + Carbfix (Large‑Scale Plant)
!!NEU.LTDAC.2024  900,    !!Climeworks – Hinwil pilot, Switzerland
!!USA.LTDAC.2023  1e3,    !!Global Thermostat – Commerce City, Colorado
!!USA.HTDAC.2024  1e3,    !!Heirloom – Tracy, California
!!USA.LTDAC.2025  5e3,    !!Heimdal – Bantam, Oklahoma
!!USA.LTDAC.2026  5e5,    !!Stratos (1PointFive / Occidental) — Texas
!!USA.HTDAC.2027  5e5,    !!Project Cypress (Climeworks + Heirloom + Battelle) — Louisiana
!!USA.LTDAC.2027  5e5,    !!Project Cypress (Climeworks + Heirloom + Battelle) — Louisiana
!!USA.LTDAC.2032  1e6,    !!HIF USA eFuels – Matagorda County, Texas
!!USA.LTDAC.2034  5e5,    !!Project Bison – Wyoming (CarbonCapture Inc.)
!!USA.LTDAC.2035  7e5     !!South Texas DAC Hub
$ifthen.DACproj %fScenario% == 2
$$ontext
CHA.LTDAC.2026  1e6,    !!Possible
CHA.H2DAC.2030  1e5,    !!Possible
CHA.TEW.2030  1e6,    !!Possible
OAS.LTDAC.2030  1e6,    !!Possible
OAS.TEW.2035  1e5,    !!Possible
DEU.LTDAC.2035  4e5,    !!Possible
DEU.TEW.2035  2e5,    !!Possible
FRA.LTDAC.2035  2e5,    !!Possible
GBR.H2DAC.2035  5e4,    !!Possible
IND.LTDAC.2026  7e5,    !!Possible
IND.TEW.2030  7e5,    !!Possible
JPN.H2DAC.2030  1e5,    !!Possible
REF.LTDAC.2029  5e5,    !!Possible
REF.TEW.2033  1e5,    !!Possible
MEA.LTDAC.2031  1e5,    !!Possible
MEA.TEW.2037  5e5,    !!Possible
SSA.LTDAC.2032  1e6,    !!Possible
SSA.TEW.2037  1e5,    !!Possible
LAM.TEW.2024  5e5
$$offtext
/;
$else.DACproj
/;
$endIf.DACproj

*---
Parameters
i06ElastCO2Seq(allCy,CO2SEQELAST)	       "Elasticities for CO2 sequestration cost curve (1)"
i06GrossCapCDRMin(CDRTECH)           "Minimum possible CAPEX of each CDR technology affected by learning curve ($/tCO2)"
i06GrossCapCDR(CDRTECH)	           "CAPEX of each CDR technology ($/tCO2)"
i06VarCostCDR(CDRTECH)               "Variable and carbon storage costs of each CDR technology ($/tCO2)"
i06VarCostCDRMin(CDRTECH)            "Minimum possible Variable and carbon storage costs of each CDR technology affected by learning curve ($/tCO2)"
i06FixOandMCDR(CDRTECH)              "Fixed and O&M costs of each CDR technology ($/tCO2)"
i06FixOandMCDRMin(CDRTECH)           "Minimum possible Fixed and O&M costs of each CDR technology affected by learning curve ($/tCO2)"
i06LftCDR(allCy,CDRTECH,YTIME)             "Lifetime of each CDR technology (years)"
i06SubsiFacCDR(CDRTECH)                  "State subsidy factor for the carbon captured applied on the carbon price"
i06SpecElecCDR(allCy,CDRTECH,YTIME)        "Specific electricity needs of CDR technologies (MWh/tCO2)"
i06SpecHeatCDR(allCy,CDRTECH,YTIME)        "Specific heat needs of CDR technologies (MWh/tCO2)"
;
*---
i06ElastCO2Seq(runCy,CO2SEQELAST) = i06CO2SeqData(CO2SEQELAST);
*---
i06GrossCapCDRMin(CDRTECH) = i06CapexCDRMin(CDRTECH);
*---
i06GrossCapCDR(CDRTECH) = i06CapexCDR(CDRTECH);
*---
i06VarCostCDR(CDRTECH) = i06VarCostCDR(CDRTECH);
*---
i06VarCostCDRMin(CDRTECH) = i06VarCostCDRMin(CDRTECH);
*---
i06FixOandMCDRMin(CDRTECH) = i06FixCostCDRMin(CDRTECH);
*---
i06FixOandMCDR(CDRTECH) = i06FixCostCDR(CDRTECH);
*---
i06SubsiFacCDR(CDRTECH) = i06SubsiCDR(CDRTECH);
*---
i06LftCDR(runCy,CDRTECH,YTIME) = i06LftExpCDR(CDRTECH);
*---
i06SpecElecCDR(runCy,CDRTECH,YTIME) = i06ElNeedsCDR(CDRTECH);
*---
i06SpecHeatCDR(runCy,CDRTECH,YTIME) = i06HeatNeedsCDR(CDRTECH);
*---