*' @title Equations of OPEN-PROMs Hydrogen
*' @code

QDemTotH2(CYrun,YTIME)$TIME(YTIME)..
         VDemTotH2(CYrun,YTIME)
                 =E=
         sum(SBS$H2SBS(SBS), VDemSecH2(CYrun,SBS, YTIME)/
         prod(INFRTECH$H2INFRSBS(INFRTECH,SBS) , iEffH2Transp(CYrun,INFRTECH,YTIME)*(1-iConsSelfH2Transp(CYrun,INFRTECH,YTIME))
         ))  // increase the demand due to transportation losses
;


QScrapLftH2Prod(CYrun,H2TECH,YTIME)$TIME(YTIME)..
        VScrapLftH2Prod(CYrun,H2TECH,YTIME)
         =E=
        (
         VGapShareH2Tech1(CYrun,H2TECH,YTIME-iProdLftH2(H2TECH))*VDemGapH2(CYrun,YTIME-iProdLftH2(H2TECH))
         /VProdH2(CYrun,H2TECH,YTIME-1)
         )$(ord(YTIME)>17+iProdLftH2(H2TECH))
;


QPremRepH2Prod(CYrun,H2TECH,YTIME)$TIME(YTIME)..
         VPremRepH2Prod(CYrun,H2TECH,YTIME)
         =E=
         1-
         (
          VCostVarProdH2Tech(CYrun,H2TECH,YTIME)**(-iWBLGammaH2Prod(CYrun,YTIME))
         /
         (
           iWBLPremRepH2Prod(CYrun,H2TECH,YTIME)*
           (sum(H2TECH2,
                         VGapShareH2Tech1(CYrun,H2TECH2,YTIME)*(1/iAvailH2Prod(H2TECH,YTIME)*VCostProdH2Tech(CYrun,H2TECH2,YTIME)
                                                         +(1-1/iAvailH2Prod(H2TECH,YTIME))*VCostVarProdH2Tech(CYrun,H2TECH2,YTIME)))

                        -VGapShareH2Tech1(CYrun,H2TECH,YTIME)*(1/iAvailH2Prod(H2TECH,YTIME)*VCostProdH2Tech(CYrun,H2TECH,YTIME)
                                                        +(1-1/iAvailH2Prod(H2TECH,YTIME))*VCostVarProdH2Tech(CYrun,H2TECH,YTIME))
           )**(-iWBLGammaH2Prod(CYrun,YTIME))

           +VCostVarProdH2Tech(CYrun,H2TECH,YTIME)**(-iWBLGammaH2Prod(CYrun,YTIME))
         )
         )$H2TECHPM(H2TECH)
;


QCapScrapH2ProdTech(CYrun,H2TECH,YTIME)$TIME(YTIME)..
         VCapScrapH2ProdTech(CYrun,H2TECH,YTIME)
         =E=
         1-(1-VScrapLftH2Prod(CYrun,h2tech,YTIME))*(1-VPremRepH2Prod(CYrun,h2tech,YTIME))
;


QDemGapH2(CYrun, YTIME)$TIME(YTIME)..
         VDemGapH2(CYrun, YTIME)
                 =E=
         ( VDemTotH2(CYrun,YTIME) - sum(H2TECH,(1-VCapScrapH2ProdTech(CYrun,h2tech,YTIME))*VProdH2(CYrun,h2tech,YTIME-1))
          + 0 +
         SQRT( SQR(VDemTotH2(CYrun,YTIME) - sum(H2TECH,(1-VCapScrapH2ProdTech(CYrun,h2tech,YTIME))*VProdH2(CYrun,h2tech,YTIME-1))-0) + SQR(1E-4) )
         )/2
;


QCostProdH2Tech(CYrun,H2TECH,YTIME)$TIME(YTIME)..
         VCostProdH2Tech(CYrun,H2TECH,YTIME)
         =E=
         (iDisc(CYrun,"H2P",YTIME)*exp(iDisc(CYrun,"H2P",YTIME)* iProdLftH2(H2TECH))/(exp(iDisc(CYrun,"H2P",YTIME)*iProdLftH2(H2TECH))-1)*
         iCostCapH2Prod(CYrun,H2TECH,YTIME)+iCostFOMH2Prod(CYrun,H2TECH,YTIME))/257/365*1000000/iAvailH2Prod(H2TECH,YTIME) +
         iCostVOMH2Prod(CYrun,H2TECH,YTIME) + VCostVarProdH2Tech(CYrun,H2TECH,YTIME)
