"""
Module 03_RestOfEnergy (legacy): postsolve — fix solution values for the next time step.

Mirrors modules/03_RestOfEnergy/legacy/postsolve.gms. After solving for a given year,
we fix the solution values (variable .value) of all RestOfEnergy variables so that
in the next iteration (next year) they are treated as constants. This is required
for multi-year sequential solving where lagged variables (e.g. V03OutTransfRefSpec(ytime-1))
must use the previously solved values.

Commented out in GAMS: *V03CapRef.FX(runCyL,YTIME)$TIME(YTIME) = V03CapRef.L(runCyL,YTIME)$TIME(YTIME);
"""


def apply_rest_of_energy_postsolve(m, core_sets_obj, year) -> None:
    """
    Fix all RestOfEnergy variables at the given year to their current solution value.

    Called after opt.solve() for that year. For each variable we iterate over
    its indices and fix the component when the last index (time) equals the solved year.
    """
    var_names = (
        "V03Transfers",
        "V03InputTransfRef",
        "V03InputTransfSolids",
        "V03InputTransfGasses",
        "V03ProdPrimary",
        "VmConsFinEneCountry",
        "V03OutTransfRefSpec",
        "V03OutTransfGasses",
        "V03OutTransfSolids",
        "V03ConsGrssInlNotEneBranch",
    )
    for vname in var_names:
        var = getattr(m, vname, None)
        if var is None:
            continue
        try:
            for idx in var:
                if not isinstance(idx, tuple):
                    if idx == year:
                        val = var[idx].value
                        if val is not None:
                            var[idx].fix(val)
                    continue
                if idx[-1] == year:
                    val = var[idx].value
                    if val is not None:
                        var[idx].fix(val)
        except Exception as _exc:
            logger.debug("Skipped: %s", _exc)
