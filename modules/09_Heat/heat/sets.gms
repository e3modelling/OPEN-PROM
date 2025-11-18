*' @title Heat Sets
*' @code

sets

*---
TSTEAM "CHP & DHP plant technologies"
/
TSTE1AL           "Lignite powered advanced CHP"
TSTE1AH           "Hard Coal powered advanced CHP"
TSTE1AD           "Diesel Oil powered advanced CHP"
*STE1AR           "Fuel Oil powered advanced CHP"
TSTE1AG           "Natural Gas powered advanced CHP"
TSTE1AB           "Biomass-Waste powered advanced CHP"
TSTE1AH2F         "HYDROGEN powered FUEL CELL CHP"
TSTE2LGN
TSTE2OSL
TSTE2GDO
TSTE2RFO
TSTE2OLQ
TSTE2OGS
TSTE2NGS
TSTE2BMS
/

TCHP(TSTEAM) "CHP plant technologies"
/
TSTE1AL           "Utilisation rate of Lignite powered advanced CHP"
TSTE1AH           "Utilisation rate of Hard Coal powered advanced CHP"
TSTE1AD           "Utilisation rate of Diesel Oil powered advanced CHP"
*STE1AR           "Utilisation rate of Fuel Oil powered advanced CHP"
TSTE1AG           "Utilisation rate of Natural Gas powered advanced CHP"
TSTE1AB           "Utilisation rate of Biomass-Waste powered advanced CHP"
TSTE1AH2F         "Utilisation rate of Hydrogen powered fuel cell CHP"
/

TDHP(TSTEAM) "CHP plant technologies"
/
TSTE2LGN
TSTE2OSL
TSTE2GDO
TSTE2RFO
TSTE2OLQ
TSTE2OGS
TSTE2NGS
TSTE2BMS
/
*---
TSTEAMTOEF(TSTEAM,EF)   Correspondence between chp plants and energy forms
/
* GEO,NUC ?
(TSTE1AL,TSTE2LGN).LGN
(TSTE1AH,TSTE2OSL).HCL
(TSTE1AD,TSTE2GDO).GDO
TSTE1AG.OGS
*TSTE1AD.RFO
*TSTE1AD.LPG
*TSTE1AD.KRS
*TSTE1AH.OLQ
TSTE2RFO.RFO
TSTE2OLQ.OLQ
TSTE2OGS.OGS
(TSTE1AG,TSTE2NGS).NGS
(TSTE1AB,TSTE2BMS).BMSWAS
TSTE1AH2F.H2F
/
*---
PGEFS(EFS)      "Fuels used as Input to District Heating"      /LGN,HCL,GDO,RFO,OLQ,NGS,OGS,BMSWAS/
STEAMEF(EFS)     "Energy forms used for steam production"
STEMODE         "Steam production modes"                       /CHP,DHP/
;
*---
ALIAS (TSTEAM2,TSTEAM);
ALIAS (TCHP2,TCHP);
ALIAS (TDHP2,TDHP);
*---
STEAMEF(EFS) = yes$(sum(TSTEAM, TSTEAMTOEF(TSTEAM,EFS)));