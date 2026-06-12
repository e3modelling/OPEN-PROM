*' @title Transport Declarations
*' @code

Parameters
i01GdpPassCarsMarkExt(allCy)	                          "GDP-dependent passenger cars market extension (GDP/capita)"
i01PassCarsScrapRate(allCy)	                          "Passenger cars scrapping rate (1)"
i01ShareAnnMilePlugInHybrid(allCy,YTIME)	           "Share of annual mileage of a plug-in hybrid which is covered by electricity (1)"
i01AvgVehCapLoadFac(allCy,TRANSE,TRANSUSE,YTIME)	      "Average capacity/vehicle and load factor (tn/veh or passenegers/veh)"
i01TechLft(allCy,DSBS,TECH,YTIME)	                     "Technical Lifetime. For passenger cars it is a variable (1)"
i01PassCarsMarkSat(allCy)	                          "Passenger cars ownership saturation threshold (1)"
i01GDPperCapita(YTIME,allCy)
i01Sigma(allCy,SG)                                   "S parameters of Gompertz function for passenger cars vehicle km (1)"
i01ShareBlend(allCy,TRANSE,EF,YTIME)
i01ShareMix(allCy,TRANSE,EF,YTIME)
i01calb(allCy,TRANSE,EF)
i01calibweibul(allCy,TRANSE,EF,YTIME)
;

Equations
*' *** Transport
Q01GapTranspActiv(allCy,TRANSE,YTIME)	                   "Compute the gap in transport activity"
*Q01ConsSpecificFuel(allCy,TRANSE,TTECH,EF,YTIME)	       "Compute Specific Fuel Consumption"
Q01CostTranspPerMeanConsSize(allCy,TRANSE,TTECH,YTIME)    "Compute transportation cost per mean in KUS$2015 per vehicle"
Q01ShareTechTr(allCy,TRANSE,TECH,YTIME)	                   "Compute technology sorting based on variable cost and new equipment"
Q01NewRegPcTechYearly(allCy,TTECH,YTIME)                   "Compute new registrations of passenger cars per technology"
Q01PcOwnPcLevl(allCy,YTIME)                                "Compute ratio of car ownership over saturation car ownership"
Q01CapCostAnnualized(allCy,TRANSE,TTECH,YTIME)
Q01CostFuel(allCy,TRANSE,TTECH,YTIME)
Q01PremScrp(allCy,TRANSE,TTECH,YTIME)
Q01RateScrPcTot(allCy,TRANSE,TTECH,YTIME)
Q01ShareBlend(allCy,TRANSE,EF,YTIME)
Q01TransportActivity(allCy,TRANSE,YTIME)                   "Compute transport acitivity"
*'                **Interdependent Equations**
Q01ConsFuelTransport(allCy,TRANSE,EF,YTIME)
Q01CapacityTransport(allCy,TRANSE,TTECH,YTIME)
;

Variables
*' *** Transport Variables
V01GapTranspActiv(allCy,TRANSE,YTIME)	                   "Gap in transport activity to be filled by new technologies ()"
                                                                !! Gap for passenger cars (million vehicles)
                                                                !! Gap for all other passenger transportation modes (Gpkm)
                                                                !! Gap for all goods transport is measured (Gtkm)
V01ConsSpecificFuel(allCy,TRANSE,TTECH,EF,YTIME)	       "Specific Fuel Consumption ()"
                                                                !! SFC for passenger cars (ktoe/Gkm)
                                                                !! SFC for other passsenger transportation modes (ktoe/Gpkm)
                                                                !! SFC for trucks is measured (ktoe/Gtkm)
V01CostTranspPerMeanConsSize(allCy,TRANSE,TTECH,YTIME)    "Transportation cost per mean (KUS$2015/vehicle)"
V01ShareTechTr(allCy,TRANSE,TECH,YTIME)	                   "Technology share in new equipment (1)"
V01NewRegPcTechYearly(allCy,TTECH,YTIME)                   "Passenger cars new registrations per technology (million vehicles)"
V01PcOwnPcLevl(allCy,YTIME)                                "Ratio of car ownership over saturation car ownership (1)"
V01CapCostAnnualized(allCy,TRANSE,TTECH,YTIME)
V01CostFuel(allCy,TRANSE,TTECH,YTIME)
V01PremScrp(allCy,TRANSE,TTECH,YTIME)
V01RateScrPcTot(allCy,TRANSE,TTECH,YTIME)
V01ShareBlend(allCy,TRANSE,EF,YTIME)
V01TransportActivity(allCy,TRANSE,YTIME)                   "Passenger transport activity (1)"
                                                                !! - Activity for passenger cars is measured in million vehicles
                                                                !! - Activity for passenger aviation million passengers carried
                                                                !! - Activity for all other passenger transportation modes is measured in Gpkm
                                                                !! - Activity for all goods trasnportation modes is measured in Gtkm
*'                **Interdependent Equations**
VmLft(allCy,DSBS,TECH,YTIME)                                 "Lifetime of technologies (years)"
V01ConsFuelTransport(allCy,TRANSE,EF,YTIME)	           "Consumption of each technology and subsector (Mtoe)"
V01CapacityTransport(allCy,TRANSE,TTECH,YTIME)

;