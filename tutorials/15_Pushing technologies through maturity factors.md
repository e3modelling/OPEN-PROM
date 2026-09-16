## Pushing technologies with maturity factors

This guide shows how to make a technology expand faster or slower from
`config.json`, without editing GAMS.

## 1. What a maturity factor is

A maturity factor is the weight a technology carries when the model splits new
capacity between competing options:

```
share_i = MatFac_i * cost_i^(-e)  /  SUM_j ( MatFac_j * cost_j^(-e) )
```

* Power generation — `Q04SharePowPlaNewEq`, `modules/04_PowerGeneration/simple/equations.gms`
* Transport — `Q01ShareTechTr`, `modules/01_Transport/simple/equations.gms`
* Industry and buildings — `Q02ShareTechNewEquipUseful`, `modules/02_Industry/technology/equations.gms`

Because the expression is normalised, only the ratios between technologies
competing in the same subsector matter. Doubling one technology's factor roughly
doubles its share while that share is small. The calibrated values live in
`data/iMatFacPlaAvailCap.csv` and `data/iMatrFactorData.csv`.

## 2. Usage

Add a `maturity_factors` block to `config.json:scenario`. Each entry in `changes`
multiplies the calibrated maturity factor of one technology. The name on the left
is up to you. It is how a batch CSV addresses that entry (section 5):

```json
"maturity_factors": {
  "levels":  { "low": 0.5, "def": 1, "high": 2 },
  "changes": {
    "solar":      { "tech": "PGSOL",     "mult": "high" },
    "windOffLam": { "tech": "PGAWNO",    "mult": 4,      "region": "LAM" },
    "bmsccsMid":  { "tech": "ATHBMSCCS", "mult": "high", "from": 2032, "to": 2050 },
    "bmsccsLate": { "tech": "ATHBMSCCS", "mult": 5,      "from": 2051 },
    "lpgCars":    { "sector": "PC", "tech": "TLPG", "mult": "low" }
  }
}
```

These are the five names `config.template.json` ships, with every `mult` set to
`def` there so that a default run is unchanged.

| Field | Required | Meaning |
|---|---|---|
| `tech` | yes | A power generation technology from `PGALL`, or a demand technology when `sector` is given |
| `mult` | yes | A level name from `levels`, or a positive number (when inserting a number, quotes should be avoided e.g. `"mult": "5"` will cause an error). |
| `sector` | demand entries | Demand subsector from `DSBS`; only pairs listed in `SECTTECH` have an effect |
| `region` | no | Region code from `allCy`; without it the entry applies to every region (global change)|
| `from`, `to` | no | First and last year, both inclusive; default is the whole horizon |

* `levels` is optional. `low` = 0.5, `def` = 1 and `high` = 2 are built in; add
  or override names as you like, e.g. `"aggressive": 5`.
* Technologies and years that have no entry in config keep their calibrated values (multiplied by 1).
* Every entry needs its own name, and names must be unique.
* Leave the block out, or `changes` empty, for an unmodified run.

## 3. How it reaches the model

1. `start.R` reads `config.json` and passes the scenario to GAMS in the
   `OPENPROM_SCENARIO` environment variable. In a batch run, that row's columns
   are already applied.
2. Every time GAMS compiles `main.gms`, it first runs
   `scripts/tasks/writeMaturityFactors.R`, the same way it runs `loadMadratData.R`.
   The script reads the scenario from `OPENPROM_SCENARIO`, or from `config.json`.
3. The script writes the multipliers to `data/iMatFacMult*.csv`. Because this
   happens on every compile, the files always match the scenario being run.
4. `core/input.gms` (demand technologies) and
   `modules/04_PowerGeneration/simple/input.gms` (power plants) read those files
   and apply the multipliers.

The CSVs are copied into the run folder with the rest of `data/`, so each archived
run records the multipliers it used.

In GAMS the multiplier is applied after every hardcoded override, so it scales
whatever value the model would otherwise use. For example, if `modules/04_PowerGeneration/simple/input.gms`
manually sets the maturity factor of `ATHBMSCCS` to 0.1 from 2032, a `"mult": "high"`, with `"high": 2`  will increase `ATHBMSCCS` to 0.2.

**Errors.** A bad level name, a missing field or a malformed row stops the run
before GAMS reads the inputs, with a message naming the change
(`changes.bmsccsLate: ...`).
A misspelled technology, subsector or region is caught by GAMS when it reads the
CSV (`Error 170 Domain violation`, Tutorial 07). A subsector-technology pair that
exists but is not in `SECTTECH`, say `PT.TLPG`, is not an error: no equation reads
that pair, so the row simply has no effect. If a row seems to do nothing, check
section 5.

## 4. Useful observations

* **Scaling every technology in a subsector changes nothing**, because the share
  equation is normalised.
* **A hardcoded zero cannot be lifted**, because `2 x 0` is still 0.
* **Calibration runs ignore the multipliers.** Under `--Calibration=MatCalibration`
  the factors are fitted, and the multiply only exists outside that branch.
* **Only power generation and demand are covered.** Hydrogen (`i05MatFacH2`) and
  CDR (`i06MatFacCDR`) are not wired.
* **Batch runs can manipulate maturity factors separately in each run**, one field at a time — see section 5.

## 5. Manipulating maturity factors in batch mode

A batch run (`Rscript start.R scenarios.csv`) builds each scenario by overriding
single keys of `config.json:scenario`, so a column can address one field of one
named change.

For example:

```csv
scenario_name,task_id,maturity_factors.changes.bmsccsLate.mult
bmsccs_x4,2,4
bmsccs_x6,2,6
bmsccs_x8,2,8
```

