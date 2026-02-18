*' @title Emissions Sets
*' @code

sets
*---
SSBSEMIT(SSBS)     Supply Subsectors emitting inputs     /PG,H2P,CHP,STEAMP/

E07MAC "Cost categories for Marginal abatement costs curves (MACC) -2010$/tC for CH4,N20 and 2005$/tC for F-gases" / 
    0, 20, 40, 60, 80, 100, 120, 140, 160, 180, 200, 220, 240, 260, 280, 300, 
    320, 340, 360, 380, 400, 420, 460, 480, 500, 520, 540, 560, 580, 600, 660, 
    680, 720, 740, 760, 780, 820, 840, 1000, 1080, 1100, 1120, 1520, 1660, 
    1700, 1740, 2580, 2600, 3440, 3460, 3500, 3540, 3600, 3840, 4000 
/
Set sFGases(E07SrcMacAbate) "F-gases (Input data in kt)" 
/
    HFC_125, HFC_134a, HFC_143a, HFC_152a, HFC_227ea
    HFC_23,  HFC_236fa, HFC_32,   HFC_43_10, HFC_245ca
    CF4,     C2F6,      C6F14,    SF6
/