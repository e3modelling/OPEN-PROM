*' @title CO2 Inputs
*' @code

*---
parameter i06CO2SeqData(CO2SEQELAST)	        "Data for CO2 sequestration (1)"
/
POT	9175,
mc_a	0,
mc_b	20,
mc_c	0.02,
mc_d	5e3,
mc_s	120,
mc_m	1.013
/ ;

parameter i06MatFacDAC(CDRTECH)                 "Maturity factor of DAC technology expressing its elasticity in implementation regarding its financial sustainability"
/
HTDAC	  0.80,
H2DAC   0.27,
LTDAC	  0.13,
TEW	    0.35
/ ;

parameter i06CapexDAC(CDRTECH)                  "CAPEX of each DAC technology ($/tCO2)"
/
HTDAC	250,
H2DAC   1300
LTDAC	1300,
TEW	400
/ ;

parameter i06CapexDACMin(CDRTECH)               "Minimum possible CAPEX of each DAC technology affected by learning curve ($/tCO2)"
/
HTDAC	120,
H2DAC	68,
LTDAC	68,
TEW	68
/ ;

parameter i06FixCostDAC(CDRTECH)                "Fixed and O&M costs of each DAC technology ($/tCO2)"
/
HTDAC	72,
H2DAC	80,
LTDAC	180,
TEW	600
/ ;

parameter i06FixCostDACMin(CDRTECH)             "Minimum possible Fixed and O&M costs of each DAC technology affected by learning curve ($/tCO2)"
/
HTDAC	40,
H2DAC	40,
LTDAC	30,
TEW	30
/ ;

parameter i06VarDACMin(CDRTECH)                 "Minimum possible Variable and carbon storage costs of each DAC technology affected by learning curve ($/tCO2)"
/
HTDAC	75,
H2DAC	94,
LTDAC	250,
TEW	130
/ ;

parameter i06VarDAC(CDRTECH)                    "Variable and carbon storage costs of each DAC technology ($/tCO2)"
/
HTDAC	90,
H2DAC	115,
LTDAC	306,
TEW	200
/ ;

parameter i06SubsiDAC(CDRTECH)                    "Subsidy factor applied to the carbon price"
/
HTDAC	1,
H2DAC	1.8,
LTDAC	1.8,
TEW	1.8
/ ;

parameter i06LftExpDAC(CDRTECH)                 "Lifetime of each DAC technology (years)"
/
HTDAC	25,
H2DAC	25,
LTDAC	20,
TEW	15
/ ;

parameter i06ElNeedsDAC(CDRTECH)                "Specific electricity needs of DAC technologies (toe/tCO2)"
/
HTDAC	0.12658832,
H2DAC	0.12658832,
LTDAC	0.0236457,
TEW	3
/ ;

parameter i06HeatNeedsDAC(CDRTECH)               "Specific heat needs of DAC technologies (toe/tCO2)"
/
HTDAC	1.265883,
H2DAC	1.265883,
LTDAC	0,
TEW	0
/ ;

parameter i06SchedNewCapDAC(allCy,CDRTECH,YTIME)        "Scheduled new DAC capacity" /
NEU.LTDAC.2027  4e4,    !!Removr – Mongstad pilot / industrial‑scale projects
NEU.LTDAC.2026  4e4,    !!Orca (Climeworks + Carbfix) + Mammoth (Climeworks + Carbfix)
NEU.LTDAC.2028  1e5,    !!Removr + Carbfix (Large‑Scale Plant)
NEU.LTDAC.2024  900,    !!Climeworks – Hinwil pilot, Switzerland
USA.LTDAC.2023  1e3,    !!Global Thermostat – Commerce City, Colorado
USA.HTDAC.2024  1e3,    !!Heirloom – Tracy, California
USA.LTDAC.2025  5e3,    !!Heimdal – Bantam, Oklahoma
USA.LTDAC.2026  5e5,    !!Stratos (1PointFive / Occidental) — Texas
USA.HTDAC.2027  5e5,    !!Project Cypress (Climeworks + Heirloom + Battelle) — Louisiana
USA.LTDAC.2027  5e5,    !!Project Cypress (Climeworks + Heirloom + Battelle) — Louisiana
USA.LTDAC.2032  1e6,    !!HIF USA eFuels – Matagorda County, Texas
USA.LTDAC.2034  5e5,    !!Project Bison – Wyoming (CarbonCapture Inc.)
USA.LTDAC.2035  7e5     !!South Texas DAC Hub
$ifthen.DACproj %fScenario% == 2
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
LAM.TEW.2024  5e5/;
$else.DACproj
/;
$endIf.DACproj

*---
Parameters
i06ElastCO2Seq(allCy,CO2SEQELAST)	       "Elasticities for CO2 sequestration cost curve (1)"
i06GrossCapDACMin(CDRTECH)           "Minimum possible CAPEX of each DAC technology affected by learning curve ($/tCO2)"
i06GrossCapDAC(CDRTECH)	           "CAPEX of each DAC technology ($/tCO2)"
i06VarCostDAC(CDRTECH)               "Variable and carbon storage costs of each DAC technology ($/tCO2)"
i06VarCostDACMin(CDRTECH)            "Minimum possible Variable and carbon storage costs of each DAC technology affected by learning curve ($/tCO2)"
i06FixOandMDAC(CDRTECH)              "Fixed and O&M costs of each DAC technology ($/tCO2)"
i06FixOandMDACMin(CDRTECH)           "Minimum possible Fixed and O&M costs of each DAC technology affected by learning curve ($/tCO2)"
i06LftDAC(allCy,CDRTECH,YTIME)             "Lifetime of each DAC technology (years)"
i06SubsiFacDAC(CDRTECH)                  "State subsidy factor for the carbon captured applied on the carbon price"
i06SpecElecDAC(allCy,CDRTECH,YTIME)        "Specific electricity needs of DAC technologies (MWh/tCO2)"
i06SpecHeatDAC(allCy,CDRTECH,YTIME)        "Specific heat needs of DAC technologies (MWh/tCO2)"
;
*---
i06ElastCO2Seq(runCy,CO2SEQELAST) = i06CO2SeqData(CO2SEQELAST);
*---
i06GrossCapDACMin(CDRTECH) = i06CapexDACMin(CDRTECH);
*---
i06GrossCapDAC(CDRTECH) = i06CapexDAC(CDRTECH);
*---
i06VarCostDAC(CDRTECH) = i06VarDAC(CDRTECH);
*---
i06VarCostDACMin(CDRTECH) = i06VarDACMin(CDRTECH);
*---
i06FixOandMDACMin(CDRTECH) = i06FixCostDACMin(CDRTECH);
*---
i06FixOandMDAC(CDRTECH) = i06FixCostDAC(CDRTECH);
*---
i06SubsiFacDAC(CDRTECH) = i06SubsiDAC(CDRTECH);
*---
i06LftDAC(runCy,CDRTECH,YTIME) = i06LftExpDAC(CDRTECH);
*---
i06SpecElecDAC(runCy,CDRTECH,YTIME) = i06ElNeedsDAC(CDRTECH);
*---
i06SpecHeatDAC(runCy,CDRTECH,YTIME) = i06HeatNeedsDAC(CDRTECH);
*---