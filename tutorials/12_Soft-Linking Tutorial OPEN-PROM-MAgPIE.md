
# Soft-Linking Tutorial: OPEN-PROM ↔ MAgPIE (coupling-channel)

This guide explains how to run the soft-coupling between the **OPEN-PROM** energy-system model and the **MAgPIE** land-use model via the **coupling-channel** approach — the mif-based interface that MAgPIE already exposes for REMIND (`c56_pollutant_prices = "coupling"`, `c60_2ndgen_biodem = "coupling"`).

Two R functions (in `postprom/R/couplePromWithMagpie.R`) do the data exchange:

* `couplePromToMagpie()` — exports OPEN-PROM carbon price + bioenergy demand to a REMIND-style `.mif` that MAgPIE consumes
* `coupleMagpieToProm()` — reads MAgPIE's `report.mif` and writes `iPrices_magpie.csv` (biomass price) and `iEmissions_magpie.csv` (AFOLU emissions) for OPEN-PROM

All of this is orchestrated by `task == 7` in `start.R`.

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
  gdxPath    = "path/to/blabla.gdx",          # OPEN-PROM round-1 gdx
  outMifPath = "path/to/openprom_coupling.mif",
  scenario   = "SSP2-PkBudg650"               # must match MAgPIE side
)
```

What it does:

* Extracts `VmCarVal[,"TRADE",]` (CO2 price, US$2015/t CO2) and converts to US$2017 via a 1.04 deflator
* Extracts `V03InpTotTransf[,"LQD","BMSWAS",]` (2G lignocellulosic feedstock, Mtoe/yr) and converts to EJ/yr (× 0.041868)
* Derives `Price|N2O` (× AR6 GWP100 = 273) and `Price|CH4` (× 27) from the CO2 price — MAgPIE requires all three GHG prices present
* Aggregates OPEN-PROM's 39 countries to MAgPIE's 12 h12 regions (EU-28 → `EUR`, the other 11 countries map 1:1)
* Writes a REMIND-style `.mif` with 4 variables × 12 regions × 91 years that MAgPIE can consume via `cfg$path_to_report_ghgprices` / `cfg$path_to_report_bioenergy`

### 2. MAgPIE → OPEN-PROM

```r
coupleMagpieToProm(
  reportMifPath       = "path/to/magpie/output/noAR_.../report.mif",
  outCsvPath          = "path/to/openprom/run/iPrices_magpie.csv",
  outEmissionsCsvPath = "path/to/openprom/run/iEmissions_magpie.csv",
  gdxPath             = "path/to/blabla.gdx"  # used to read the SBS set
)
```

What it does:

* Reads `Prices|Bioenergy (US$2017/GJ)` and converts to OPEN-PROM's k$2015/toe (× 0.96 × 41.868 / 1000)
* Interpolates MAgPIE's 5-year steps onto OPEN-PROM's `YTIME = 2010..2100` annual grid
* Disaggregates MAgPIE's 12 h12 regions back to OPEN-PROM's 39 countries (EU-28 members inherit the `EUR` value; other 11 regions 1:1) and broadcasts across the 34 `SBS` subsectors — writes `iPrices_magpie.csv` (the file that the GAMS switch above reads)
* Also reads 11 AFOLU emission variables (`Emissions|CO2|Land`, `CH4|Land`, `N2O|Land`, fire-related BC/CO/OC/SO2/VOC, NH3, NO2, NO3-) and writes `iEmissions_magpie.csv`. **The GAMS side does not currently `$include` this file** — it is produced and saved for future extension

---

## Full Workflow (automated by `start.R task 7`)

```r
source("start.R")  # with task <- 7
```

Pipeline:

1. **OPEN-PROM round-1** (`link2MAgPIE=off`) → `blabla.gdx` + `blabla_round1.gdx` snapshot
2. `couplePromToMagpie()` → `openprom_coupling.mif` (reads `blabla_round1.gdx`)
3. **MAgPIE run** — launched via `Rscript start.R` inside `magpie/`, with env-vars `OPENPROM_COUPLING_MIF`, `OPENPROM_COUPLING_SCENARIO`, `OPENPROM_COUPLING_GHG=on`, `OPENPROM_COUPLING_BIOENERGY=on` set; MAgPIE writes `report.mif`
4. `coupleMagpieToProm()` → `iPrices_magpie.csv` + `iEmissions_magpie.csv`
5. **OPEN-PROM round-2** (`link2MAgPIE=on`) — reads `iPrices_magpie.csv`, fixes BMSWAS price, re-solves; overwrites `blabla.gdx` with the round-2 result (the round-1 snapshot is preserved)
6. `reportOutput.R` + sync

`config.json` must define `magpie_path` (absolute path to the MAgPIE root) so task 7 knows where to launch the land-use run.

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
├── iEmissions_magpie.csv                         Step 4 output (AFOLU; produced for completeness, GAMS does not yet read it)
├── reporting.mif                                 Step 6 (`convertGDXtoMIF`) — converted MIF report
├── plot.tex / plot.pdf                           Step 6 (`batchPlotReport`) — auto-generated plots
└── metadata.json                                 written by `saveMetadata()` at task entry

magpie/output/noAR_<timestamp>/                   ← created by Step 3, one new folder per MAgPIE run
├── report.mif                                    Step 3 output → Step 4 input
├── fulldata.gdx                                  MAgPIE main GDX
├── full.log / full.lst                           GAMS log/listing
├── runstatistics.rda                             runtime stats
└── _renv.lock / renv.lock                        per-run renv snapshot

<config$model_runs_path>/                         ← SharePoint / shared drive (Step 6 sync target)
└── SSP2-PkBudg650_<timestamp>.tgz                tar-gzipped copy of the OPEN-PROM run folder
```

