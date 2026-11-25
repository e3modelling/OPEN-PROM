## Climate impacts of OPEN-PROM runs with MAGICC and RIME, and the buildings climate feedback

This guide turns an OPEN-PROM run into climate impacts per region and per country:
heat, cooling demand, precipitation, water and air quality. Part B shows how one of
these impacts, cooling degree days, feeds back into OPEN-PROM's buildings demand.

The chain is **OPEN-PROM → MAGICC → RIME**:

1. OPEN-PROM writes the run's emissions (`runs/<run>/emissions.csv`).
2. MAGICC, run through IIASA's climate-assessment, turns them into a global
   temperature pathway (median GSAT).
3. RIME, IIASA's Rapid Impact Model Emulator, reads gridded impact maps at the
   warming level of each year.
4. The maps are averaged over the OPEN-PROM regions and written as IAMC tables, or,
   for the feedback, as an OPEN-PROM input file.

MAGICC and RIME are used as external tools at pinned versions; their repositories
stay unchanged. All OPEN-PROM scripts are in `scripts/tools`.

# Part A – Climate impacts

## 1. Install once (WSL)

MAGICC needs Linux, so everything runs in WSL. From the OPEN-PROM root, in WSL:

```
bash scripts/tools/installClimateAssessmentToolWSL.sh   # MAGICC via climate-assessment (tutorial 13)
bash scripts/tools/installRimeWSL.sh                    # RIME
```

`installRimeWSL.sh` does three things:

* clones RIME at a tested commit to `../rime`, next to OPEN-PROM;
* creates `../rime/.venv` with Python 3.10 and the pinned packages of
  `scripts/tools/rime-requirements.txt`. RIME needs Python 3.10, and
  climate-assessment 3.11 or later, so they use separate environments;
* creates `../rime-data`, the download cache for impact maps, country tables and
  Natural Earth.

The OPEN-PROM region mapping (`regionmappingOPDEV5.csv`) is taken from mrprom
automatically.

## 2. Run

VS Code task **RUN CLIMATE EMULATOR**: pick `magicc`, the run folder, the step
`impacts` and the indicators. From the OPEN-PROM root, the same command is:

```
Rscript scripts/tools/runClimateModels.r --runFolder <run> --steps impacts --indicators tr20,hwd_95_10,wsi
```

| Option | Meaning |
|---|---|
| `--runFolder <run>` | run folder under `runs/`; `latest` = newest folder with an `emissions.csv` |
| `--indicators a,b,c` | indicators from section 3; `all` = every indicator; without it, `climate_impacts.indicators` in `config.json` |
| `--tables true` | also country results (section 4); default `climate_impacts.tables` |
| `--steps` | `impacts` = MAGICC (only if the run has no MAGICC output yet), then RIME impacts · `emulator` = MAGICC only · `all` / `rime` = buildings feedback input (Part B) |

MAGICC runs once per run folder. Later runs, for other indicators or for the
feedback, reuse its output.

## 3. Indicators

All 45 gridded indicators of the Climate Solutions Explorer data (SSP2, global
warming levels 1.2–3.5 °C) can be selected:

| Group | Indicators | Weighting (`auto`) |
|---|---|---|
| Energy | `sdd_c_18p3`, `sdd_c_20p0`, `sdd_c_24p0`, `sdd_c`: cooling degree days, base 18.3, 20, 24, 26 °C | population |
| Heat | `hw_<pct>_<days>`: heatwave events; `hwd_<pct>_<days>`: heatwave days (pct 95, 97, 99; days 3, 5, 7, 10); `tr20`: tropical nights | population |
| Precipitation | `cdd`: consecutive dry days (not cooling degree days); `pr_r10`, `pr_r20`: heavy-rain days; `pr_r95p`, `pr_r99p`: extreme rainfall; `sdii`: rain intensity | population |
| Water | `dri`, `dri_qtot`: drought intensity; `iavar`, `iavar_qtot`: interannual variability; `seas`, `seas_qtot`: seasonality; `wsi`: water stress index. Data up to 3.0 °C | area |
| Land | `lc`: habitat land-cover change (SSP1, SSP2, SSP5) | area |
| Air | `pm2p5_2030`, `pm2p5_2050`: PM2.5 concentration (four warming levels) | population |

