
Equations
*** Power Generation
QElecDem(allCy,YTIME)     "Compute total electricity demand"

*** Transport
qMExtV(allCy,YTIME)       "Compute passenger cars market extension (GDP dependent)"
qMExtF(allCy,YTIME)       "Compute passenger cars market extension (GDP independent)"
qNumVeh(allCy,YTIME)      "Compute stock of passenger cars (in million vehicles)"

qDummyObj                 "Define dummy objective function"
;

Variables
VElecDem(allCy,YTIME)          "Total electricity demand (TWh)"
VFeCons(allCy,EF,YTIME)        "Total final energy consumnption (Mtoe)"
VFNonEnCons(allCy,EFS,YTIME)   "Final non energy consumption (Mtoe)"
VLosses(allCy,EFS,YTIME)       "Distribution losses (Mtoe)"
VEnCons(allCy,EFS,YTIME)       "Final consumption in energy sector (Mtoe)"
VNetImp(allCy,EFS,YTIME)       "Net imports (Mtoe)"
VMExtV(allCy,YTIME)            "Passenger cars market extension (GDP dependent)"
VMExtF(allCy,YTIME)            "Passenger cars market extension (GDP independent)"
VLamda(allCy,YTIME)            "Ratio of car ownership over saturation car ownership (1)"
VNumVeh(allCy,YTIME)           "Stock of passenger cars (million vehicles)"
vDummyObj                      "Dummy maximisation variable (1)"
;

Scalars
sTWhToMtoe   "TWh to Mtoe conversion factor" /0.086/
;