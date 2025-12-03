Main
====

This is the OPEN-PROM model, the open version of the world energy model PROMETHEUS of E3-Modelling.

*** preliminaries 

==============================================================================*
OPEN-PROM NAMING CONVENTION                       *
==============================================================================*
* Below, you'll find the coding naming convention, a collection of conventions designed to streamline the development process and enhance code readability.
* Please uphold these standards as you code! The naming convention for objects in the code is established as follows:
--------------------------*
CORE PRINCIPLES
--------------------------*
* [ prefix ][ object type (e.g. Capacity, Cost, Share, etc.) ][ more specific information, if needed ][ object scope, e.g. Transport, Electricity, etc. ][ more specific information, if needed ]
* Example:
* [ Q/V/i ][ Cost/Cap/Dem/Cons/Price/etc. ][ Total ][ Elec/Tr/Ind/Dom ][ etc. ]
* Q: Equation
* q: Equation whose main computed variable does not participate in more than one equation, thus has decreased impact on the model
* V: Variable, main variable computed by each equation
* v: Variable that does not participate in more than one equation, thus has decreased impact on the model
* i: Input, Inputs are datasets or constants that are exogenous to the model
----------------------
1. VARIABLE PREFIXES
----------------------
The first two "fields" of an object (object = variable, equation, parameter, etc.) name encode its scope:

Vm : "Model-wide / Interdependent" Variable
-> Used across multiple modules

Vxx : "Module-specific" Variable
-> Used only within module 'xx', where 'xx' is a 2-digit identifier

V   : "Core-only" Variable
-> Used only inside the core 

Example:
VmLft(allCy,DSBS,EF,YTIME)
-> Lifetime of technologies, shared across modules

V01ActivGoodsTransp(allCy,TRANSE,YTIME)
-> Activity variable exclusive to Module 01_Transport

----------------------
2. EQUATION PREFIXES
----------------------
All equations **must begin** with the exact 2-digit module code:

QxxEquationName(...)
→ Where 'xx' is the module number (e.g., 01, 02, 03, ...)
→ This ensures traceability of equations to their origin module

Examples:
Q01RateScrPc(allCy,YTIME)
→ Passenger car scrapping rate equation from 01_Transport

-------------------------------------------------
3. INPUT PREFIXES (PARAMETERS, TABLES, SCALARS)
-------------------------------------------------
Inputs follow the same logic:

im : "Model-wide / Interdependent" Input
-> Declared in /core and used across modules

ixx : "Module-specific" Input
-> Exclusive to module 'xx'

Examples:
imPriceFuelsInt(WEF,YTIME)
-> Fuel import prices, shared across model

imImpExp(allCy,EFS,YTIME)
-> imports of exporting countries, shared

i01PlugHybrFractOfMileage(ELSH_SET,YTIME)
-> PHEV mileage split, only used in Transport module

i01Pop(YTIME,allCy)
-> Population input for Transport module only

------------------------------
4. MODULE NAMING CONVENTION
------------------------------
Each module is numbered and named as follows:

01_Transport
02_Industry
03_RestOfEnergy
04_PowerGeneration
05_Hydrogen
06_CO2
07_Emissions
08_Prices
09_Heat
Prefixes (V01, i01, etc.) map directly to these numbers.
----------------------------------------
5. INTERDEPENDENT VARIABLE/INPUT USAGE
----------------------------------------
Only use Vm / im prefixes if:
- The variable/input is referenced or calculated across more than one module
- There is logical dependency between modules (e.g. shared emissions factors,
activity drivers, prices, or capacity assumptions)

