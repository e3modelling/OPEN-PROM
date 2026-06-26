# Soft-linking

:::{note}
**In brief** — This page is the operational how-to for OPEN-PROM's two soft-links: the iterative coupling with the MAgPIE land-use model (driven by `task_id=7`) and the link to climate emulators via the IIASA `climate-assessment` tool. It covers the config switches, the run command, the per-step pipeline, checkpointing and resumption — not the rationale, which is described in the interlinkages chapter.
:::

:::{seealso}
For *why* these couplings exist and how the data channels are designed, see {ref}`magpie-link` for the land-use link and {ref}`meteor` for the climate-emulator link, in the model interlinkages chapter.
:::

## Soft-linking with MAgPIE

The coupling is orchestrated entirely by `task_id == 7` in `start.R` (body in `scripts/tasks/task7SoftLinkMagpie.R`). It runs OPEN-PROM, exports a carbon-price and bioenergy signal to MAgPIE, runs MAgPIE, reads MAgPIE's land-use prices and emissions back, and re-solves OPEN-PROM. Two R functions in `postprom/R/couplePromWithMagpie.R` perform the exchange: `couplePromToMagpie()` (OPEN-PROM → MAgPIE) and `coupleMagpieToProm()` (MAgPIE → OPEN-PROM).

### Configuration

Soft-linking is the top-level `softLinkMAgPIE` (`on`/`off`) switch. Within a task-7 run the task body itself toggles the internal GAMS flag `link2MAgPIE` per round — `off` for round 1, `on` for round 2 — so you do not set it by hand. When `link2MAgPIE` is `on`, `modules/08_Prices/legacy/input.gms` reads `iPrices_magpie.csv`, the preloop phase fixes the `BMSWAS` biomass fuel price to the MAgPIE-supplied value, and `equations.gms` excludes `BMSWAS` from the regular price recursion.

Three fields must be present in `config.json` before launching:

| Field | Meaning |
|---|---|
| `paths.magpie_path` | Absolute path to the MAgPIE root (`<…>/OPEN-PROM/magpie/`). |
| `scenario.magpie.project` | Subdirectory under `magpie/e3m_projects/` (e.g. `"uptake"`). Must contain a MAgPIE-side `scenarios.csv` listing subscenarios — this is MAgPIE's own file, **not** OPEN-PROM's root-level `scenarios.csv`. |
| `scenario.scenario_name` | `title` of one row in that MAgPIE-side `scenarios.csv` (e.g. `"SSP2-PkBudg650"`). Used as the scenario label on **both** sides (it names the run folder and the MAgPIE subscenario). |

The task-7 body pre-flight-validates these three fields and aborts **before** the long round-1 solve if any path is missing or misspelled.

### Running

```bash
Rscript start.R task_id=7
```

The pipeline:

