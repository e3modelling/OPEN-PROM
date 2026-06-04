
# Soft-Linking Tutorial: OPEN-PROM ↔ MAgPIE (coupling-channel)

This guide explains how to run the soft-coupling between the **OPEN-PROM** energy-system model and the **MAgPIE** land-use model via the **coupling-channel** approach — the mif-based interface that MAgPIE already exposes for REMIND (`c56_pollutant_prices = "coupling"`, `c60_2ndgen_biodem = "coupling"`).

Two R functions (in `postprom/R/couplePromWithMagpie.R`) do the data exchange:

* `couplePromToMagpie()` — exports OPEN-PROM carbon price + bioenergy demand to a REMIND-style `.mif` that MAgPIE consumes
* `coupleMagpieToProm()` — reads MAgPIE's `report.mif` and writes `iPrices_magpie.csv` (biomass price for round-2) and `iEmissions_magpie.mif` (AFOLU emissions, 200 variables, IAMC mif format) for OPEN-PROM

All of this is orchestrated by `task_id == 7` in `start.R` (the body is in `scripts/tasks/task7SoftLinkMagpie.R`).

---

## Model Integration Switch (OPEN-PROM side)

A global GAMS flag toggles whether OPEN-PROM reads MAgPIE-derived biomass prices:

```gams
$setGlobal link2MAgPIE on
```

`modules/08_Prices/legacy/input.gms` conditionally reads the price table only when the switch is on:

```gams
$ifthen %link2MAgPIE% == on
table iPricesMagpie(allCy,SBS,YTIME)
$ondelim
$include "./iPrices_magpie.csv"
$offdelim
;
$endif
```

In the **preloop** phase, the biomass fuel price is fixed to the MAgPIE-supplied value:

```gams
$IF %link2MAgPIE% == on
VmPriceFuelSubsecCarVal.FX(runCy,SBS,"BMSWAS",YTIME)$(An(YTIME)) = iPricesMagpie(runCy,SBS,YTIME);
```

And the price-formation equation in `modules/08_Prices/legacy/equations.gms:21` excludes `BMSWAS` from the regular price-recursion when the switch is on (`$(not sameas("BMSWAS",EF))`).

The reverse-direction switch on the MAgPIE side is triggered by environment variables — `magpie/start.R` sets `cfg$gms$c56_pollutant_prices = "coupling"` and `cfg$gms$c60_2ndgen_biodem = "coupling"` when `OPENPROM_COUPLING_MIF` is defined. With the env-vars unset, MAgPIE's default behaviour is unchanged.

---

## R functions

### 1. OPEN-PROM → MAgPIE

```r
library(postprom)
couplePromToMagpie(
  gdxPath        = "path/to/blabla.gdx",          # OPEN-PROM round-1 gdx
  outMifPath     = "path/to/openprom_coupling.mif",
  scenario       = "SSP2-PkBudg650",              # must match MAgPIE side
  nonCo2Mode     = "gwp",                         # "gwp" (default) or "zero"
  deflator15to17 = 1.04                           # US$2015 -> US$2017
)
```

What it does:

* **CO2 price**: extracts `VmCarVal[,"TRADE",]` (US$2015/t CO2), bioenergy-weighted-averaged 39 → 12 h12, deflated US$2015→US$2017
* **Bioenergy demand**: weighted blend of three OPEN-PROM 2nd-gen carriers from `V03ProdPrimary` (Mtoe/yr) — `0.4 × BMSWAS + 0.6 × BGSL + 0.6 × BKRS` (raw 2G feedstock + 2G biogasoline + 2G biokerosene). Summed 39 → 12 h12, converted Mtoe/yr → EJ/yr (× 0.041868)
* **Non-CO2 prices**: `Price|N2O` and `Price|CH4` derived from CO2 via AR6 GWP100 (273 / 27) when `nonCo2Mode = "gwp"`, or set to zero when `"zero"` — MAgPIE requires all three GHG prices present
* **Aggregation**: OPEN-PROM's 39 countries → MAgPIE's 12 h12 regions (EU-28 → `EUR`, the other 11 countries map 1:1)
* **Output**: REMIND-style `.mif` with 4 variables × 12 regions × 91 years, consumed by MAgPIE via `cfg$path_to_report_ghgprices` / `cfg$path_to_report_bioenergy`

