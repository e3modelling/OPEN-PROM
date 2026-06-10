*' @title ClimateImpact (iam_compact) equations
*' @code
*' Protocol column-D cap (Derailment / D1): the TOTAL yearly additions of the shocked
*' techs (hydro+thermo = CFTECHMAP12) <= HD_D2's total, per region/year. Aggregate (not
*' per-fuel) so the model can reallocate within the envelope and spill the rest to
*' renewables (opened up by the Part-5 boost); the per-fuel cap was infeasible for small
*' systems. RHS i12CapBoundAggD2 is built in input.gms Part 4 (huge -> slack, e.g. D4),
*' so the model shape is identical for D1 and D4. Projection years only (not DATAY).

Q12CapBoundAgg(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy))$(not DATAY(YTIME)))..
    sum(PGALL$(CFTECHMAP12(PGALL,'hydro') or CFTECHMAP12(PGALL,'thermo')),
        V04NewCapElec(allCy,PGALL,YTIME))
    =L=
    i12CapBoundAggD2(allCy,YTIME);
