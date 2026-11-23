## Climate feedback on buildings demand (feedback loop 1)

This note describes the optional feedback from climate to buildings energy demand.
Heating and cooling degree days (HDD/CDD) scale the climate-sensitive part of
household (`HOU`) and services (`SE`) demand. It applies only to the `technology`
realization of `02_Industry`.

## 1. Switch

In `main.gms`:

```
$setglobal climFeedback off   !! on / off: degree-day feedback on buildings demand
```

or on the command line: `gams main.gms --climFeedback=on ...`.

* `off`: the two equations are compiled exactly as before, so results are identical
  to a model without the feedback.
* `on`: the climate factors are compiled into the equations. With the neutral
  default inputs (ratios = 1, shares = 0) every factor is exactly 1 and results
  are unchanged.

## 2. Method

Buildings demand is recursive: this year = last year × growth factors. A climate
index is built per country, subsector and year:

```
ClimIdx(HDD,t) = 1 + ShHeat * (DD(HDD,t) ^ ElDD(HDD) - 1)
ClimIdx(CDD,t) = 1 + ShCool * (DD(CDD,t) ^ ElDD(CDD) - 1)
```

`DD(·,t)` is the degree-day ratio to 2023 and `ClimIdx = 1` outside the projection
years (`An`), so 2023 and all historical/calibration years are unaffected.

One multiplicative factor is added to each equation in
`modules/02_Industry/technology/equations.gms`, right after the lagged term:

| Equation | Variable | Factor |
|---|---|---|
| `Q02DemSubUsefulSubsec` | `V02DemSubUsefulSubsec` (heating etc.) | `ClimIdx(HDD,t) / ClimIdx(HDD,t-1)` |
| `Q02UsefulElecNonSubIndTert` | `V02UsefulElecNonSubIndTert` (incl. cooling) | `ClimIdx(CDD,t) / ClimIdx(CDD,t-1)` |

Because the equations are recursive, the year-on-year ratio makes the effect
cumulative: after `n` years the demand level carries `ClimIdx(t)/ClimIdx(2023)`,
with no double counting. The factor is 1 when the lagged index is 0.

## 3. Parameters (`02_Industry/technology`)

| Parameter | Meaning | Default |
|---|---|---|
| `DDTYPE` | set `/HDD, CDD/` | |
| `i02ClimDD(DDTYPE,allCy,YTIME)` | degree-day ratio to 2023 (1) | 1 |
| `i02ShHeat(allCy,DSBS)` | space-heating share of `V02DemSubUsefulSubsec` (1) | 0 |
| `i02ShCool(allCy,DSBS)` | cooling share of `V02UsefulElecNonSubIndTert` (1) | 0 |
| `i02ElDD(DDTYPE)` | elasticity of demand to degree days (1) | HDD 1, CDD 1 |
| `i02ClimIdx(allCy,DSBS,DDTYPE,YTIME)` | climate index (1) | 1 |

`i02ClimIdx` is written to `blabla.gdx` with all other symbols, so on and off runs
can be compared there.

## 4. Input files

Both are read only when `climFeedback == on`. Lookup order (first match wins):
`./<file>`, then `./data/<file>`, then the neutral template in
`modules/02_Industry/technology/templates/`. The file actually used is written to
the GAMS log.

* `iClimDegDays.csv`: rows `DDTYPE.region`, year columns, ratio of degree days to
  2023. Source: RIME, SSP2, population-weighted. Missing or zero entries stay 1.
* `iClimShares.csv`: rows `region.subsector`, columns `HDD` (heating share) and
  `CDD` (cooling share). Source: IEA Energy End-uses and Efficiency Indicators.
  Only `HOU` and `SE` are used; everything else is 0.

The templates are neutral placeholders.

### Generating `iClimDegDays.csv` with RIME

The VS Code task **RUN CLIMATE EMULATOR** (tutorial 13) can produce the file from
a finished run:

1. MAGICC/CICERO turns `runs/<run>/emissions.csv` into a median GSAT pathway.
2. `scripts/tools/rimeDegreeDays.py` looks up, for each year, the degree days of
   every country at that year's warming level. It uses RIME's nearest
   (year, warming level) lookup for the chosen SSP, the same method as
   `rime.table_impacts_gwl`. It then writes `DD(t)/DD(2023)`.
3. The result is `runs/<run>/EmissionsOutput-<model>/iClimDegDays.csv`. Copy it
   to `data/` and run OPEN-PROM with `--climFeedback=on`.

Settings in `config.json`:

```json
"rime": {
  "cdd_file": "C:/.../sdd_c_18p3_COUNTRIES.nc",
  "cdd_variable": "sdd_c_18p3|Hazard|Absolute|Population weighted",
  "hdd_file": null,
  "hdd_variable": null,
  "ssp": "SSP2",
  "regionmapping": "C:/.../regionmappingOPDEV5.csv"
}
```

* `cdd_file` is a RIME region dataset (dimensions gwl, year, ssp, region), as
  written by RIME's `generate_aggregated_inputs.py` from the Climate Solutions
  Explorer tables (Werning et al. 2024, doi:10.5281/zenodo.14524342). Cooling
  degree days are available with base temperatures 26, 24, 20 and 18.3 °C
  (`sdd_c`, `sdd_c_24p0`, `sdd_c_20p0`, `sdd_c_18p3`). In RIME, `cdd` means
  *consecutive dry days*, not cooling degree days.
* **That dataset has no heating degree days.** HDD rows are written only if
  `hdd_file` and `hdd_variable` point to a RIME-format dataset with HDD.
  Otherwise HDD stays 1 and only the cooling side of the feedback is active.
* `regionmapping` (columns `CountryCode`, `RegionCode`) lets aggregate regions
  (LAM, OAS, RWO, …) be filled with the unweighted mean of their member
  countries. Without it, those regions stay 1.
* To rerun only this step on an existing emulator output, use
  `--steps degreedays`.

## 5. Assumptions

* No adaptation: the response of demand to degree days does not change over time.
* Shares are fixed at their 2023 values.
* Air-conditioning uptake comes only through the existing income/activity
  elasticities. The CDD factor scales the cooling share. It does not add new AC
  ownership.
* The `legacy` Industry realization is not affected.
