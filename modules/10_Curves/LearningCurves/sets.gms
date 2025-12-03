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
;
*---