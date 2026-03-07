# OPEN-PROM Python PoC

Proof-of-concept: OPEN-PROM **core** + **01_Transport (simple)** in Python using Pyomo and Ipopt.

## Layout

- **config/** — Run configuration (`poc_config.py`), paths (`paths.py`).
- **core/** — Sets, parameters, variables, equations, preloop, input loader, postsolve.
- **modules/** — Module packages aligned with GAMS (folder names use leading `_` for valid Python identifiers):  
  - **_01_Transport/simple/** — 01_Transport (realization: simple)  
  - **_02_Industry/technology/** — 02_Industry (realization: technology)  
  - **_03_RestOfEnergy/legacy/** — 03_RestOfEnergy (realization: legacy)  
  - **_04_PowerGeneration/simple/** — 04_PowerGeneration (realization: simple)  
  - **_05_Hydrogen/legacy/** — 05_Hydrogen (realization: legacy)  
  - **_06_CO2/legacy/** — 06_CO2 (realization: legacy)
- **data/** — Place CSV/CSVR input files here (see `data/README.md`).
- **prices_stub.py** — Exogenous fuel prices and subsidies (no 08_Prices / 11_Economy).
- **build_model.py** — Assembles the Pyomo model.
- **run_poc.py** — Builds and solves (one year in PoC); requires Ipopt.
- **run_report.py** — Run report (main.lst): configuration, data load, build, solver log, errors.

## Setup

### 1. Virtual environment (recommended)

From the **`openprom_py`** directory, create and use a virtual environment so dependencies stay isolated:

**Windows (PowerShell):**
```powershell
cd openprom_py
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
```

**Windows (Command Prompt):**
```cmd
cd openprom_py
python -m venv .venv
.venv\Scripts\activate.bat
pip install -r requirements.txt
```

**Linux / macOS:**
```bash
cd openprom_py
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

Always **activate** the same `.venv` before running the PoC (`python run_poc.py`). The `.venv` folder is in `.gitignore`.

### 2. Ipopt and data

Install the NLP solver Ipopt; see **Installing Ipopt** below. Then copy or symlink GAMS input files into `data/` (see `data/README.md` for the list).

## Installing Ipopt

Ipopt is not on PyPI; install it using one of the following. See `requirements.txt` for a short pointer.

- **Windows (recommended)**  
  Install [Miniconda](https://docs.conda.io/en/latest/miniconda.html) (choose “Add to PATH” or use **Anaconda Prompt** from the Start Menu). Open a new terminal, then:
  ```bash
  conda install -c conda-forge ipopt
  ```
  Run the PoC from the same environment so that `ipopt` is on PATH. **Easier:** open Anaconda Prompt, `cd` to `openprom_py`, and run `setup_conda_env.bat` to create a conda env `openprom` with Python 3.14, Ipopt, and Pyomo/pandas in one go.

- **Windows (no conda)**  
  Conda is the supported way to get Ipopt on Windows. Alternatives: use WSL and install Ipopt inside Linux, or see [Ipopt releases](https://github.com/coin-or/Ipopt/releases) for binaries (manual PATH setup).

- **Linux**  
  ```bash
  sudo apt install ipopt
  ```
  or use conda-forge as above.

- **macOS**  
  ```bash
  brew install ipopt
  ```
  or use conda-forge.

**Verify:** From the `openprom_py` directory:
```bash
python -c "from pyomo.opt import SolverFactory; print('Ipopt available:', SolverFactory('ipopt').available())"
```

## Run

With your virtual environment **activated** and from the `openprom_py` directory:

```bash
python build_model.py    # Build only (no data required)
python run_poc.py        # Build and solve (needs Ipopt; data optional for minimal run)
```

Data paths are relative to the project root; `config.paths.DATA_DIR` points to `data/`.

Each run of `run_poc.py` creates a **run archive** in `runs/<timestamp>/` (e.g. `runs/2026-03-06T15-30-00/`) containing:
- **main.lst** — run report (configuration, data load, model build, solver log, errors).
- **openprom_py/** — snapshot of the code at run start (excludes `.venv`, `__pycache__`, `runs`).  
The `runs/` directory is in `.gitignore`. For import or startup errors before the archive is created, check the console.

## Solver

- **NLP:** Ipopt (same role as CONOPT in GAMS).
- HiGHS is reserved for future LP/MIP subproblems.

## Extending

Add further modules under `modules/` following the same pattern (sets, declarations, input, equations, preloop, postsolve) and register them in `build_model.py`.
