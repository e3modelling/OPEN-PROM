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

parameter i06MatFacDAC(DACTECH)                 "Maturity factor of DAC technology expressing its elasticity in implementation regarding its financial sustainability"
/
HTDAC	  0.59,
H2DAC   0.37,
LTDAC	  0.25,
EWDAC	  0.45
/ ;

parameter i06CapexDAC(DACTECH)                  "CAPEX of each DAC technology ($/tCO2)"
/
HTDAC	400,
H2DAC   1300
LTDAC	1300,
EWDAC	400
/ ;

parameter i06CapexDACMin(DACTECH)               "Minimum possible CAPEX of each DAC technology affected by learning curve ($/tCO2)"
/
HTDAC	120,
H2DAC	68,
LTDAC	68,
EWDAC	68
/ ;

parameter i06FixCostDAC(DACTECH)                "Fixed and O&M costs of each DAC technology ($/tCO2)"
/
HTDAC	55,
H2DAC	80,
LTDAC	180,
EWDAC	600
/ ;

parameter i06FixCostDACMin(DACTECH)             "Minimum possible Fixed and O&M costs of each DAC technology affected by learning curve ($/tCO2)"
/
HTDAC	40,
H2DAC	40,
LTDAC	30,
EWDAC	30
/ ;

parameter i06VarDACMin(DACTECH)                 "Minimum possible Variable and carbon storage costs of each DAC technology affected by learning curve ($/tCO2)"
/
HTDAC	94,
H2DAC	94,
LTDAC	320,
EWDAC	130
/ ;

parameter i06VarDAC(DACTECH)                    "Variable and carbon storage costs of each DAC technology ($/tCO2)"
/
HTDAC	115,
H2DAC	115,
LTDAC	370,
EWDAC	200
/ ;


parameter i06LftExpDAC(DACTECH)                 "Lifetime of each DAC technology (years)"
/
HTDAC	25,
H2DAC	25,
LTDAC	20,
EWDAC	15
/ ;

parameter i06ElNeedsDAC(DACTECH)                "Specific electricity needs of DAC technologies (MWh/tCO2)"
/
HTDAC	0.3666666667,
H2DAC	0.3666666667,
LTDAC	0.275,
EWDAC	3
/ ;

parameter i06HeatNeedsDAC(DACTECH)               "Specific heat needs of DAC technologies (MWh/tCO2)"
/
HTDAC	1.4722222222,
H2DAC	1.4722222222,
LTDAC	0,
EWDAC	0
/ ;

parameter i06SchedNewCapDAC(allCy,DACTECH,YTIME)        "Scheduled new DAC capacity" /
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
USA.LTDAC.2034  1e6,    !!Project Bison – Wyoming (CarbonCapture Inc.)
USA.LTDAC.2035  1e6     !!South Texas DAC Hub
$ifthen.DACproj %fScenario% == 2
CHA.LTDAC.2026  1e6,    !!Possible
CHA.H2DAC.2030  1e5,    !!Possible
CHA.EWDAC.2030  1e6,    !!Possible
OAS.LTDAC.2030  1e6,    !!Possible
OAS.EWDAC.2035  1e5,    !!Possible
DEU.LTDAC.2035  4e5,    !!Possible
DEU.EWDAC.2035  2e5,    !!Possible
FRA.LTDAC.2035  2e5,    !!Possible
GBR.H2DAC.2035  5e4,    !!Possible
IND.LTDAC.2026  7e5,    !!Possible
IND.EWDAC.2030  7e5,    !!Possible
JPN.H2DAC.2030  1e5,    !!Possible
REF.LTDAC.2029  5e5,    !!Possible
REF.EWDAC.2033  1e5,    !!Possible
MEA.LTDAC.2031  1e5,    !!Possible
MEA.EWDAC.2037  5e5,    !!Possible
SSA.LTDAC.2032  1e6,    !!Possible
SSA.EWDAC.2037  1e5,    !!Possible
LAM.EWDAC.2024  5e5/;
$else.DACproj
/;
$endIf.DACproj

*---
Parameters
i06ElastCO2Seq(allCy,CO2SEQELAST)	       "Elasticities for CO2 sequestration cost curve (1)"
i06GrossCapDACMin(DACTECH)           "Minimum possible CAPEX of each DAC technology affected by learning curve ($/tCO2)"
i06GrossCapDAC(DACTECH)	           "CAPEX of each DAC technology ($/tCO2)"
i06VarCostDAC(DACTECH)               "Variable and carbon storage costs of each DAC technology ($/tCO2)"
i06VarCostDACMin(DACTECH)            "Minimum possible Variable and carbon storage costs of each DAC technology affected by learning curve ($/tCO2)"
i06FixOandMDAC(DACTECH)              "Fixed and O&M costs of each DAC technology ($/tCO2)"
i06FixOandMDACMin(DACTECH)           "Minimum possible Fixed and O&M costs of each DAC technology affected by learning curve ($/tCO2)"
i06LftDAC(allCy,DACTECH,YTIME)             "Lifetime of each DAC technology (years)"
i06SubsDAC(allCy,DACTECH,YTIME)            "State subsidy for the carbon captured ($/tCO2)"
i06SpecElecDAC(allCy,DACTECH,YTIME)        "Specific electricity needs of DAC technologies (MWh/tCO2)"
i06SpecHeatDAC(allCy,DACTECH,YTIME)        "Specific heat needs of DAC technologies (MWh/tCO2)"
;
*---
i06ElastCO2Seq(runCy,CO2SEQELAST) = i06CO2SeqData(CO2SEQELAST);
*---
i06GrossCapDACMin(DACTECH) = i06CapexDACMin(DACTECH);
*---
i06GrossCapDAC(DACTECH) = i06CapexDAC(DACTECH);
*---
i06VarCostDAC(DACTECH) = i06VarDAC(DACTECH);
*---
i06VarCostDACMin(DACTECH) = i06VarDACMin(DACTECH);
*---
i06FixOandMDACMin(DACTECH) = i06FixCostDACMin(DACTECH);
*---
i06FixOandMDAC(DACTECH) = i06FixCostDAC(DACTECH);
*---
i06LftDAC(runCy,DACTECH,YTIME) = i06LftExpDAC(DACTECH);
*---
i06SpecElecDAC(runCy,DACTECH,YTIME) = i06ElNeedsDAC(DACTECH);
*---
i06SpecHeatDAC(runCy,DACTECH,YTIME) = i06HeatNeedsDAC(DACTECH);
*---