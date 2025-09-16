*' @title CO2 Inputs
*' @code

*---
parameter i06CO2SeqData(CO2SEQELAST)	   "Data for CO2 sequestration (1)"
/
POT	9175,
mc_a	0.00125928,
mc_b	6.6,
mc_c	0.02,
mc_d	0.000839237,
mc_s	120,
mc_m	1.013
/ ;

parameter i06CapexDAC(DACTECH)               "CAPEX of each DAC technology ($/tCO2)"
/
HTDAC	200,
LTDAC	85,
EWDAC	400
/ ;

parameter i06FixCostDAC(DACTECH)             "Fixed and O&M costs of each DAC technology ($/tCO2)"
/
HTDAC	160,
LTDAC	51,
EWDAC	600
/ ;

parameter i06LftExpDAC(DACTECH)               "Lifetime of each DAC technology (years)"
/
HTDAC	25,
LTDAC	20,
EWDAC	15
/ ;

parameter i06SubsidDAC(DACTECH)               "Specific electricity needs of DAC technologies (MWh/tCO2)"
/
HTDAC	0.01,
LTDAC	0.01,
EWDAC	0.01
/ ;

parameter i06ElNeedsDAC(DACTECH)               "Specific electricity needs of DAC technologies (MWh/tCO2)"
/
HTDAC	0.416667,
LTDAC	2.7,
EWDAC	3
/ ;

parameter i06HeatNeedsDAC(DACTECH)               "Specific heat needs of DAC technologies (MWh/tCO2)"
/
HTDAC	2.2222,
LTDAC	0,
EWDAC	0
/ ;

*---
Parameters
i06ElastCO2Seq(allCy,CO2SEQELAST)	       "Elasticities for CO2 sequestration cost curve (1)"
i06GrossCapDAC(allCy,DACTECH,YTIME)	       "CAPEX of each DAC technology ($/tCO2)"
i06FixOandMDAC(allCy,DACTECH,YTIME)        "Fixed and O&M costs of each DAC technology ($/tCO2)"
i06LftDAC(allCy,DACTECH,YTIME)             "Lifetime of each DAC technology (years)"
i06SubsDAC(allCy,DACTECH,YTIME)            "State subsidy for the carbon captured ($/tCO2)"
i06SpecElecDAC(allCy,DACTECH,YTIME)        "Specific electricity needs of DAC technologies (MWh/tCO2)"
i06SpecHeatDAC(allCy,DACTECH,YTIME)        "Specific heat needs of DAC technologies (MWh/tCO2)"
;
*---
i06ElastCO2Seq(runCy,CO2SEQELAST) = i06CO2SeqData(CO2SEQELAST);
*---
i06GrossCapDAC(runCy,DACTECH,YTIME) = i06CapexDAC(DACTECH);
*---
i06FixOandMDAC(runCy,DACTECH,YTIME) = i06FixCostDAC(DACTECH);
*---
i06LftDAC(runCy,DACTECH,YTIME) = i06LftExpDAC(DACTECH);
*---
i06SubsDAC(runCy,DACTECH,YTIME) = i06SubsidDAC(DACTECH);
*---
i06SpecElecDAC(runCy,DACTECH,YTIME) = i06ElNeedsDAC(DACTECH);
*---
i06SpecHeatDAC(runCy,DACTECH,YTIME) = i06HeatNeedsDAC(DACTECH);
*---