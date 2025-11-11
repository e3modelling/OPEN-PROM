# OPEN-PROM AI Coding Assistant Instructions

## Project Overview
OPEN-PROM is an energy-economy model written in GAMS (General Algebraic Modelling System) with R orchestration. It's based on the PROMETHEUS model architecture and uses a modular design with 8 specialized modules (Transport, Industry, RestOfEnergy, PowerGeneration, Hydrogen, CO2, Emissions, Prices).

## Architecture & Key Components

### Core Structure
- **Entry Point**: `main.gms` - main GAMS file that orchestrates the entire model
- **Orchestration**: `start.R` - R script that manages different run modes and workflows
- **Core Engine**: `/core/` directory contains fundamental GAMS components (sets, declarations, equations, solve logic)
- **Modules**: `/modules/XX_Name/` - modular components with standardized interfaces

### Module System & Interactions
Each module follows this standardized pattern:
- `module.gms` - entry point that conditionally includes realizations based on global switches
- `legacy/` and `simple/` subdirectories contain different implementations 
- `realization.gms` - phase-based dispatcher that includes files based on execution phase
- Standard files: `sets.gms`, `declarations.gms`, `input.gms`, `equations.gms`, `preloop.gms`, `postsolve.gms`

#### Phase-Based Execution Model
The model executes in 6 distinct phases, with each module contributing to each phase:
1. **Sets** - Define module-specific sets and mappings
2. **Declarations** - Declare module variables, parameters, and equations 
3. **Input** - Load and process module input data
4. **Equations** - Define mathematical relationships and constraints
5. **Preloop** - Pre-solve calculations and calibrations
6. **Postsolve** - Post-processing and result calculations

#### Module Interdependencies & Communication
Modules interact through shared variables with `Vm` prefix and core parameters with `im` prefix:

**Cross-Module Variable Examples:**
- `VmConsFuel(allCy,DSBS,EF,YTIME)` - Fuel consumption shared across Industry, Transport, H2, Emissions
- `VmProdElec(allCy,PGALL,YTIME)` - Electricity production from PowerGeneration used by Transport, Industry
- `VmCarVal(allCy,NAP,YTIME)` - Carbon prices from Prices module used by all sectors
- `VmDemFinEneTranspPerFuel(allCy,TRANSE,EF,YTIME)` - Transport demand used by PowerGeneration, Hydrogen

**Key Integration Points:**
- **Energy Balances**: Transport electric demand → PowerGeneration electricity supply
- **Hydrogen Economy**: Industry/Transport H2 demand → Hydrogen production → PowerGeneration input
- **Emissions Accounting**: All modules feed fuel consumption → Emissions calculations
- **Price Propagation**: Prices module carbon costs → All sectoral cost calculations

## Critical Naming Conventions

### Variable & Parameter Prefixes
- `Vm*` - Model-wide interdependent variables (used across modules)
- `Vxx*` - Module-specific variables (xx = module number, e.g., V01 for Transport)
- `V*` - Core-only variables
- `im*` - Model-wide interdependent inputs/parameters
- `ixx*` - Module-specific inputs (e.g., i01 for Transport module)
- `Qxx*` - Equations (MUST start with 2-digit module code)

### Examples
```gams
VmLft(allCy,DSBS,EF,YTIME)          // Lifetime across modules
V01ActivGoodsTransp(allCy,TRANSE,YTIME)  // Transport-only variable
Q01RateScrPc(allCy,YTIME)           // Transport module equation
imPriceFuelsInt(WEF,YTIME)          // Cross-module fuel prices
i01PlugHybrFractOfMileage(ELSH_SET,YTIME) // Transport-specific input
```

## Development Workflows

### Running the Model
Use VS Code tasks (defined in workspace) instead of direct terminal commands:
- **OPEN-PROM DEV**: Development mode with existing data (`task=0`)
- **OPEN-PROM DEV NEW DATA**: Generate new input data (`task=1`)
- **OPEN-PROM RESEARCH**: Research mode (`task=2`)
- **OPEN-PROM DEBUGGING**: Debug mode without run folders (`task=4`)
- **CALIBRATE**: Run calibration process (`task=5`)

### Configuration
- `config.json` - User configuration (scenario name, paths, descriptions)
- `config.template.json` - Template showing required structure
- Copy template and customize for local setup

### Run Management
- Each run creates timestamped folder under `/runs/`
- Automatic metadata capture (Git info, run settings) in `metadata.json`
- Optional cloud sync to SharePoint locations
- Run modes controlled by `DevMode` parameter (0=Research, 1=Development)

## File Organization

