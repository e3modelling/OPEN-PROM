*' @title Learning Curves Sets
*' @code

*' NOTE: LCTECH is equivalent to the existing PGRENSW set
*' but is defined here for clarity within the Learning Curves module.
sets
LCTECH(PGALL) "Technologies with learning curves - subset of PGALL"
/
    PGSOL    "Solar PV"
    PGCSP    "Concentrated Solar Power"
    PGAWND   "Wind onshore" 
    PGAWNO   "Wind offshore"
/

LCSOL(LCTECH) "Solar technologies subset"
/
    PGSOL
    PGCSP
/

LCWND(LCTECH) "Wind technologies subset"  
/
    PGAWND
    PGAWNO
/

*' Regional learning-by-searching (R&D) technology scope.
*' Why this is separate from LCTECH:
*' - LCTECH controls the existing global learning-by-doing CAPEX multiplier (deployment driven).
*' - RDTECH controls the new regional R&D knowledge stock and R&D-driven multiplier.
*' - Keeping separate sets allows us to:
*'   1) preserve existing LBD behavior unchanged,
*'   2) include technologies not in LCTECH (e.g., DAC),
*'   3) run scenarios that toggle R&D effects independently.
*' Current scope includes wind/solar + DAC families used in this implementation.
RDTECH(TECH) "Technologies with regional learning-by-searching"
/
    PGSOL
    PGCSP
    PGAWND
    PGAWNO
    HTDAC
    H2DAC
    LTDAC
/
;
*---