1. **OPEN-PROM round 1** (`link2MAgPIE=off`) → `blabla.gdx`, snapshotted to `blabla_round1.gdx`.
2. `couplePromToMagpie()` reads the round-1 snapshot → `openprom_coupling.mif` (carbon price + bioenergy demand, aggregated to MAgPIE's 12 regions).
3. **MAgPIE run** — launched via `Rscript start.R` inside `magpie/`, with the `OPENPROM_*` environment variables set; writes `report.mif` plus the `cell.{land,land_split,peatland}_0.5.mz` and `clustermap_*.rds` disaggregation files.
4. `coupleMagpieToProm()` reads `report.mif` → `iPrices_magpie.csv` (biomass price for round 2) and `iEmissions_magpie.mif` (AFOLU emissions; reporting only — current GAMS does not yet `$include` it).
5. **OPEN-PROM round 2** (`link2MAgPIE=on`) — reads `iPrices_magpie.csv`, fixes the `BMSWAS` price, re-solves; overwrites `blabla.gdx` with the round-2 result while preserving the round-1 snapshot.
6. `reportOutput.R` + `syncRun()`.

:::{warning}
The bio channel sent in step 2 is a weighted blend of three `V03ProdPrimary` carriers (`0.4 × BMSWAS + 0.6 × BGSL + 0.6 × BKRS`). Under scenarios where OPEN-PROM does not activate the liquid-biofuel pathway this signal can legitimately be near-zero; the CO₂-price channel still transmits independently.
:::

### Run-folder layout

A successful task-7 run touches two folders. Key artefacts:

```
runs/<scenario>_<timestamp>/        ← OPEN-PROM run folder
├── blabla.gdx                      Step 1 output → Step 5 overwrites with round 2
├── blabla_round1.gdx               Immutable Step 1 snapshot; Step 2 reads only this
├── openprom_coupling.mif           Step 2 output → MAgPIE Step 3 input
├── iPrices_magpie.csv              Step 4 output → Step 5 input (BMSWAS price table)
├── iEmissions_magpie.mif           Step 4 output (AFOLU; IAMC mif; reporting only)
├── reporting.mif / plot.pdf        Step 6 report + plots
└── metadata.json

magpie/output/<scenario>_<timestamp>/   ← created fresh by Step 3
├── report.mif                          Step 3 main output → Step 4 input
├── cell.land_0.5.mz                    0.5° country weights for Step 4
├── cell.land_split_0.5.mz / cell.peatland_0.5.mz
└── clustermap_*.rds                    cell → (cluster, region, country) mapping
```

Notes on lifetimes:

- `modelstat.txt`, `main.lst`, `main.log` reflect only the **latest** solve. After step 5 they no longer prove step 1 succeeded — but the presence of `blabla_round1.gdx` does.
- The MAgPIE step always creates a **new** timestamped subfolder, so resuming leaves earlier MAgPIE folders untouched; step 4 picks the most recent one (`which.max(mtime)`).
- The `cell.*.mz` files come from MAgPIE's standard `extra/disaggregation.R` postprocessor (on by default). If you disable it, step 4 fails with a clear error.

### Resuming a failed run

If a run fails mid-pipeline (e.g. MAgPIE crashes in step 3) you can retry without re-paying for round 1 by adding the optional `magpie.existing_prom_run` field pointing at the previous run folder.

- **Single-scenario mode** (`Rscript start.R task_id=7`): put it under `config.json:scenario.magpie`.
- **Batch mode** (`Rscript start.R scenarios.csv`): add a `magpie.existing_prom_run` **column** and populate it only on the rows you want to resume. Do **not** set it in `config.json:scenario` when batching — every non-overriding row would inherit the same path and reuse the same round-1, defeating the comparison.

When the field is non-empty the task body skips step 1, `cd`s into the named folder instead of creating a new one, and resumes from step 2; steps 2–6 overwrite previous artefacts in place. Omitting the field (the default) treats every run as "from scratch".

:::{important}
Step 5 overwrites `blabla.gdx` with the round-2 result, so step 2 always reads the immutable `blabla_round1.gdx` snapshot instead — feeding the round-2 gdx back into `couplePromToMagpie()` would be wrong coupling input. If you point `existing_prom_run` at an older folder that has only `blabla.gdx` (no snapshot), the script creates the snapshot once on first reuse.
:::

:::{note}
Year column headers in `iPrices_magpie.csv` must be **bare integers** (`2010,2011,…,2100`) — no `y` prefix — to match OPEN-PROM's `YTIME` labels; a mismatch triggers GAMS error 170 (domain violation). When launching GAMS from a task body in `scripts/tasks/`, always pass `-Idir=./data`, because `core/input.gms` includes CSVs with root-relative paths that live in `./data/`.
:::

## Soft-linking with climate emulators

OPEN-PROM's emissions pathways are translated into climate indicators (global mean surface air temperature, peak warming, warming probabilities) by IIASA's `climate-assessment` tool, which runs the MAGICC, FaIR or CICERO-SCM emulators in probabilistic mode. The link is one-directional: OPEN-PROM runs first and writes an emissions CSV, then `climate-assessment` consumes it.

:::{note}
The model interlinkages chapter describes the climate coupling in terms of **METEOR** (see {ref}`meteor`), a spatially-resolved emulator that feeds gridded temperature and precipitation — and the derived HDD/CDD impact indicators — back into OPEN-PROM's energy demand. The tool documented operationally here, IIASA's **`climate-assessment`**, is a distinct, complementary tool used for the global-mean climate-outcome assessment (temperature, peak warming, warming probabilities). The two address different stages of the climate coupling rather than being the same tool.
:::

### Setup on Windows (via WSL)

`climate-assessment` is Linux-oriented (it needs Intel Fortran libraries absent on Windows), so run it under WSL.

1. **Install WSL.** In PowerShell (Administrator): `wsl --install`, then reboot. Confirm with `wsl --version`.
2. **Co-locate the repos.** Place `OPEN-PROM` and `climate-assessment` in the **same parent folder** (the linking script depends on this), e.g. `/mnt/c/Users/<user>/Models/{OPEN-PROM,climate-assessment}`.
3. **Run the installer.** From WSL (not CMD), inside the OPEN-PROM folder:

   ```bash
   chmod +x scripts/tools/installClimateAssessmentToolWSL.sh
   ./scripts/tools/installClimateAssessmentToolWSL.sh
   ```

   This installs build dependencies, compiles **Python 3.11.9** from source via `altinstall` (the tool requires 3.11.x; Ubuntu ships 3.12.x), clones `climate-assessment`, creates a `.venv` virtual environment inside it, and installs the package (`pip install --editable .[…]`, `xarray<2023.12.0`). On success you will see a new `.venv/` folder.

4. **Add MAGICC7.** Download the MAGICC7 binary and its probabilistic-parameters file (registration may be required), place them in e.g. `climate-assessment/magicc-files/`, then copy `.env.sample` to `.env` and point it at those files:

   ```
   MAGICC_EXECUTABLE_7=/mnt/c/Users/<user>/Models/climate-assessment/magicc-files/bin/magicc
   MAGICC_WORKER_NUMBER=8
   MAGICC_WORKER_ROOT_DIR=/mnt/tmp/workers
   ```

   Each worker needs ~500 MB; create the worker directory before running.

:::{tip}
If `apt` reports broken dependencies (e.g. *"E: Unmet dependencies … apt --fix-broken install"*), the usual fix is to neutralise the `udev` post-install script (`sudo mv /var/lib/dpkg/info/udev.postinst{,.bak}`), force-configure (`sudo dpkg --configure -a`), hold the package (`sudo apt-mark hold udev`), then `sudo apt --fix-broken install` before retrying the dependency install.
:::

### Running the link

1. OPEN-PROM runs first; `postprom` writes an `emissions.csv` into each run folder. The minimum required inputs for `climate-assessment` are CO₂ emissions from **both** energy/industry and AFOLU (negative values are allowed only for CO₂); the remaining gases and HFCs are infilled from AR6 and the Navigate / REMIND-MAgPIE datasets. The AFOLU CO₂ may instead come from MAgPIE when the soft-link above is used.
2. Place the file at `runs/<runFolder>/emissions.csv` (or pass a custom path) and run:

   ```bash
   Rscript scripts/tools/runClimateModels.r --model magicc --runFolder <runFolder>
   ```

3. The script calls the Python workflow inside the correct virtual environment (harmonise → infill → emulate), saves outputs to `runs/<runFolder>/EmissionsOutput-<model>/`, and writes a global-mean-temperature plot `Global_Mean_Temperature.png`.
