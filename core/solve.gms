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
$IFTHEN.calib %Calibration% == MatCalibration
            solve openprom using nlp minimizing vDummyObj;
            ODummyObj(runCyL,YTIME)$TIME(YTIME) = vDummyObj.L;  !! Assign objective function value
$ELSE.calib
            solve openprom using cns;
$ENDIF.calib
            sModelStat = openprom.modelstat;
        endif;
    endloop;

put fStat;
put "Country:", runCyL.tl, " Model Status:", sModelStat:0:2, " Year:", an.tl /;