### 2. MAgPIE → OPEN-PROM

```r
coupleMagpieToProm(
  reportMifPath       = "path/to/magpie/output/SSP2-PkBudg650_.../report.mif",
  outCsvPath          = "path/to/openprom/run/iPrices_magpie.csv",
  outEmissionsMifPath = "path/to/openprom/run/iEmissions_magpie.mif",
  gdxPath             = "path/to/blabla.gdx",   # used to read the SBS set
  scenario            = "SSP2-PkBudg650",
  deflator17to15      = 0.96
)
```

What it does (two output channels):

**(a) Bioenergy price → `iPrices_magpie.csv`** (consumed by GAMS round-2)

* Reads `Prices|Bioenergy (US$2017/GJ)` and converts to OPEN-PROM's k$2015/toe (× 0.96 × 41.868 / 1000)
* Interpolates MAgPIE's 5-year steps onto OPEN-PROM's `YTIME = 2010..2100` annual grid
* **Intensive variable** (price) — broadcast 12 h12 → 39 resCy (EU-28 members inherit `EUR`; other 11 regions 1:1), then broadcast across 34 `SBS` subsectors

**(b) AFOLU emissions → `iEmissions_magpie.mif`** (IAMC mif, 200 variables; reporting-only — current GAMS does not `$include` this file)

* Reads 200 curated AFOLU emission variables across 11 gases (BC, CH4, CO, CO2, N2O, NH3, NO2, NO3-, OC, SO2, VOC) covering MAgPIE's 4 sub-trees: `|Land|*` endogenous, `|AFOLU|Land|Fires|*` GFED wildfires, `|AFOLU|Agriculture` GAINS/CEDS air pollutants, plus the post-process Grassi alias dropped to avoid double-count
* **Extensive variable** (Mt/yr) — disaggregated 12 h12 → 39 resCy via two passes over the IAMC `|+|` tree (parsed from variable names):
  * **Pass 1, leaves**: weight-based split. 199 leaves use **MAgPIE-internal cell-level (0.5°) land-use distributions** as country weights (one of 11 physical drivers — drained peatland area, secondary forest area, cropland area, etc.); 1 leaf (`Emissions|CO2|Land|+|Indirect`) uses **ClimateWatch year-2010 LULUCF CO2 signed weights** because per-Mha forest sink density varies ~8x across EU climate zones
  * **Pass 2, parents**: country values = Σ direct children, processed deepest-first. Country-level `|+|` sum-to-parent identities hold automatically
* **Pre-requisite**: the run's `cell.{land,land_split,peatland}_0.5.mz` + `clustermap_*.rds` must exist in the MAgPIE output directory (produced by MAgPIE's standard `extra/disaggregation.R` postprocessor)
* Per-leaf weight assignments are in `inst/extdata/magpie-afolu-emission-variables.csv` (manually maintained — single source of truth for variable list, weight choice, and parent–child documentation)

---

## Full Workflow (automated by `start.R task_id=7`)

```bash
Rscript start.R task_id=7
```

Pipeline:

1. **OPEN-PROM round-1** (`link2MAgPIE=off`) → `blabla.gdx` + `blabla_round1.gdx` snapshot
2. `couplePromToMagpie()` → `openprom_coupling.mif` (reads `blabla_round1.gdx`)
3. **MAgPIE run** — launched via `Rscript start.R` inside `magpie/`, with env-vars `OPENPROM_MAGPIE_PROJECT`, `OPENPROM_MAGPIE_SUBSCENARIO`, `OPENPROM_COUPLING_MIF`, `OPENPROM_COUPLING_SCENARIO`, `OPENPROM_COUPLING_GHG=on`, `OPENPROM_COUPLING_BIOENERGY=on` set; MAgPIE writes `report.mif` + `cell.{land,land_split,peatland}_0.5.mz` + `clustermap_*.rds`
4. `coupleMagpieToProm()` → `iPrices_magpie.csv` + `iEmissions_magpie.mif`
5. **OPEN-PROM round-2** (`link2MAgPIE=on`) — reads `iPrices_magpie.csv`, fixes BMSWAS price, re-solves; overwrites `blabla.gdx` with the round-2 result (the round-1 snapshot is preserved)
6. `reportOutput.R` + sync