;


QCostVarProdH2Tech(CYrun,H2TECH,YTIME)$TIME(YTIME)..
         VCostVarProdH2Tech(CYrun,H2TECH,YTIME)
         =E=
         sum(EF$H2TECHEFtoEF(H2TECH,EF), (VPriceFuelSubsecCarVal(CYrun,"H2P",EF,YTIME)*1e3+

            iCaptRateH2Prod(CYrun,H2TECH,YTIME)*iCo2EmiFac(CYrun,"H2P",EF,YTIME)*VCstCO2SeqCsts(CYrun,YTIME)+

            (1-iCaptRateH2Prod(CYrun,H2TECH,YTIME))*iCo2EmiFac(CYrun,"H2P",EF,YTIME)*

            (sum(NAP$NAPtoALLSBS(NAP,"H2P"),VCarVal(NAP,YTIME))))

            /iEffH2Prod(CYrun,H2TECH,YTIME)
            )$(not H2TECHREN(H2TECH))
;


QAcceptCCSH2Tech(CYrun,YTIME)$TIME(YTIME)..
         VAcceptCCSH2Tech(CYrun,YTIME)
         =E=
         iWBLGammaH2Prod(CYrun,YTIME)*5+25*EXP(-0.06*((sum(NAP$NAPtoALLSBS(NAP,"H2P"),VCarVal(NAP,YTIME-1)))))
;


QShareCCSH2Prod(CYrun,H2TECH,YTIME)$(TIME(YTIME) $H2CCS(H2TECH))..
         VShareCCSH2Prod(CYrun,H2TECH,YTIME)
         =E=
                 1.5  *
*         iWBLShareH2Prod(CYrun,H2TECH,YTIME) *
                 VCostProdH2Tech(CYrun,H2TECH,YTIME)**(-VAcceptCCSH2Tech(CYrun,YTIME)) /
         (
                 1.5  *
*         iWBLShareH2Prod(CYrun,H2TECH,YTIME) *
                 VCostProdH2Tech(CYrun,H2TECH,YTIME)**(-VAcceptCCSH2Tech(CYrun,YTIME)) +

                 sum(H2TECH2$H2CCS_NOCCS(H2TECH,H2TECH2),

                 1  *
*         iWBLShareH2Prod(CYrun,H2TECH2,YTIME) *
                 VCostProdH2Tech(CYrun,H2TECH2,YTIME)**(-VAcceptCCSH2Tech(CYrun,YTIME)))
         )
;


QShareNoCCSH2Prod(CYrun,H2TECH,YTIME)$(TIME(YTIME) $H2NOCCS(H2TECH))..
         VShareNoCCSH2Prod(CYrun,H2TECH,YTIME)
         =E=
         1 - sum(H2TECH2$H2CCS_NOCCS(H2TECH2,H2TECH)  , VShareCCSH2Prod(CYrun,H2TECH2,YTIME) )
;


QCostProdCCSNoCCSH2Prod(CYrun,H2TECH,YTIME)$(TIME(YTIME) $H2NOCCS(H2TECH)) ..
         VCostProdCCSNoCCSH2Prod(CYrun,H2TECH,YTIME)
         =E=
         VShareNoCCSH2Prod(CYrun,H2TECH,YTIME)*VCostProdH2Tech(CYrun,H2TECH,YTIME)+
         sum(H2CCS$H2CCS_NOCCS(H2CCS,H2TECH), VShareCCSH2Prod(CYrun,H2CCS,YTIME)*VCostProdH2Tech(CYrun,H2CCS,YTIME))
;