Otherwise, keep the variable/input confined to its module with a Vxx / ixx prefix.
-------------------------------
6. PRACTICAL NAMING EXAMPLES
-------------------------------
Interdependent Variable:
VmCO2Emissions(allCy,SECT,YTIME)       ! CO2 output, calculated across sectors
Transport-specific Variable:
V01NewRegCar(allCy,CARTECH,YTIME)      ! New registrations in transport
Core Input shared across modules:
imGDP(allCy,YTIME)                     ! GDP used by multiple modules
Power Gen-only Input:
i04PlantLifetime(PGALL)                ! Power plant lifetime for investment
* Cost: Cost
* Cap: Capacity
* Dem: Demand
* Pow: Power
* Prod: Production
* Cons: Consumption
* Gen: Generation
* Req: Required
* Price: Pri
* Fin: Final
* Ene: Energy
* Elec: Electricity
* Ren: Renewable
* Sec: Sector
* Contr: Contribution
* Curr: Current
* Pot: Potential
* Tr: Transport
* Ind: Industry
* Indx: Index
* Inv: Investment
* Dom: Domestic
* Dec: Decision
* Mat: Maturity
* Fac: Factor
* Mult: Multiplier
* Endog: Endogenous
* Exog: Exogenous
* Allow: Allowed
* Maxm: Maximum
* Mnm: Minimum
* Pc: Passenger Cars
* Cum: Cummulative
* Imp: Imports
* Exp: Exports
* Bsl: Base Load
* Tot: Total
* Tech: Technology
* Var: Variable
* Pol: Policy
* Chp: Combined Heat and Power plants
* Ccs: Carbon capture and storage
* Clim: Climate
* Est: Estimated
* Transf: Transformation
* Capt: Captured
* Seq: Sequestration
* NAP: National Allocation Plan
* Carb: Carbon
* Val: Value
* Subsec: Subsector
* Sub: Substitutable
* Avg: Average
* Consu: Consumers
==============================================================================*
END OF NAMING CONVENTION                            *
==============================================================================*


Authors
-------

Maro Baka <Maro.Baka@ricardo.com>, 
Panagiotis Fragkos <Panagiotis.Fragkos@ricardo.com>, 
Anastasis Giannousakis <Anastasis.Giannousakis@ricardo.com>, 
Michael Madianos <Michael.Madianos@ricardo.com>, 
Giorgos Plessias <George.Plessias@ricardo.com>, 
Dionysis Pramangioulis <dionysis.pramangioulis@ricardo.com>, 
Sonja Sechi <Sonja.Sechi@ricardo.com>, 
Fotis Sioutas <Fotis.Sioutas@ricardo.com>, 
Alexandros Tsimpoukis <Alexandros.Tsimpoukis@ricardo.com>, 
Eleftheria Zisarou <Eleftheria.Zisarou@ricardo.com>, 
Giannis Tolios

How to cite
-----------

Baka M, Fragkos P, Giannousakis A, Madianos M, Plessias G,
Pramangioulis D, Sechi S, Sioutas F, Tsimpoukis A, Zisarou E, Tolios G
(2024). “OPEN PROM - Version 0.1.”

### Bibtex format

```
@Misc{,
  title = {OPEN PROM - Version 0.1},
  author = {Maro Baka and Panagiotis Fragkos and Anastasis Giannousakis and Michael Madianos and Giorgos Plessias and Dionysis Pramangioulis and Sonja Sechi and Fotis Sioutas and Alexandros Tsimpoukis and Eleftheria Zisarou and Giannis Tolios},
  date = {2024-05-13},
  year = {2024},
}
```

### Citation File Format

```
cff-version: 1.0.3
message: ~
authors:
- family-names: Baka
  given-names: Maro
  affiliation: E3Modelling-Ricardo
  email: Maro.Baka@ricardo.com
- family-names: Fragkos
  given-names: Panagiotis
  affiliation: E3Modelling-Ricardo
  email: Panagiotis.Fragkos@ricardo.com
- family-names: Giannousakis
  given-names: Anastasis
  affiliation: E3Modelling-Ricardo
  email: Anastasis.Giannousakis@ricardo.com
- family-names: Madianos
  given-names: Michael
  affiliation: E3Modelling-Ricardo
  email: Michael.Madianos@ricardo.com
- family-names: Plessias
  given-names: Giorgos
  affiliation: E3Modelling-Ricardo
  email: George.Plessias@ricardo.com
- family-names: Pramangioulis
  given-names: Dionysis
  affiliation: E3Modelling-Ricardo
  email: dionysis.pramangioulis@ricardo.com
- family-names: Sechi
  given-names: Sonja
  affiliation: E3Modelling-Ricardo
  email: Sonja.Sechi@ricardo.com
- family-names: Sioutas
  given-names: Fotis
  affiliation: E3Modelling-Ricardo
  email: Fotis.Sioutas@ricardo.com
- family-names: Tsimpoukis
  given-names: Alexandros
  affiliation: E3Modelling-Ricardo
  email: Alexandros.Tsimpoukis@ricardo.com
- family-names: Zisarou
  given-names: Eleftheria
  affiliation: E3Modelling-Ricardo
  email: Eleftheria.Zisarou@ricardo.com
- family-names: Tolios
  given-names: Giannis
  affiliation: ~
  email: ~
title: OPEN PROM
version: '0.1'
date-released: '2024-05-13'
repository-code: https://github.com/e3modelling/OPEN-PROM
keywords: prometheus
license: GNU AGPLv3

```

