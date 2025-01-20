# A Comprehensive Guide to the OPEN-PROM Modular Model

This tutorial provides a detailed walkthrough of the **OPEN-PROM model**, an open-source version of the PROMETHEUS world energy model developed by E3-Modelling. By following this guide, users will understand the structure, functionality, and operation of the model, enabling them to explore energy scenarios and contribute to its development.


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
The OPEN-PROM model simulates energy systems by solving equations for various modules such as power generation, transport, and industry. Its modular design enables independent execution of components and easy integration of new features. The model projects energy scenarios from 2021 to 2100, offering insights into climate and energy policy impacts.


## 2. Folder Structure

The OPEN-PROM model organizes its files into two main directories:

### 2.1 Core Folder
This contains the backbone of the model, structured as follows:

- **sets.gms**: Defines sets used across the model.
- **declarations.gms**: Declares variables, parameters, and scalars.
- **input.gms**: Manages input data processing.
- **equations.gms**: Contains core equations for the model.
- **preloop.gms**: Prepares variables and data for solving.
- **solve.gms**: Handles the iterative solving process.
- **postsolve.gms**: Processes results after solving.

### 2.2 Modules Folder
Each module focuses on a specific energy sector and is stored in a subfolder. The main subfolders include:

1. **01_PowerGeneration**
2. **02_Transport**
3. **03_Industry**
4. **04_RestOfEnergy**
5. **05_CO2**
6. **06_Emissions**
7. **07_Prices**

Each module folder contains:

- `module.gms`: Switches to include the realization script based on the module type.
- **legacy** subfolder: Includes `declarations.gms`, `equations.gms`, `preloop.gms`, `postsolve.gms`, and `realization.gms`.
- `include.gms`: Consolidates subfile calls for module components.

## 3. Core Files

###  Sets
`sets.gms` defines the sets for time steps, countries, technologies, and more, enabling modular and scalable equations.

###  Declarations
`declarations.gms` initializes variables, parameters, and scalars used in equations.

###  Input
`input.gms` processes raw data, preparing it for use in equations.

###  Equations
`equations.gms` defines the mathematical relationships governing the model. These include:

- Capacity equations.
- Emissions constraints.
- CO2 sequestration cost curves.

###  Preloop
`preloop.gms` initializes parameters and prepares data before the solving phase.

###  Solve
`solve.gms` handles the model’s iterative solving process, which includes nested loops for time steps, countries, and solver attempts.

###  Postsolve
`postsolve.gms` processes results, calculates additional metrics, and writes output files.


## 4. Modules

### 4.1 Description and Purpose
Modules encapsulate specific energy system components, such as power generation or transport. This modularity enables independent development and testing of components. It is worth noticing that both the core as well as the modules of the model are small models inthemselves.

### 4.2 Folder Structure
Each module subfolder contains:

- `module.gms`: Switch for including realization scripts.
- **legacy** subfolder: Contains declarations, equations, and other components.
- `include.gms`: Integrates subfiles for each module.

### 4.3 Module Realization
`module.gms` uses conditional statements to include the correct realization script based on the module type (e.g., "legacy").



## 5. Main File

The `main.gms` file orchestrates the entire model execution. Key components include:

### 5.1 Preliminaries and Configuration
Defines global options and flags, such as:

- Solver attempts.
- Research or development mode.
- Time horizon and scenario settings.

### 5.2 Module Integration
Includes core files and calls module components using `include.gms`.


## 6. Execution Flow

### 6.1 Script Call Hierarchy
Execution begins with `main.gms`, which sequentially includes:

1. Core scripts (sets, declarations, etc.).
2. Module-specific scripts (declarations, equations, etc.).

### 6.2 Control Loops
The model iterates through:

- **Outer Loop**: Time steps.
- **Middle Loop**: Countries.
- **Inner Loop**: Solver attempts.



## 7. Key Notes and Coding Conventions

### 7.1 Coding Conventions
Follow the established naming conventions for variables, equations, and parameters, such as:

- **Q**: Equation.
- **V**: Variable.
- **i**: Input data.

### 7.2 Guidelines
- Modularize code for scalability.
- Document all changes thoroughly.

## 8. Conclusion
This tutorial provides a comprehensive understanding of the OPEN-PROM model, from its modular structure to execution flow. By adhering to the guidelines and conventions, users can effectively utilize and extend the model for energy scenario analysis.