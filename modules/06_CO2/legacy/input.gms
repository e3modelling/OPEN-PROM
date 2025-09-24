*' @title CO2 Inputs
*' @code

*---
parameter i06CO2SeqData(CO2SEQELAST)	        "Data for CO2 sequestration (1)"
/
POT	9175,
mc_a	0.00125928,
mc_b	6.6,
mc_c	0.02,
mc_d	0.000839237,
mc_s	120,
mc_m	1.013
/ ;

parameter i06CapexDAC(DACTECH)                  "CAPEX of each DAC technology ($/tCO2)"
/
HTDAC	150,
H2DAC   1500
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
EWDAC	200
/ ;

parameter i06VarDAC(DACTECH)                    "Variable and carbon storage costs of each DAC technology ($/tCO2)"
/
HTDAC	115,
H2DAC	115,
LTDAC	370,
EWDAC	130
/ ;


parameter i06LftExpDAC(DACTECH)                 "Lifetime of each DAC technology (years)"
/
HTDAC	25,
H2DAC	25,
LTDAC	20,
EWDAC	15
/ ;

parameter i06SubsidDAC(DACTECH)                 "Specific electricity needs of DAC technologies (MWh/tCO2)"
/
HTDAC	0.01,
H2DAC	0.01,
LTDAC	0.01,
EWDAC	0.01
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

parameter i06SchedNewCapDAC(allCy,DACTECH,YTIME)        "Scheduled new DAC capacity"
/
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
USA.LTDAC.2035  1e6,    !!South Texas DAC Hub
LAM.EWDAC.2024  5e5     !!South Texas DAC Hub
/ ;

*---
Parameters
i06ElastCO2Seq(allCy,CO2SEQELAST)	       "Elasticities for CO2 sequestration cost curve (1)"
i06GrossCapDACMin(allCy,DACTECH)           "Minimum possible CAPEX of each DAC technology affected by learning curve ($/tCO2)"
i06GrossCapDAC(allCy,DACTECH)	           "CAPEX of each DAC technology ($/tCO2)"
i06VarCostDAC(allCy,DACTECH)               "Variable and carbon storage costs of each DAC technology ($/tCO2)"
i06VarCostDACMin(allCy,DACTECH)            "Minimum possible Variable and carbon storage costs of each DAC technology affected by learning curve ($/tCO2)"
i06FixOandMDAC(allCy,DACTECH)              "Fixed and O&M costs of each DAC technology ($/tCO2)"
i06FixOandMDACMin(allCy,DACTECH)           "Minimum possible Fixed and O&M costs of each DAC technology affected by learning curve ($/tCO2)"
i06LftDAC(allCy,DACTECH,YTIME)             "Lifetime of each DAC technology (years)"
i06SubsDAC(allCy,DACTECH,YTIME)            "State subsidy for the carbon captured ($/tCO2)"
i06SpecElecDAC(allCy,DACTECH,YTIME)        "Specific electricity needs of DAC technologies (MWh/tCO2)"
i06SpecHeatDAC(allCy,DACTECH,YTIME)        "Specific heat needs of DAC technologies (MWh/tCO2)"
;
*---
i06ElastCO2Seq(runCy,CO2SEQELAST) = i06CO2SeqData(CO2SEQELAST);
*---
i06GrossCapDACMin(runCy,DACTECH) = i06CapexDACMin(DACTECH);
*---
i06GrossCapDAC(runCy,DACTECH) = i06CapexDAC(DACTECH);
*---
i06VarCostDAC(runCy,DACTECH) = i06VarDAC(DACTECH);
*---
i06VarCostDACMin(allCy,DACTECH) = i06VarDACMin(DACTECH);
*---
i06FixOandMDACMin(allCy,DACTECH) = i06FixCostDACMin(DACTECH);
*---
i06FixOandMDAC(runCy,DACTECH) = i06FixCostDAC(DACTECH);
*---
i06LftDAC(runCy,DACTECH,YTIME) = i06LftExpDAC(DACTECH);
*---
i06SubsDAC(runCy,DACTECH,YTIME) = i06SubsidDAC(DACTECH);
*---
i06SpecElecDAC(runCy,DACTECH,YTIME) = i06ElNeedsDAC(DACTECH);
*---
i06SpecHeatDAC(runCy,DACTECH,YTIME) = i06HeatNeedsDAC(DACTECH);
*---