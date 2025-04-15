library(openprom)
library(gdx)
library(ggplot2)
library(dplyr)
library(quitte)

runpath <- "C:/Users/mm102/e3/OPEN-PROM/runs/COPY"

capacity_vars <- c(
  "Capacity|Electricity|Solar",
  "Capacity|Electricity|Oil",
  "Capacity|Electricity|Wind",
  "Capacity|Electricity|Coal",
  "Capacity|Electricity|Gas",
  "Capacity|Electricity|Nuclear",
  "Capacity|Electricity|Biomass",
  "Capacity|Electricity|Geothermal"
)

capacity_sol <- c(
  "Capacity|Electricity|PGADPV",
  "Capacity|Electricity|PGASOL",
  "Capacity|Electricity|PGSOL",
)

capacity_wind <- c(
  "Capacity|Electricity|PGAWND",
  "Capacity|Electricity|PGAWNO",
  "Capacity|Electricity|PGWND",
)

FE_vars <- c(
  "Final Energy|Solids",
  "Final Energy|Hydrogen",
  "Final Energy|Gases",
  "Final Energy|Electricity",
  "Final Energy|Liquids",
  "Final Energy|Heat",
  "Final Energy|Biomass"
)

FE_industry <- c(
  "Final Energy|Industry",
  "Final Energy|Transportation",
  "Final Energy|Residential and Commercial",
  "Final Energy|Non Energy and Bunkers"
)

SE_vars <- c(
  "Secondary Energy|Electricity|Solar",
  "Secondary Energy|Electricity|Oil",
  "Secondary Energy|Electricity|Wind",
  "Secondary Energy|Electricity|Coal",
  "Secondary Energy|Electricity|Gas",
  "Secondary Energy|Electricity|Nuclear",
  "Secondary Energy|Electricity|Biomass",
  "Secondary Energy|Electricity|Geothermal"
)

SE_wind <- c(
  "Secondary Energy|Electricity|PGAWND",
  "Secondary Energy|Electricity|PGAWNO",
  "Secondary Energy|Electricity|PGWND"
)
SE_sol <- c(
  "Secondary Energy|Electricity|PGADPV",
  "Secondary Energy|Electricity|PGASOL",
  "Secondary Energy|Electricity|PGSOL"
)

Emissions_vars <- c(
  "Emissions|CO2|Energy|Demand|Bunkers", "Emissions|CO2|Energy|Demand|Industry",
  "Emissions|CO2|Energy|Demand|Residential and Commercial",
  "Emissions|CO2|Energy|Demand|Transportation", "Emissions|CO2|Energy|Supply"
)

Emissions_cumulated <- c("Emissions|CO2|Cumulated")
# runCY <- readGDX(file.path(runpath, "blabla.gdx"), "runCYL")

obj <- reportCapacityElectricity(file.path(runpath, "blabla.gdx"), c("MEA", "USA", "LAM"))
#obj2 <- reportFinalEnergy(file.path(runpath, "blabla.gdx"), c("MEA", "USA", "LAM"))
# obj3 <- reportSE(file.path(runpath, "blabla.gdx"), c("MEA", "USA", "LAM"))
#Emissions <- reportEmissions(file.path(runpath, "blabla.gdx"), c("MEA", "USA", "LAM"))
an <- readGDX(file.path(runpath, "blabla.gdx"), "an", field = "l", c("MEA", "USA", "LAM"))
plotReport(obj, an, capacity_vars, "bar", save_name = "a.png")
