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
*---
Parameters
i06ElastCO2Seq(allCy,CO2SEQELAST)	       "Elasticities for CO2 sequestration cost curve (1)"
;
*---
i06ElastCO2Seq(runCy,CO2SEQELAST) = i06CO2SeqData(CO2SEQELAST);
*---