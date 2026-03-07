"""
Core sets for OPEN-PROM, built from run configuration.

Mirrors core/sets.gms. The GAMS model defines:
  - Static sets (countries, sectors, energy forms, technologies, etc.) that do not
    depend on the run; these are defined here as tuples/sets.
  - Dynamic sets that depend on compile-time symbols: runCy/runCyL (countries for
    which the model runs), ytime, an (years for which the model runs), time (same
    as an), datay (historical years), tFirst (base year). These are built in
    build_time_sets() and build_run_country_sets() and stored in CoreSets.

All set names and members match the GAMS definitions so that equation translation
remains straightforward.
"""
from __future__ import annotations

from typing import Set, Tuple, List, Mapping, Any

# -----------------------------------------------------------------------------
# Geographic coverage (GAMS: allCy, resCy)
# -----------------------------------------------------------------------------

ALLCY = (
    "LAM", "OAS", "SSA", "NEU", "MEA", "REF", "LTU", "EST", "LUX", "LVA", "CAZ",
    "AUT", "BEL", "BGR", "CHA", "CYP", "CZE", "DEU", "DNK", "ESP", "ELL", "FIN",
    "FRA", "GBR", "GRC", "HRV", "HUN", "IND", "IRL", "ITA", "JPN", "MLT", "NLD",
    "POL", "PRT", "ROU", "SVK", "SVN", "SWE", "USA", "MAR", "EGY", "RWO",
)

RESCY = (
    "LAM", "OAS", "SSA", "EST", "LTU", "LUX", "LVA", "NEU", "MEA", "REF", "CAZ",
    "AUT", "BEL", "BGR", "CHA", "CYP", "CZE", "DEU", "DNK", "ESP", "FIN", "FRA",
    "GBR", "GRC", "HRV", "HUN", "IND", "IRL", "ITA", "JPN", "MLT", "NLD", "POL",
    "PRT", "ROU", "SVK", "SVN", "SWE", "USA",
)

DSBS = (
    "IS", "NF", "CH", "BM", "PP", "FD", "EN", "TX", "OE", "OI", "SE", "AG", "HOU",
    "PC", "PB", "PT", "PN", "PA", "GU", "GT", "GN", "BU", "PCH", "NEN", "DAC", "EW",
)

TRANSE = ("PC", "PT", "PA", "PB", "PN", "GU", "GT", "GN")
TRANP = ("PC", "PT", "PA", "PB", "PN")  # passenger
TRANG = ("GU", "GT", "GN")  # goods

INDSE = ("IS", "NF", "CH", "BM", "PP", "FD", "EN", "TX", "OE", "OI")
DOMSE = ("SE", "AG", "HOU")
INDDOM = INDSE + DOMSE

# SBS = model subsectors (same as DSBS for our PoC scope; GAMS has more in ALLSBS)
SBS = DSBS

# Energy forms (demand side)
EF = (
    "HCL", "LGN", "CRO", "LPG", "GSL", "KRS", "GDO", "RFO", "OLQ", "NGS", "OGS",
    "NUC", "STE", "HYD", "WND", "SOL", "BMSWAS", "GEO", "MET", "ETH", "BGDO",
    "BGSL", "BKRS", "H2F", "ELC", "HEATPUMP",
)

# EFS = energy forms on the supply side (same as EF but used in supply/balance equations)
# STE = steam (output of CHP/heat sector); used in RestOfEnergy (03).
EFS = (
    "HCL", "LGN", "CRO", "LPG", "GSL", "KRS", "GDO", "RFO", "OLQ", "NGS", "OGS",
    "NUC", "STE", "HYD", "WND", "SOL", "BMSWAS", "GEO", "MET", "ETH", "BGDO",
    "BGSL", "BKRS", "H2F", "ELC",
)

# -----------------------------------------------------------------------------
# Supply-side sectors and mappings (GAMS: SSBS, SECtoEFPROD, EFtoEFS, TOCTEF, IMPEF, H2EF)
# Used by module 03_RestOfEnergy for energy balance (transformation, primary prod, etc.)
# -----------------------------------------------------------------------------

