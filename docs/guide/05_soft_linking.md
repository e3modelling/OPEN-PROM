# Soft-linking

:::{note}
**In brief** — This page is the operational how-to for running OPEN-PROM's external couplings: the iterative
soft-link with the MAgPIE land-use model and the one-way/iterative soft-link with the METEOR climate emulator.
It covers the relevant configuration switches, task IDs, paths, how to drive an iteration, and how convergence
and checkpointing work in practice. For *why* these couplings exist and what they exchange, see the
interlinkages chapter.
:::

## Soft-linking with MAgPIE

:::{seealso}
For the rationale and the exchanged quantities (carbon-price signal, advanced-bioenergy demand, bioenergy price,
AFOLU emissions), see {ref}`magpie-link`.
:::

The OPEN-PROM ⇄ MAgPIE soft-link is driven by **task 7** of the `start.R` harness. It runs the two models as
independently solved jobs and exchanges data between them as a **round-based state machine**: a cold round 0
solve, followed by zero or more *hot* rounds that each run a forward / MAgPIE / backward / hot sequence, looping
until the shared boundary signals converge or a round cap is reached.

### Prerequisites

- A working MAgPIE installation (the `magpie/` sibling repository), with `config.json:paths.magpie_path` pointing
  at its root (trailing slash included).
- A MAgPIE *project* folder under `<magpie_path>/e3m_projects/<project>/` containing a `scenarios.csv`. The
  project name is set in `config.json:scenario.soft_link_magpie.project` (the template default is `uptake`).
- A `scenario_name`, which is used as the label on **both** sides: it names the OPEN-PROM run folder and selects
  the MAgPIE subscenario (matched against the `title` column of the project's `scenarios.csv` by exact or prefix
  match).

### Running an iteration

Task 7 is batchable (one scenario per CSV row), so either form works:

```bash
Rscript start.R task_id=7        # single scenario from config.json:scenario
Rscript start.R scenarios.csv    # batch; only task_id 2 and 7 are batchable
```

The harness runs a **cold round 0** and then iterates **hot rounds** `k ≥ 1`:

1. **Round 0 — OPEN-PROM (cold).** A first energy-system solve with the link disabled
   (`--softLinkMAgPIE=off`), producing `blabla_round0.gdx`. This is the baseline the forward coupling reads from.
2. **Hot round `k` — four sequential phases**, each checkpointed to `coupling_state.json` before the next begins:
   - **forward** — `postprom::couplePromToMagpie()` converts the previous round's GDX into
     `openprom_coupling.mif` (the carbon-price and advanced-bioenergy-demand signals MAgPIE consumes).
   - **magpie** — MAgPIE is executed inside its project folder via `Rscript e3m_start.R`, reading the forwarded
     boundary; the harness diffs the `output/` listing to capture the one new run directory.
   - **backward** — `postprom::coupleMagpieToProm()` reads MAgPIE's `report.mif` and writes `iPrices_magpie.csv`
     (the bioenergy price fed back into GAMS) plus `iEmissions_magpie.mif` (AFOLU emissions for reporting only).
   - **openprom_hot** — a solve with the link enabled (`--softLinkMAgPIE=on`), so the biomass-and-waste price is
     fixed from the just-written `iPrices_magpie.csv` rather than from OPEN-PROM's internal price dynamics. The
     result is saved as `blabla_round{k}.gdx`.
3. The hot-round sequence repeats. From round `k ≥ 2` a convergence test runs after `openprom_hot` (see below);
   the loop exits at the first converged round, or when `k` reaches `max_iter`.
4. **Finalisation.** The last round's GDX is copied `blabla_round{final}.gdx` → `blabla.gdx`,
   `coupling_summary.json` is written, and (per the `behavior` flags) `reportOutput.R` and run synchronisation
   run on the final solution.

:::{important}
Only the **bioenergy price** (`iPrices_magpie.csv`) feeds back into the GAMS solve. The MAgPIE AFOLU emissions
(`iEmissions_magpie.mif`) do not influence the energy-system solution; the `softmif` land-emission mode merely
tags `blabla.gdx` so `postprom` sources AFOLU emissions from the MAgPIE `.mif` during reporting.
:::

### Configuration

The task-7 knobs live under `config.json:scenario.soft_link_magpie` (and the matching `soft_link_magpie.*`
columns of `scenarios.csv`):

| Key | Default | Meaning |
|---|---|---|
| `project` | `uptake` | MAgPIE project folder under `<magpie_path>/e3m_projects/` |
| `existing_prom_run` | `null` | path to an interrupted run folder to resume from (see below) |
| `max_iter` | `1` | maximum number of hot rounds |
| `price_tol` | `0.05` | relative tolerance on the bioenergy **price** (5%) |
| `quant_tol` | `0.05` | relative tolerance on the bioenergy **quantity** (5%) |

:::{warning}
The template default is `max_iter = 1`, which runs round 0 plus a single hot round and stops without ever
reaching the convergence test (that test starts at round `k ≥ 2`). For a genuinely converged soft-link set
`max_iter` to a larger value (e.g. 5) together with `price_tol`/`quant_tol`.
:::

### Convergence controls and state files

From the second hot round onward (`k ≥ 2`) the harness compares the exchanged **bioenergy price** and
**bioenergy quantity** pathways against the previous round, on the natural shared boundary of the two models (the
H12 land-use regions × years), restricted to years from the model start year (`2024`) onward. For each series it
computes a per-cell relative change against a denominator floor (`1.0` US$2017/GJ for price, `0.01` EJ/yr for
quantity) and reduces it to a maximum, `delta_price_max` / `delta_quant_max` (the judges) and an L2 norm
(diagnostic only). The coupling is declared **converged** only when *both* maxima fall below their tolerances:

