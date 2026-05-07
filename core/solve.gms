loop an do !! start outer iteration loop (time steps)
   sIter = sIter + 1;
   TIME(YTIME) = NO;
   TIME(AN)$(ord(an)=sIter) = YES;
   display TIME;
   sCY = 0;
   loop runCyL do !! start countries loop
      sCY = sCY + 1;
      runCy(allCy) = NO;
      runCy(runCyL)$(ord(runCyL)=sCY) = YES;
      display runCy;
      
    sModelStat = 100;
    loop rcc$(rcc.ord <= sSolverTryMax) do !! start inner iteration loop (solver attempts)
        if sModelStat gt 2 then
            solve openprom using nlp minimizing vDummyObj;
            sModelStat = openprom.modelstat;
            ODummyObj(runCyL,YTIME)$TIME(YTIME) = vDummyObj.L;  !! Assign objective function value
$ifthen.calib %Calibration% == MatCalibration
            ODummyObjPGALL(runCyL,YTIME)$TIME(YTIME) = vDummyObjPGALL.L;  !! Assign objective function value for PGALL
            ODummyObjTRANSE(runCyL,YTIME)$TIME(YTIME) = vDummyObjTRANSE.L;  !! Assign objective function value for TRANSE
            ODummyObjDOMSE1(runCyL,YTIME)$TIME(YTIME) = vDummyObjDOMSE1.L;  !! Assign objective function value for DOMSE1
            ODummyObjDOMSE2(runCyL,YTIME)$TIME(YTIME) = vDummyObjDOMSE2.L;  !! Assign objective function value for DOMSE2
$ENDIF.calib
        endif;
    endloop;


put fStat;
put "Country:", runCyL.tl, " Model Status:", sModelStat:0:2, " Year:", an.tl /;
