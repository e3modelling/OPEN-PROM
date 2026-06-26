*' @title Agriculture Sets
*' @code

sets

*---
FOOD_TYPES       Food types /PLANT,MEAT,FISH/
AGRI_MODES       Agriculture energy services  /CROPS,IRRIGATION,CLIMATE,POSTHARVESTING,LIVESTOCK,FORESTRY,FISHING/
FERT_TYPES       Fertilizer types /N,PH,K/

MODEStoFOOD(AGRI_MODES,FOOD_TYPES)      "Agriculture modes mapped to the corresponding food type production"
/
CROPS.PLANT
LIVESTOCK.MEAT
FISHING.FISH
/

AGRITECH(TTECH)
/
TELC
TGDO
/

AGRMODEStoTECH(AGRI_MODES,AGRITECH)
/
CROPS.TGDO
LIVESTOCK.TELC
/
;

alias(AGRITECH, AGRITECH2);
