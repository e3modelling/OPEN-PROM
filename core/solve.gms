*' @title Sets
*' @code
 
loop an do !! start outer iteration loop (time steps)
   s = s + 1;
   TIME(YTIME) = NO;
   TIME(AN)$(ord(an)=s) = YES;
   display TIME;
   cy = 0;
   loop runCyL do !! start countries loop
      cy = cy + 1;
      runCy(allCy) = NO;
      runCy(runCyL)$(ord(runCyL)=cy) = YES;
      display runCy;
      
    sModelStat = 100;
    loop rcc$(rcc.val <= sSolverTryMax) do !! start inner iteration loop (solver attempts)
        if sModelStat gt 2 then
            solve openprom using nlp minimizing vDummyObj;
            sModelStat = openprom.modelstat;
            ODummyObj(runCyL,YTIME)$TIME(YTIME) = vDummyObj.L;  !! Assign objective function value
        endif;
    endloop;


put fStat;
put "Country:", runCyL.tl, " Model Status:", sModelStat:0:2, " Year:", an.tl /;
