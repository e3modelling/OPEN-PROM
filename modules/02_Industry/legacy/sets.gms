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
   scrap-eaf-bat   "best available tech scrap electric arc furnace"
   bf-bof-ccs   "best available tech blast furnace basic oxygen furnace with CCS ammine based"
   dr-eaf-ccs "best available tech direct reduction electric arc furnace with CCS ammine based"
/
*---

ISTECH_HISTtoEF(ISTECH_HIST,EF) "Mapping between IS technologies and fuels"
/
bf-bof.(hcl, ngs, elc),
dr-eaf.(ngs, elc),
scrap-eaf.(elc, ngs)
/
*---
ISTECHNEW_HISTtoEF(ISTECH_NEW,EF) "Mapping between IS technologies and fuels"
/
bf-bof-bat.(hcl, ngs, elc),
dr-eaf-bat.(ngs, elc),
scrap-eaf-bat.(elc, ngs)
/
*---