For task 7, three pieces of information are required, all inside `config.json`:

* `config.json:paths.magpie_path` — absolute path to the MAgPIE root (`<...>/OPEN-PROM/magpie/`)
* `config.json:scenario.magpie.project` — subdirectory name under `magpie/e3m_projects/` (e.g. `"uptake"`); must contain a MAgPIE-side `scenarios.csv` that lists subscenarios (this is MAgPIE's own file inside the project folder, not OPEN-PROM's root-level `scenarios.csv` used for batch mode)
* `config.json:scenario.scenario_name` — `title` of one row in that MAgPIE-side `scenarios.csv` (e.g. `"SSP2-PkBudg650"`); used as the scenario label on **both** the OPEN-PROM side and the MAgPIE side (the run folder name and the MAgPIE subscenario name share this string)

The task 7 body performs pre-flight validation on these three fields and aborts before the long round-1 GAMS solve if any path is missing or misspelled.

### Run-folder layout (what each step produces)

A successful task 7 run touches **two folders**: the OPEN-PROM run folder created by Step 1 (`createRunFolder`) and a fresh MAgPIE output folder created by Step 3.

```
runs/SSP2-PkBudg650_<timestamp>/                  ← OPEN-PROM run folder
├── blabla.gdx                                    Step 1 output → Step 5 overwrites with round-2
├── blabla_round1.gdx                             Step 1 snapshot; Step 2 reads only this; preserved across resumes
├── outputData.gdx                                round-2 OPEN-PROM main GDX (used by Step 6)
├── modelstat.txt                                 GAMS model status of the latest solve (Step 5 overwrites Step 1's)
├── main.lst / main.log                           GAMS listing & log of the latest solve
├── full_round1.log                               Windows only: tee'd Step 1 console log
├── full_round2.log                               Windows only: tee'd Step 5 console log
├── openprom_coupling.mif                         Step 2 output → MAgPIE Step 3 input
├── iPrices_magpie.csv                            Step 4 output → Step 5 input (BMSWAS price table)
├── iEmissions_magpie.mif                         Step 4 output (AFOLU 200 vars; IAMC mif; reporting only — GAMS does not yet $include it)
├── reporting.mif                                 Step 6 (`convertGDXtoMIF`) — converted MIF report
├── plot.tex / plot.pdf                           Step 6 (`batchPlotReport`) — auto-generated plots
└── metadata.json                                 written by `saveMetadata()` at task entry

magpie/output/<scenario>_<timestamp>/             ← created by Step 3, one new folder per MAgPIE run
├── report.mif                                    Step 3 main output → Step 4 input
├── fulldata.gdx                                  MAgPIE main GDX
├── cell.land_0.5.mz                              0.5° gridded land categories (Step 4 country weights)
├── cell.land_split_0.5.mz                        further-split (forestry sub-classes, cropland tree cover, …)
├── cell.peatland_0.5.mz                          0.5° peatland states (drained / intact / rewetted / …)
├── clustermap_*.rds                              cell → (cluster, region, country) mapping (Step 4 aggregates by country)
├── full.log / full.lst                           GAMS log/listing
├── runstatistics.rda                             runtime stats
└── _renv.lock / renv.lock                        per-run renv snapshot

<config$model_runs_path>/                         ← SharePoint / shared drive (Step 6 sync target)
└── SSP2-PkBudg650_<timestamp>.tgz                tar-gzipped copy of the OPEN-PROM run folder
```

Notes on file lifetimes:

* `blabla.gdx` is produced twice (Step 1, then overwritten in Step 5). `blabla_round1.gdx` is the immutable round-1 snapshot — every resume reads from it, never from `blabla.gdx`.
* `modelstat.txt`, `main.lst`, `main.log` likewise reflect only the *latest* solve. If Step 5 finishes, you cannot tell from these whether Step 1 also succeeded — but `blabla_round1.gdx` proves it did.
* The MAgPIE step always creates a *new* timestamped subfolder under `magpie/output/` (named `<scenario>_<timestamp>` from `cfg$title`), so resuming task 7 leaves the previous MAgPIE folder untouched and Step 4 picks the most recent one (`which.max(mtime)`).
* The `cell.*.mz` files are produced by MAgPIE's standard `extra/disaggregation.R` postprocessor — included by default in every MAgPIE run. If you customise the MAgPIE output script list and disable this postprocessor, Step 4 will fail with a clear error.
* `syncRun()` writes the `.tgz` archive locally first, copies it to `config.json:paths.model_runs_path`, then deletes the local copy. Excludes `main.lst` / `mainCalib.lst` on success; the `config.json:behavior.uploadGDX` flag controls whether `.gdx` files are included.

---

## Resuming from an Existing Run

If a task 7 run fails mid-pipeline (e.g. MAgPIE crashes in Step 3) and you want to retry without paying the cost of OPEN-PROM round-1 again, add the optional `magpie.existing_prom_run` field.

**Single-scenario mode** (`Rscript start.R task_id=7`): put it directly under `config.json:scenario.magpie`:

```json
{
  "scenario": {
    "scenario_name": "SSP2-PkBudg650_resume",
    "description": "Resume MAgPIE coupling from an existing round-1 run",
    "magpie": {
      "project": "uptake",
      "existing_prom_run": "/abs/path/to/runs/SSP2-PkBudg650_2026-04-25_xxx"
    }
  }
}
```

**Batch mode** (`Rscript start.R scenarios.csv`): add a `magpie.existing_prom_run` column to `scenarios.csv` and populate it only on the specific row(s) where you want a resume. Leaving the cell empty on other rows means those scenarios run from scratch. Do **not** put `magpie.existing_prom_run` in `config.json:scenario` when batching across multiple scenarios, because every row that doesn't override the column would inherit the same path and reuse the same OPEN-PROM round-1 — defeating the comparison.

When this field is non-empty, the task 7 body:

* skips Step 1 (the round-1 GAMS solve),
* `cd`s into the named folder instead of creating a new one, and
* resumes from Step 2.

Outputs from Step 2–6 overwrite previous artefacts in place, so a re-run after a Step 3 failure simply rewrites `openprom_coupling.mif`, picks up the next MAgPIE output folder, and re-solves round-2.

**Why the `blabla_round1.gdx` snapshot matters.** Step 5 overwrites `blabla.gdx` with the round-2 result. Without a snapshot, a resume started after Step 5 would feed the round-2 gdx back into `couplePromToMagpie()` — wrong coupling input. Step 1 success therefore always copies `blabla.gdx → blabla_round1.gdx`, and Step 2 reads only from the `_round1` snapshot. If you point `magpie.existing_prom_run` at a folder produced before this feature landed (only `blabla.gdx`, no snapshot), the script makes the snapshot once on first reuse.

**Disabling resumption.** Omit the `magpie.existing_prom_run` field — runs are treated as "from scratch" by default.

---

## Notes

* CSV format requirement: year column headers in `iPrices_magpie.csv` must be **bare integers** (`2010,2011,…,2100`) — no `y` prefix. OPEN-PROM's `YTIME` set is declared as `/%fStartHorizon%*%fEndHorizon%/` which expands to plain-integer labels, and any mismatch triggers GAMS error 170 (domain violation)
* When launching GAMS from a task body in `scripts/tasks/`, always pass `-Idir=./data` because `core/input.gms` includes CSVs with root-relative paths (`./iActv.csvr` etc.) that live in the `./data/` subdirectory
* The forward bio channel sends a weighted blend of three `V03ProdPrimary` carriers (`0.4 × BMSWAS + 0.6 × BGSL + 0.6 × BKRS`) — raw 2G feedstock plus 2G biogasoline and biokerosene; the weights approximate each carrier's effective 2G-biomass content. Under scenarios where OPEN-PROM does not activate the liquid biofuel pathway, this signal can legitimately be near-zero; the CO2 price channel still transmits independently
* The IAMC tree of `iEmissions_magpie.mif` preserves `|+|` markers — country-level sum-to-parent identities hold (parent = Σ direct children), matching the h12-level identities in MAgPIE's source `report.mif`