# SSBS = supply subsectors (electricity PG, hydrogen H2P, heat STEAMP, liquids LQD, solids SLD, gas GAS, CHP)
SSBS = ("PG", "H2P", "STEAMP", "LQD", "SLD", "GAS", "CHP")

# SECtoEFPROD(SSBS, EFS) = which energy forms are *produced* by each supply sector
# Example: LQD produces CRO, GSL, BGSL, GDO, ...; SLD produces HCL, LGN, BMSWAS.
_SECTOEFPROD_LIST = [
    ("SLD", "HCL"), ("SLD", "LGN"), ("SLD", "BMSWAS"),
    ("LQD", "CRO"), ("LQD", "GSL"), ("LQD", "BGSL"), ("LQD", "GDO"), ("LQD", "BGDO"),
    ("LQD", "RFO"), ("LQD", "LPG"), ("LQD", "KRS"), ("LQD", "BKRS"), ("LQD", "OLQ"),
    ("LQD", "MET"), ("LQD", "ETH"),
    ("GAS", "NGS"), ("GAS", "OGS"),
    ("PG", "ELC"), ("PG", "NUC"),
    ("H2P", "H2F"),
    ("STEAMP", "STE"),
]
SECtoEFPROD: Set[Tuple[str, str]] = set(_SECTOEFPROD_LIST)

# EFtoEFS(EF, EFS) = demand-side fuel EF maps to supply-side aggregate EFS (for balance reporting)
# Used in Q03ConsFinEneCountry: sum over EF where EFtoEFS(EF,EFS) and SECtoEF(INDDOM,EF).
# Most map 1:1; GAMS has (BGDO,BGSL,BKRS,ETH,BMSWAS).BMSWAS and similar. We use 1:1 for EF in EFS.
_EFTOEFS_LIST: List[Tuple[str, str]] = [(e, e) for e in EFS]
# Biofuels / other: map to parent EFS where needed (BGDO->GDO etc. already in EFS as separate)
_EFTOEFS_LIST.extend([("BGSL", "GSL"), ("BGDO", "GDO"), ("BKRS", "KRS"), ("ETH", "ETH"), ("BMSWAS", "BMSWAS")])
EFtoEFS: Set[Tuple[str, str]] = set(_EFTOEFS_LIST)

# TOCTEF = energy forms produced by power/boilers (ELC, STE). Used in Q03OutTransfCHP.
TOCTEF = ("ELC", "STE")

# IMPEF = energy forms in imports/exports (used in Q03Exp, Q03Imp). Subset of EFS.
IMPEF = ("LGN", "HCL", "CRO", "GSL", "GDO", "RFO", "LPG", "KRS", "OLQ", "NGS", "OGS", "ELC")

# H2EF = hydrogen (single element set for equation guards)
H2EF = ("H2F",)

# STEAM(EFS) = steam for equation guards
STEAM_EFS = ("STE",)

# Commented out in GAMS (03_RestOfEnergy/legacy/sets.gms): TRANSFSECS /PG,H2P,CHP,STEAMP,LQD,SLD,GAS,H2INFR/

# Transport technologies
TTECH = (
    "TGSL", "TLPG", "TGDO", "TNGS", "TELC", "TKRS", "TETH",
    "TPHEVGSL", "TPHEVGDO", "TH2F", "TCHEVGSL", "TCHEVGDO",
)

# All TECH (demand side) – for declarations that use TECH
TECH = (
    "TGSL", "TLPG", "TGDO", "TNGS", "TELC", "TKRS", "TETH", "TMET",
    "TPHEVGSL", "TPHEVGDO", "TH2F", "TCHEVGSL", "TCHEVGDO",
    "TNGSCCS", "TLGN", "THCL", "THCLCCS", "TRFO", "TOLQ", "TOGS", "TSTE",
    "TBMSWAS", "THEATPUMP", "HTDAC", "H2DAC", "LTDAC", "TEW",
)

