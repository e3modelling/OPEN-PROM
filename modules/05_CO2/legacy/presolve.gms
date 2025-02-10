*QCapCO2ElecHydr
VCapCO2ElecHydr.L(runCy,YTIME)$(An(YTIME))
=
sum(PGEF,sum(CCS$PGALLtoEF(CCS,PGEF),
        VProdElec.L(runCy,CCS,YTIME)*sTWhToMtoe/iPlantEffByType(runCy,CCS,YTIME)*
        iCo2EmiFac(runCy,"PG",PGEF,YTIME)*iCO2CaptRate(runCy,CCS,YTIME)));

*QCaptCummCO2
VCaptCummCO2.L(runCy,YTIME)$(An(YTIME)) = VCaptCummCO2.L(runCy,YTIME-1)+VCapCO2ElecHydr.L(runCy,YTIME-1);

*QTrnsWghtLinToExp
VTrnsWghtLinToExp.L(runCy,YTIME)$(An(YTIME))
=
1/(1+exp(-iElastCO2Seq(runCy,"mc_s")*( VCaptCummCO2.L(runCy,YTIME)/iElastCO2Seq(runCy,"pot")-iElastCO2Seq(runCy,"mc_m")))); 
