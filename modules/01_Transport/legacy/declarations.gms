*' @title Transport Declarations
*' @code

Equations
*' *** Transport
QActivGoodsTransp(allCy,TRANSE,YTIME)                      "Compute goods transport activity"
QGapTranspActiv(allCy,TRANSE,YTIME)	                       "Compute the gap in transport activity"
QConsSpecificFuel(allCy,TRANSE,TTECH,EF,YTIME)	           "Compute Specific Fuel Consumption"
QCostTranspPerMeanConsSize(allCy,TRANSE,RCon,TTECH,YTIME)  "Compute transportation cost per mean and consumer size in KUS$2015 per vehicle"
QCostTranspPerVeh(allCy,TRANSE,RCon,TTECH,YTIME)	       "Compute transportation cost per mean and consumer size in KUS$2015 per vehicle"
QCostTranspMatFac(allCy,TRANSE,RCon,TTECH,YTIME)	       "Compute transportation cost including maturity factor"
QTechSortVarCost(allCy,TRANSE,Rcon,YTIME)	               "Compute technology sorting based on variable cost"
QShareTechTr(allCy,TRANSE,EF,YTIME)	                       "Compute technology sorting based on variable cost and new equipment"
QConsTechTranspSectoral(allCy,TRANSE,TTECH,EF,YTIME)	   "Compute consumption of each technology in transport sectors"
*qDemFinEneSubTransp(allCy,TRANSE,YTIME)	               "Compute final energy demand in transport"
QMEPcGdp(allCy,YTIME)                                      "Compute passenger cars market extension (GDP dependent)"
QMEPcNonGdp(allCy,YTIME)                                   "Compute passenger cars market extension (GDP independent)"
QStockPcYearly(allCy,YTIME)                                "Compute stock of passenger cars (in million vehicles)"
QNewRegPcYearly(allCy,YTIME)                               "Compute new registrations of passenger cars"
QActivPassTrnsp(allCy,TRANSE,YTIME)                        "Compute passenger transport acitivity"
QNumPcScrap(allCy,YTIME)                                   "Compute scrapped passenger cars"
QPcOwnPcLevl(allCy,YTIME)                                  "Compute ratio of car ownership over saturation car ownership"
QRateScrPc(allCy,YTIME)                                    "Compute passenger cars scrapping rate"

*'                **Interdependent Equations**
Q01DemFinEneTranspPerFuel(allCy,TRANSE,EF,YTIME)	           "Compute final energy demand in transport per fuel"
Q01Lft(allCy,DSBS,EF,YTIME)	                               "Compute the lifetime of passenger cars" 
;

Variables
*' *** Transport Variables
VActivGoodsTransp(allCy,TRANSE,YTIME)	                   "Goods transport acitivity (Gtkm)"
VGapTranspActiv(allCy,TRANSE,YTIME)	                       "Gap in transport activity to be filled by new technologies ()"
                                                                !! Gap for passenger cars (million vehicles)
                                                                !! Gap for all other passenger transportation modes (Gpkm)
                                                                !! Gap for all goods transport is measured (Gtkm)
VConsSpecificFuel(allCy,TRANSE,TTECH,EF,YTIME)	           "Specific Fuel Consumption ()"
                                                                !! SFC for passenger cars (ktoe/Gkm)
                                                                !! SFC for other passsenger transportation modes (ktoe/Gpkm)
                                                                !! SFC for trucks is measured (ktoe/Gtkm)
VCostTranspPerMeanConsSize(allCy,TRANSE,RCon,TTECH,YTIME)  "Transportation cost per mean and consumer size (KUS$2015/vehicle)"
VCostTranspPerVeh(allCy,TRANSE,RCon,TTECH,YTIME)	       "Transportation cost per mean and consumer size (KUS$2015/vehicle)"
VCostTranspMatFac(allCy,TRANSE,RCon,TTECH,YTIME)	       "Transportation cost including maturity factor (KUS$2015/vehicle)"
VTechSortVarCost(allCy,TRANSE,Rcon,YTIME)	               "Technology sorting based on variable cost (1)"
VShareTechTr(allCy,TRANSE,EF,YTIME)	                       "Technology share in new equipment (1)"
VConsTechTranspSectoral(allCy,TRANSE,TTECH,EF,YTIME)	   "Consumption of each technology and subsector (Mtoe)"
*vDemFinEneSubTransp(allCy,TRANSE,YTIME)	               "Final energy demand in transport subsectors (Mtoe)"
VMEPcGdp(allCy,YTIME)                                      "Passenger cars market extension (GDP dependent)"
VMEPcNonGdp(allCy,YTIME)                                   "Passenger cars market extension (GDP independent)"
VStockPcYearly(allCy,YTIME)                                "Stock of passenger cars (million vehicles)"
VNewRegPcYearly(allCy,YTIME)                               "Passenger cars new registrations (million vehicles)"
VActivPassTrnsp(allCy,TRANSE,YTIME)                        "Passenger transport acitivity (1)"
                                                                !! - Activity for passenger cars is measured in (000)km
                                                                !! - Activity for passenger aviation million passengers carried
                                                                !! - Activity for all other passenger transportation modes is measured in Gpkm
VNumPcScrap(allCy,YTIME)                                   "Scrapped passenger cars (million vehicles)"
VPcOwnPcLevl(allCy,YTIME)                                  "Ratio of car ownership over saturation car ownership (1)"
VRateScrPc(allCy,YTIME)                                    "Scrapping rate of passenger cars (1)"
VConsElecNonSubIndTert(allCy,DSBS,YTIME)                   "Consumption of non-substituable electricity in Industry and Tertiary (Mtoe)"

*'                **Interdependent Equations**
VMVDemFinEneTranspPerFuel(allCy,TRANSE,EF,YTIME)             "Final energy demand in transport subsectors per fuel (Mtoe)"
VMVLft(allCy,DSBS,EF,YTIME)                                  "Lifetime of technologies (years)"
;