# KPDL = polynomial distribution lag indices (a1..a6)
KPDL = ("a1", "a2", "a3", "a4", "a5", "a6")

# PGALL = power generation plant types (needed for core declarations / dummy obj)
PGALL = (
    "ATHLGN", "ATHCOAL", "ATHGAS", "ATHBMSWAS", "ATHBMSCCS", "ATHOIL",
    "PGLHYD", "PGSHYD", "PGAWND", "PGSOL", "PGCSP", "PGOTHREN", "PGANUC",
    "ATHCOALCCS", "ATHLGNCCS", "ATHGASCCS", "PGAWNO", "PGH2F",
)

# PGEF = energy forms used in power generation (EFS that appear in PGALLtoEF)
PGEF = ("LGN", "HCL", "GDO", "RFO", "NGS", "OGS", "NUC", "HYD", "BMSWAS", "SOL", "GEO", "WND", "ELC", "STE", "H2F")

# Power generation subsets and mappings (GAMS: PGREN, PGRENSW, PGSCRN, CCS, NOCCS, CCS_NOCCS, PGOTH, PGECONCHAR, PGALLtoEF)
# PGREN = renewable plants with saturation (used in share/cost equations)
PGREN = ("PGLHYD", "PGSHYD", "PGAWND", "PGSOL", "PGCSP", "PGOTHREN", "PGAWNO")
# PGREN2 = renewable + nuclear + CCS + H2 (for VmRenValue term: exclude these from fuel cost)
PGREN2 = ("PGLHYD", "PGSHYD", "PGAWND", "PGSOL", "PGCSP", "PGOTHREN", "PGAWNO", "PGANUC", "ATHCOALCCS", "ATHLGNCCS", "ATHGASCCS", "PGH2F")
# PGRENSW = solar and wind (for RES share / capex rate)
PGRENSW = ("PGSOL", "PGCSP", "PGAWND", "PGAWNO")
# PGSCRN = plants not subject to endogenous scrapping (V04IndxEndogScrap = 1)
PGSCRN = ("ATHBMSWAS", "PGLHYD", "PGSHYD", "PGAWND", "PGSOL", "PGCSP", "PGANUC", "ATHCOALCCS", "ATHLGNCCS", "ATHGASCCS", "PGAWNO", "PGOTHREN", "ATHBMSCCS", "PGH2F")
# CCS (PGALL) = plants with CCS
CCS_PG = ("ATHCOALCCS", "ATHLGNCCS", "ATHGASCCS", "ATHBMSCCS")
# NOCCS (PGALL) = plants that can have CCS but are the non-CCS version
NOCCS_PG = ("ATHLGN", "ATHCOAL", "ATHGAS", "ATHBMSWAS")
# CCS_NOCCS(PGALL, PGALL) = mapping (CCS_plant, NOCCS_plant)
_CCS_NOCCS_LIST = [("ATHLGNCCS", "ATHLGN"), ("ATHCOALCCS", "ATHCOAL"), ("ATHGASCCS", "ATHGAS"), ("ATHBMSCCS", "ATHBMSWAS")]
CCS_NOCCS: Set[Tuple[str, str]] = set(_CCS_NOCCS_LIST)
# PGOTH = other power/steam data (e.g. TOTNOMCAP, TOTCAP)
PGOTH = ("TOTCAP", "TOTNOMCAP")
# PGECONCHAR = economic character (e.g. LFT for lifetime)
PGECONCHAR = ("LFT",)
# PGALLtoEF(PGALL, EFS) = which energy form each plant uses
_PGALLTOEF_LIST = [
    ("ATHLGN", "LGN"), ("ATHLGNCCS", "LGN"),
    ("ATHCOAL", "HCL"), ("ATHCOALCCS", "HCL"),
    ("ATHOIL", "GDO"),
    ("ATHGAS", "NGS"), ("ATHGASCCS", "NGS"),
    ("ATHBMSWAS", "BMSWAS"), ("ATHBMSCCS", "BMSWAS"),
    ("PGANUC", "NUC"),
    ("PGLHYD", "HYD"), ("PGSHYD", "HYD"),
    ("PGAWND", "WND"), ("PGAWNO", "WND"),
    ("PGSOL", "SOL"), ("PGCSP", "SOL"),
    ("PGOTHREN", "GEO"),
    ("PGH2F", "H2F"),
]
PGALLtoEF: Set[Tuple[str, str]] = set(_PGALLTOEF_LIST)
# NAPtoALLSBS(NAP, SBS): which sectors belong to Trade vs NoTrade (for VmCarVal sum)
# GAMS: Trade.(FD,EN,TX,...); NoTrade.(SE,AG,HOU,...)
_NAPTOALLSBS_LIST = [
    ("Trade", "FD"), ("Trade", "EN"), ("Trade", "TX"), ("Trade", "OE"), ("Trade", "OI"), ("Trade", "NF"), ("Trade", "CH"),
    ("Trade", "IS"), ("Trade", "BM"), ("Trade", "PP"), ("Trade", "PG"), ("Trade", "BM_CO2"), ("Trade", "H2P"),
    ("Trade", "STEAMP"), ("Trade", "DAC"), ("Trade", "EW"),
]
# Add NoTrade sectors (DSBS that are not in Trade)
for _s in DSBS:
    if not any(_t[1] == _s for _t in _NAPTOALLSBS_LIST):
        _NAPTOALLSBS_LIST.append(("NoTrade", _s))
