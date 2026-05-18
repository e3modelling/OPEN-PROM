loop an do !! start outer iteration loop (time steps)
   sIter = sIter + 1;
   TIME(YTIME) = NO;
   TIME(AN)$(ord(an)=sIter) = YES;
   display TIME;
$ifthen.curves "%Curves%" == "LearningCurves"
   p10CumCapGlobal(LCTECH,YTIME)$TIME(YTIME) = p10CumCapGlobal(LCTECH,YTIME-1);
$endif.curves
   sCY = 0;

$ifthen.countryParallel "%CountrySolveMode%" == "parallel"
   openprom.solveLink = %solveLink.asyncThreads%;
   pSolveHandle(runCyL) = 0;

   loop runCyL do !! submit one asynchronous solve per country
      sCY = sCY + 1;
      runCy(allCy) = NO;
      runCy(runCyL)$(ord(runCyL)=sCY) = YES;
      display runCy;

      solve openprom using nlp minimizing vDummyObj;
      pSolveHandle(runCyL) = openprom.handle;
   endloop;

$onImplicitAssign
   sCY = 0;
   loop runCyL do !! start countries loop; collect each country solution before postsolve
      sCY = sCY + 1;
      runCy(allCy) = NO;
      runCy(runCyL)$(ord(runCyL)=sCY) = YES;

      sAsyncAttempt = 1;
      sModelStat = 100;

      repeat
         repeat
            sAsyncWaitHandle = pSolveHandle(runCyL);
            sHandleCollect = handleCollect(pSolveHandle(runCyL));
            if sHandleCollect = 0 then
               sReadyCollect = readyCollect(sAsyncWaitHandle, 100);
               display$sReadyCollect "Problem waiting for asynchronous solve handle", runCyL, sReadyCollect;
            endif;
         until sHandleCollect;

         sModelStat = openprom.modelstat;
         display sModelStat;
         display$handleDelete(pSolveHandle(runCyL)) "Trouble deleting asynchronous solve handle", runCyL;
         pSolveHandle(runCyL) = 0;

         if (sModelStat gt 2) and (sAsyncAttempt lt sSolverTryMax) then
            sAsyncAttempt = sAsyncAttempt + 1;
            solve openprom using nlp minimizing vDummyObj;
            pSolveHandle(runCyL) = openprom.handle;
         endif;
      until (sModelStat le 2) or (sAsyncAttempt ge sSolverTryMax);

      ODummyObj(runCyL,YTIME)$TIME(YTIME) = vDummyObj.L;  !! Assign objective function value
$ifthen.calib %Calibration% == MatCalibration
      ODummyObjPGALL(runCyL,YTIME)$TIME(YTIME) = vDummyObjPGALL.L;  !! Assign objective function value for PGALL
      ODummyObjTRANSE(runCyL,YTIME)$TIME(YTIME) = vDummyObjTRANSE.L;  !! Assign objective function value for TRANSE
      ODummyObjINDDOMShares(allCy,YTIME,DSBS)$(TIME(YTIME) and runCy(allCy) and ((INDDOM(DSBS) or sameas("NEN",DSBS) or sameas("PCH",DSBS)) and not (sameas("AG",DSBS) and not EU28(allCy)))) = vDummyObjINDDOMShares.L(DSBS);  !! Assign objective function value for INDDOM Shares
      ODummyObjINDDOMFinalEnergy(allCy,YTIME,DSBS)$(TIME(YTIME) and runCy(allCy) and ((INDDOM(DSBS) or sameas("NEN",DSBS) or sameas("PCH",DSBS)) and not (sameas("AG",DSBS) and not EU28(allCy)))) = vDummyObjINDDOMFinalEnergy.L(DSBS);  !! Assign objective function value for INDDOM Final Energy
$ENDIF.calib

      put fStat;
      put "Country:", runCyL.tl, " Model Status:", sModelStat:0:2, " Year:", an.tl /;
$else.countryParallel
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
            ODummyObjDOMSEShares(allCy,YTIME,DSBS)$(TIME(YTIME) and runCy(allCy) and ((INDDOM(DSBS) or sameas("NEN",DSBS) or sameas("PCH",DSBS)) and not (sameas("AG",DSBS) and not EU28(allCy)))) = vDummyObjDOMSEShares.L(DSBS);  !! Assign objective function value for DOMSE Shares
            ODummyObjDOMSEFinalEnergy(allCy,YTIME,DSBS)$(TIME(YTIME) and runCy(allCy) and ((INDDOM(DSBS) or sameas("NEN",DSBS) or sameas("PCH",DSBS)) and not (sameas("AG",DSBS) and not EU28(allCy)))) = vDummyObjDOMSEFinalEnergy.L(DSBS);  !! Assign objective function value for DOMSE Final Energy
$endif.calib
         endif;
      endloop;

      put fStat;
      put "Country:", runCyL.tl, " Model Status:", sModelStat:0:2, " Year:", an.tl /;
$endif.countryParallel