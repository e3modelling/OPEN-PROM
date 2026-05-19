*' @title ClimateImpact (iam_compact) sets
*' @code

set CFMACRO12   "Climate-impact macro regions"
    / NA, SA, EU, AF, AS /
;

*--- PROM region -> macro region mapping ---
*    Boundary judgements:
*      CAZ -> NA (Canada-dominant)
*      REF -> EU (IAM convention)
*      MEA -> AF (MENA convention)
set CFPROMMACRO12(allCy, CFMACRO12)  "PROM region -> macro region mapping" /
    USA.NA, CAZ.NA,
    LAM.SA,
    AUT.EU, BEL.EU, BGR.EU, CYP.EU, CZE.EU, DEU.EU, DNK.EU, ESP.EU,
    EST.EU, FIN.EU, FRA.EU, GBR.EU, GRC.EU, HRV.EU, HUN.EU, IRL.EU,
    ITA.EU, LTU.EU, LUX.EU, LVA.EU, MLT.EU, NEU.EU, NLD.EU, POL.EU,
    PRT.EU, REF.EU, ROU.EU, SVK.EU, SVN.EU, SWE.EU,
    SSA.AF, MEA.AF,
    CHA.AS, IND.AS, JPN.AS, OAS.AS
/ ;

set CFTECHGRP12 "Climate-impact PG technology groups"
    / hydro, thermo /
;

*--- PGALL tech -> CF group. Wind/solar/CSP/geothermal/H2-fired not impacted.
set CFTECHMAP12(PGALL, CFTECHGRP12) "PGALL technology -> CF group" /
    PGLHYD.hydro,    PGSHYD.hydro,
    ATHCOAL.thermo,  ATHLGN.thermo,    ATHGAS.thermo,    ATHOIL.thermo,
    ATHBMSWAS.thermo,
    ATHCOALCCS.thermo, ATHLGNCCS.thermo, ATHGASCCS.thermo, ATHBMSCCS.thermo,
    PGANUC.thermo
/ ;

set CFPERIOD12  "Climate-impact periods"  / P1, P2 /  ;