NAPtoALLSBS: Set[Tuple[str, str]] = set(_NAPTOALLSBS_LIST)

# ETYPES for elasticity parameters
ETYPES = ("a", "b1", "b2", "b3", "b4", "b5", "c", "c1", "c2", "c3", "c4", "c5", "aend", "b3end", "b4end")

# TRANSPCHAR for transport data
TRANSPCHAR = ("KM_VEH", "KM_VEH_TRUCK", "OCCUP_CAR", "RES_MEXTV", "RES_MEXTF")

# TRANSUSE
TRANSUSE = ("CAP", "LF")

# Industrial / domestic / non-energy technologies (subset of TECH)
ITECH = (
    "TGDO", "TLPG", "TKRS", "TNGS", "TNGSCCS", "TELC", "TLGN", "THCL", "THCLCCS",
    "TRFO", "TOLQ", "TOGS", "TSTE", "TH2F", "TGSL", "TBMSWAS",
)
# CCS technologies (industry)
CCSTECH = ("TNGSCCS", "THCLCCS")
# Non-energy subsectors (bunkers, etc.)
NENSE = ("PCH", "NEN", "BU")
# CDR subsectors (excluded from industry equations)
CDR = ("DAC", "EW")
# Electricity energy form (singleton for equation guards)
ELCEF = ("ELC",)
# Steam-related technologies (use PG discount in GAMS)
TSTEAM = ("TSTE",)