Names, units and descriptions come from RIME's `indicator_params.yml`.

## 4. Outputs

Written to `runs/<run>/EmissionsOutput-magicc/`:

| File | Content |
|---|---|
| `emissions_alloutput.xlsx`, `Global_Mean_Temperature.png` | MAGICC temperature (percentiles) and plot |
| `rime_maps_<indicator>.nc` | RIME maps, 0.5° grid (0.25° for `lc`), one map per RIME year |
| `rime_impacts.mif`, `rime_impacts.csv` | the 39 OPEN-PROM regions and World, every RIME year (2020–2100, 5-yearly) |
| `rime_impacts_countries.mif`, `.csv` | with `--tables true`: every country |

**Regional results** use the variable `Climate impacts|RIME|<indicator>|Population weighted`,
or `|Area weighted`. The `.mif` loads into the OPEN-PROM reporting and comparison
tools; the `.csv` has the same table with commas.

**Country results** follow RIME's own table route and variable selection, for each
indicator:

| Variable (after `Climate impacts\|RIME\|<indicator>`) | Meaning |
|---|---|
| `\|Hazard\|Absolute\|Population weighted` | indicator value, population-weighted |
| `\|Hazard\|Absolute\|Land area weighted` | indicator value, area-weighted |
| `\|Hazard\|Risk score\|Population weighted` | RIME hazard score, where the data provide it (not e.g. for `tr20`) |
| `\|Exposure\|Population`, `\|Exposure\|Population\|%` | people exposed, and their share of the population |
| `\|Exposure\|Land area` | land area exposed |

Each indicator's country table (about 55 MB) is read from Zenodo once and cached in
`../rime-data/tables`. There are no country tables for `lc` and `pm2p5`.

## 5. Method

* **Temperature.** RIME uses MAGICC's median GSAT (`GMTPathway`).
* **Maps.** For each RIME year, the map at that year's warming level is taken
  (`map_transform_gwl_wrapper`), interpolating between the warming levels of the
  data in 0.01 °C steps.
* **Validity.** No value is given:
  * for temperatures outside the data (1.2–3.5 °C; 1.2–3.0 °C for water);
  * after an overshoot. RIME is not valid once temperature falls more than
    0.15 °C below its peak, so maps stop at the last year that passes that check,
    e.g. 2060.
* **Regions.** Countries (Natural Earth 1:50m) are grouped into the 39 OPEN-PROM
  regions. Each grid cell counts with the fraction of it that lies in the region,
  from a 10×10 sub-sampling, so small countries such as Malta and Luxembourg are
  kept. World covers all mapped land.
* **Weights.** `auto` uses population weights for indicators about people (energy,
  heat, precipitation, air) and area weights for water and land. Population is the
  SSP2 gridded population of each year (`pop_grid`, ISIMIP `ssp2soc`); without
  that file, area weights are used. `climate_impacts.weighting` can force
  `population` or `area` for all indicators.
* **Country tables.** Each table runs through RIME's `loop_interpolate_gwl`,
  `RegionArray` and `table_impacts_gwl` with the same median GSAT and validity rules.
* **Regions vs countries.** The two routes start from different data products: per-cell
  maps averaged by OPEN-PROM, and country values computed by the Climate Solutions
  Explorer. For a single-country region they agree closely for some countries (DEU,
  IND, USA within about 3% in a test) but can differ by 10–50% for others (ESP, ITA).
  Use one route per analysis; don't mix them.

# Part B – Buildings climate feedback (feedback loop 1)

## 6. What it does

Heating and cooling degree days (HDD/CDD) scale the climate-sensitive part of
household (`HOU`) and services (`SE`) energy demand. It applies only to the
`technology` realization of `02_Industry`, and is switched in `main.gms`:

