library(dplyr)
library(gdx)
library(quitte)
library(tidyr)
library(utils)
library(mrprom)
library(stringr)

gdx <- "C:/Users/sioutas/github/open-prom-goxygen/OPEN-PROM/runs/USA"

# Link between Model Subsectors and Fuels
sets4 <- toolGetMapping(name = "SECTTECH.csv",
                        type = "blabla_export",
                        where = "mrprom")

# Industrial SubSectors
INDSE <- toolGetMapping(name = "INDSE.csv",
                        type = "blabla_export",
                        where = "mrprom")

# Take the Fuels of INDSE
sets4_INDSE <- filter(sets4, SBS %in% unique(INDSE[["INDSE"]]))

sets4_INDSE[["EF"]] = paste(sets4_INDSE[["SBS"]], sets4_INDSE[["EF"]], sep=".")

# Fuel consumption per fuel and subsector (Mtoe)
iFuelConsPerFueSub <- readGDX(paste0(gdx, './blabla.gdx'), "iFuelConsPerFueSub")

# Take the Fuels and sectors of INDSE
iFuelConsPerFueSub_INDSE <- iFuelConsPerFueSub[,,sets4_INDSE[["EF"]]]
iFuelConsPerFueSub_INDSE <- as.quitte(iFuelConsPerFueSub_INDSE)

# Consumption of fuels in each demand subsector including heat from heatpumps (Mtoe)
VConsFuelInclHP <- readGDX(paste0(gdx, './blabla.gdx'), "VConsFuelInclHP", field = 'l')

# Take the Fuels and sectors of INDSE
VConsFuelInclHP_INDSE <- VConsFuelInclHP[,,sets4_INDSE[["EF"]]]
VConsFuelInclHP_INDSE <- as.quitte(VConsFuelInclHP_INDSE)

names(VConsFuelInclHP_INDSE) <- sub("DSBS", "SBS", names(VConsFuelInclHP_INDSE))

# join in one dataset iFuelConsPerFueSub_INDSE and VConsFuelInclHP_INDSE
compare_INDSE <- left_join(iFuelConsPerFueSub_INDSE, VConsFuelInclHP_INDSE,
                         by = c("region", "model", "scenario", "variable", "unit",
                                "SBS", "EF", "period"))

# Tertiary SubSectors
DOMSE <- toolGetMapping(name = "DOMSE.csv",
                        type = "blabla_export",
                        where = "mrprom")

# Take the Fuels of DOMSE
sets4_DOMSE <- filter(sets4, SBS %in% unique(DOMSE[["DOMSE"]]))

sets4_DOMSE[["EF"]] = paste(sets4_DOMSE[["SBS"]], sets4_DOMSE[["EF"]], sep=".")

# Consumption of fuels in each demand subsector including heat from heatpumps (Mtoe) for Tertiary
VConsFuelInclHP_DOMSE <- VConsFuelInclHP[,,sets4_DOMSE[["EF"]]]
VConsFuelInclHP_DOMSE <- as.quitte(VConsFuelInclHP_DOMSE)
names(VConsFuelInclHP_DOMSE) <- sub("DSBS", "SBS", names(VConsFuelInclHP_DOMSE))

# Fuel consumption per fuel and subsector (Mtoe) for Tertiary
iFuelConsPerFueSub_DOMSE <- iFuelConsPerFueSub[,,sets4_DOMSE[["EF"]]]
iFuelConsPerFueSub_DOMSE <- as.quitte(iFuelConsPerFueSub_DOMSE)

# join in one dataset iFuelConsPerFueSub_DOMSE and VConsFuelInclHP_DOMSE
compare_DOMSE <- left_join(iFuelConsPerFueSub_DOMSE, VConsFuelInclHP_DOMSE,
                           by = c("region", "model", "scenario", "variable", "unit",
                                  "SBS", "EF", "period"))

# join in one dataset INDSE and DOMSE
compare_INDOM <- rbind(compare_INDSE, compare_DOMSE)

# All Transport Subsectors
TRANSE <- toolGetMapping(name = "TRANSE.csv",
                        type = "blabla_export",
                        where = "mrprom")