# SECTTECH(DSBS, TECH): which technologies are in which demand subsector
_SECTTECH_LIST = [
    # Transport
    ("PC", "TGSL"), ("PC", "TLPG"), ("PC", "TGDO"), ("PC", "TNGS"), ("PC", "TELC"),
    ("PC", "TPHEVGSL"), ("PC", "TPHEVGDO"), ("PC", "TCHEVGSL"), ("PC", "TCHEVGDO"), ("PC", "TH2F"),
    ("PB", "TLPG"), ("PB", "TGSL"), ("PB", "TGDO"), ("PB", "TNGS"), ("PB", "TELC"), ("PB", "TH2F"),
    ("GU", "TLPG"), ("GU", "TGSL"), ("GU", "TGDO"), ("GU", "TNGS"), ("GU", "TELC"), ("GU", "TCHEVGDO"), ("GU", "TH2F"),
    ("PT", "TGDO"), ("PT", "TELC"), ("GT", "TGDO"), ("GT", "TELC"),
    ("PA", "TKRS"),
    ("PN", "TGDO"), ("PN", "TH2F"), ("GN", "TGDO"), ("GN", "TH2F"),
    # Industry (INDSE)
    ("IS", "TLGN"), ("IS", "THCL"), ("IS", "TGDO"), ("IS", "TGSL"), ("IS", "TRFO"), ("IS", "TLPG"), ("IS", "TKRS"),
    ("IS", "TOLQ"), ("IS", "TNGS"), ("IS", "TOGS"), ("IS", "TELC"), ("IS", "TBMSWAS"), ("IS", "TSTE"), ("IS", "TH2F"),
    ("IS", "TNGSCCS"), ("IS", "THCLCCS"),
    ("NF", "TLGN"), ("NF", "THCL"), ("NF", "TGDO"), ("NF", "TGSL"), ("NF", "TRFO"), ("NF", "TLPG"), ("NF", "TKRS"),
    ("NF", "TOLQ"), ("NF", "TNGS"), ("NF", "TOGS"), ("NF", "TELC"), ("NF", "TBMSWAS"), ("NF", "TSTE"), ("NF", "TH2F"),
    ("CH", "TLGN"), ("CH", "THCL"), ("CH", "TGDO"), ("CH", "TGSL"), ("CH", "TRFO"), ("CH", "TLPG"), ("CH", "TKRS"),
    ("CH", "TOLQ"), ("CH", "TNGS"), ("CH", "TOGS"), ("CH", "TELC"), ("CH", "TBMSWAS"), ("CH", "TSTE"), ("CH", "TH2F"),
    ("CH", "TNGSCCS"), ("CH", "THCLCCS"),
    ("BM", "TLGN"), ("BM", "THCL"), ("BM", "TGDO"), ("BM", "TGSL"), ("BM", "TRFO"), ("BM", "TLPG"), ("BM", "TKRS"),
    ("BM", "TOLQ"), ("BM", "TNGS"), ("BM", "TOGS"), ("BM", "TELC"), ("BM", "TBMSWAS"), ("BM", "TSTE"), ("BM", "TH2F"),
    ("BM", "TNGSCCS"), ("BM", "THCLCCS"),
    ("PP", "TLGN"), ("PP", "THCL"), ("PP", "TGDO"), ("PP", "TGSL"), ("PP", "TRFO"), ("PP", "TLPG"), ("PP", "TKRS"),
    ("PP", "TOLQ"), ("PP", "TNGS"), ("PP", "TOGS"), ("PP", "TELC"), ("PP", "TBMSWAS"), ("PP", "TSTE"), ("PP", "TH2F"),
    ("FD", "TLGN"), ("FD", "THCL"), ("FD", "TGDO"), ("FD", "TGSL"), ("FD", "TRFO"), ("FD", "TLPG"), ("FD", "TKRS"),
    ("FD", "TOLQ"), ("FD", "TNGS"), ("FD", "TOGS"), ("FD", "TELC"), ("FD", "TBMSWAS"), ("FD", "TSTE"), ("FD", "TH2F"),
    ("EN", "TLGN"), ("EN", "THCL"), ("EN", "TGDO"), ("EN", "TGSL"), ("EN", "TRFO"), ("EN", "TLPG"), ("EN", "TKRS"),
    ("EN", "TOLQ"), ("EN", "TNGS"), ("EN", "TOGS"), ("EN", "TELC"), ("EN", "TBMSWAS"), ("EN", "TSTE"), ("EN", "TH2F"),
    ("TX", "TLGN"), ("TX", "THCL"), ("TX", "TGDO"), ("TX", "TGSL"), ("TX", "TRFO"), ("TX", "TLPG"), ("TX", "TKRS"),
    ("TX", "TOLQ"), ("TX", "TNGS"), ("TX", "TOGS"), ("TX", "TELC"), ("TX", "TBMSWAS"), ("TX", "TSTE"), ("TX", "TH2F"),
    ("OE", "TLGN"), ("OE", "THCL"), ("OE", "TGDO"), ("OE", "TGSL"), ("OE", "TRFO"), ("OE", "TLPG"), ("OE", "TKRS"),
    ("OE", "TOLQ"), ("OE", "TNGS"), ("OE", "TOGS"), ("OE", "TELC"), ("OE", "TBMSWAS"), ("OE", "TSTE"), ("OE", "TH2F"),
    ("OI", "TLGN"), ("OI", "THCL"), ("OI", "TGDO"), ("OI", "TGSL"), ("OI", "TRFO"), ("OI", "TLPG"), ("OI", "TKRS"),
    ("OI", "TOLQ"), ("OI", "TNGS"), ("OI", "TOGS"), ("OI", "TELC"), ("OI", "TBMSWAS"), ("OI", "TSTE"), ("OI", "TH2F"),
    # Domestic (HOU, AG, SE)
    ("HOU", "THCL"), ("HOU", "TLPG"), ("HOU", "TKRS"), ("HOU", "TGDO"), ("HOU", "TNGS"), ("HOU", "TOGS"),
    ("HOU", "TBMSWAS"), ("HOU", "TELC"), ("HOU", "TSTE"),
    ("AG", "THCL"), ("AG", "TLPG"), ("AG", "TKRS"), ("AG", "TGDO"), ("AG", "TNGS"), ("AG", "TOGS"),
    ("AG", "TBMSWAS"), ("AG", "TELC"), ("AG", "TSTE"),
    ("SE", "THCL"), ("SE", "TLPG"), ("SE", "TKRS"), ("SE", "TNGS"), ("SE", "TOGS"), ("SE", "TELC"), ("SE", "TSTE"),
    # Bunkers
    ("BU", "TGDO"), ("BU", "TRFO"), ("BU", "TKRS"), ("BU", "TH2F"),
]
SECTTECH: Set[Tuple[str, str]] = set(_SECTTECH_LIST)

