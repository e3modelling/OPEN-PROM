*' @title Heat Inputs
*' @code

Parameters
*---
i09ProdLftSte(TCHP,YTIME)                  "Lifetime of steam production technologies in years"
i09CostVOMSteProd(allCy,TCHP,YTIME)
i09CaptRateSteProd(TCHP)
i09ScaleEndogScrap
;
*---
i09ProdLftSte(TCHP,YTIME) = 20;
i09CaptRateSteProd(TCHP) = 0;
i09CostVOMSteProd(allCy,TCHP,YTIME) = 0;
i09ScaleEndogScrap = 4 / card(TCHP);