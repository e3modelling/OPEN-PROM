
# Soft-Linking Tutorial: OPEN-PROM ↔ MAgPIE

This guide explains how to run the iterative soft-coupling between the **OPEN-PROM** energy-system model and the **MAgPIE** land-use model via the **coupling-channel** approach — the mif-based interface that MAgPIE already exposes for REMIND (`c56_pollutant_prices = "coupling"`, `c60_2ndgen_biodem = "coupling"`).

The coupling loops OPEN-PROM ↔ MAgPIE round-by-round until two convergence judges fall below user-set tolerances, or a user-set `max_iter` is reached. Per-phase checkpointing supports resume after external interruption (power loss, `kill -9`, SSH drop).

Two stateless single-direction R functions in `postprom/R/couplePromWithMagpie.R` do the data exchange:

* `couplePromToMagpie()` — exports OPEN-PROM carbon price + bioenergy demand to a REMIND-style `.mif` that MAgPIE consumes
* `coupleMagpieToProm()` — reads MAgPIE's `report.mif` and writes `iPrices_magpie.csv` (biomass price for the next OPEN-PROM round) and `iEmissions_magpie.mif` (AFOLU emissions, 200 variables, IAMC mif format)

The iteration loop, checkpointing, convergence judgment and resume logic live in `scripts/tasks/task7SoftLinkMagpie.R` (orchestrated by `task_id == 7` in `start.R`). The two coupler functions stay stateless; cross-round logic is entirely in task 7.

---

## 1. Model Integration Switch (OPEN-PROM side)

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

## 2. R coupler functions

### 2.1 OPEN-PROM → MAgPIE

```r
library(postprom)
couplePromToMagpie(
  gdxPath        = "path/to/blabla_round{k-1}.gdx",   # previous round's OPEN-PROM gdx
  outMifPath     = "path/to/openprom_coupling.mif",
  scenario       = "Full_C600_biolim100",             # must match MAgPIE side
  nonCo2Mode     = "gwp",                             # "gwp" (default) or "zero"
  deflator15to17 = 1.04                               # US$2015 -> US$2017
)
```

What it does:

* **CO2 price**: extracts `VmCarVal[,"TRADE",]` (US$2015/t CO2), bioenergy-weighted-averaged 39 → 12 h12, deflated US$2015→US$2017
* **Bioenergy demand**: weighted blend of three OPEN-PROM 2nd-gen carriers from `V03ProdPrimary` (Mtoe/yr) — `0.4 × BMSWAS + 0.6 × BGSL + 0.6 × BKRS`. Summed 39 → 12 h12, converted Mtoe/yr → EJ/yr (× 0.041868)
* **Non-CO2 prices**: `Price|N2O` and `Price|CH4` derived from CO2 via AR6 GWP100 (273 / 27) when `nonCo2Mode = "gwp"`, or set to zero when `"zero"`
* **Aggregation**: OPEN-PROM's 39 countries → MAgPIE's 12 h12 regions (EU-28 → `EUR`, the other 11 countries map 1:1)
* **Output**: REMIND-style `.mif` with 4 variables × 12 regions × 91 years

### 2.2 MAgPIE → OPEN-PROM

```r
coupleMagpieToProm(
  reportMifPath       = "path/to/magpie/output/Full_C600_biolim100_.../report.mif",
  outCsvPath          = "path/to/openprom/run/iPrices_magpie.csv",
  outEmissionsMifPath = "path/to/openprom/run/iEmissions_magpie.mif",
  gdxPath             = "path/to/blabla_round0.gdx",   # used only to read the SBS set
  scenario            = "Full_C600_biolim100",
  deflator17to15      = 0.96
)
```

What it does (two output channels):

**(a) Bioenergy price → `iPrices_magpie.csv`** (consumed by GAMS in the next OPEN-PROM round)

* Reads `Prices|Bioenergy (US$2017/GJ)` and converts to OPEN-PROM's k$2015/toe (× 0.96 × 41.868 / 1000)
* Interpolates MAgPIE's 5-year steps onto OPEN-PROM's `YTIME = 2010..2100` annual grid
* **Intensive variable** (price) — broadcast 12 h12 → 39 resCy (EU-28 members inherit `EUR`; other 11 regions 1:1), then broadcast across 34 `SBS` subsectors

