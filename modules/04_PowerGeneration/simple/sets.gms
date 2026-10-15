*' @title PowerGeneration Sets
*' @code

*---
PGEF(EFS)        "Energy forms used for steam production"
;
PGEF(EFS) = yes$(sum(PGALL, PGALLTOEF(PGALL,EFS)));
ALIAS (PGEF2,PGEF);