```
$setglobal climFeedback off   !! on / off: degree-day feedback on buildings demand
```

or on the command line: `gams main.gms --climFeedback=on ...`.

* `off`: the two equations are compiled exactly as before, so results are identical
  to a model without the feedback.
* `on`: the climate factors are compiled into the equations. With the neutral
  default inputs (ratios = 1, shares = 0) every factor is exactly 1 and results
  are unchanged.

## 7. Formulation

Buildings demand is recursive: this year = last year × growth factors. A climate
index is built per region, subsector and year:

```
ClimIdx(HDD,t) = 1 + ShHeat * (DD(HDD,t) ^ ElDD(HDD) - 1)
ClimIdx(CDD,t) = 1 + ShCool * (DD(CDD,t) ^ ElDD(CDD) - 1)
```

`DD(·,t)` is the degree-day ratio to 2023 (section 9) and `ClimIdx = 1` outside the
projection years (`An`), so 2023 and all historical and calibration years are
unaffected.

One multiplicative factor is added to each equation in
`modules/02_Industry/technology/equations.gms`, right after the lagged term:

| Equation | Variable | Factor |
|---|---|---|
| `Q02DemSubUsefulSubsec` | `V02DemSubUsefulSubsec` (heating etc.) | `ClimIdx(HDD,t) / ClimIdx(HDD,t-1)` |
| `Q02UsefulElecNonSubIndTert` | `V02UsefulElecNonSubIndTert` (incl. cooling) | `ClimIdx(CDD,t) / ClimIdx(CDD,t-1)` |

Because the equations are recursive, the year-on-year ratio makes the effect
cumulative: after `n` years the demand level carries `ClimIdx(t)/ClimIdx(2023)`,
with no double counting. The factor is 1 when the lagged index is 0.

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

## 8. Input files

Both are read only when `climFeedback == on`. Lookup order (first match wins):
`./<file>`, then `./data/<file>`, then the neutral template in
`modules/02_Industry/technology/templates/`. The file actually used is written to
the GAMS log.

* `iClimDegDays.csv`: header `dummy,dummy,<years>`, rows `HDD,<region>,…` and
  `CDD,<region>,…`; ratio of degree days to 2023 (section 9). Missing or zero
  entries stay 1.
* `iClimShares.csv`: header `dummy,dummy,HDD,CDD`, rows `<region>,HOU,…` and
  `<region>,SE,…`; heating share (`HDD`) and cooling share (`CDD`) (section 10).
  Only `HOU` and `SE` are used; everything else is 0.

The templates are neutral placeholders.

## 9. Producing `iClimDegDays.csv`

With MAGICC and RIME installed (section 1), run the VS Code task with the step `all`,
or:

```
Rscript scripts/tools/runClimateModels.r --runFolder <run> --steps all    # MAGICC + degree days
Rscript scripts/tools/runClimateModels.r --runFolder <run> --steps rime   # degree days from an existing MAGICC output
```

This produces the RIME maps of cooling degree days (`sdd_c_24p0`, base 24 °C) and their
population-weighted means per OPEN-PROM region, exactly as in Part A (section 5).
`climDegreeDays.py` then turns them into the model input, written to
`runs/<run>/EmissionsOutput-magicc/`:

| File | Content |
|---|---|
| `iClimDegDays.csv` | the OPEN-PROM input |
| `iClimDegDays_absolute.csv` | annual degree days per region (°C·days) |
| `iClimDegDays_diagnostics.png` | ratios over time per region |

Copy `iClimDegDays.csv` (and `iClimShares.csv`) to `data/` and run OPEN-PROM with
`--climFeedback=on`.

**From RIME years to the model input:**

* **Base temperature.** 24 °C is close to the indoor temperatures at which air
  conditioning is actually switched on, so mild days that need no cooling are not
  counted.
* **Annual values, 2023–2100.** Linear between the 5-year RIME years. After the
  last emulated year, for example 2060 in an overshoot run, the last value is held.
