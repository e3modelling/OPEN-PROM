table iGDP(YTIME,allCy) "GDP (billion US$2015)"
$ondelim
$include "./iGDP.csvr"
$offdelim
;
table iPop(YTIME,allCy) "Population (billion)"
$ondelim
$include "./iPop.csvr"
$offdelim
;
table iTransChar(allCy,TRANSPCHAR,YTIME) "km per car, passengers per car and residuals for passenger cars market extension ()"
$ondelim
$include "./iTransChar.csv"
$offdelim
;
table iElastA(allCy,SBS,ETYPES,YTIME) "Activity Elasticities per subsector (1)"
$ondelim
$include "./iElastA.csv"
$offdelim
;
table iSigma(allCy,SG) "S parameters of Gompertz function for passenger cars vehicle km (1)"
$ondelim
$include "./iSigma.csv"
$offdelim
;
table iResActiv(allCy,TRANSE,YTIME) "Residuals on transport activity ()"
$ondelim
$include "./iResActiv.csv"
$offdelim
;
table iElastNonSubElec(allCy,SBS,ETYPES,YTIME) "Elasticities of Non Substitutable Electricity (1)"
$ondelim
$include "./iElastNonSubElec.csv"
$offdelim
;
table iFracElecPriChp(allCy, YTIME) "Fraction of Electricity Price at which a CHP sells electricity to network (1)"
$ondelim
$include "./iFracElecPriChp.csv"
$offdelim
;
table iCapCosChp(allCy,CHP,YTIME) "Capital Cost per CHP plant type (kEuro05/KW)"
$ondelim
$include "./iCapCosChp.csv"
$offdelim
;
table iFixOandMCosChp(allCy,CHP,YTIME) "Fixed O&M cost per CHP plant type (kEuro05/KW)"
$ondelim
$include "./iFixOandMCosChp.csv"
$offdelim
;
table iAvailRateChp(allCy,CHP) "Availability rate of CHP Plants ()"
$ondelim
$include "./iAvailRateChp.csv"
$offdelim
;
table iCosPerChp(allCy,CHP, YTIME) "Variable (other than fuel) cost per CHP Type (Gross Euro05/KW)"
$ondelim
$include "./iCosPerChp.csv"
$offdelim
;
table iBoiEffChp(allCy,CHP,YTIME) "Boiler efficiency (typical) used in adjusting CHP efficiency ()"
$ondelim
$include "./iBoiEffChp.csv"
$offdelim
;
table iDisc(allCy,SBS,YTIME) "Discount rates per subsector ()"
$ondelim
$include "./iDisc.csv"
$offdelim
;
table iCo2EmiFacAllSbs(allCy,EF) "CO2 emission factors (kgCO2/kgoe fuel burned)"
$ondelim
$include "./iCo2EmiFacAllSbs.csv"
$offdelim
;
iCo2EmiFac(allCy,SBS,EF,YTIME) = iCo2EmiFacAllSbs(allCy,EF);
iCo2EmiFac(allCy,"IS","HCL",YTIME)$(not An(YTIME))   = iCo2EmiFacAllSbs(allCy,"SLD"); !! This is the assignment for coke
table iUsfEneConvSubTech(SBS,EF,YTIME)             "Useful Energy Conversion Factor per subsector and technology (1)"
$ondelim
$include "./iUseEneConvSubTech.csv"
$offdelim
;
iUsfEnergy(allCy,SBS,EF,TEA,YTIME) = iUsfEneConvSubTech(SBS,EF,YTIME);