Three runs differing only in that multiplier. The `tech`, `region` and years come
from the entry in `config.json`, and every other change is inherited. Any field
works, not just `mult`: `maturity_factors.changes.bmsccsLate.from`, `.region` and
so on. An empty cell inherits the default (config) values.

Changes are defined in `config.json` only. A column naming a change that is not
there, whether new or misspelled, stops the run with a message listing the names
that are defined. To switch a lever on in some rows only, define it in
`config.json` with `"mult": "def"` and set its multiplier in those rows. Keep one
entry per technology, region and window: a later entry wins where two overlap,
even at `def`.

Levels can be edited in the same way, e.g. `maturity_factors.levels.high`.

### A complete example

It runs against the block shipped in `config.template.json`, where every `mult`
is `def` (essentially a default GAMS run - all maturity factors are multiplied by 1):

```json
"maturity_factors": {
  "levels":  { "low": 0.5, "def": 1, "high": 2 },
  "changes": {
    "solar":      { "tech": "PGSOL",     "mult": "def" },
    "windOffLam": { "tech": "PGAWNO",    "mult": "def", "region": "LAM" },
    "bmsccsMid":  { "tech": "ATHBMSCCS", "mult": "def", "from": 2030, "to": 2050 },
    "bmsccsLate": { "tech": "ATHBMSCCS", "mult": "def", "from": 2051 },
    "lpgCars":    { "sector": "PC", "tech": "TLPG", "mult": "def" }
  }
}
```

This `scenarios.csv` runs a reference case and five variants:

```csv
scenario_name,start,task_id,description,maturity_factors.changes.bmsccsLate.mult,maturity_factors.changes.bmsccsLate.from,maturity_factors.changes.solar.mult,maturity_factors.changes.windOffLam.mult,maturity_factors.changes.lpgCars.mult
baseline,1,2,template values (all def),,,,,
bmsccs_x4,1,2,biomass CCS x4 from 2051,4,,,,
bmsccs_x8_from2040,1,2,biomass CCS x8 from 2040,8,2040,,,
solar_high,1,2,solar high everywhere,,,high,,
lam_wind_high,1,2,offshore wind high in LAM only,,,,high,
combo,0,2,biomass CCS x8 + solar high + fewer LPG cars,8,,high,,low
```

The same file as a table. Maturity columns are shortened to `<name>.<field>`
(the full header is `maturity_factors.changes.<name>.<field>`), and – marks an
empty cell, which inherits from `config.json`:

| scenario_name | start | task_id | description | bmsccsLate.mult | bmsccsLate.from | solar.mult | windOffLam.mult | lpgCars.mult |
|---|---|---|---|---|---|---|---|---|
| baseline | 1 | 2 | template values (all def) | – | – | – | – | – |
| bmsccs_x4 | 1 | 2 | biomass CCS x4 from 2051 | 4 | – | – | – | – |
| bmsccs_x8_from2040 | 1 | 2 | biomass CCS x8 from 2040 | 8 | 2040 | – | – | – |
| solar_high | 1 | 2 | solar high everywhere | – | – | high | – | – |
| lam_wind_high | 1 | 2 | offshore wind high in LAM only | – | – | – | high | – |
| combo | 0 | 2 | biomass CCS x8 + solar high + fewer LPG cars | 8 | – | high | – | low |

What each row runs with:

| Row | ATHBMSCCS 2045 | ATHBMSCCS 2060 | PGSOL | PGAWNO in LAM | PC.TLPG |
|---|---|---|---|---|---|
| baseline | x1 | x1 | x1 | x1 | x1 |
| bmsccs_x4 | x1 | x4 | x1 | x1 | x1 |
| bmsccs_x8_from2040 | x8 | x8 | x1 | x1 | x1 |
| solar_high | x1 | x1 | x2 | x1 | x1 |
| lam_wind_high | x1 | x1 | x1 | x2 | x1 |
| combo (skipped) | x1 | x8 | x2 | x1 | x0.5 |

* `bmsccs_x8_from2040` changes two fields of one entry. Its new window overlaps
  `bmsccsMid` (2030-2050), and `bmsccsLate` comes later in the template, so it
  wins for 2040-2050.
* `lam_wind_high` changes only the multiplier; `region: LAM` is inherited, so the
  push stays in LAM.
* `combo` has `start` 0, so it is defined but not run.
* A region entry wins over a global entry for the same technology even at `def`,
  so avoid a `def` region entry for a technology you also push globally.

## 6. Valid names

**Power plants** (`PGALL`, `core/sets.gms`): ATHLGN, ATHCOAL, ATHGAS, ATHOIL,
ATHBMSWAS, ATHBMSCCS, ATHCOALCCS, ATHLGNCCS, ATHGASCCS, PGLHYD, PGSHYD, PGAWND,
PGAWNO, PGSOL, PGCSP, PGOTHREN, PGANUC, PGH2F.

**Demand subsectors** (`DSBS`): transport PC, PT, PA, PB, PN, GU, GT, GN;
industry IS, NF, CH, BM, PP, FD, EN, TX, OE, OI; buildings and services SE, AG,
HOU; non-energy and bunkers PCH, NEN, BU.

**Which technology belongs to which subsector** is the `SECTTECH` mapping in
`core/sets.gms`. For example, `PC` accepts TGSL, TLPG, TGDO, TNGS, TELC, TPHEVGSL,
TPHEVGDO, TCHEVGSL, TCHEVGDO and TH2F.

**Region codes** are the `allCy` set in `core/sets.gms`.