QGapShareH2Tech2(CYrun,H2TECH,YTIME)$TIME(YTIME)..
        VGapShareH2Tech2(CYrun,H2TECH,YTIME)
             =E=
         (
         iWBLShareH2Prod(CYrun,H2TECH,YTIME) *  (VCostProdH2Tech(CYrun,H2TECH,YTIME)$(not H2NOCCS(H2TECH)) + VCostProdCCSNoCCSH2Prod(CYrun,H2TECH,YTIME)$H2NOCCS(H2TECH))**(-iWBLGammaH2Prod(CYrun,YTIME))
         /
         sum(H2TECH2$(not H2CCS(H2TECH2)) ,
                 iWBLShareH2Prod(CYrun,H2TECH2,YTIME) *  (VCostProdH2Tech(CYrun,H2TECH2,YTIME)$(not H2NOCCS(H2TECH2)) + VCostProdCCSNoCCSH2Prod(CYrun,H2TECH2,YTIME)$H2NOCCS(H2TECH2))**(-iWBLGammaH2Prod(CYrun,YTIME)))
         )$(not H2CCS(H2TECH))
         +
         sum(H2NOCCS$H2CCS_NOCCS(H2TECH,H2NOCCS), VGapShareH2Tech2(CYrun,H2NOCCS,YTIME))$H2CCS(H2TECH)
;


QGapShareH2Tech1(CYrun,H2TECH,YTIME)$TIME(YTIME)..
        VGapShareH2Tech1(CYrun,H2TECH,YTIME)
         =E=
         (VGapShareH2Tech2(CYrun,H2TECH,YTIME)$((not H2CCS(H2TECH)) $(not H2NOCCS(H2TECH)))
          +
         VGapShareH2Tech2(CYrun,H2TECH,YTIME)*(VShareCCSH2Prod(CYrun,H2TECH,YTIME)$H2CCS(H2TECH) +  VShareNoCCSH2Prod(CYrun,H2TECH,YTIME)$H2NOCCS(H2TECH))
         )
;


QProdH2(CYrun,H2TECH,YTIME)$TIME(YTIME)..
         VProdH2(CYrun,h2tech,YTIME)
         =E=
         (1-VCapScrapH2ProdTech(CYrun,H2TECH,YTIME))*VProdH2(CYrun,H2TECH,YTIME-1)+ VGapShareH2Tech1(CYrun,H2TECH,YTIME)*VDemGapH2(CYrun,YTIME)
;


QCostAvgProdH2(CYRUN,YTIME)$TIME(YTIME)..
         VCostAvgProdH2(CYrun,YTIME)
         =E=
         sum(H2TECH, VProdH2(CYrun,H2TECH,YTIME)*VCostProdH2Tech(CYrun,H2TECH,YTIME))/sum(H2TECH,VProdH2(CYrun,H2TECH,YTIME))
;


QConsFuelTechH2Prod(CYrun,H2TECH,EF,YTIME)$(TIME(YTIME) $H2TECHEFtoEF(H2TECH,EF))..
         VConsFuelTechH2Prod(CYrun,H2TECH,EF,YTIME)
         =E=
         (VProdH2(CYrun,H2TECH,YTIME)/iEffH2Prod(CYrun,H2TECH,YTIME))$TFIRSTan(YTIME)
         +
         (
         VConsFuelTechH2Prod(CYrun,H2TECH,EF,YTIME-1)*
         (VProdH2(CYrun,H2TECH,YTIME)/iEffH2Prod(CYrun,H2TECH,YTIME))/
         (VProdH2(CYrun,H2TECH,YTIME-1)/iEffH2Prod(CYrun,H2TECH,YTIME-1))
         )$(not TFIRSTan(YTIME))
;


QConsFuelH2Prod(CYrun,EF,YTIME)$(TIME(YTIME) $H2PRODEF(EF))..
         VConsFuelH2Prod(CYrun,EF,YTIME)
         =E=
         sum(H2TECH$H2TECHEFtoEF(H2TECH,EF),VConsFuelTechH2Prod(CYrun,H2TECH,EF,YTIME))
;


//
//                               B. Hydrogen Infrustructure
//


