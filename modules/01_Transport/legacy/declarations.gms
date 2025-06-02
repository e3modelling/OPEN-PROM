*' @title Transport Declarations
*' @code

Equations
*' *** Transport
Q01ActivGoodsTransp(allCy,TRANSE,YTIME)                    "Compute goods transport activity"
Q01GapTranspActiv(allCy,TRANSE,YTIME)	                   "Compute the gap in transport activity"
Q01ConsSpecificFuel(allCy,TRANSE,TTECH,EF,YTIME)	       "Compute Specific Fuel Consumption"
Q01CostTranspPerMeanConsSize(allCy,TRANSE,RCon,TTECH,YTIME)"Compute transportation cost per mean and consumer size in KUS$2015 per vehicle"
Q01CostTranspPerVeh(allCy,TRANSE,RCon,TTECH,YTIME)	       "Compute transportation cost per mean and consumer size in KUS$2015 per vehicle"
Q01CostTranspMatFac(allCy,TRANSE,RCon,TTECH,YTIME)	       "Compute transportation cost including maturity factor"
Q01TechSortVarCost(allCy,TRANSE,Rcon,YTIME)	               "Compute technology sorting based on variable cost"
Q01ShareTechTr(allCy,TRANSE,EF,YTIME)	                   "Compute technology sorting based on variable cost and new equipment"
Q01ConsTechTranspSectoral(allCy,TRANSE,TTECH,EF,YTIME)	   "Compute consumption of each technology in transport sectors"
*q01DemFinEneSubTransp(allCy,TRANSE,YTIME)	               "Compute final energy demand in transport"
Q01MEPcGdp(allCy,YTIME)                                    "Compute passenger cars market extension (GDP dependent)"
Q01MEPcNonGdp(allCy,YTIME)                                 "Compute passenger cars market extension (GDP independent)"
Q01StockPcYearly(allCy,YTIME)                              "Compute stock of passenger cars (in million vehicles)"
Q01NewRegPcYearly(allCy,YTIME)                             "Compute new registrations of passenger cars"
Q01ActivPassTrnsp(allCy,TRANSE,YTIME)                      "Compute passenger transport acitivity"
Q01NumPcScrap(allCy,YTIME)                                 "Compute scrapped passenger cars"
Q01PcOwnPcLevl(allCy,YTIME)                                "Compute ratio of car ownership over saturation car ownership"
Q01RateScrPc(allCy,YTIME)                                  "Compute passenger cars scrapping rate"

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
V01CostTranspPerMeanConsSize(allCy,TRANSE,RCon,TTECH,YTIME)"Transportation cost per mean and consumer size (KUS$2015/vehicle)"
V01CostTranspPerVeh(allCy,TRANSE,RCon,TTECH,YTIME)	       "Transportation cost per mean and consumer size (KUS$2015/vehicle)"
V01CostTranspMatFac(allCy,TRANSE,RCon,TTECH,YTIME)	       "Transportation cost including maturity factor (KUS$2015/vehicle)"
V01TechSortVarCost(allCy,TRANSE,Rcon,YTIME)	               "Technology sorting based on variable cost (1)"
V01ShareTechTr(allCy,TRANSE,EF,YTIME)	                   "Technology share in new equipment (1)"
V01ConsTechTranspSectoral(allCy,TRANSE,TTECH,EF,YTIME)	   "Consumption of each technology and subsector (Mtoe)"
*v01DemFinEneSubTransp(allCy,TRANSE,YTIME)	               "Final energy demand in transport subsectors (Mtoe)"
V01MEPcGdp(allCy,YTIME)                                    "Passenger cars market extension (GDP dependent)"
V01MEPcNonGdp(allCy,YTIME)                                 "Passenger cars market extension (GDP independent)"
V01StockPcYearly(allCy,YTIME)                              "Stock of passenger cars (million vehicles)"
V01NewRegPcYearly(allCy,YTIME)                             "Passenger cars new registrations (million vehicles)"
V01ActivPassTrnsp(allCy,TRANSE,YTIME)                      "Passenger transport acitivity (1)"
                                                                !! - Activity for passenger cars is measured in (000)km
                                                                !! - Activity for passenger aviation million passengers carried
                                                                !! - Activity for all other passenger transportation modes is measured in Gpkm
V01NumPcScrap(allCy,YTIME)                                 "Scrapped passenger cars (million vehicles)"
V01PcOwnPcLevl(allCy,YTIME)                                "Ratio of car ownership over saturation car ownership (1)"
V01RateScrPc(allCy,YTIME)                                  "Scrapping rate of passenger cars (1)"

*'                **Interdependent Equations**
MVConsElecNonSubIndTert(allCy,DSBS,YTIME)                  "Consumption of non-substituable electricity in Industry and Tertiary (Mtoe)"
MVDemFinEneTranspPerFuel(allCy,TRANSE,EF,YTIME)            "Final energy demand in transport subsectors per fuel (Mtoe)"
MVLft(allCy,DSBS,EF,YTIME)                                 "Lifetime of technologies (years)"
;