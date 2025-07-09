
# 🌍 Soft-Linking Tutorial: OPEN-PROM ↔ MAgPIE

This guide explains how to use the soft-linking functionality between the **OPEN-PROM** energy system model and the **MAgPIE** land-use model using two R functions:

- `linkPromToMagpie()` → For exporting data from **OPEN-PROM to MAgPIE**.
- `MAgPIE2OPEN()` → For importing data from **MAgPIE to OPEN-PROM**.

It also describes the internal **model switch logic** implemented in `OPEN-PROM` to conditionally enable or disable this integration.

---

## ⚙️ Model Integration Switch (in OPEN-PROM)

OPEN-PROM includes a conditional switch that enables or disables the use of MAgPIE-derived inputs. This is done using the global flag:

```gams
$setGlobal link2MAgPIE on
```

In `input.gms`, a conditional block reads MAgPIE-based biomass prices **only if the switch is activated**:

```gams
$ifthen %link2MAgPIE% == on
table iPricesMagpie(allCy,SBS,YTIME)
$ondelim
$include "./iPrices_magpie.csv"
$offdelim
;
$endif
```

In the **preloop** phase, the fuel price values are set via:

```gams
$IF %link2MAgPIE% == on 
VmPriceFuelSubsecCarVal.FX(runCy,SBS,"BMSWAS",YTIME)$(An(YTIME)) = iPricesMagpie(runCy,SBS,YTIME);
```

In the **equation definitions**, the switch logic is embedded using a combination of `$IFTHEN` and `$(...)`:

```gams
Q08PriceFuelSubsecCarVal(allCy,SBS,EF,YTIME)$(SECTTECH(SBS,EF) $TIME(YTIME)
$IFTHEN %link2MAgPIE% == on 
   $(not sameas("BMSWAS",EF))
$ENDIF
   $(not sameas("NUC",EF)) $runCy(allCy))..
   VmPriceFuelSubsecCarVal(allCy,SBS,EF,YTIME) =E= ...
```

This ensures that if the user sets `link2MAgPIE = on`, MAgPIE-derived values will override default ones for bioenergy prices and emissions.

---

## 🔄 R Code for Data Exchange

### 1️⃣ From OPEN-PROM → MAgPIE

This direction is triggered using the following R command:

```r
linkPromToMagpie("path/to/output.gdx", 
                 "path/to/f56_pollutant_prices.cs3", 
                 "path/to/f60_1stgen_bioenergy_dem.cs3")
```

This function:
- Extracts **carbon prices** and **bioenergy demand** from an OPEN-PROM `.gdx` file.
- Converts carbon prices to MAgPIE's expected format (in CO2 pollutant units).
- Converts bioenergy demand from **Mtoe → PJ**, aggregated to MAgPIE's regions.
- Writes two `.cs3` files that MAgPIE uses as scenario-specific inputs:
  - `f56_pollutant_prices.cs3` (carbon price trajectories)
  - `f60_1stgen_bioenergy_dem.cs3` (bioenergy demand)

These outputs are then copied into MAgPIE’s input folders before its execution.

---

### 2️⃣ From MAgPIE → OPEN-PROM

After running MAgPIE, the reverse link is executed using:

```r
MAgPIE2OPEN("path/to/input.gdx", 
            "path/to/output/report.mif", 
            "path/to/OPEN-PROM/input/folder/")
```

This function:
- Reads the `.mif` report from MAgPIE and extracts:
  - **Biomass prices** (converted to USD2015/toe).
  - **Land-use emissions** (CO2 and other gases).
- Processes and interpolates the results.
- Converts MAgPIE region format to match OPEN-PROM.
- Saves two CSV files in OPEN-PROM format:
  - `iPrices_magpie.csv` – bioenergy fuel prices by sector and region
  - `iEmissions_magpie.csv` – emissions data from the AFOLU sector

These files are then picked up by OPEN-PROM during its second model run, completing the loop.

---

## 🔁 Full Workflow

The full sequence for executing the soft-link is:

1. Run OPEN-PROM with `link2MAgPIE = off` to generate carbon prices and bioenergy demand.
2. Execute `linkPromToMagpie()` to generate MAgPIE input files.
3. Run MAgPIE using the updated `.cs3` input files.
4. Execute `MAgPIE2OPEN()` to extract and reformat the outputs.
5. Run OPEN-PROM again with `link2MAgPIE = on` to finalize results using land-informed biomass prices and emissions.

This setup ensures a flexible and traceable workflow for coupling energy system and land-use models using a modular and scenario-driven approach. The conditional GAMS switches allow seamless toggling, while the R script handles all the data transformations.