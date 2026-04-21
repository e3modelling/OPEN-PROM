## A Comprehensive Guide to the OPEN-PROM Modular Model

This tutorial provides a high-level walkthrough of the **OPEN-PROM model**, an open-source version of the PROMETHEUS world energy model developed by E3-Modelling. It focuses on structure, execution flow, and code organization rather than equation-by-equation detail.


## Table of Contents

1. **Overview of the Model**
2. **Folder Structure**
3. **Core Files**
    - Sets
    - Declarations
    - Input
    - Equations
    - Preloop
    - Solve
    - Postsolve
4. **Modules**
    - Description and Purpose
    - Folder Structure
    - Module Realization
5. **Main File**
    - Preliminaries and Configuration
    - Module Integration
6. **Execution Flow**
    - Script Call Hierarchy
    - Control Loops
7. **Key Notes and Coding Conventions**
8. **Conclusion**

## 1. Overview of the Model

The OPEN-PROM model is a recursive, modular energy-system model. It is built around a set of interacting sector modules, such as transport, industry, power generation, hydrogen, prices, and emissions. This modular design makes it possible to expand or replace parts of the system without rewriting the entire model.

At a practical level, the model does three things:

1. Reads a mapped dataset for the selected regions and years.
2. Builds a large nonlinear system from core files plus module files.
3. Solves the system year by year, carrying forward the previous year as the next year’s starting state.

That recursive structure is the key idea to keep in mind when reading the code. In the current default configuration, the model solves activity years from 2024 to 2100, while earlier years are treated as historical anchors.

It is also important to understand what kind of model OPEN-PROM is. It is not a classic perfect-foresight optimization model in which the whole system solves one all-years-at-once planning problem with one master objective. But it is also not a loose simulation in which everything is imposed from outside and the model only applies a few accounting rules.

Instead, OPEN-PROM sits between those two extremes:

- it solves the system recursively, year by year, rather than with perfect foresight;
- within each year, it still solves a coupled nonlinear system of equations;
- those equations enforce technology-choice rules, cost relations, balances, stock dynamics, price feedbacks, and other consistency conditions at the same time.

This matters because it is one of the ways OPEN-PROM balances breadth and detail. By avoiding a large perfect-foresight optimization structure, the model can stay more flexible in regional coverage and in the way sector-specific behavioral and technological detail is represented. At the same time, it is not arbitrary: for a given year and region, demands, shares, capacities, prices, and emissions must jointly satisfy the active equation system.

It is also useful to distinguish the normal run from the calibration run. In the normal workflow, the model is mainly solving for a numerically closed feasible system. The equation `qDummyObj` simply fixes `vDummyObj = 1`, and the NLP solver is used because the equation system is nonlinear, not because the model is minimizing a full-system planner objective. In calibration mode (`Calibration=MatCalibration`), that dummy objective is replaced by a real fitting objective. Selected maturity-related parameters become decision variables, and the model minimizes the mismatch between model outputs and calibration targets. In other words, the structure of the model remains the same, but the solve is now used for constrained fitting rather than only for system closure.

That is also why calibration is so important in OPEN-PROM. The model does not rely only on abstract equilibrium logic; it also contains a detailed calibration layer that pushes key parts of the system, especially technology diffusion behavior, closer to observed or intended historical patterns.

## 2. Folder Structure

The OPEN-PROM model is organized around two main directories:

### 2.1 Core Folder
This directory contains the shared backbone of the model:

- **sets.gms**: Defines sets used across the model.
- **declarations.gms**: Declares variables, parameters, and scalars.
- **input.gms**: Manages input data processing.
- **equations.gms**: Contains core equations for the model.
- **preloop.gms**: Prepares variables and data for solving.
- **solve.gms**: Handles the iterative solving process.
- **postsolve.gms**: Processes results after solving.

### 2.2 Modules Folder
Each module focuses on a specific energy sector or cross-sector function and is stored in its own subfolder. The main subfolders are:

1. **01_Transport**
2. **02_Industry**
3. **03_RestOfEnergy**
4. **04_PowerGeneration**
5. **05_Hydrogen**
6. **06_CO2**
7. **07_Emissions**
8. **08_Prices**
9. **09_Heat**
10. **10_Curves**
11. **11_Economy**

Each module folder contains:

- `module.gms`: switches to the active realization for that module.
- one or more realization subfolders such as `legacy`, `simple`, `technology`, `heat`, `economy`, or `LearningCurves`.
- each realization folder usually contains phase files such as `declarations.gms`, `equations.gms`, `input.gms`, `preloop.gms`, `postsolve.gms`, and `realization.gms`.

