*---
sets for Iron and Steel
ISTECHHIST   "Historical Existing IS routes"
    / 
    bfbof   "blast furnace basic oxygen furnace"
   dreaf   "direct reduction electric arc furnace fed by natural gas"
   screaf   "scrap electric arc furnace"
    /
*---
ISTECHNEW   "New IS routes"
/
   bfbofbat "best available tech blast furnace basic oxygen furnace"
   dreafbat "best available tech direct reduction electric arc furnace fed ny natural gas"
   screafbat   "best available tech scrap electric arc furnace"
   h2dreaf "best available tech direct reduction electric arc furnace fed ny 100% hydrogen"
   bfbofccs   "best available tech blast furnace basic oxygen furnace with CCS ammine based"
   dreafccs "best available tech direct reduction electric arc furnace with CCS ammine based"
/
*---

ISTECHHISTtoEF(ISTECHHIST,EF) "Mapping between IS technologies and fuels"
/
bfbof.(hcl, ngs, elc),
dreaf.(ngs, elc),
screaf.(elc, ngs)
/
*---
ISTECHNEWHISTtoEF(ISTECHNEW,EF) "Mapping between IS technologies and fuels"
/
bfbofbat.(hcl, ngs, elc),
dreafbat.(ngs, elc),
screafbat.(elc, ngs)
/
*---