* **Ratio to 2023:** `min(cap, 1 + (DD(t) − DD(2023)) / max(DD(2023), floor))`.
  * It is exactly 1 in 2023, so there is no jump in OPEN-PROM's first projection
    year.
  * It equals `DD(t)/DD(2023)` wherever `DD(2023) ≥ floor`.
  * The floor is 50 °C·days for CDD and 100 for HDD; the cap is 3.
  * The regions where the floor or cap is active are printed. At a 24 °C base, most
    of central and northern Europe has fewer than 50 CDD, so their ratios are damped.
* **No heating degree days** exist in the Climate Solutions Explorer data. HDD = 1,
  and only the cooling side of the feedback is active.

## 10. Producing `iClimShares.csv`

```
python scripts/tools/climShares.py --regionmapping <regionmappingOPDEV5.csv> --out data/iClimShares.csv
```

This runs in the RIME environment or any Python with pandas and openpyxl. It writes
`iClimShares.csv` and `iClimShares_sources.csv`, which gives the source, year and
confidence of every value. Both shares are in final energy:

* **HDD column** (`i02ShHeat`): space heating / (space heating + water heating +
  cooking), all fuels.
* **CDD column** (`i02ShCool`): space-cooling electricity / (electricity − electricity
  for space heating, water heating and cooking).

| Regions | HOU | SE |
|---|---|---|
| EU-27 | Eurostat `nrg_d_hhq` (API, `--eu-year`, default 2023) | JRC-IDEES 2021, tertiary workbook, read directly from the country zips (CC BY 4.0) |
| others | `scripts/tools/climShares_manual.csv`: one row per value, with source and confidence | same |

A row in the manual file also overrides the EU data. Regions without data are
written as 0, meaning no climate effect, and the script lists them. Nine non-EU
regions (GBR, JPN, CAZ, LAM, OAS, SSA, MEA, NEU, REF) have no sourced values yet;
`scripts/tools/climShares_IEA_prompt.md` is a prompt for filling them from the IEA
Energy End-uses and Efficiency Indicators.

## 11. Feedback assumptions

* No adaptation: the response of demand to degree days does not change over time.
* Shares are fixed at their latest observed values.
* Air-conditioning uptake comes only through the existing income/activity
  elasticities. The CDD factor scales the cooling share. It does not add new AC
  ownership.
* The `legacy` Industry realization is not affected.

# Settings and sources

## 12. Settings (`config.json`, defaults in `config.template.json`)

```json
"paths": { "climate_assessment_path": "../climate-assessment",
           "rime_path": "../rime", "rime_data_path": "../rime-data" },
"climate_impacts": { "indicators": ["sdd_c_24p0", "tr20", "hwd_95_10", "wsi"],
                     "weighting": "auto", "tables": false },
"climate_feedback": { "ssp": "SSP2", "cdd_indicator": "sdd_c_24p0", "hdd_indicator": null,
                      "pop_grid": null, "regionmapping": null,
                      "floor_cdd": 50, "floor_hdd": 100, "cap": 3.0 }
```

`climate_feedback.pop_grid` (the population file) and `regionmapping` (another
mapping than mrprom's) apply to both impacts and the feedback.

## 13. Data and sources

| Data | Source | Licence |
|---|---|---|
| Impact maps and country tables | Werning et al. (2024), *Climate Solutions Explorer – hazard, impacts and exposure data*, v1.1, [doi:10.5281/zenodo.14524342](https://zenodo.org/records/14524342) | CC BY 4.0 |
| Emulator | RIME, [github.com/iiasa/rime](https://github.com/iiasa/rime), commit `9f52c23` | GPL-3.0 |
| Temperature | MAGICC v7.5.3 via IIASA climate-assessment v0.1.6 (tutorial 13) | |
| Country borders | Natural Earth, Admin 0 countries, 1:50m | public domain |
| Population | ISIMIP3b, SSP2 (`ssp2soc`), 0.5°, annual | |
| End-use shares | Eurostat `nrg_d_hhq`; JRC-IDEES 2021; EIA RECS 2020 and CBECS 2018; IEA reports (section 10) | |