The global dispatcher that assembles all modules is `modules/include.gms`, located in the top-level `modules/` directory.

## 3. Core Files

###  Sets
`sets.gms` defines the sets for years, countries, technologies, and other key dimensions used throughout the model.

###  Declarations
`declarations.gms` declares variables, parameters, and scalars used in the rest of the model.

###  Input
`input.gms` reads and prepares input data for use in the equation system.

###  Equations
`equations.gms` defines the mathematical relationships governing the model. In the core layer, it also defines `qDummyObj`, which behaves differently depending on the calibration setting:

- in the normal run, it fixes `vDummyObj = 1`;
- in calibration mode, it becomes the fitting objective minimized by the NLP solve.

###  Preloop
`preloop.gms` prepares bounds, initial values, and other runtime settings before the solving phase.

###  Solve
`solve.gms` handles the model’s iterative solving process, which includes nested loops for years, countries/regions, and solver attempts. The actual solver call is:

`solve openprom using nlp minimizing vDummyObj;`

###  Postsolve
`postsolve.gms` processes results, calculates additional metrics, writes output files, and fixes selected solved values so they can be carried forward into the next year.


## 4. Modules

### 4.1 Description and Purpose
Modules encapsulate specific energy system components, such as power generation or transport. This modularity enables more independent development and testing of components. In practice, both the core layer and the individual modules contain meaningful pieces of model logic rather than acting as empty wrappers.

In the current default setup, the active realizations are:

- `Transport = simple`
- `Industry = technology`
- `RestOfEnergy = legacy`
- `PowerGeneration = simple`
- `Hydrogen = legacy`
- `CO2 = legacy`
- `Emissions = legacy`
- `Prices = legacy`
- `Heat = heat`
- `Curves = off`
- `Economy = economy`

### 4.2 Folder Structure
Each module subfolder contains:

- `module.gms`: Switch for including realization scripts.
- one or more realization subfolders: These contain declarations, equations, inputs, and other phase files.

Not every module uses the same realization names. For example:

- Transport uses `legacy` or `simple`
- Industry uses `legacy` or `technology`
- PowerGeneration uses `legacy` or `simple`
- Heat uses `heat`
- Economy uses `economy`
- Curves uses `LearningCurves`

### 4.3 Module Realization
`module.gms` uses conditional statements to include the correct realization script based on the selected module type. For example, a module may switch between `legacy` and `simple`, or between `legacy` and `technology`.

The realization file then reacts to the active assembly `phase` and includes the correct phase file for that moment in the build process.



## 5. Main File

The `main.gms` file orchestrates the entire model execution. Its main responsibilities are:

### 5.1 Preliminaries and Configuration
It defines global options and flags, such as:

- Solver attempts.
- Research or development mode.
- Time horizon and scenario settings.
- Calibration mode.
- Active module realizations.
- Country selection through `fCountries`.

### 5.2 Module Integration
It includes core files and calls module components through `modules/include.gms`.

The main file does not assemble one complete module at a time. Instead, it assembles the model phase by phase: sets first, then declarations, then inputs, equations, preloop, solve, and postsolve.


## 6. Execution Flow

### 6.1 Script Call Hierarchy
Execution begins with `main.gms`, which includes:

1. Core scripts for each phase.
2. Module-specific scripts for the same phase.

The important detail is that the hierarchy is phase-based, not sector-based. `main.gms` calls a phase, `modules/include.gms` propagates that phase, and each module realization includes only the matching file for that phase.

### 6.2 Control Loops
The model iterates through:

- **Outer Loop**: Years.
- **Middle Loop**: Countries.
- **Inner Loop**: Solver attempts.

In the normal run, this loop searches for a numerically closed solution for the active year and region. In calibration mode, the same loop structure is used, but the solve is guided by a fitting objective instead of the constant dummy objective.



## 7. Key Notes and Coding Conventions

### 7.1 Coding Conventions
Follow the established naming conventions for variables, equations, and parameters, such as:

- **Q**: Equation.
- **V**: Variable.
- **i**: Input data.
- **Vm / im**: shared variables or inputs used across more than one module.

### 7.2 Guidelines
- Modularize code for scalability.
- Document all changes thoroughly.
- Distinguish clearly between model logic and wrapper workflow logic.
- Remember that a `phase` is a code-assembly concept, not a model-year concept.

## 8. Conclusion
This tutorial provides a high-level understanding of the OPEN-PROM model, from its modular structure to its execution flow. It is intended to help users read the codebase more effectively and understand how the model is assembled, solved, and calibrated before moving on to more detailed technical documentation.