```text
converged  iff  delta_price_max < price_tol  AND  delta_quant_max < quant_tol
```

Otherwise another hot round runs until convergence or `max_iter`. A missing value on either side counts as *not
converged*, so the loop never declares victory on an empty (region, year) grid.

State and diagnostics written into the run folder:

| File | Purpose |
|---|---|
| `blabla_round0.gdx` | the cold round-0 OPEN-PROM solution |
| `blabla_round{k}.gdx` | the hot-round OPEN-PROM solution for round *k* |
| `blabla.gdx` | a copy of the final round, used by `reportOutput` |
| `openprom_coupling.mif` | the last forward boundary sent to MAgPIE (overwritten each round) |
| `iPrices_magpie.csv` | the last bioenergy price returned to GAMS (overwritten each round) |
| `iEmissions_magpie.mif` | the last AFOLU emissions returned to `postprom` (overwritten each round) |
| `coupling_state.json` | per-phase checkpoint (status, rounds, captured H12 series) enabling resume |
| `convergence_log.csv` | the per-round deviation trajectory (one row per round `k ≥ 2`) |
| `coupling_summary.json` | finalisation summary: status, thresholds, final deltas, timestamps |

`coupling_state.json` is rewritten atomically after every phase, recording one of the statuses `iterating`,
`failed`, `converged`, or `max_iter`. To resume an interrupted run, point
`config.json:scenario.soft_link_magpie.existing_prom_run` at its run folder; the harness skips round 0 and
continues from the highest round's last completed phase. A resume is only allowed when the run is still
`iterating` and its pinned config snapshot (`max_iter`, `price_tol`, `quant_tol`, `scenario_name`) matches the
current configuration exactly; runs that already failed, converged, or hit `max_iter` cannot be resumed.

### Emulator alternative (without running MAgPIE)

For cases where running the full MAgPIE model on every round is too costly, the land-use response can instead be
represented by **pre-fitted emulator curves**, selected with the user switches at the top of `main.gms`. These
are configured for ordinary single-solve tasks (0–6) through `config.json:scenario.land_use_emulator`, which
`start.R` maps onto the GAMS flags `--landUseEmulator` and `--emulatorGHGScen`:

- `softLinkMAgPIE` (`on`/`off`) — the iterative task-7 soft-link above. When `on` it wins: the biomass price is
  fixed from MAgPIE and AFOLU emissions are read from MAgPIE's `.mif`. The emulator switches below only take
  effect when `softLinkMAgPIE` is `off`.
- `land_use_emulator.source` → `landUseEmulator` (`legacy`/`globiom`/`magpie`) — selects the emulator source.
  `legacy` means no emulator (static biomass price, exogenous AFOLU emissions); `globiom`/`magpie` drive the
  biomass price from a fitted supply curve and AFOLU emissions from fitted land-use-emission curves.
- `land_use_emulator.carbon_price` → `emulatorGHGScen` (`GHG000`, `GHG010`, `GHG020`, `GHG050`, `GHG100`) — picks
  the active land-use carbon-price row in the emulator coefficient tables.

:::{tip}
The three approaches form a hierarchy of increasing fidelity and cost: exogenous land-use assumptions
(`land_use_emulator.source = legacy`) → emulator-based coupling (`globiom`/`magpie`) → full iterative
OPEN-PROM ⇄ MAgPIE soft-linking (`softLinkMAgPIE=on`, task 7). The emulator route never launches an external
land-use model; it only evaluates the fitted curves during the solve.
:::

## Soft-linking with climate emulators (METEOR)

:::{seealso}
For an overview of METEOR and what the coupling adds (spatially explicit climate feedbacks, HDD/CDD impact
indicators), see {ref}`meteor`.
:::

The OPEN-PROM ⇄ METEOR link is an external post-processing pipeline rather than a built-in task: OPEN-PROM
emissions trajectories are translated into spatial climate outcomes and impact indicators that are then fed back
into selected model parameters.

### Workflow

1. **Run an OPEN-PROM scenario** and export its emissions trajectories — CO₂, CH₄, N₂O and sulphur-related
   emissions — in an IAMC-compatible format.
2. **Compute radiative forcing** by passing the IAMC emissions to the C-SCM emissions-to-forcing module, which
   converts the trajectories into radiative-forcing time series.
3. **Emulate the spatial climate response** with METEOR, producing gridded projections of climate variables
   (temperature, precipitation) for the selected horizons, e.g. mid-century and end-of-century.
4. **Post-process to OPEN-PROM regions** — apply regional masks, aggregate the gridded fields to OPEN-PROM
   regions, compute regional annual or monthly averages, and derive impact indicators such as Heating Degree
   Days (HDD) and Cooling Degree Days (CDD).
5. **Feed back into OPEN-PROM** — use the regional HDD/CDD indicators to adjust final-energy-demand assumptions,
   most directly in the buildings (heating and cooling) sector.

Summarised as a chain:

```text
OPEN-PROM emissions scenario → IAMC-formatted emissions → C-SCM forcing calculation
  → METEOR spatial climate emulation → regional aggregation and impact indicators → feedback to OPEN-PROM
```

### One-way vs iterative use

The pipeline can be run as a **one-way soft link**, where METEOR outputs simply inform selected OPEN-PROM
parameters for a single pass, or as an **iterative coupling**, where OPEN-PROM is rerun after the climate-impact
indicators have been updated, letting climate impacts influence energy demand, technology deployment, emissions
and the resulting mitigation pathway across successive rounds.

:::{warning}
The most direct operational feedback currently implemented is the HDD/CDD adjustment to heating and cooling
demand. Wider feedbacks (for example on water-system energy requirements or electricity peak loads) are part of
the coupling's intended scope but are not yet wired into the standard run.
:::
