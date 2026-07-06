*' @title Prices Sets
*' @code

*---
*' srcRefSBS: for the unified fuel price-transmission in Q08 (i08PriceTransElast),
*' maps each source fuel to the reference subsector from which to read its price:
*'   CRO    -> same subsector as the target fuel (CRO is priced in every SBS)
*'   BMSWAS -> "PG" (biomass is not priced in demand subsectors, e.g. transport)
sets
srcRefSBS(EF,SBS,SBS2)   "price-transmission source fuel -> reference subsector for its price"
;