**(b) AFOLU emissions → `iEmissions_magpie.mif`** (IAMC mif, 200 variables; reporting-only — current GAMS does not `$include` this file)

* Reads 200 curated AFOLU emission variables across 11 gases (BC, CH4, CO, CO2, N2O, NH3, NO2, NO3-, OC, SO2, VOC)
* **Extensive variable** (Mt/yr) — disaggregated 12 h12 → 39 resCy via two passes over the IAMC `|+|` tree
* **Pre-requisite**: the run's `cell.{land,land_split,peatland}_0.5.mz` + `clustermap_*.rds` must exist in the MAgPIE output directory (produced by MAgPIE's standard `extra/disaggregation.R` postprocessor)

---

## 3. The iterative workflow

```bash
Rscript start.R task_id=7
```

### 3.1 Round model

| Round | What runs | Output gdx |
|---|---|---|
| **0** | cold OPEN-PROM (`--link2MAgPIE=off`) | `blabla_round0.gdx` |
| **k ≥ 1** | four sequential phases (see below) | `blabla_round{k}.gdx` |

Each round k ≥ 1 has four phases, executed in order:

| Phase | What runs |
|---|---|
| `forward` | `couplePromToMagpie(blabla_round{k-1}.gdx)` → `openprom_coupling.mif`; also captures `h12_quant` series |
| `magpie` | snapshot `magpie/output/` listing, set `OPENPROM_COUPLING_*` env vars, run `Rscript e3m_start.R` from `magpie_path`, then diff the listing (must yield exactly 1 new dir) |
| `backward` | `coupleMagpieToProm(<new MAgPIE dir>/report.mif)` → `iPrices_magpie.csv` + `iEmissions_magpie.mif`; also captures `h12_price` series |
| `openprom_hot` | OPEN-PROM (`--link2MAgPIE=on`); reads the just-written `iPrices_magpie.csv` → `blabla_round{k}.gdx` |

After each k ≥ 2 completes, convergence is checked against round k-1. If both deltas fall below their tolerances, the loop exits with `status="converged"`. Otherwise, if k reaches `max_iter`, it exits with `status="max_iter"`. Finalization copies `blabla_round{final_k}.gdx` → `blabla.gdx` for `reportOutput.R`, writes `coupling_summary.json`, and runs `reportOutput.R` + `syncRun` per the behavior flags.

### 3.2 Convergence judgment

Two h12-region × year series are captured per round:

| Series | Source | Variable | Unit |
|---|---|---|---|
| `h12_quant` | `openprom_coupling.mif` | `Primary Energy Production\|Biomass\|Energy Crops` | EJ/yr |
| `h12_price` | MAgPIE `report.mif` | `Prices\|Bioenergy` | US$2017/GJ |

For each round k ≥ 2 and x ∈ {price, quant}, restrict to t ≥ 2024 and compute the per-cell relative change

$$rel(r,t) = |x_k(r,t) - x_{k-1}(r,t)| / max(|x_{k-1}(r,t)|, floor)$$

then reduce to two scalars:

* `delta_x_max = max(rel)` — **the convergence judge**
* `delta_x_l2 = sqrt(mean(rel^2))` — diagnostic only

The `floor` (1.0 US$/GJ for price, 0.01 EJ/yr for quant) prevents spurious 100% spikes from near-zero prev values on regions/years that don't matter (e.g. price flicker 0.001 → 0.002).

**Convergence rule:** both must hold.

```
converged iff  delta_price_max < price_tol  AND  delta_quant_max < quant_tol
```

Defaults: `price_tol = quant_tol = 0.05` (5%), `max_iter = 1` (single round, equivalent to legacy single-shot behaviour).

### 3.3 State machine and checkpointing

Each successful phase atomically writes `coupling_state.json` (tmp file + rename). The `status` field disambiguates the four possible exits:

| `status` | Source | Next-invocation behaviour |
|---|---|---|
| `iterating` | last successful saveState (in progress OR frozen by external interruption — `kill -9`, power loss, SSH drop) | **auto-resume** from the highest round's last completed phase |
| `failed` | `tryCatch` after a model-self error (modelstat ≠ 2/5, MAgPIE exit ≠ 0, couple* raised, magpie output dir count ≠ 1); `last_failure` carries `{round, phase, timestamp, message}` | **rejected** — the run is dead, same config will fail again; start fresh |
| `converged` | loop exited via convergence test | rejected — already done |
| `max_iter` | loop hit `max_iter` without converging | rejected — already done |