# ITECHtoEF(ITECH, EF): fuels consumed by industrial technologies (GAMS ITECHtoEF)
_ITECHTOEF = [
    ("TGDO", "GDO"), ("TGDO", "BGDO"),
    ("TLPG", "LPG"),
    ("TKRS", "KRS"), ("TKRS", "BKRS"),
    ("TNGS", "NGS"), ("TNGSCCS", "NGS"),
    ("TELC", "ELC"),
    ("TLGN", "LGN"), ("THCL", "HCL"), ("THCLCCS", "HCL"),
    ("TRFO", "RFO"), ("TOLQ", "OLQ"), ("TOGS", "OGS"), ("TGSL", "GSL"), ("TGSL", "BGSL"),
    ("TSTE", "STE"), ("TH2F", "H2F"), ("TBMSWAS", "BMSWAS"),
]
ITECHtoEF: Set[Tuple[str, str]] = set(_ITECHTOEF)

# TTECHtoEF(TTECH, EF): fuels consumed by transport technologies
_TTECHTOEF = [
    ("TGSL", "GSL"), ("TGSL", "BGSL"),
    ("TLPG", "LPG"),
    ("TGDO", "GDO"), ("TGDO", "BGDO"), ("TGDO", "RFO"),
    ("TNGS", "NGS"), ("TNGS", "OGS"),
    ("TELC", "ELC"),
    ("TKRS", "KRS"), ("TKRS", "BKRS"),
    ("TETH", "ETH"),
    ("TPHEVGSL", "GSL"), ("TPHEVGSL", "BGSL"), ("TPHEVGSL", "ELC"),
    ("TPHEVGDO", "GDO"), ("TPHEVGDO", "BGDO"), ("TPHEVGDO", "ELC"),
    ("TH2F", "H2F"),
    ("TCHEVGSL", "GSL"), ("TCHEVGSL", "BGSL"),
    ("TCHEVGDO", "GDO"), ("TCHEVGDO", "BGDO"),
]
TTECHtoEF: Set[Tuple[str, str]] = set(_TTECHTOEF)

