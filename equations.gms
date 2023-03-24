* Power Generation

* Calculate total electricity demand
QElecDem(runCy,YTIME)$TIME(YTIME)..
         VElecDem(runCy,YTIME)
             =E=
         1/sTWhToMtoe *
         ( VFeCons(runCy,"ELC",YTIME) + VFNonEnCons(runCy,"ELC",YTIME) + VLosses(runCy,"ELC",YTIME)
           + VEnCons(runCy,"ELC",YTIME) - VNetImp(runCy,"ELC",YTIME)
         );


* Transport

*$ontext
* Equation for passenger cars market extension (GDP dependent)
qMExtV(runCy,YTIME)$TIME(YTIME)..
         VMExtV(runCy,YTIME)
                 =E=
         iTransChar(runCy,"RES_MEXTV",YTIME) * VMExtV(runCy,YTIME-1) *
***         [(iGDP(runCy,YTIME)/iPop(runCy,YTIME)) / (iGDP(runCy,YTIME-1)/iPop(runCy,YTIME-1))] ** iElastA(runCy,"PC","a",YTIME)
         [(iGDP(YTIME,runCy)/(iPop(YTIME,runCy)+0.1)) / ((1+iGDP(YTIME-1,runCy))/(0.1+iPop(YTIME-1,runCy)))] ** iElastA(runCy,"PC","a",YTIME);
*$offtext

* Define dummy objective function
qDummyObj.. vDummyObj =e= 1;