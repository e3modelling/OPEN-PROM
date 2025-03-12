*' @title Equations of OPEN-PROMs Hydrogen
*' @code

QDemTotH2(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         VDemTotH2(allCy,YTIME)
                 =E=
         sum(SBS$H2SBS(SBS), VDemSecH2(allCy,SBS, YTIME)/
         prod(INFRTECH$H2INFRSBS(INFRTECH,SBS) , iEffH2Transp(allCy,INFRTECH,YTIME)*(1-iConsSelfH2Transp(allCy,INFRTECH,YTIME))))  !! increase the demand due to transportation losses
;


QScrapLftH2Prod(allCy,H2TECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
        VScrapLftH2Prod(allCy,H2TECH,YTIME)
         =E=
        (
         VGapShareH2Tech1(allCy,H2TECH,YTIME-iProdLftH2(H2TECH))*VDemGapH2(allCy,YTIME-iProdLftH2(H2TECH))
         /VProdH2(allCy,H2TECH,YTIME-1)
         )$(ord(YTIME)>17+iProdLftH2(H2TECH))
;


QPremRepH2Prod(allCy,H2TECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         VPremRepH2Prod(allCy,H2TECH,YTIME)
         =E=
         1-
         (
          VCostVarProdH2Tech(allCy,H2TECH,YTIME)**(-iWBLGammaH2Prod(allCy,YTIME))
         /
         (
           iWBLPremRepH2Prod(allCy,H2TECH,YTIME)*
           (sum(H2TECH2,
                         VGapShareH2Tech1(allCy,H2TECH2,YTIME)*(1/iAvailH2Prod(H2TECH,YTIME)*VCostProdH2Tech(allCy,H2TECH2,YTIME)
                                                         +(1-1/iAvailH2Prod(H2TECH,YTIME))*VCostVarProdH2Tech(allCy,H2TECH2,YTIME)))

                        -VGapShareH2Tech1(allCy,H2TECH,YTIME)*(1/iAvailH2Prod(H2TECH,YTIME)*VCostProdH2Tech(allCy,H2TECH,YTIME)
                                                        +(1-1/iAvailH2Prod(H2TECH,YTIME))*VCostVarProdH2Tech(allCy,H2TECH,YTIME))
           )**(-iWBLGammaH2Prod(allCy,YTIME))

           +VCostVarProdH2Tech(allCy,H2TECH,YTIME)**(-iWBLGammaH2Prod(allCy,YTIME))
         )
         )$H2TECHPM(H2TECH)
;


QCapScrapH2ProdTech(allCy,H2TECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         VCapScrapH2ProdTech(allCy,H2TECH,YTIME)
         =E=
         1-(1-VScrapLftH2Prod(allCy,h2tech,YTIME))*(1-VPremRepH2Prod(allCy,h2tech,YTIME))
;


QDemGapH2(allCy, YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         VDemGapH2(allCy, YTIME)
                 =E=
         ( VDemTotH2(allCy,YTIME) - sum(H2TECH,(1-VCapScrapH2ProdTech(allCy,h2tech,YTIME))*VProdH2(allCy,h2tech,YTIME-1))
          + 0 +
         SQRT( SQR(VDemTotH2(allCy,YTIME) - sum(H2TECH,(1-VCapScrapH2ProdTech(allCy,h2tech,YTIME))*VProdH2(allCy,h2tech,YTIME-1))-0) + SQR(1E-4) )
         )/2
;


QCostProdH2Tech(allCy,H2TECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         VCostProdH2Tech(allCy,H2TECH,YTIME)
         =E=
         (iDisc(allCy,"H2P",YTIME)*exp(iDisc(allCy,"H2P",YTIME)* iProdLftH2(H2TECH))/(exp(iDisc(allCy,"H2P",YTIME)*iProdLftH2(H2TECH))-1)*
         iCostCapH2Prod(allCy,H2TECH,YTIME)+iCostFOMH2Prod(allCy,H2TECH,YTIME))/257/365*1000000/iAvailH2Prod(H2TECH,YTIME) +
         iCostVOMH2Prod(allCy,H2TECH,YTIME) + VCostVarProdH2Tech(allCy,H2TECH,YTIME)
;


QCostVarProdH2Tech(allCy,H2TECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         VCostVarProdH2Tech(allCy,H2TECH,YTIME)
         =E=
         sum(EF$H2TECHEFtoEF(H2TECH,EF), (VPriceFuelSubsecCarVal(allCy,"H2P",EF,YTIME)*1e3+

            iCaptRateH2Prod(allCy,H2TECH,YTIME)*iCo2EmiFac(allCy,"H2P",EF,YTIME)*VCstCO2SeqCsts(allCy,YTIME)+

            (1-iCaptRateH2Prod(allCy,H2TECH,YTIME))*iCo2EmiFac(allCy,"H2P",EF,YTIME)*

            (sum(NAP$NAPtoALLSBS(NAP,"H2P"),VCarVal(allCy,NAP,YTIME))))

            /iEffH2Prod(allCy,H2TECH,YTIME)
            )$(not H2TECHREN(H2TECH))
;


QAcceptCCSH2Tech(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         VAcceptCCSH2Tech(allCy,YTIME)
         =E=
         iWBLGammaH2Prod(allCy,YTIME)*5+25*EXP(-0.06*((sum(NAP$NAPtoALLSBS(NAP,"H2P"),VCarVal(allCy,NAP,YTIME -1)))))
;


QShareCCSH2Prod(allCy,H2TECH,YTIME)$(TIME(YTIME) $H2CCS(H2TECH) $(runCy(allCy)))..
         VShareCCSH2Prod(allCy,H2TECH,YTIME)
         =E=
                 1.5  *
*         iWBLShareH2Prod(allCy,H2TECH,YTIME) *
                 VCostProdH2Tech(allCy,H2TECH,YTIME)**(-VAcceptCCSH2Tech(allCy,YTIME)) /
         (
                 1.5  *
*         iWBLShareH2Prod(allCy,H2TECH,YTIME) *
                 VCostProdH2Tech(allCy,H2TECH,YTIME)**(-VAcceptCCSH2Tech(allCy,YTIME)) +

                 sum(H2TECH2$H2CCS_NOCCS(H2TECH,H2TECH2),

                 1  *
*         iWBLShareH2Prod(allCy,H2TECH2,YTIME) *
                 VCostProdH2Tech(allCy,H2TECH2,YTIME)**(-VAcceptCCSH2Tech(allCy,YTIME)))
         )
;


QShareNoCCSH2Prod(allCy,H2TECH,YTIME)$(TIME(YTIME) $H2NOCCS(H2TECH) $(runCy(allCy)))..
         VShareNoCCSH2Prod(allCy,H2TECH,YTIME)
         =E=
         1 - sum(H2TECH2$H2CCS_NOCCS(H2TECH2,H2TECH)  , VShareCCSH2Prod(allCy,H2TECH2,YTIME) )
;


QCostProdCCSNoCCSH2Prod(allCy,H2TECH,YTIME)$(TIME(YTIME) $H2NOCCS(H2TECH) $(runCy(allCy))) ..
         VCostProdCCSNoCCSH2Prod(allCy,H2TECH,YTIME)
         =E=
         VShareNoCCSH2Prod(allCy,H2TECH,YTIME)*VCostProdH2Tech(allCy,H2TECH,YTIME)+
         sum(H2CCS$H2CCS_NOCCS(H2CCS,H2TECH), VShareCCSH2Prod(allCy,H2CCS,YTIME)*VCostProdH2Tech(allCy,H2CCS,YTIME))
;


QGapShareH2Tech2(allCy,H2TECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
        VGapShareH2Tech2(allCy,H2TECH,YTIME)
             =E=
         (
         iWBLShareH2Prod(allCy,H2TECH,YTIME) *  (VCostProdH2Tech(allCy,H2TECH,YTIME)$(not H2NOCCS(H2TECH)) + VCostProdCCSNoCCSH2Prod(allCy,H2TECH,YTIME)$H2NOCCS(H2TECH))**(-iWBLGammaH2Prod(allCy,YTIME))
         /
         sum(H2TECH2$(not H2CCS(H2TECH2)) ,
                 iWBLShareH2Prod(allCy,H2TECH2,YTIME) *  (VCostProdH2Tech(allCy,H2TECH2,YTIME)$(not H2NOCCS(H2TECH2)) + VCostProdCCSNoCCSH2Prod(allCy,H2TECH2,YTIME)$H2NOCCS(H2TECH2))**(-iWBLGammaH2Prod(allCy,YTIME)))
         )$(not H2CCS(H2TECH))
         +
         sum(H2NOCCS$H2CCS_NOCCS(H2TECH,H2NOCCS), VGapShareH2Tech2(allCy,H2NOCCS,YTIME))$H2CCS(H2TECH)
;


QGapShareH2Tech1(allCy,H2TECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
        VGapShareH2Tech1(allCy,H2TECH,YTIME)
         =E=
         (VGapShareH2Tech2(allCy,H2TECH,YTIME)$((not H2CCS(H2TECH)) $(not H2NOCCS(H2TECH)))
          +
         VGapShareH2Tech2(allCy,H2TECH,YTIME)*(VShareCCSH2Prod(allCy,H2TECH,YTIME)$H2CCS(H2TECH) +  VShareNoCCSH2Prod(allCy,H2TECH,YTIME)$H2NOCCS(H2TECH))
         )
;


QProdH2(allCy,H2TECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         VProdH2(allCy,h2tech,YTIME)
         =E=
         (1-VCapScrapH2ProdTech(allCy,H2TECH,YTIME))*VProdH2(allCy,H2TECH,YTIME-1)+ VGapShareH2Tech1(allCy,H2TECH,YTIME)*VDemGapH2(allCy,YTIME)
;


QCostAvgProdH2(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         VCostAvgProdH2(allCy,YTIME)
         =E=
         sum(H2TECH, VProdH2(allCy,H2TECH,YTIME)*VCostProdH2Tech(allCy,H2TECH,YTIME))/sum(H2TECH,VProdH2(allCy,H2TECH,YTIME))
;


QConsFuelTechH2Prod(allCy,H2TECH,EF,YTIME)$(TIME(YTIME) $H2TECHEFtoEF(H2TECH,EF) $(runCy(allCy)))..
         VConsFuelTechH2Prod(allCy,H2TECH,EF,YTIME)
         =E=
         (VProdH2(allCy,H2TECH,YTIME)/iEffH2Prod(allCy,H2TECH,YTIME))$TFIRSTan(YTIME)
         +
         (
         VConsFuelTechH2Prod(allCy,H2TECH,EF,YTIME-1)*
         (VProdH2(allCy,H2TECH,YTIME)/iEffH2Prod(allCy,H2TECH,YTIME))/
         (VProdH2(allCy,H2TECH,YTIME-1)/iEffH2Prod(allCy,H2TECH,YTIME-1))
         )$(not TFIRSTan(YTIME))
;


QConsFuelH2Prod(allCy,EF,YTIME)$(TIME(YTIME) $H2PRODEF(EF) $(runCy(allCy)))..
         VConsFuelH2Prod(allCy,EF,YTIME)
         =E=
         sum(H2TECH$H2TECHEFtoEF(H2TECH,EF),VConsFuelTechH2Prod(allCy,H2TECH,EF,YTIME))
;


!!
!!                               B. Hydrogen Infrustructure
!!


QH2InfrArea(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         VH2InfrArea(allCy,YTIME)
         =E=
         0.001+iPolH2AreaMax(allCy)/(1 + exp( -iH2Adopt(allCy,"B",YTIME)*( VDemTotH2(allCy,YTIME)/(iHabAreaCountry(allCy)/sAreaStyle*0.275)- iH2Adopt(allCy,"MID",YTIME))))

;


QDelivH2InfrTech(allCy,INFRTECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
        VDelivH2InfrTech(allCy,INFRTECH,YTIME)
         =E=
         (
         (    sum(SBS$(H2INFRSBS(INFRTECH,SBS) $SECTTECH(SBS,"H2F")), VDemSecH2(allCy,SBS, YTIME))/
            (iEffH2Transp(allCy,INFRTECH,YTIME)*(1-iConsSelfH2Transp(allCy,INFRTECH,YTIME))) )$H2INFRDNODES(INFRTECH)  !! for final demand nodes

         +

         sum(INFRTECH2$H2NETWORK(INFRTECH,INFRTECH2), VDelivH2InfrTech(allCy,INFRTECH2,YTIME)/(iEffH2Transp(allCy,INFRTECH,YTIME)*(1-iConsSelfH2Transp(allCy,INFRTECH,YTIME))))$(not H2INFRDNODES(INFRTECH))

         )$iPolH2AreaMax(allCy)
         +1e-7
;


QInvNewReqH2Infra(allCy,INFRTECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         VInvNewReqH2Infra(allCy,INFRTECH,YTIME)
         =E=
         ( VDelivH2InfrTech(allCy,INFRTECH,YTIME)-VDelivH2InfrTech(allCy,INFRTECH,YTIME-1)
          + 0 + 
          SQRT( SQR(VDelivH2InfrTech(allCy,INFRTECH,YTIME)-VDelivH2InfrTech(allCy,INFRTECH,YTIME-1)+0) + SQR(1e-4) ) )/2
;


QH2Pipe(allCy,INFRTECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         VH2Pipe(allCy,INFRTECH,YTIME)
         =E=
         (  55*VInvNewReqH2Infra(allCy,INFRTECH,YTIME)/(1e-3*sDelivH2Turnpike))$sameas("TPIPA",INFRTECH)  !! turnpike pipeline km
         +
         (iPipeH2Transp(INFRTECH)*1e6*VInvNewReqH2Infra(allCy,INFRTECH,YTIME))$(sameas("LPIPU",INFRTECH) or sameas("HPIPI",INFRTECH)) !!Low pressure urban pipelines km and industrial pipelines km
         +
         (sLenH2StationConn*VCostInvTechH2Infr(allCy,"SSGG",YTIME))$sameas("MPIPS",INFRTECH)   !! Pipelines connecting hydrogen service stations with the ring km
         +
         (sum(INFRTECH2$H2NETWORK(INFRTECH,INFRTECH2),VCostInvTechH2Infr(allCy,INFRTECH2,YTIME)*iKmFactH2Transp(allCy,INFRTECH2)))$(sameas("MPIPU",INFRTECH)  or sameas("HPIPU",INFRTECH)) !! Ring pipeline in km and high pressure pipelines km
         +
         (VInvNewReqH2Infra(allCy,INFRTECH,YTIME)/sSalesH2Station*1E3)$sameas("SSGG",INFRTECH)   !! Number of new service stations to be built to meet the demand
;


QCostInvTechH2Infr(allCy,INFRTECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         VCostInvTechH2Infr(allCy,INFRTECH,YTIME)
         =E=
         1e-6*(iCostInvH2Transp(allCy,INFRTECH,YTIME)/VH2InfrArea(allCy,YTIME)*VCostInvTechH2Infr(allCy,INFRTECH,YTIME))$(sameas("TPIPA",INFRTECH))
         +
         1e-6*(iCostInvH2Transp(allCy,INFRTECH,YTIME)/VH2InfrArea(allCy,YTIME)*VCostInvTechH2Infr(allCy,INFRTECH,YTIME))$(PIPES(INFRTECH) $(not sameas("TPIPA",INFRTECH)))
         +
         (iCostInvH2Transp(allCy,INFRTECH,YTIME)*VInvNewReqH2Infra(allCy,INFRTECH,YTIME))$(sameas("SSGG",INFRTECH)) !!Service stations investment cost
;


QCostTechH2Infr(allCy,INFRTECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         VCostTechH2Infr(allCy,INFRTECH,YTIME)
         =E=
         ((iDisc(allCy,"H2INFR",YTIME)*exp(iDisc(allCy,"H2INFR",YTIME)* iTranspLftH2(INFRTECH))/(exp(iDisc(allCy,"H2INFR",YTIME)* iTranspLftH2(INFRTECH))-1))
         *
         VCostInvCummH2Transp(allCy,INFRTECH,YTIME)*(1+iCostInvFOMH2(INFRTECH,YTIME)))/iAvailRateH2Transp(INFRTECH,YTIME) + iCostInvVOMH2(INFRTECH,YTIME)
         *
         (iDisc(allCy,"H2INFR",YTIME)*exp(iDisc(allCy,"H2INFR",YTIME)* iTranspLftH2(INFRTECH))/(exp(iDisc(allCy,"H2INFR",YTIME)* iTranspLftH2(INFRTECH))-1))*
         VCostInvCummH2Transp(allCy,INFRTECH,YTIME)
         +
         (
            iConsSelfH2Transp(allCy,INFRTECH,YTIME)*VInvNewReqH2Infra(allCy,INFRTECH,YTIME)*
            (VCostAvgProdH2(allCy,YTIME-1)$sameas("HPIPU",INFRTECH)+
            VPriceFuelSubsecCarVal(allCy,"OI","ELC",YTIME-1)*1e3)$sameas("SSGG",INFRTECH)
         )$(sameas("SSGG",INFRTECH) or sameas("HPIPU",INFRTECH))
         /VInvNewReqH2Infra(allCy,INFRTECH,YTIME)
;


QCostInvCummH2Transp(allCy,INFRTECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         VCostInvCummH2Transp(allCy,INFRTECH,YTIME) 
         =E=
         sum(YYTIME$(an(YYTIME) $(ord(YYTIME)<=ord(YTIME))),

                 VCostTechH2Infr(allCy,INFRTECH,YYTIME)*VInvNewReqH2Infra(allCy,INFRTECH,YYTIME)*exp(0.04*(ord(YTIME)-ord(YYTIME)))
         )
         /
         sum(YYTIME$(an(YYTIME) $(ord(YYTIME)<=ord(YTIME))),VInvNewReqH2Infra(allCy,INFRTECH,YYTIME))
;


QTariffH2Infr(allCy,INFRTECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         VTariffH2Infr(allCy,INFRTECH,YTIME)
         =E=
         iCostAvgWeight(allCy,YTIME)* VH2Pipe(allCy,INFRTECH,YTIME)
         +
         (1-iCostAvgWeight(allCy,YTIME))*VCostTechH2Infr(allCy,INFRTECH,YTIME)
;


QPriceH2Infr(allCy,SBS,YTIME)$(TIME(YTIME) $H2SBS(SBS) $(runCy(allCy)))..
         VPriceH2Infr(allCy,SBS,YTIME)
         =E=
         sum(INFRTECH$H2INFRSBS(INFRTECH,SBS) , VTariffH2Infr(allCy,INFRTECH,YTIME))
;


QCostTotH2(allCy,SBS,YTIME)$(TIME(YTIME) $H2SBS(SBS) $(runCy(allCy)))..
         VCostTotH2(allCy,SBS,YTIME)
         =E=
         VPriceH2Infr(allCy,SBS,YTIME)+VCostAvgProdH2(allCy,YTIME)
;