The state file holds per-round `phase`, captured h12 matrices, computed deltas, and a `config_snapshot` of `{max_iter, price_tol, quant_tol, sce_name}`. Resume requires bit-identical `config_snapshot` to the current scenario config; any mismatch rejects with the differing field shown.

### 3.4 Pre-flight checks

These run at the top of `runTask7()` and stop with a clear message before any expensive step:

* **Required fields**: `paths.magpie_path`, `scenario.magpie.project`, `scenario.scenario_name`, `scenario.magpie.max_iter ≥ 1`
* **Filesystem**: `magpie_path/`, `magpie_path/e3m_projects/<project>/`, `magpie_path/e3m_projects/<project>/scenarios.csv` all exist
* **MAgPIE subscenario**: `scenario_name` must match exactly one row in the `title` column of the MAgPIE-side `scenarios.csv` via exact-or-prefix match (same semantics MAgPIE's own `e3m_start.R` uses). Zero matches → error listing all available titles; multiple matches → error listing the ambiguous candidates. This prevents wasting hours on a typo.
* **Resume mode** (only when `existing_prom_run` is set): the directory exists, `coupling_state.json` exists in it, `status` ∉ {`failed`, `converged`, `max_iter`}, and `config_snapshot` is bit-identical to current cfg.

---

## 4. Configuration

All task 7 settings live under `config.json:scenario.magpie` (or, in batch mode, as `magpie.*` columns in `scenarios.csv`):

```jsonc
{
  "scenario": {
    "scenario_name": "Full_C600_biolim100",     // also the MAgPIE subscenario name
    "description":   "UPTAKE C600 biolim100, coupled to convergence",
    "gams_flags":    { "fScenario": 600 },
    "magpie": {
      "project":           "uptake",            // subdir under magpie/e3m_projects/
      "existing_prom_run": null,                // see §5 (Resume)
      "max_iter":          5,                   // upper bound on hot rounds
      "price_tol":         0.05,                // delta_price_max threshold
      "quant_tol":         0.05                 // delta_quant_max threshold
    }
  }
}
```

| Field | Default | What it controls |
|---|---|---|
| `magpie.project` | (required) | Subdir name under `magpie/e3m_projects/` containing the MAgPIE-side `scenarios.csv` |
| `magpie.existing_prom_run` | `null` | Absolute path to a run folder to resume; see §5 |
| `magpie.max_iter` | `1` | Maximum number of hot rounds. `max_iter=1` reproduces the legacy single-shot behaviour (one MAgPIE call). |
| `magpie.price_tol` | `0.05` | `delta_price_max < price_tol` is one half of the convergence rule |
| `magpie.quant_tol` | `0.05` | `delta_quant_max < quant_tol` is the other half |

Three internal constants are **not** exposed to config — they are written at the top of `scripts/tasks/task7SoftLinkMagpie.R` and changing them is a code edit:

| Constant | Value | Why |
|---|---|---|
| `.PRICE_FLOOR` | `1.0` US$2017/GJ | Floor for relative-change denominator (physical noise threshold) |
| `.QUANT_FLOOR` | `0.01` EJ/yr | Same, for quantity |
| `.CONVERGE_YEAR_START` | `2024` | Matches `main.gms`'s `$evalGlobal fStartY`; historical years are exogenously fixed so they don't matter for convergence |

---

## 5. Resuming an interrupted run

If a run is interrupted **externally** (power loss, `kill -9`, SSH drop, OOM kill — anything that prevents the R process from running its `tryCatch` handlers), the state file is frozen at the last successful phase with `status="iterating"`. To resume, point `existing_prom_run` at the run folder:

```jsonc
"magpie": {
  "project":           "uptake",
  "existing_prom_run": "/abs/path/to/runs/Full_C600_biolim100_2026-05-27_15-20-36",
  "max_iter":          5,
  "price_tol":         0.05,
  "quant_tol":         0.05
}
```

The four resume-side fields (`max_iter`, `price_tol`, `quant_tol`, `sce_name`) must match the run folder's `config_snapshot` bit-identically — otherwise the run aborts at pre-flight. To change a knob, start a fresh run.

Task 7 then:
* reads `coupling_state.json` and confirms `status="iterating"`
* validates the config matches the snapshot
* resumes from the highest round's last completed phase (the expensive MAgPIE step is **not** re-run if it already completed)
* continues the loop until convergence or `max_iter`

**Failed runs are not resumable.** If `status="failed"`, the same config in the same folder will fail again — task 7 stops at pre-flight with the `last_failure` summary and tells you to start fresh. The folder is preserved for diagnostics. There is no command-line "force-resume failed run" entry point.

---

## 6. Run-folder layout

Successful task 7 run touches **two folders**: the OPEN-PROM run folder (created on first invocation) and one MAgPIE output folder per round.

```
runs/<scenario_name>_<timestamp>/                   ← OPEN-PROM run folder
├── blabla_round0.gdx                               cold OPEN-PROM solution (round 0)
├── blabla_round1.gdx                               round-1 hot OPEN-PROM solution
├── blabla_round2.gdx                               ...
├── blabla_round{final_k}.gdx                       last hot round
├── blabla.gdx                                      copy of blabla_round{final_k}.gdx (for reportOutput.R)
├── openprom_coupling.mif                           last round's forward output (overwritten each round)
├── iPrices_magpie.csv                              last round's backward price output (overwritten)
├── iEmissions_magpie.mif                           last round's backward emissions output (overwritten)
├── coupling_state.json                             full state machine snapshot — see §3.3
├── convergence_log.csv                             per-round convergence trajectory — see below
├── coupling_summary.json                           finalize-time summary: status, thresholds,
│                                                   final_deltas, magpie_output_dirs, timestamps
├── outputData.gdx                                  last hot round's OPEN-PROM output GDX
├── modelstat.txt                                   GAMS model status of the latest solve
├── main.lst / main.log                             GAMS listing & log of the latest solve
├── reporting.mif                                   convertGDXtoMIF output (from reportOutput.R)
└── metadata.json                                   written by saveMetadata() at task entry

magpie/output/<scenario>_<timestamp>/               ← created by each MAgPIE phase, one per round
├── report.mif                                      MAgPIE main coupling output → backward input
├── fulldata.gdx                                    MAgPIE main GDX
├── cell.{land,land_split,peatland}_0.5.mz          0.5° gridded land categories (for backward weights)
├── clustermap_*.rds                                cell → (cluster, region, country) mapping
└── ...
```

### `convergence_log.csv` columns

One row is appended per round k ≥ 2 after `openprom_done` completes. Rounds 0 and 1 do not appear (no comparable previous round for k=0; for k=1, round 0 is cold so its h12 series do not exist).

| Column | Meaning |
|---|---|
| `round` | k (≥ 2) |
| `delta_price_max` | **judge**: compare to `price_tol` |
| `delta_price_l2` | diagnostic L2 for price |
| `delta_quant_max` | **judge**: compare to `quant_tol` |
| `delta_quant_l2` | diagnostic L2 for quant |
| `status` | `iterating` or `converged` (never `failed` or `max_iter` — those exit before the row is written) |

**Reading max vs L2** (always `max ≥ L2`):

| Pattern | Interpretation |
|---|---|
| `max ≫ L2` | a few cells still moving, bulk has settled — localized issue |
| `max ≈ L2` | broad disagreement, system not settled |
| `max ≈ tol`, `L2 ≪ tol` | usually safe to stop iterating; the average state is converged, only outliers cling to tol |

### Example trajectory

A real run of `Full_C600_biolim100` with `max_iter=20`, `price_tol=quant_tol=0.01`:

```csv
round,delta_price_max,delta_price_l2,delta_quant_max,delta_quant_l2,status
2,0.0733018,0.0148365,0.65505,0.214075,iterating
3,0.0194236,0.0023783,0.040672,0.0100922,iterating
4,0.00313016,0.000511805,0.00811401,0.001176,converged
```

Three hot rounds + cold = total 3h 49min on this hardware. The δ values drop by 4–16× per round; both judges fall below 1% at round 4.
