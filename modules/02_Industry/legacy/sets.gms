*' @title Industry Sets
*' @code

*---
sets
ISTECH_HIST   "Historical Existing IS routes"
    / 
    bf-bof   "blast furnace basic oxygen furnace"
   dr-eaf   "direct reduction electric arc furnace"
   scrap-eaf   "scrap electric arc furnace"
    /
*---
ISTECH_NEW   "New IS routes"
/
   bf-bof-bat "best available tech blast furnace basic oxygen furnace"
   dr-eaf-bat "best available tech direct reduction electric arc furnace"
   scrap-eaf   "best available tech scrap electric arc furnace"
/
*---

ISTECH_HISTtoEF(ISTECH_HIST,EF) "Mapping between IS technologies and fuels"
/
bf-bof.(hcl, ngs),
dr-eaf.(ngs),
scrap-eaf.(elc)
/
*---