Notes on file lifetimes:

* `blabla.gdx` is produced twice (Step 1, then overwritten in Step 5). `blabla_round1.gdx` is the immutable round-1 snapshot — every resume reads from it, never from `blabla.gdx`.
* `modelstat.txt`, `main.lst`, `main.log` likewise reflect only the *latest* solve. If Step 5 finishes, you cannot tell from these whether Step 1 also succeeded — but `blabla_round1.gdx` proves it did.
* The MAgPIE step always creates a *new* timestamped subfolder under `magpie/output/`, so resuming task 7 leaves the previous MAgPIE folder untouched and Step 4 picks the most recent one (`which.max(mtime)`).
* `syncRun()` writes the `.tgz` archive locally first, copies it to `config$model_runs_path`, then deletes the local copy. Excludes `main.lst` / `mainCalib.lst` on success; the `uploadGDX` flag in `start.R` controls whether `.gdx` files are included.

---

## Resuming from an Existing Run

If a task 7 run fails mid-pipeline (e.g. MAgPIE crashes in Step 3) and you want to retry without paying the cost of OPEN-PROM round-1 again, point the optional `task7_existingRun` field in `config.json` at the existing run folder:

```json
{
  "model_runs_path": "...",
  "magpie_path":     "...",
  "task7_existingRun": "/abs/path/to/runs/SSP2-PkBudg650_2026-04-25_xxx"
}
```

When this field is non-empty, `start.R`:

* skips Step 1 (the round-1 GAMS solve),
* `cd`s into the named folder instead of creating a new one, and
* resumes from Step 2.

Outputs from Step 2–6 overwrite previous artefacts in place, so a re-run after a Step 3 failure simply rewrites `openprom_coupling.mif`, picks up the next MAgPIE output folder, and re-solves round-2.

**Why the `blabla_round1.gdx` snapshot matters.** Step 5 overwrites `blabla.gdx` with the round-2 result. Without a snapshot, a resume started after Step 5 would feed the round-2 gdx back into `couplePromToMagpie()` — wrong coupling input. Step 1 success therefore always copies `blabla.gdx → blabla_round1.gdx`, and Step 2 reads only from the `_round1` snapshot. If you point `task7_existingRun` at a folder produced before this feature landed (only `blabla.gdx`, no snapshot), the script makes the snapshot once on first reuse.

**Disabling resumption.** `"task7_existingRun": ""`, `"task7_existingRun": null`, or simply omitting the field — all three are treated as "run from scratch".

---

## Notes

* CSV format requirement: year column headers in `iPrices_magpie.csv` must be **bare integers** (`2010,2011,…,2100`) — no `y` prefix. OPEN-PROM's `YTIME` set is declared as `/%fStartHorizon%*%fEndHorizon%/` which expands to plain-integer labels, and any mismatch triggers GAMS error 170 (domain violation)
* When launching GAMS from `start.R`, always pass `-Idir=./data` because `core/input.gms` includes CSVs with root-relative paths (`./iActv.csvr` etc.) that live in the `./data/` subdirectory
* The forward bio channel sends `V03InpTotTransf[,"LQD","BMSWAS",]` — the narrow 2G lignocellulosic feedstock flow. Under scenarios where OPEN-PROM does not activate the liquid biofuel pathway, this signal can legitimately be near-zero; the CO2 price channel still transmits independently
