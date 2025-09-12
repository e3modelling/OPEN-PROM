*' @title Transport Declarations
*' @code

Equations
*' *** Transport
Q01ActivGoodsTransp(allCy,TRANSE,YTIME)                    "Compute goods transport activity"
Q01GapTranspActiv(allCy,TRANSE,YTIME)	                   "Compute the gap in transport activity"
Q01ConsSpecificFuel(allCy,TRANSE,TTECH,EF,YTIME)	       "Compute Specific Fuel Consumption"
Q01CostTranspPerMeanConsSize(allCy,TRANSE,TTECH,YTIME)    "Compute transportation cost per mean in KUS$2015 per vehicle"
Q01ShareTechTr(allCy,TRANSE,EF,YTIME)	                   "Compute technology sorting based on variable cost and new equipment"
Q01ConsTechTranspSectoral(allCy,TRANSE,TTECH,EF,YTIME)	   "Compute consumption of each technology in transport sectors"
*q01DemFinEneSubTransp(allCy,TRANSE,YTIME)	               "Compute final energy demand in transport"
Q01StockPcYearly(allCy,YTIME)                              "Compute stock of passenger cars (in million vehicles)"
Q01StockPcYearlyTech(allCy,TTECH,YTIME)                    "Compute stock of passenger cars (in million vehicles)"
Q01NewRegPcYearly(allCy,YTIME)                             "Compute new registrations of passenger cars per technology"
Q01ActivPassTrnsp(allCy,TRANSE,YTIME)                      "Compute passenger transport acitivity"
Q01NumPcScrap(allCy,YTIME)                                 "Compute scrapped passenger cars"
Q01PcOwnPcLevl(allCy,YTIME)                                "Compute ratio of car ownership over saturation car ownership"
Q01RateScrPc(allCy,YTIME)                                  "Compute passenger cars scrapping rate"
Q01CapCostAnnualized(allCy,TRANSE,TTECH,YTIME)
Q01CostFuel(allCy,TRANSE,TTECH,YTIME)
*'                **Interdependent Equations**
Q01DemFinEneTranspPerFuel(allCy,TRANSE,EF,YTIME)	       "Compute final energy demand in transport per fuel"
Q01Lft(allCy,DSBS,EF,YTIME)	                               "Compute the lifetime of passenger cars" 
;

Variables
*' *** Transport Variables
V01ActivGoodsTransp(allCy,TRANSE,YTIME)	                   "Goods transport acitivity (Gtkm)"
V01GapTranspActiv(allCy,TRANSE,YTIME)	                   "Gap in transport activity to be filled by new technologies ()"
                                                                !! Gap for passenger cars (million vehicles)
                                                                !! Gap for all other passenger transportation modes (Gpkm)
                                                                !! Gap for all goods transport is measured (Gtkm)
V01ConsSpecificFuel(allCy,TRANSE,TTECH,EF,YTIME)	       "Specific Fuel Consumption ()"
                                                                !! SFC for passenger cars (ktoe/Gkm)
                                                                !! SFC for other passsenger transportation modes (ktoe/Gpkm)
                                                                !! SFC for trucks is measured (ktoe/Gtkm)
V01CostTranspPerMeanConsSize(allCy,TRANSE,TTECH,YTIME)    "Transportation cost per mean (KUS$2015/vehicle)"
V01ShareTechTr(allCy,TRANSE,EF,YTIME)	                   "Technology share in new equipment (1)"
V01ConsTechTranspSectoral(allCy,TRANSE,TTECH,EF,YTIME)	   "Consumption of each technology and subsector (Mtoe)"
*v01DemFinEneSubTransp(allCy,TRANSE,YTIME)	               "Final energy demand in transport subsectors (Mtoe)"
V01StockPcYearly(allCy,YTIME)                              "Stock of passenger cars (million vehicles)"
V01StockPcYearlyTech(allCy,TTECH,YTIME)                    "stock of passenger cars per technology (in million vehicles)"
V01NewRegPcYearly(allCy,YTIME)                             "Passenger cars new registrations (million vehicles)"
V01ActivPassTrnsp(allCy,TRANSE,YTIME)                      "Passenger transport activity (1)"
                                                                !! - Activity for passenger cars is measured in (000)km
                                                                !! - Activity for passenger aviation million passengers carried
                                                                !! - Activity for all other passenger transportation modes is measured in Gpkm
V01NumPcScrap(allCy,YTIME)                                 "Scrapped passenger cars (million vehicles)"
V01PcOwnPcLevl(allCy,YTIME)                                "Ratio of car ownership over saturation car ownership (1)"
V01RateScrPc(allCy,YTIME)                                  "Scrapping rate of passenger cars (1)"
V01CapCostAnnualized(allCy,TRANSE,TTECH,YTIME)
V01CostFuel(allCy,TRANSE,TTECH,YTIME)
*'                **Interdependent Equations**
VmDemFinEneTranspPerFuel(allCy,TRANSE,EF,YTIME)            "Final energy demand in transport subsectors per fuel (Mtoe)"
VmLft(allCy,DSBS,EF,YTIME)                                 "Lifetime of technologies (years)"
;