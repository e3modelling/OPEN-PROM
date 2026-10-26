*' @title Alternative fuels Sets
*' @code

sets
ALTEF(EFS) /NH3/

ALTEFTECH(STECH)
/
gsr         "gas steam reforming"
gss         "gas steam reforming with CCS"
weg         "water electrolysis from grid power"
wew         "water electrolysis with wind"
wes         "water electrolysis with solar"
cgf         "coal gasification"
cgs         "coal gasification with CCS"
bgfl        "biomass gasification large scale"
bgfls       "biomass gasification large scale with CCS"
/

ALTEFtoALTEFTECH(ALTEF,ALTEFTECH) 
/
NH3.(gsr,gss,weg,wew,wes,cgf,cgs,bgfl,bgfls)
/
;
alias(ALTEFTECH, ALTEFTECH2);