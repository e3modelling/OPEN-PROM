*' @title Industry Sets
*' @code

*---
sets

ICTSCEN "Scenarios for projected ICT growth" /Lower,Upper,Central,Mean/
IND_SERVS "Industry & Domestic energy services" /PRIM_STEEL,SEC_STEEL,OTHER/

INDDOMtoSERVS(INDDOM,IND_SERVS)    "Mapping between industry"
/
IS.(PRIM_STEEL,SEC_STEEL)
/

INDITECH(TECH)
/
BOF     "Blast furnace basic oxygen furnace for primary steel production"
EAF     "best available tech direct reduction electric arc furnace fed ny natural gas for primary steel production"
/

SERVStoTECH(IND_SERVS,INDITECH)
/
PRIM_STEEL.BOF
PRIM_STEEL.EAF
SEC_STEEL.EAF
/

INDITECHTOEF(INDITECH,EF)
/
BOF.(ELC,BFG,COG,COKE,BMSWAS,STE,RFO,GDO,OLQ,LPG,LGN,LPG)
EAF.(ELC,BMSWAS,STE,RFO,GDO,OLQ,LPG,LGN,LPG)
/

IND_SERVStoEF(IND_SERVS,EF)

IS_TRANSF "IS transformation routes" /BLASTFUR,COKEOVS,DRI/

IS_TRANSF_OUT(IS_TRANSF,EF)   "Energy outputs of IS transformation processes"
/
BLASTFUR.(BFG)
COKEOVS.(COKE,COG)
/

IS_TRANSF_IN(IS_TRANSF,EF)   "Energy inputs of IS transformation processes"
/
BLASTFUR.(HCL)
COKEOVS.(HCL)
/
;

INDDOMtoSERVS(INDDOM,"OTHER")$(not sameas("IS", INDDOM)) = yes;
IND_SERVStoEF(IND_SERVS,EF) = yes$SUM(INDITECH$(SERVStoTECH(IND_SERVS,INDITECH) and INDITECHTOEF(INDITECH,EF)), 1);
SECtoEF(INDDOM,EF) = yes$SUM(IND_SERVS$IND_SERVStoEF(IND_SERVS,EF), 1);
alias(INDITECH, INDITECH2);