# SECtoEF(SBS, EF): link subsectors to energy forms (built from SECTTECH + TECHtoEF in GAMS)
# GAMS: loop TECH, DSBS, EF -> SECtoEF(DSBS,EF)=yes. We only need transport + INDDOM for PoC.
# Full SECtoEF from GAMS for PG, CHP, H2P, STEAMP, SLD, LQD, GAS; and for demand from SECTTECH.
_SECTOEF_SUPPLY = [
    ("PG", "LGN"), ("PG", "HCL"), ("PG", "GDO"), ("PG", "RFO"), ("PG", "NGS"), ("PG", "OGS"),
    ("PG", "NUC"), ("PG", "HYD"), ("PG", "BMSWAS"), ("PG", "SOL"), ("PG", "GEO"), ("PG", "WND"), ("PG", "H2F"),
    ("CHP", "LGN"), ("CHP", "HCL"), ("CHP", "GDO"), ("CHP", "RFO"), ("CHP", "NGS"), ("CHP", "OGS"),
    ("CHP", "NUC"), ("CHP", "HYD"), ("CHP", "BMSWAS"), ("CHP", "SOL"), ("CHP", "GEO"), ("CHP", "WND"),
    ("H2P", "HCL"), ("H2P", "LGN"), ("H2P", "RFO"), ("H2P", "GDO"), ("H2P", "NGS"), ("H2P", "OGS"),
    ("H2P", "NUC"), ("H2P", "BMSWAS"), ("H2P", "SOL"), ("H2P", "WND"), ("H2P", "ELC"),
    ("STEAMP", "HCL"), ("STEAMP", "LGN"), ("STEAMP", "GDO"), ("STEAMP", "RFO"), ("STEAMP", "LPG"),
    ("STEAMP", "KRS"), ("STEAMP", "NGS"), ("STEAMP", "OGS"), ("STEAMP", "OLQ"), ("STEAMP", "NUC"),
    ("STEAMP", "GEO"), ("STEAMP", "BMSWAS"), ("STEAMP", "ELC"), ("STEAMP", "H2F"),
]
# Demand side: from SECTTECH + TTECHtoEF (transport) or ITECHtoEF (industry/domestic)
_SECTOEF_DEMAND: List[Tuple[str, str]] = []
for (dsbs, tech) in SECTTECH:
    for (t, ef) in TTECHtoEF:
        if t == tech:
            _SECTOEF_DEMAND.append((dsbs, ef))
    for (t, ef) in ITECHtoEF:
        if t == tech:
            _SECTOEF_DEMAND.append((dsbs, ef))
# INDDOM (industry/tertiary) x ELC and HEATPUMP for core preloop
for sbs in INDDOM:
    _SECTOEF_DEMAND.append((sbs, "ELC"))
    _SECTOEF_DEMAND.append((sbs, "HEATPUMP"))
# Supply sector to EFS: add SECtoEFPROD so (LQD, CRO), (SLD, HCL), (GAS, NGS), etc. exist for Q03InpTotTransf
SECtoEF: Set[Tuple[str, str]] = set(_SECTOEF_SUPPLY) | SECtoEFPROD | set(_SECTOEF_DEMAND)

# PLUGIN(TECH)
PLUGIN = {"TPHEVGSL", "TPHEVGDO"}

# CHYBV(TECH) conventional hybrids
CHYBV = {"TCHEVGSL", "TCHEVGDO"}

# RENEF(TECH) renewable technologies in demand side
RENEF = {"TELC", "TPHEVGSL", "TPHEVGDO", "TH2F", "TCHEVGSL", "TCHEVGDO", "TBMSWAS", "TNGSCCS", "THCLCCS", "HTDAC", "H2DAC", "LTDAC", "TEW"}

# NAP (national allocation plan) – for core variables VmCarVal
NAP = ("Trade", "NoTrade")

# WEF (imported energy forms)
WEF = ("WHCL", "WCOKE", "WCRO", "WNGS", "WLGN", "WGSL", "WGDO", "WRFO", "WH2F")


