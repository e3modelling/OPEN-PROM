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
TSTE2NGS
TSTE2BMS
TSTE2GEO
TSTE2OTH
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
TSTE2NGS
TSTE2BMS
TSTE2GEO
TSTE2OTH
/
*---
TSTEAMTOEF(TSTEAM,EF)   Correspondence between chp plants and energy forms
/
(TSTE1AL,TSTE2LGN).LGN
(TSTE1AH,TSTE2OSL).HCL
(TSTE1AD,TSTE2GDO).(GDO,RFO,OLQ,LPG,KRS)
(TSTE1AG,TSTE2NGS).(NGS,OGS)
(TSTE1AB,TSTE2BMS).BMSWAS
TSTE1AH2F.H2F
TSTE2GEO.GEO
TSTE2OTH.NUC
/
*---
STEAMEF(EFS)    "Fuels used for steam production"
STEMODE         "Steam production modes"                       /CHP,DHP/
;
*---
ALIAS (TSTEAM2,TSTEAM);
ALIAS (TCHP2,TCHP);
ALIAS (TDHP2,TDHP);
*---
STEAMEF(EFS) = yes$(sum(TSTEAM, TSTEAMTOEF(TSTEAM,EFS)));