
Equations
*** Power Generation
QElecDem(allCy,YTIME)     "Calculate total electricity demand"

*** Transport
qMExtV(allCy,YTIME)       "Equation for passenger cars market extension (GDP dependent)"

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
vDummyObj                      "Dummy maximisation variable (1)"
;

Scalars
sTWhToMtoe   "TWh to Mtoe conversion factor" /0.086/
;