def _techs_per_subsector() -> Mapping[str, int]:
    """TECHS(DSBS) = number of technologies in transport subsectors."""
    out: dict = {}
    for dsbs in TRANSE:
        out[dsbs] = sum(1 for (d, t) in SECTTECH if d == dsbs)
    return out


TECHS = _techs_per_subsector()


def build_time_sets(
    start_horizon: int,
    end_horizon: int,
    start_y: int,
    end_y: int,
    base_y: int,
) -> dict:
    """
    Build time-related sets as ordered lists and sets.
    Returns dict with: ytime, an, time, datay, tFirst, year_to_ord, ord_to_year.
    """
    ytime = [y for y in range(start_horizon, end_horizon + 1)]
    an = [y for y in range(start_y, end_y + 1)]
    time_set = set(an)
    datay = [y for y in range(start_horizon, base_y + 1)]
    tFirst = {base_y}
    year_to_ord = {y: i + 1 for i, y in enumerate(ytime)}
    ord_to_year = {i + 1: y for i, y in enumerate(ytime)}
    return {
        "ytime": ytime,
        "an": an,
        "time": time_set,
        "datay": set(datay),
        "tFirst": tFirst,
        "year_to_ord": year_to_ord,
        "ord_to_year": ord_to_year,
    }


def build_run_country_sets(
    countries: tuple,
    dev_mode: int = 0,
) -> dict:
    """
    runCy / runCyL: countries for which the model runs.
    If dev_mode == 0 (research), runCy = resCy; else runCy = config countries.
    """
    run_cy = tuple(countries) if dev_mode != 0 else RESCY
    return {
        "runCy": run_cy,
        "runCyL": run_cy,
    }


class CoreSets:
    """
    Container for all core sets and time/country subsets.
    Build with CoreSets.from_config(config).
    """

    def __init__(
        self,
        ytime: List[int],
        an: List[int],
        time: Set[int],
        datay: Set[int],
        tFirst: Set[int],
        year_to_ord: Mapping[int, int],
        ord_to_year: Mapping[int, int],
        runCy: tuple,
        runCyL: tuple,
    ):
        self.ytime = ytime
        self.an = an
        self.time = time
        self.datay = datay
        self.tFirst = tFirst
        self.year_to_ord = year_to_ord
        self.ord_to_year = ord_to_year
        self.runCy = runCy
        self.runCyL = runCyL

    @classmethod
    def from_config(cls, config: Any) -> "CoreSets":
        """Build from PoCConfig (has start_horizon, end_horizon, start_y, end_y, base_y, countries)."""
        time_data = build_time_sets(
            config.start_horizon,
            config.end_horizon,
            config.start_y,
            config.end_y,
            config.base_y,
        )
        run_data = build_run_country_sets(
            tuple(config.countries),
            dev_mode=0,  # PoC: use config countries
        )
        # Override: for PoC we want runCy = config countries
        run_data["runCy"] = tuple(config.countries)
        run_data["runCyL"] = tuple(config.countries)
        return cls(
            ytime=time_data["ytime"],
            an=time_data["an"],
            time=time_data["time"],
            datay=time_data["datay"],
            tFirst=time_data["tFirst"],
            year_to_ord=time_data["year_to_ord"],
            ord_to_year=time_data["ord_to_year"],
            runCy=run_data["runCy"],
            runCyL=run_data["runCyL"],
        )

    def ord(self, y: int) -> int:
        """1-based position of year y in ytime (GAMS ord(ytime))."""
        return self.year_to_ord.get(y, 0)

    def in_time(self, y: int) -> bool:
        """True if y is in the solving horizon (time set)."""
        return y in self.time

    def in_datay(self, y: int) -> bool:
        """True if y is historical (data year)."""
        return y in self.datay

    def base_year(self) -> int:
        return next(iter(self.tFirst))


# Scalar TF = order of base year in ytime (1-based)
def scalar_TF(core_sets: CoreSets) -> int:
    return core_sets.ord(core_sets.base_year())
