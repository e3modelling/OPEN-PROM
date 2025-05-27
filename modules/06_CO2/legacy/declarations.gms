*' @title CO2 SEQUESTRATION COST CURVES Declarations
*' @code

Equations
*' *** CO2 SEQUESTRATION COST CURVES EQUATIONS
QCapCO2ElecHydr(allCy,YTIME)	                           "Compute CO2 captured by electricity and hydrogen production plants (Mtn CO2)"
QCaptCummCO2(allCy,YTIME)	                               "Compute cumulative CO2 captured (Mtn of CO2)"
QTrnsWghtLinToExp(allCy,YTIME)	                           "Transtition weight for shifting from linear to exponential CO2 sequestration cost curve"

*'                **Interdependent Equations**
Q06CstCO2SeqCsts(allCy,YTIME)	                               "Compute cost curve for CO2 sequestration costs" 
;

Variables
*' *** CO2 SEQUESTRATION COST CURVES VARIABLES
VCapCO2ElecHydr(allCy,YTIME)	                           "CO2 captured by electricity and hydrogen production plants (Mtn CO2)"
VCaptCummCO2(allCy,YTIME)	                               "Cumulative CO2 captured (Mtn CO2)"
VTrnsWghtLinToExp(allCy,YTIME)	                           "Weight for transtition from linear CO2 sequestration cost curve to exponential (1)"

*'                **Interdependent Variables**
VMVCstCO2SeqCsts(allCy,YTIME)	                           "Cost curve for CO2 sequestration costs (US$2015/tn of CO2 sequestrated)"
;