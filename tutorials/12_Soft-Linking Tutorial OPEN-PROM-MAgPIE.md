
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

1. **OPEN-PROM round-1** (`link2MAgPIE=off`) → `blabla.gdx`
2. `couplePromToMagpie()` → `openprom_coupling.mif`
3. **MAgPIE run** — launched via `Rscript start.R` inside `magpie/`, with env-vars `OPENPROM_COUPLING_MIF`, `OPENPROM_COUPLING_SCENARIO`, `OPENPROM_COUPLING_GHG=on`, `OPENPROM_COUPLING_BIOENERGY=on` set; MAgPIE writes `report.mif`
4. `coupleMagpieToProm()` → `iPrices_magpie.csv` + `iEmissions_magpie.csv`
5. **OPEN-PROM round-2** (`link2MAgPIE=on`) — reads `iPrices_magpie.csv`, fixes BMSWAS price, re-solves
6. `reportOutput.R` + sync

`config.json` must define `magpie_path` (absolute path to the MAgPIE root) so task 7 knows where to launch the land-use run.

---

## Notes

* CSV format requirement: year column headers in `iPrices_magpie.csv` must be **bare integers** (`2010,2011,…,2100`) — no `y` prefix. OPEN-PROM's `YTIME` set is declared as `/%fStartHorizon%*%fEndHorizon%/` which expands to plain-integer labels, and any mismatch triggers GAMS error 170 (domain violation)
* When launching GAMS from `start.R`, always pass `-Idir=./data` because `core/input.gms` includes CSVs with root-relative paths (`./iActv.csvr` etc.) that live in the `./data/` subdirectory
* The forward bio channel sends `V03InpTotTransf[,"LQD","BMSWAS",]` — the narrow 2G lignocellulosic feedstock flow. Under scenarios where OPEN-PROM does not activate the liquid biofuel pathway, this signal can legitimately be near-zero; the CO2 price channel still transmits independently