QH2InfrArea(CYrun,YTIME)$TIME(YTIME)..
         VH2InfrArea(CYrun,YTIME)
         =E=
         0.001+iPolH2AreaMax(CYrun)/(1 + exp( -iH2Adopt(CYrun,"B",YTIME)*( VDemTotH2(CYrun,YTIME)/(iHabAreaCountry(CYrun)/sAreaStyle*0.275)- iH2Adopt(CYrun,"MID",YTIME))))

;


QDelivH2InfrTech(CYrun,INFRTECH,YTIME)$TIME(YTIME)..
        VDelivH2InfrTech(CYrun,INFRTECH,YTIME)
         =E=
         (
         (    sum(SBS$(H2INFRSBS(INFRTECH,SBS) $SECTTECH(SBS,"H2F")), VDemSecH2(CYrun,SBS, YTIME))/
            (iEffH2Transp(CYrun,INFRTECH,YTIME)*(1-iConsSelfH2Transp(CYrun,INFRTECH,YTIME))) )$H2INFRDNODES(INFRTECH)  // for final demand nodes

         +

         sum(INFRTECH2$H2NETWORK(INFRTECH,INFRTECH2), VDelivH2InfrTech(CYrun,INFRTECH2,YTIME)/(iEffH2Transp(CYrun,INFRTECH,YTIME)*(1-iConsSelfH2Transp(CYrun,INFRTECH,YTIME))))$(not H2INFRDNODES(INFRTECH))

         )$iPolH2AreaMax(CYrun)
         +1e-7
;


QInvNewReqH2Infra(CYrun,INFRTECH,YTIME)$TIME(YTIME)..
         VInvNewReqH2Infra(CYrun,INFRTECH,YTIME)
         =E=
         ( VDelivH2InfrTech(CYrun,INFRTECH,YTIME)-VDelivH2InfrTech(CYrun,INFRTECH,YTIME-1)
          + 0 + 
          SQRT( SQR(VDelivH2InfrTech(CYrun,INFRTECH,YTIME)-VDelivH2InfrTech(CYrun,INFRTECH,YTIME-1)+0) + SQR(1e-4) ) )/2
;

!!!!!!!!!!!!
QH2Pipe(CYrun,INFRTECH,YTIME)$TIME(YTIME)..
         VCostInvTechH2Infr(CYrun,INFRTECH,YTIME)
         =E=
         (  55*VInvNewReqH2Infra(CYrun,INFRTECH,YTIME)/(1e-3*sDelivH2Turnpike))$sameas("TPIPA",INFRTECH)  // turnpike pipeline km
         +
         (iPipeH2Transp(INFRTECH)*1e6*VInvNewReqH2Infra(CYrun,INFRTECH,YTIME))$(sameas("LPIPU",INFRTECH) or sameas("HPIPI",INFRTECH)) //Low pressure urban pipelines km and industrial pipelines km
         +
         (sLenH2StationConn*VCostInvTechH2Infr(CYrun,"SSGG",YTIME))$sameas("MPIPS",INFRTECH)   // Pipelines connecting hydrogen service stations with the ring km
         +
         (sum(INFRTECH2$H2NETWORK(INFRTECH,INFRTECH2),VCostInvTechH2Infr(CYrun,INFRTECH2,YTIME)*iKmFactH2Transp(CYrun,INFRTECH2)))$(sameas("MPIPU",INFRTECH)  or sameas("HPIPU",INFRTECH)) // Ring pipeline in km and high pressure pipelines km
         +
         (VInvNewReqH2Infra(CYrun,INFRTECH,YTIME)/sSalesH2Station*1E3)$sameas("SSGG",INFRTECH)   // Number of new service stations to be built to meet the demand
;


QCostInvTechH2Infr(CYrun,INFRTECH,YTIME)$TIME(YTIME)..
         VCostInvCummH2Transp(CYrun,INFRTECH,YTIME)
         =E=
         1e-6*(iCostInvH2Transp(CYrun,INFRTECH,YTIME)/VH2InfrArea(CYrun,YTIME)*VCostInvTechH2Infr(CYrun,INFRTECH,YTIME))$(sameas("TPIPA",INFRTECH))
         +
         1e-6*(iCostInvH2Transp(CYrun,INFRTECH,YTIME)/VH2InfrArea(CYrun,YTIME)*VCostInvTechH2Infr(CYrun,INFRTECH,YTIME))$(PIPES(INFRTECH) $(not sameas("TPIPA",INFRTECH)))
         +
         (iCostInvH2Transp(CYrun,INFRTECH,YTIME)*VInvNewReqH2Infra(CYrun,INFRTECH,YTIME))$(sameas("SSGG",INFRTECH)) //Service stations investment cost