### Data Flow
```
/data/ -> Input CSV files and region mappings
/targets/ -> Target/reference data for calibration
/core/ -> Core GAMS logic (sets, equations, solve)
/modules/ -> Sectoral model components
/runs/ -> Timestamped execution folders
```

### Key Files
- `main.gms` - Model entry point with extensive naming convention documentation
- `start.R` - Execution orchestrator with 6 different task modes
- `reportOutput.R` - Post-processing and validation reporting
- `core/sets.gms` - Geographic and sectoral set definitions
- `modules/include.gms` - Module inclusion logic with phase control

## Development Patterns

### Module Realization Selection
Global switches in `main.gms` control which realization each module uses:
```gams
$setGlobal Transport        simple
$setGlobal Industry         technology  
$setGlobal PowerGeneration  simple
$setGlobal Hydrogen         legacy
```
Each module's `module.gms` conditionally includes the selected realization.

### Adding New Variables
1. Determine scope: module-specific (Vxx) vs cross-module (Vm)
2. Follow naming convention: [prefix][type][scope][detail]  
3. Declare in appropriate file (`core/declarations.gms` for Vm, module files for Vxx)
4. **Critical**: Cross-module variables must be declared in core, not modules

### Cross-Module Integration Patterns
When adding module interactions:
1. **Shared Variables**: Use `Vm` prefix, declare in `core/declarations.gms`
2. **Sectoral Mappings**: Use set mappings like `SECTTECH(DSBS,EF)`, `NAPtoALLSBS(NAP,DSBS)`
3. **Energy Flows**: Follow pattern `VmConsFuel` → `VmDemSec*` → `VmProd*`
4. **Price Linkages**: Carbon values propagate via `VmCarVal` to all cost calculations

### Module Development Guidelines
- Module equations MUST use module number prefix (e.g., `Q05DemSecH2` for Hydrogen)
- Cross-module references only through `Vm`/`im` variables - never `Vxx` across modules
- Support multiple realizations via conditional compilation (`$Ifi "%ModuleName%" == "realization"`)
- Each realization must implement all required phases

### Data Integration
- CSV files in `/data/` follow specific naming patterns (iXXVariableName.csv)
- Region mappings control geographic aggregation
- MrPROM tool handles real data loading (separate from dummy data generation)

## Critical Dependencies
- **GAMS** - Core modeling language and solver
- **R packages**: jsonlite, madrat, postprom, reticulate, dplyr, quitte
- **Python packages**: seaborn, colorama, pandas (auto-installed via reticulate)
- Regional data mappings (not distributed with code)

## Common Pitfalls
- Never mix module prefixes (don't use V01 variables in module 02)
- Equation names MUST start with 2-digit module codes
- Cross-module variables must be declared in `/core/`, not in module files
- Module interactions only through `Vm`/`im` variables, never direct `Vxx` references
- Use absolute paths in R scripts due to working directory changes
- Run folder creation can fail if SharePoint paths in config.json are invalid
- GDX files are large - control inclusion in archives via `uploadGDX` flag

## Module Interaction Examples

### Hydrogen-Transport Integration
```gams
! In Hydrogen module (05_Hydrogen/legacy/equations.gms):
VmDemSecH2(allCy,SBS,YTIME) =E= 
    sum(TRANSE$SAMEAS(TRANSE,SBS), VmDemFinEneTranspPerFuel(allCy,TRANSE,"H2F",YTIME))
```

### Emissions-All Sectors Integration  
```gams
! In Emissions module (07_Emissions/legacy/equations.gms):
V07GrnnHsEmisCO2Equiv(NAP,YTIME) =E=
    sum(INDSE, VmConsFuel(allCy,INDSE,EFS,YTIME) * imCo2EmiFac(allCy,INDSE,EFS,YTIME)) +
    sum(PGEF, VmInpTransfTherm(allCy,PGEF,YTIME) * imCo2EmiFac(allCy,"PG",PGEF,YTIME))
```

### Power-Industry Integration
```gams  
! In PowerGeneration module (04_PowerGeneration/simple/equations.gms):
VmPeakLoad(allCy,YTIME) =E=
    sum(INDDOM,VmConsFuel(allCy,INDDOM,"ELC",YTIME)/i04LoadFacElecDem(INDDOM)) + 
    sum(TRANSE, VmDemFinEneTranspPerFuel(allCy,TRANSE,"ELC",YTIME)/i04LoadFacElecDem("TRANSE"))
```

## Debugging Strategies
- Use `task=4` for debugging mode (no run folders, faster iteration)
- Check `modelstat.txt` for solver status
- GAMS log files: `main.lst` (standard), `full.log` (with R output)
- Validation reports generated automatically in research mode
- Git diff captured automatically for run tracking