# Take the Fuels of Transport
map_TRANSECTOR <- sets4 %>% filter(SBS %in% TRANSE[,1])

map_TRANSECTOR[["EF"]] = paste(map_TRANSECTOR[["SBS"]], map_TRANSECTOR[["EF"]], sep=".")

# Final energy demand in transport subsectors per fuel (Mtoe)
VDemFinEneTranspPerFuel <- readGDX(paste0(gdx, './blabla.gdx'), "VDemFinEneTranspPerFuel", field = 'l')

# sectors and fuels of TRANSE
VDemFinEneTranspPerFuel_TRANSE <- VDemFinEneTranspPerFuel[,,map_TRANSECTOR[["EF"]]]

VDemFinEneTranspPerFuel_TRANSE <- as.quitte(VDemFinEneTranspPerFuel_TRANSE)

names(VDemFinEneTranspPerFuel_TRANSE) <- sub("TRANSE", "SBS", names(VDemFinEneTranspPerFuel_TRANSE))

# sectors and fuels of TRANSE
iFuelConsPerFueSub_TRANSE <- iFuelConsPerFueSub[,,map_TRANSECTOR[["EF"]]]

iFuelConsPerFueSub_TRANSE <- as.quitte(iFuelConsPerFueSub_TRANSE)

names(iFuelConsPerFueSub_TRANSE) <- sub("TRANSE", "SBS", names(iFuelConsPerFueSub_TRANSE))

# join in one dataset iFuelConsPerFueSub_TRANSE and VDemFinEneTranspPerFuel_TRANSE
compare_TRANSE <- left_join(iFuelConsPerFueSub_TRANSE, VDemFinEneTranspPerFuel_TRANSE,
                            by = c("region", "model", "scenario", "variable", "unit",
                                   "SBS", "EF", "period"))

# for the country that calibration run
runCy <- readGDX(paste0(gdx, './blabla.gdx'), "runCy")
# years for which the model run
an <- readGDX(paste0(gdx, './blabla.gdx'), "an")

### INDOM

names(compare_INDOM) <- sub("value.y","results_calib", names(compare_INDOM))
names(compare_INDOM) <- sub("value.x","targets_vanilla", names(compare_INDOM))

# difference between targets_vanilla and results_calib
compare_INDOM <- compare_INDOM %>% mutate(targets_vanilla_results_calib = (100 * (abs(targets_vanilla - results_calib))) / (0.5 * (abs(targets_vanilla + results_calib)))) %>% 
  filter(region %in% runCy[1] & period %in% an) %>% filter(targets_vanilla > 0.00001)

# take the column of the difference
compare_INDOM <- compare_INDOM %>% select(region, period, SBS, EF, targets_vanilla_results_calib)

# pivot_wider
compare_INDOM <- compare_INDOM %>%
  pivot_wider(names_from = period, values_from = targets_vanilla_results_calib)

# write in csv
write.csv(compare_INDOM, "results_INDOM.csv", row.names=FALSE)

### TRANSE

names(compare_TRANSE) <- sub("value.y","results_calib", names(compare_TRANSE))
names(compare_TRANSE) <- sub("value.x","targets_vanilla", names(compare_TRANSE))

# difference between targets_vanilla and results_calib
compare_TRANSE <- compare_TRANSE %>% mutate(targets_vanilla_results_calib = (100 * (abs(targets_vanilla - results_calib))) / (0.5 * (abs(targets_vanilla + results_calib)))) %>% 
  filter(region %in% runCy[1] & period %in% an) %>% filter(targets_vanilla > 0.00001)

# take the column of the difference
compare_TRANSE <- compare_TRANSE %>% select(region, period, SBS, EF, targets_vanilla_results_calib)

# pivot_wider
compare_TRANSE <- compare_TRANSE %>%
  pivot_wider(names_from = period, values_from = targets_vanilla_results_calib)

# write in csv
write.csv(compare_TRANSE, "results_TRANSE.csv", row.names=FALSE)

# to see the heatmap in excel
# you select the values and then Home -> Conditional Formatting -> Color Scales and select a color