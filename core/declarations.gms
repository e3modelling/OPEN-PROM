*' @title Core Declarations
*' @code

$IFTHEN.calib %Calibration% == MatCalibration
Equations
qDummyObj                                                  "Define dummy objective function"
;
*---
Variables
vDummyObj                                                  "Dummy maximisation variable (1)"
;
$ENDIF.calib

Scalars
smTWhToMtoe                                                "TWh to Mtoe conversion factor" /0.086/
smElecToSteRatioChp                                        "Technical maximum of electricity to steam ratio in CHP plants" /0.9/
sIter                                                      "time step iterator" /0/
sSolverTryMax                                              "maximum attempts to solve each time step" /%SolverTryMax%/
sModelStat                                                 "helper parameter for solver status"
smFracElecPriChp                                           "Fraction of Electricity Price at which a CHP sells electricity to network" /0/
sCY                                                        "country iterator" /0/
sUnitToKUnit                                               "units to Kilo units conversion" /1000/
;