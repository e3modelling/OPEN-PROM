    openprom.optfile=1;
    sModelStat = 100;
    loop rcc$(rcc.val <= sSolverTryMax) do
        if sModelStat ne 2 then
            solve openprom using nlp maximizing vDummyObj;
            sModelStat = openprom.modelstat;
        endif;
    endloop;    !! close inner iteration loop


endloop;  !! close outer iteration loop
