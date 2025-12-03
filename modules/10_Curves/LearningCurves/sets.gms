*' @title Learning Curves Sets
*' @code

*' @title Learning Curves Sets
*' @code

sets
LCTECH "Technologies with learning curves"
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