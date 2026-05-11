loop an do !! start outer iteration loop (time steps)
   sIter = sIter + 1;
   TIME(YTIME) = NO;
   TIME(AN)$(ord(an)=sIter) = YES;
   display TIME;
   sCY = 0;

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
         display$handleDelete(pSolveHandle(runCyL)) "Trouble deleting asynchronous solve handle", runCyL;
         pSolveHandle(runCyL) = 0;

         if (sModelStat gt 2) and (sAsyncAttempt lt sSolverTryMax) then
            sAsyncAttempt = sAsyncAttempt + 1;
            solve openprom using nlp minimizing vDummyObj;
            pSolveHandle(runCyL) = openprom.handle;
         endif;
      until (sModelStat le 2) or (sAsyncAttempt ge sSolverTryMax);

      ODummyObj(runCyL,YTIME)$TIME(YTIME) = vDummyObj.L;  !! Assign objective function value

      put fStat;
      put "Country:", runCyL.tl, " Model Status:", sModelStat:0:2, " Year:", an.tl /;
