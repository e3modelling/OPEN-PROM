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

parameter i06CapexDAC(DACTECH)                        ""
/
HTDAC	1490,
LTDAC	85,
EWDAC	400
/ ;

parameter i06FixCostDAC(DACTECH)
/
HTDAC	160,
LTDAC	51,
EWDAC	600
/ ;

parameter i06LftExpDAC(DACTECH)
/
HTDAC	25,
LTDAC	20,
EWDAC	15
/ ;
*---
Parameters
i06ElastCO2Seq(allCy,CO2SEQELAST)	       "Elasticities for CO2 sequestration cost curve (1)"
i06GrossCapDAC(allCy,DACTECH,YTIME)	       "CAPEX of each DAC technology"
i06FixOandMDAC(allCy,DACTECH,YTIME)        "Fixed and O&M costs of each DAC technology"
i06LftDAC(allCy,DACTECH,YTIME)             "Lifetime of each DAC technology"
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