;


QCostTechH2Infr(CYrun,INFRTECH,YTIME)$TIME(YTIME)..
         VCostTechH2Infr(CYrun,INFRTECH,YTIME)
         =E=
         ((iDisc(CYrun,"H2INFR",YTIME)*exp(iDisc(CYrun,"H2INFR",YTIME)* iTranspLftH2(INFRTECH))/(exp(iDisc(CYrun,"H2INFR",YTIME)* iTranspLftH2(INFRTECH))-1))
         *
         VCostInvCummH2Transp(CYrun,INFRTECH,YTIME)*(1+iCostInvFOMH2(INFRTECH,YTIME)))/iAvailRateH2Transp(INFRTECH,YTIME) + iCostInvVOMH2(INFRTECH,YTIME)
         *
         (iDisc(CYrun,"H2INFR",YTIME)*exp(iDisc(CYrun,"H2INFR",YTIME)* iTranspLftH2(INFRTECH))/(exp(iDisc(CYrun,"H2INFR",YTIME)* iTranspLftH2(INFRTECH))-1))*
         VCostInvCummH2Transp(CYrun,INFRTECH,YTIME)
         +
         (
            iConsSelfH2Transp(CYrun,INFRTECH,YTIME)*VInvNewReqH2Infra(CYrun,INFRTECH,YTIME)*
            (VCostAvgProdH2(CYrun,YTIME-1)$sameas("HPIPU",INFRTECH)+
            VPriceFuelSubsecCarVal(CYrun,"OI","ELC",YTIME-1)*1e3)$sameas("SSGG",INFRTECH)
         )$(sameas("SSGG",INFRTECH) or sameas("HPIPU",INFRTECH))
         /VInvNewReqH2Infra(CYrun,INFRTECH,YTIME)
;


QCostInvCummH2Transp(CYrun,INFRTECH,YTIME)$TIME(YTIME)..
         VH2Pipe(CYrun,INFRTECH,YTIME) 
         =E=
         sum(YYTIME$(an(YYTIME) $(ord(YYTIME)<=ord(YTIME))),

                 VCostTechH2Infr(CYrun,INFRTECH,YYTIME)*VInvNewReqH2Infra(CYrun,INFRTECH,YYTIME)*exp(0.04*(ord(YTIME)-ord(YYTIME)))
         )
         /
         sum(YYTIME$(an(YYTIME) $(ord(YYTIME)<=ord(YTIME))),VInvNewReqH2Infra(CYrun,INFRTECH,YYTIME))
;

!!!!!!!!!!!!
QTariffH2Infr(CYrun,INFRTECH,YTIME)$TIME(YTIME)..
         VTariffH2Infr(CYrun,INFRTECH,YTIME)
         =E=
         iCostAvgWeight(CYrun,YTIME)* VH2Pipe(CYrun,INFRTECH,YTIME)
         +
         (1-iCostAvgWeight(CYrun,YTIME))*VCostTechH2Infr(CYrun,INFRTECH,YTIME)
;


QPriceH2Infr(CYrun,SBS,YTIME)$(TIME(YTIME) $H2SBS(SBS))..
         VPriceH2Infr(CYrun,SBS,YTIME)
         =E=
         sum(INFRTECH$H2INFRSBS(INFRTECH,SBS) , VTariffH2Infr(CYrun,INFRTECH,YTIME))
;


QCostTotH2(CYrun,SBS,YTIME)$(TIME(YTIME) $H2SBS(SBS))..
         VCostTotH2(CYrun,SBS,YTIME)
         =E=
         VPriceH2Infr(CYrun,SBS,YTIME)+VCostAvgProdH2(CYrun,YTIME)
;
