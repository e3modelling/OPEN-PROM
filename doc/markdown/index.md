OPEN PROM
=========

This is the OPEN-PROM model, the open version of the 
world energy model PROMETHEUS of E3Modelling. 

Some preliminary documentation of OPEN-PROM can be found in the 
Wiki of this repository, extensive documentation of the PROMETHEUS model 
(on which both MENA-EDS and OPEN-PROM are based) can be found 
here: https://e3modelling.com/modelling-tools/prometheus/

*** preliminaries 

```
option limcol = 16;
```

*** number of rows that are listed for each equation in the equation listing

```
option limrow = 16;
```

*** "dollar" ($) commands section: define GAMS flags & code control & compilation-time options

*** onEolCom: turn on end-of-line comments (starting with !!, i.e. the GAMS default)

```
$onEolCom
```

*** onEnd: turn on alternative flow control syntax (more readable loop, for, if etc.)
```
$onEnd
```

*** onEmpty allows declarations of empty parameters

```
$onEmpty
```

*** TODO: check if the contents of this block are actually used later

*** GAMS "flags" definitions

*** Maximum number of solver attempts

```
$evalGlobal SolverTryMax 1
```

```
$setGlobal fCountries 'RAS,RWO,REU,REP,RAF,RLA,ARG,OCE,AUT,BEL,BRA,BGR,CAN,CHA,HRV,CYP,CZE,DNK,EGY,EST,FIN,FRA,DEU,GRC,HUN,NSI,IND,IDN,IRN,IRL,ISR,ITA,JPN,KOR,LVA,LTU,LUX,MLT,MEX,MAR,NLD,NGA,POL,PRT,ROU,RUS,SAU,SVK,SVN,ZAF,ESP,SWE,TUN,TUR,GBR,USA'
```

```
$setGlobal fSingleCountryRun 'yes'
```

```
$setGlobal fCountryList %countries%
```

```
$setGlobal fScenario 'DECARB_400'
$setGlobal fBaseline 'BASE'
```

```
$evalGlobal fPeriodOfYears 1
```

```
$setGlobal fIncludeNonCO2 no
```

```
$setGlobal fReadCommonDB 'yes'
$setGlobal fReadCountryDB 'yes'
$setGlobal fReadCountryCalib 'yes'
```

```
$evalGlobal fStartHorizon 2010
$evalGlobal fEndHorizon 2100
$evalGlobal fEndY 2020
$evalGlobal fStartY 2018
$evalGlobal fBaseY %fStartY% - %fPeriodOfYears%
```

*** end of dollar commands section, no further flag definitions allowed 

*** load input data files

```
$include sets.gms
$include declarations.gms
$include input.gms
$include equations.gms
$include preloop.gms
$include solve.gms
```


Authors
-------

Giannousakis Anastasis <bat@m.an>, 
Plessias Georgios <bat@m.an>

How to cite
-----------

Anastasis G, Georgios P (2019). “OPEN PROM - Version 0.1.”

### Bibtex format

```
@Misc{,
  title = {OPEN PROM - Version 0.1},
  author = {Giannousakis Anastasis and Plessias Georgios},
  date = {2019-05-13},
  year = {2019},
}
```

### Citation File Format

```
cff-version: 1.0.3
message: If you use this model, please cite it as below.
authors:
- family-names: Anastasis
  given-names: Giannousakis
  affiliation: E3Modelling
  email: bat@m.an
- family-names: Georgios
  given-names: Plessias
  affiliation: E3Modelling
  email: bat@m.an
title: OPEN PROM
version: '0.1'
date-released: '2019-05-13'
repository-code: https://github.com/e3modelling/OPEN-PROM
keywords: testing
license: CC0

```

