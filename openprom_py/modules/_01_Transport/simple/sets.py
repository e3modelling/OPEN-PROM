"""
Transport (simple) module sets.

From 01_Transport/simple/sets.gms:
- BLENDMAP(EF, EF): mapping from primary fuel to blended/alternative fuel for
  blending equations (e.g. GSL -> GSL or BGSL; GDO -> GDO, BGDO, RFO, OLQ).
- ROAD(TRANSE): road transport subsectors (PC passenger cars, PB buses, GU goods).
- SG: Gompertz curve parameters (S1, S2) for car ownership level.
"""
from core import sets as core_sets

# BLENDMAP(EF, EF): which primary fuels map to which (blended) fuel types
# Used in Q01DemFinEneTranspPerFuel to aggregate consumption by fuel.
BLENDMAP = {
    ("GSL", "GSL"), ("GSL", "BGSL"),
    ("GDO", "GDO"), ("GDO", "BGDO"), ("GDO", "RFO"), ("GDO", "OLQ"),
    ("KRS", "KRS"), ("KRS", "BKRS"),
    ("NGS", "NGS"), ("NGS", "OGS"),
}

# ROAD(TRANSE): road transport subsectors (PC, PB, GU)
# Used to distinguish road from other transport in equations.
ROAD = {"PC", "PB", "GU"}

# SG: Gompertz parameters for passenger car ownership (S1, S2)
# Used in Q01PcOwnPcLevl: ownership level = f(GDP per capita, saturation, sigma).
SG = ("S1", "S2")
