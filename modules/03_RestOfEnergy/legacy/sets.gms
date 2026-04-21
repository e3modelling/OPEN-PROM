*' @title RestOfEnergy Sets
*' @code
sets
*---
SECtoEFPROD(SSBS,EFS)      "Energy forms produced by each supply sector"
/
SLD.(HCL,LGN,BMSWAS)
LQD.(GSL,BGSL,GDO,BGDO,RFO,LPG,KRS,BKRS,OLQ)
GAS.(NGS,OGS)
PG.(ELC,NUC)
H2P.H2F
STEAMP.STE
CHP.(ELC,STE)
/

*TRANSFSECS    /PG,H2P,CHP,STEAMP,LQD,SLD,GAS,H2INFR/
;
