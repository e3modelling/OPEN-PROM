*' @title Industry Sets
*' @code

*---

*' @title Industry Sets
*' @code

*--- Existing Industry subsectors are declared in core: verify if they should be moved here ---

*--- Iron and Steel Industry Sets ------------

* Iron and Steel existing routes
sets
  ISTECH_HIST   "Historical Existing IS routes"
    / BF_BOF       "Blast Furnace – Basic Oxygen Furnace"
    , DR_EAF       "Direct Reduction – Electric Arc Furnace"
    , SCRAP_EAF    "Scrap‑based Electric Arc Furnace"
    /;

* Iron & Steel new routes (BAT = Best Available Tech, CCS, H₂‑DR)
sets
  ISTECH_NEW    "New IS routes (BAT, CCS, H₂‑DR)"
    / BF_BOF_BAT     "BF‑BOF Best Available Technology"
    , DR_EAF_BAT     "DR‑EAF Best Available Technology"
    , SCRAP_EAF_BAT  "Scrap‑EAF Best Available Technology"
    , OSR_BOF    "OSR‑BOF Oxygen Smelt Reduction"
    , BF_BOF_CCS     "BF‑BOF with Carbon Capture"
    , DR_EAF_CCS     "DR‑EAF with Carbon Capture"
    , OSR_BOF_CCS    "OSR‑BOF with Carbon Capture"
    , H2_DR_EAF      "Hydrogen‑based Direct Reduction – EAF"
    /;

* Union of all IS technologies if useful
  ISTECH        "All IS technologies (existing and new)"
    / BF_BOF, DR_EAF, SCRAP_EAF,
    , BF_BOF_BAT, DR_EAF_BAT, SCRAP_EAF_BAT, OSR_BOF
    , BF_BOF_CCS, DR_EAF_CCS, OSR_BOF_CCS
    , H2_DR_EAF
    /;

* Mapping fuels and energy forms EF vs IS technologies 
* In future check if we need to define other type of coals for DR-EAF, SCRAP-EAF. In future we can consider also blend of hydrogen hydrogen for the traditional techs
  
  SECTTECH_IS(ISTECH, EF)  "Mapping of IS technologies to energy forms"
    / BF_BOF.(LGN, HCL,  CRO, LPG, GSL, KRS, GDO, RFO, OLQ, NGS, OGS, ELC, 
    BMSWAS, STE1AL, STE1AH, STE1AD, STE1AR, STE1AG, STE1AB)
    , DR_EAF.(HCL, NGS, ELC)
    , SCRAP_EAF.(HCL, NGS, ELC)

    , BF_BOF_BAT.(LGN, HCL,  CRO, LPG, GSL, KRS, GDO, RFO, OLQ, NGS, OGS, ELC,
                   BMSWAS, STE1AL, STE1AH, STE1AD, STE1AR, STE1AG, STE1AB)
    , DR_EAF_BAT.(HCL, NGS, ELC)
    , SCRAP_EAF_BAT.(HCL, NGS, ELC, H2F)
    , OSR_BOF.(LGN, HCL,  CRO, LPG, GSL, KRS, GDO, RFO, OLQ, NGS, OGS, ELC, 
            BMSWAS, STE1AL, STE1AH, STE1AD, STE1AR, STE1AG, STE1AB)

    , BF_BOF_CCS.(LGN, HCL,  CRO, LPG, GSL, KRS, GDO, RFO, OLQ, NGS, OGS, ELC,
                   BMSWAS, STE1AL, STE1AH, STE1AD, STE1AR, STE1AG, STE1AB) 
    , DR_EAF_CCS.(HCL, NGS, ELC, H2F)
    , OSR_BOF_CCS.(LGN, HCL,  CRO, LPG, GSL, KRS, GDO, RFO, OLQ, NGS, OGS, ELC,
                   BMSWAS, STE1AL, STE1AH, STE1AD, STE1AR, STE1AG, STE1AB)

    , H2_DR_EAF.(H2F, ELC, NGS, HCL,BMSWAS)
    /;


*--- End --------------------------------------------