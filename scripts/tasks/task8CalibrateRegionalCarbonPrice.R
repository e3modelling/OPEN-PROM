# Task 8: Calibrate Regional Carbon Price
# Usage: Rscript start.R task_id=8 [resume_from="runs/<campaign>"]
#
# Search sequence
# 1. Read annual Kyoto-GHG caps and their coverage. Enable each cap that meets
#    the coverage threshold. EU27 shares one calibrated price path, with
#    member caps summed and eligibility based on the lowest member coverage.
# 2. Keep the input prices through the fixed year. Search each eligible
#    group's NDC-year price first. In ndc-ltt mode, hold that price and search
#    the slope to the first eligible later LTT. Keep each finished path in
#    place until all groups complete the first pass. Each trial evaluates the
#    candidate prices of all groups together in one world solve.
# 3. Check all enabled caps after the first pass. Repair current positive
#    gaps jointly by raising annual prices, with NDC repair taking priority
#    within each group. A positive gap at the price ceiling remains unmet.
# 4. Confirm the candidate with a fresh solve. A cap miss returns to joint
#    repair. After confirmation, publish prices and research reports and
#    verify the Excel history before cleanup. If all remaining misses are
#    at the price ceiling, confirm and publish with those misses recorded.
#
# The final solve for each region-year must have solver status 1 and model
# status 2. Recovered intermediate attempts are archived as warnings.
# The model uses exogCV_NPi with the MAgPIE NDC_LTT emulator and live soft-link
# disabled. Country solves are serial by default.
#
# Settings in config.json under regional_carbon_price_calibration
# Values below are from config.template.json. Prices use USD2015/t CO2,
# slopes use price units per year, and caps use annual Mt CO2eq.
#
#   resume_from = null
#     Use null for a fresh campaign or a campaign directory to resume.
#     The CLI resume_from argument takes precedence. The evaluation limit
#     can be increased on resume. Campaign inputs and targets stay frozen.
#   prefix_policy = "exogCV_NPi"
#     Input price row to preserve through the fixed year. Groups without
#     an eligible NDC keep this background price path for the full horizon.
#     The row must exist for every model region and satisfy the price checks.
#   fixed_through_year = 2023
#     Last preserved input year, inclusive. The default allows changes from 2024.
#   target_mode = "ndc-ltt"
#     "ndc" calibrates Nationally Determined Contribution (NDC) caps only.
#     "ndc-ltt" also calibrates the first sufficiently covered later long-term
#     target (LTT) for each NDC-enabled group, where available.
#   target_variant = "unconditional"
#     Choose "unconditional" or "conditional" to select the pledge variant
#     in both targets/tNDCLTT.csv (annual caps) and
#     targets/tNDCLTT_coverage.csv (covered shares).
#
#     Target setting                 target_mode   target_variant
#     Unconditional NDC only         "ndc"         "unconditional"
#     Unconditional NDC and LTT      "ndc-ltt"     "unconditional"
#     Conditional NDC only           "ndc"         "conditional"
#     Conditional NDC and LTT        "ndc-ltt"     "conditional"
#
#   ndc_year = 2030
#     Year of the NDC cap and first calibrated price anchor. Years other than
#     2030 require the dedicated NDC rows from mrprom::fullNDCLTT().
#   end_year = 2100
#     Last model year and latest eligible LTT year. The year order is
#     2023 <= fixed_through_year < ndc_year < end_year <= 2100.
#   min_target_coverage = 0.9
#     Minimum share of known 2019 GHG emissions represented by the target,
#     in (0, 1]. With 0.9, coverage of 90% qualifies and 89% does not.
#     EU27 requires each member to meet the threshold. A zero cap with
#     sufficient coverage is a valid target. Zero coverage means unavailable.
#   continuation_slope_multiplier_max = 0.2
#     Maximum tail-to-previous-slope ratio. The previous segment ends at the
#     LTT anchor when enabled, or at the NDC anchor otherwise. A preceding
#     slope of 10 permits a tail slope of up to 2 with the default ratio.
#     Available headroom under max_price can reduce it further. A zero
#     multiplier gives a flat tail.
#
#   search
#     ndc_start_price = 400          First NDC price to try, clipped to bounds.
#     initial_ndc_price_step = 200   First change when expanding the NDC search.
#     ltt_start_slope = 10           First NDC-to-LTT slope to try, clipped to bounds.
#     initial_ltt_slope_step = 10    First change when expanding the LTT search.
#     max_price = 5000               Ceiling on the modeled price path.
#     price_resolution = 1          Stop refining at this NDC price bracket width.
#     slope_resolution = 0.01       Stop refining at this LTT slope bracket width.
#     max_evaluations = 150          Limit on physical attempts across search and confirmation, including failures. Cache hits use no new attempt.
#     ndc_tolerance_mtco2eq = 5      Preferred slack below the annual NDC cap.
#     ltt_tolerance_mtco2eq = 5      Preferred slack below the annual LTT cap.
#     For a cap of 100 with tolerance 5, the preferred band is 95 to 100.
#     At a legal floor or at search resolution, the current feasible point
#     may have extra slack. A positive cap gap always fails.


# ---- Configuration, targets and price paths --------------------------------
task8Validate <- function(cfg) {
  required <- c("resume_from", "prefix_policy", "fixed_through_year", "target_mode", "target_variant",
    "ndc_year", "end_year", "min_target_coverage", "continuation_slope_multiplier_max", "search")
  if (!is.list(cfg) || anyDuplicated(names(cfg)) || !all(required %in% names(cfg)) ||
      any(!names(cfg) %in% c(required,"execution"))) stop("Use the Task 8 settings in config.template.json")
  if (!cfg$target_mode %in% c("ndc", "ndc-ltt") || !cfg$target_variant %in% c("unconditional", "conditional")) stop("Invalid target_mode or target_variant")
  task7Number(cfg$fixed_through_year, "fixed_through_year", 2023, TRUE)
  for (k in c("ndc_year", "end_year")) task7Number(cfg[[k]], k, 2024, TRUE)
  if (!(cfg$fixed_through_year < cfg$ndc_year && cfg$ndc_year < cfg$end_year && cfg$end_year <= 2100)) stop("Require fixed year < NDC year < end year <= 2100")
  task7Number(cfg$min_target_coverage, "min_target_coverage")
  if (cfg$min_target_coverage <= 0 || cfg$min_target_coverage > 1) stop("Coverage threshold must be in (0,1]")
  task7Number(cfg$continuation_slope_multiplier_max, "continuation_slope_multiplier_max")
  keys <- c("ndc_start_price", "initial_ndc_price_step", "ltt_start_slope", "initial_ltt_slope_step",
    "max_price", "price_resolution", "slope_resolution", "max_evaluations", "ndc_tolerance_mtco2eq", "ltt_tolerance_mtco2eq")
  if (!is.list(cfg$search) || anyDuplicated(names(cfg$search)) || !setequal(names(cfg$search), keys)) stop("Invalid Task 8 search settings")
  for (k in keys) task7Number(cfg$search[[k]], k, 0, k == "max_evaluations")
  if (any(unlist(cfg$search[c("initial_ndc_price_step", "initial_ltt_slope_step", "price_resolution", "slope_resolution")]) <= 0) || cfg$search$max_evaluations < 2) stop("Positive search steps/resolutions and at least two evaluations are required")
  if(is.null(cfg$execution)) cfg$execution <- list(country_solve_mode="serial",country_solve_jobs=4L,solver_threads=1L)
  e <- cfg$execution
  if(!is.list(e) || anyDuplicated(names(e)) || !setequal(names(e),c("country_solve_mode","country_solve_jobs","solver_threads")) ||
      !e$country_solve_mode %in% c("serial","parallel")) stop("Invalid Task 8 execution settings")
  for(k in c("country_solve_jobs","solver_threads")) task7Number(e[[k]],k,1,TRUE)
  invisible(cfg)
}

task8Targets <- function(folder, regions, cfg) {
  read <- function(name) {
    x <- read.csv(file.path(folder, "targets", name), check.names = FALSE, colClasses = "character")
    if (ncol(x) < 3 || anyDuplicated(paste(x[[1]],x[[2]])) || anyDuplicated(names(x)[-(1:2)]) ||
        any(!grepl("^[0-9]{4}$", names(x)[-(1:2)]))) stop("Invalid target table: ", name)
    x
  }
  caps <- read("tNDCLTT.csv"); cov <- read("tNDCLTT_coverage.csv")
  if (!identical(names(caps),names(cov)) || !identical(caps[1:2],cov[1:2])) stop("Target/coverage keys or years differ")
  values <- as.numeric(as.matrix(caps[-(1:2)])); shares <- as.numeric(as.matrix(cov[-(1:2)]))
  if (any(!is.finite(values)) || any(!is.finite(shares) | shares < 0 | shares > 1)) stop("Nonfinite caps or invalid coverage")
  eu <- c("AUT","BEL","BGR","HRV","CYP","CZE","DNK","EST","FIN","FRA","DEU","GRC","HUN","IRL","ITA","LVA","LTU","LUX","MLT","NLD","POL","PRT","ROU","SVK","SVN","ESP","SWE")
  if (!all(eu %in% regions)) stop("Research mapping lacks EU27")
  groups <- c(list(EU27 = eu), setNames(lapply(setdiff(regions,eu),function(r) r),setdiff(regions,eu)))
  variants <- c("Unconditional", "Conditional")
  ndcVariables <- paste0("targetNDC", variants, "MtCO2e")
  lttVariables <- paste0("targetLongTerm", variants, "MtCO2e")
  keys <- paste(caps[[1]], caps[[2]])
  dedicatedNdc <- any(caps[[2]] %in% ndcVariables)
  if (!dedicatedNdc && cfg$ndc_year != 2030L) {
    stop("Regenerate the NDC/LTT pair with current mrprom for NDC years other than 2030")
  }
  # The original pair is supported for the default 2030 NDC year.
  ndcPrefix <- if (dedicatedNdc) "targetNDC" else "target"
  required <- c(paste0(ndcPrefix, variants, "MtCO2e"), lttVariables)
  if (!all(as.vector(outer(regions, required, paste)) %in% keys)) {
    stop("Missing NDC/LTT source rows. Regenerate the pair with current mrprom.")
  }
  variant <- match(cfg$target_variant, tolower(variants))
  # EU members are single-country model regions; their accepted annual caps must
  # cover all members. This avoids averaging percentages with unequal emissions.
  get <- function(members,y,kind="NDC") {
    if (!as.character(y) %in% names(caps)) return(c(cap = 0, coverage = 0))
    variable <- if (kind == "LTT") lttVariables[variant] else paste0(ndcPrefix, variants[variant], "MtCO2e")
    i <- match(paste(members, variable), keys)
    c(cap = sum(as.numeric(caps[i,as.character(y)])), coverage = min(as.numeric(cov[i,as.character(y)])))
  }
  out <- list()
  for (g in names(groups)) {
    d <- get(groups[[g]],cfg$ndc_year)
    out[[length(out)+1L]] <- data.frame(Group=g,Kind="NDC",Year=cfg$ndc_year,Cap=d["cap"],Coverage=d["coverage"],
      Enabled=d["coverage"]>0 && d["coverage"]>=cfg$min_target_coverage,row.names=NULL)
    # The dedicated LTT rows exclude revised NDCs and carry earlier LTT caps.
    # Select the earliest sufficiently covered later long-term deadline.
    later <- sort(as.integer(names(caps)[-(1:2)])); later <- later[later>cfg$ndc_year & later<=cfg$end_year]
    if (cfg$target_mode=="ndc-ltt" && out[[length(out)]]$Enabled) for (y in later) {
      d <- get(groups[[g]],y,"LTT")
      if (d["coverage"]>0 && d["coverage"]>=cfg$min_target_coverage) {
        out[[length(out)+1L]] <- data.frame(Group=g,Kind="LTT",Year=y,Cap=d["cap"],Coverage=d["coverage"],Enabled=TRUE,row.names=NULL)
        break
      }
    }
  }
  list(groups=groups,conditions=do.call(rbind,out))
}

task8Setup <- function(cfg,input,regions,targets) {
  cfg <- task8Validate(cfg)
  cfg$search_algorithm <- "regional-deferred-repair-v4"
  cfg$regions <- regions; cfg$groups <- targets$groups; cfg$conditions <- targets$conditions
  cfg$policy <- "exogCV_NPi"; cfg$fScenario <- 1L; cfg$emulator <- "NDC_LTT"
  cfg$annual_metric <- "Emissions|Kyoto Gases.Mt CO2-equiv/yr"
  cfg$anchors <- setNames(vapply(regions,function(r) {
    i <- task7PolicyRow(input,r,cfg$prefix_policy)
    x <- as.numeric(input[i,as.character(2023:cfg$fixed_through_year)])
    if (any(!is.finite(x) | x<0) || any(diff(x)< -1e-8)) stop("Invalid/decreasing input prefix: ",r)
    task7PolicyRow(input,r,cfg$policy)
    tail(x,1)
  },numeric(1)),regions)
  if (diff(range(cfg$anchors[cfg$groups$EU27]))>1e-8) stop("EU27 prefix endpoints must agree")
  if(any(cfg$anchors>cfg$search$max_price)) stop("An input endpoint exceeds max_price")
  cfg
}

task8Bounds <- function(cfg,g,ndc) {
  n <- cfg$ndc_year; p <- max(cfg$anchors[cfg$groups[[g]]]); ceiling <- cfg$search$max_price
  l <- cfg$conditions[cfg$conditions$Group==g & cfg$conditions$Kind=="LTT" & cfg$conditions$Enabled,]
  list(ndc=c(p,ceiling),ltt=c(0,if(nrow(l)) max(0,(ceiling-ndc)/(l$Year-n)) else 0))
}

# Choose the largest allowed tail multiplier that keeps one straight tail below
# the price ceiling. This does not introduce a second bend when the ceiling binds.
task8Tail <- function(cfg,g,controls) {
  l <- cfg$conditions[cfg$conditions$Group==g & cfg$conditions$Kind=="LTT" & cfg$conditions$Enabled,]
  year <- if(nrow(l)) l$Year else cfg$ndc_year
  previous <- if(nrow(l)) controls[g,"ltt"] else
    (controls[g,"ndc"]-max(cfg$anchors[cfg$groups[[g]]]))/(cfg$ndc_year-cfg$fixed_through_year)
  price <- controls[g,"ndc"]+if(nrow(l)) previous*(year-cfg$ndc_year) else 0
  available <- if(year<cfg$end_year) max(0,(cfg$search$max_price-price)/(cfg$end_year-year)) else 0
  slope <- min(cfg$continuation_slope_multiplier_max*previous,available)
  c(slope=slope,multiplier=if(previous>0) slope/previous else 0)
}

task8InitialControls <- function(cfg) {
  x <- matrix(0,length(cfg$groups),2,dimnames=list(names(cfg$groups),c("ndc","ltt")))
  for(g in rownames(x)) {
    bounds <- task8Bounds(cfg,g,0)$ndc
    x[g,"ndc"] <- max(bounds[1],min(cfg$search$ndc_start_price,bounds[2]))
  }
  x
}

# Canonical post-prefix path, shared by input construction and repair checks.
# Keep each member's original anchor, including insignificant input rounding.
task8GroupPrices <- function(cfg,g,controls,years,anchor=NULL) {
  l <- cfg$conditions[cfg$conditions$Group==g & cfg$conditions$Kind=="LTT" & cfg$conditions$Enabled,]
  a <- if(is.null(anchor)) max(cfg$anchors[cfg$groups[[g]]]) else anchor
  h <- cfg$fixed_through_year; n <- cfg$ndc_year
  y <- pmin(years,cfg$end_year); p <- controls[g,"ndc"]; slope <- controls[g,"ltt"]
  early <- (p-a)/(n-h); after <- pmax(y-n,0)
  v <- a+early*pmin(pmax(y-h,0),n-h)
  tail_slope <- unname(task8Tail(cfg,g,controls)["slope"])
  if(nrow(l)) v <- v+(slope*pmin(after,l$Year-n)+tail_slope*pmax(y-l$Year,0))
  else v <- v+(tail_slope*after)
  v
}

task8MakePrices <- function(cfg,input,controls) {
  x <- input; years <- 2010:2100
  for (g in names(cfg$groups)) {
    cnd <- cfg$conditions[cfg$conditions$Group==g & cfg$conditions$Enabled,]
    if (!any(cnd$Kind=="NDC")) next
    for (r in cfg$groups[[g]]) {
      src <- task7PolicyRow(input,r,cfg$prefix_policy); dest <- task7PolicyRow(input,r,cfg$policy)
      v <- as.numeric(input[src,as.character(years)])
      use <- years>cfg$fixed_through_year
      v[use] <- task8GroupPrices(cfg,g,controls,years,anchor=cfg$anchors[[r]])[use]
      if (any(!is.finite(v) | v<0) || any(diff(v[years>=2023])< -1e-8) || any(v[years>=2024]>cfg$search$max_price+1e-8)) stop("Invalid full price path for ",g)
      x[dest,as.character(years)] <- vapply(v,function(z) sprintf("%.15g",z),character(1))
    }
  }
  # Regions without NDCs keep the chosen valid background/prefix policy.
  for (r in cfg$regions) if (!any(cfg$conditions$Enabled & cfg$conditions$Kind=="NDC" & cfg$conditions$Group==names(Filter(function(m) r %in% m,cfg$groups)))) {
    i <- task7PolicyRow(input,r,cfg$prefix_policy); j <- task7PolicyRow(x,r,cfg$policy)
    x[j,as.character(years)] <- input[i,as.character(years)]
    v <- as.numeric(x[j,as.character(2023:cfg$end_year)])
    if (any(!is.finite(v)) || any(diff(v)< -1e-8) || any(v>cfg$search$max_price)) stop("Invalid background price path for ",r)
  }
  x
}

# ---- Annual emissions and cap checks ---------------------------------------
task8Check <- function(cfg,annual) {
  expected <- expand.grid(region=cfg$regions,year=2010:cfg$end_year)
  key <- function(x) paste(x$region,x$year)
  if (anyDuplicated(key(annual)) || !setequal(key(annual),key(expected)) || any(!is.finite(annual$value))) stop("Incomplete regional annual GHG report")
  d <- cfg$conditions
  d$Emissions <- vapply(seq_len(nrow(d)),function(i) sum(annual$value[annual$region %in% cfg$groups[[d$Group[i]]] & annual$year==d$Year[i]]),numeric(1))
  d$Gap <- d$Emissions-d$Cap; d$Met <- !d$Enabled | d$Gap<=0
  d
}

task8Selected <- function(cfg,prices) {
  x <- prices[vapply(cfg$regions,function(r) task7PolicyRow(prices,r,cfg$policy),integer(1)),,drop=FALSE]
  rownames(x) <- NULL; x
}

task8Annual <- function(cfg,index,prices,report=NULL) {
  n <- length(cfg$regions)
  x <- data.frame(Trial=rep(index,2*n+1),Metric=c(rep("Carbon price",n),rep("Kyoto GHG emissions",n+1)),
    Region=c(cfg$regions,cfg$regions,"World"),Unit=c(rep("USD2015/t CO2",n),rep("Mt CO2eq/yr",n+1)),check.names=FALSE)
  selected <- task8Selected(cfg,prices)
  for (y in 2010:2100) {
    x[[as.character(y)]] <- c(as.numeric(selected[[as.character(y)]]),rep(NA_real_,n+1))
    if (!is.null(report) && y<=cfg$end_year) {
      a <- report$annual[report$annual$year==y,]
      x[n+seq_len(n),as.character(y)] <- a$value[match(cfg$regions,a$region)]
      x[2*n+1,as.character(y)] <- sum(a$value)
    }
  }
  x
}

# Normalize the other controls by their price effects, not raw slope units.
# Contexts guide endpoint refreshes; only the current world result proves a cap.
# ---- Initial search and upward joint repair --------------------------------
task8Context <- function(cfg,controls,g,kind) {
  x <- controls/max(1,cfg$search$max_price)
  for(r in rownames(x)) {
    l <- cfg$conditions[cfg$conditions$Group==r & cfg$conditions$Kind=="LTT" & cfg$conditions$Enabled,]
    x[r,"ltt"] <- x[r,"ltt"]*if(nrow(l)) l$Year-cfg$ndc_year else 0
  }
  x[g,if(kind=="NDC") "ndc" else "ltt"] <- NA_real_
  as.vector(x)[!is.na(as.vector(x))]
}

task8Step <- function(x,gap,bounds,step,resolution,tolerance,state=NULL,context=numeric(),iteration=NULL,refresh=TRUE) {
  if(!is.finite(gap) || !is.finite(x)) stop("Invalid annual cap residual/control")
  distance <- function(a,b) if(length(a)!=length(b)) Inf else if(length(a)) max(abs(a-b)) else 0
  fresh <- function() list(low=NULL,high=NULL,history=list(),jump=step,direction=0L,
    side=0L,streak=0L,bounds=bounds,iteration=0L,last_width=NA_real_)
  if(is.null(state) || !identical(state$bounds,bounds)) state <- fresh()
  if(is.null(iteration)) iteration <- state$iteration+1L
  state$iteration <- iteration
  previous_width <- if(!is.null(state$low) && !is.null(state$high)) state$high$x-state$low$x else NA_real_
  point <- list(x=x,gap=gap,context=context,iteration=iteration)
  # Retain distinct local samples even while a settled control is held constant.
  state$history <- Filter(function(p) abs(p$x-x)>1e-12,state$history)
  state$history <- tail(c(state$history,list(point)),4L)
  lost <- FALSE
  side <- if(gap>0) 1L else -1L
  state$streak <- if(state$side==side) state$streak+1L else 1L
  state$side <- side
  if(gap>0) {
    if(!is.null(state$high) && state$high$x<=x) { state$high <- NULL; lost <- TRUE }
    if(is.null(state$low) || x>=state$low$x) state$low <- point
  } else {
    if(!is.null(state$low) && state$low$x>=x) { state$low <- NULL; lost <- TRUE }
    if(is.null(state$high) || x<=state$high$x) state$high <- point
  }
  result <- function(value=x,done=FALSE,reason="searching") list(value=value,state=state,done=done,reason=reason)
  if(gap<=0 && (gap>= -tolerance || x<=bounds[1]+1e-10))
    return(result(done=TRUE,reason=if(gap< -tolerance) "legal_floor" else "in_band"))
  # A held resolution endpoint stays settled while its current world result is
  # feasible. Background changes alone must not reopen mutual endpoint checks.
  if(identical(state$terminal,"resolution") && gap<=0 && identical(x,state$terminal_x))
    return(result(done=TRUE,reason="resolution"))
  state$terminal <- NULL; state$terminal_x <- NULL
  if(gap>0 && x>=bounds[2]-1e-10) return(result(done=TRUE,reason="upper_bound_unmet"))
  if(!is.null(state$low) && !is.null(state$high)) {
    width <- state$high$x-state$low$x
    # At resolution, accept only the currently evaluated feasible control. An
    # infeasible current point must revisit the high side before it can settle;
    # neither acceptance depends on the opposite endpoint's stale context.
    if(width<=resolution) {
      if(gap<=0) {
        state$terminal <- "resolution"; state$terminal_x <- x
        return(result(done=TRUE,reason="resolution"))
      }
      return(result(state$high$x,reason="resolution"))
    }
    opposite <- if(gap>0) state$high else state$low
    changed <- distance(context,opposite$context)
    age <- iteration-opposite$iteration
    # Revalidate the old side before interpolating repeatedly against stale data.
    if(refresh && changed>1e-12 && age>=2L && (changed>=0.05 || state$streak>=2L))
      return(result(opposite$x,reason="refresh_endpoint"))
    fraction <- (state$low$gap+tolerance/2)/(state$low$gap-state$high$gap)
    slow <- state$streak>=2L || (is.finite(state$last_width) && width>0.75*state$last_width)
    bisect <- slow || !is.finite(fraction) || fraction<0.2 || fraction>0.8
    if(bisect) fraction <- 0.5
    state$last_width <- width
    return(result(state$low$x+fraction*width,reason=if(bisect) "bisect" else "interpolate"))
  }
  direction <- if(gap>0) 1L else -1L
  if(lost) {
    local <- Filter(function(p) abs(p$x-x)>1e-12 && distance(context,p$context)<=0.05,state$history)
    delta <- NA_real_
    if(length(local)) {
      p <- tail(local,1)[[1]]; derivative <- (gap-p$gap)/(x-p$x)
      if(is.finite(derivative) && derivative< -1e-12) delta <- abs((gap+tolerance/2)/derivative)
    }
    fallback <- if(is.finite(previous_width)) min(step/10,previous_width/2) else step/10
    state$jump <- max(2*resolution,min(step,if(is.finite(delta)) delta else fallback))
    state$direction <- direction
  } else if(direction!=state$direction) state$jump <- step
  value <- max(bounds[1],min(bounds[2],x+direction*state$jump))
  state$jump <- state$jump*2; state$direction <- direction
  result(value,reason=if(lost) "local_rebracket" else "expand")
}

# The latest valid complete-matrix observation is authoritative, including a
# failed-cap independent confirmation. A new confirmation always bypasses cache.
task8CachedTrial <- function(trials,candidate) {
  for(a in rev(trials)) if(isTRUE(a$valid) && isTRUE(all.equal(a$controls,candidate,tolerance=0))) return(a)
  NULL
}

task8Unmet <- function(checks) checks[checks$Enabled & !checks$Met, , drop = FALSE]

task8AtPriceCeiling <- function(cfg, result) {
  missed <- task8Unmet(result$checks)
  nrow(missed) > 0L && isTRUE(all(result$controls[missed$Group, "ndc"] >= cfg$search$max_price - 1e-10))
}

task8GapSummary <- function(missed) {
  paste(paste(missed$Group, missed$Kind, round(missed$Gap, 3), "Mt gap"), collapse = "; ")
}

# Old controllers stopped after archiving this same boundary condition.
# Only a matching terminal reason and a valid, fully bounded candidate qualify.
task8BoundaryOrigin <- function(state) {
  if (!is.null(state$boundary_from) && !is.na(state$boundary_from)) return(state$boundary_from)
  if (!identical(state$status, "unfinished") || !length(state$trials)) return(NA_integer_)
  last <- tail(state$trials, 1L)[[1L]]
  if (isTRUE(last$valid) && task8AtPriceCeiling(state$cfg, last) &&
      identical(state$reason, paste0("Regional calibration incomplete: ", task8GapSummary(task8Unmet(last$checks))))) {
    return(last$iteration)
  }
  NA_integer_
}

# First finish each group's NDC -> LTT path without reopening completed stages.
# Only after every group finishes do joint, upward-only repairs of actual cap
# misses. Logical stages belong to this scheduler, not cached trial labels.
# Optional controls/result start directly from a failed confirmation on resume.
task8Search <- function(cfg,evaluate,controls=NULL,result=NULL,repair_only=FALSE) {
  if(is.null(controls)) controls <- task8InitialControls(cfg)
  groups <- unique(cfg$conditions$Group[cfg$conditions$Enabled & cfg$conditions$Kind=="NDC"])
  later <- if(cfg$target_mode=="ndc-ltt") unique(cfg$conditions$Group[cfg$conditions$Enabled & cfg$conditions$Kind=="LTT"]) else character()
  ndc_states <- ltt_states <- ndc_repair <- ltt_repair <- setNames(vector("list",length(groups)),groups)
  phase <- setNames(rep(if(repair_only) "done" else "NDC",length(groups)),groups)
  mode <- if(repair_only) "repair" else "initial"
  early_steps <- setNames(rep(cfg$search$initial_ndc_price_step,length(groups)),groups)
  seen <- character(); world_iteration <- 1L
  if(is.null(result)) result <- evaluate(controls,paste("Regional",mode))
  if(!isTRUE(all.equal(result$controls,controls,tolerance=0))) stop("Current regional observation does not match its controls")
  repeat {
    signature <- paste(format(as.vector(controls),digits=17),collapse=",")
    signature <- paste(mode,paste(phase,collapse=","),signature,sep=";")
    if(sum(seen==signature)>=4L) stop("Regional calibration incomplete: repeated simultaneous search matrix")
    seen <- c(seen,signature)
    candidate <- controls; boundary <- actions <- character(); previous_phase <- phase
    gap <- function(g,kind) result$checks$Gap[result$checks$Group==g & result$checks$Kind==kind]
    advance <- function(g,kind,state) {
      is_ndc <- kind=="NDC"; column <- if(is_ndc) "ndc" else "ltt"
      task8Step(controls[g,column],gap(g,kind),task8Bounds(cfg,g,controls[g,"ndc"])[[column]],
        cfg$search[[if(is_ndc) "initial_ndc_price_step" else "initial_ltt_slope_step"]],
        cfg$search[[if(is_ndc) "price_resolution" else "slope_resolution"]],
        cfg$search[[if(is_ndc) "ndc_tolerance_mtco2eq" else "ltt_tolerance_mtco2eq"]],
        state,iteration=world_iteration,refresh=FALSE)
    }
    for(g in groups) {
      if(mode=="initial") {
        if(phase[[g]]=="done") next
        kind <- phase[[g]]; is_ndc <- kind=="NDC"
        z <- advance(g,kind,if(is_ndc) ndc_states[[g]] else ltt_states[[g]])
        if(is_ndc) ndc_states[[g]] <- z$state else ltt_states[[g]] <- z$state
        candidate[g,if(is_ndc) "ndc" else "ltt"] <- z$value
        if(z$reason=="upper_bound_unmet") boundary <- c(boundary,paste(g,kind,round(gap(g,kind),3),"Mt gap at price ceiling"))
        if(z$done) {
          if(is_ndc && g %in% later) {
            phase[[g]] <- "LTT"
            candidate[g,"ltt"] <- min(cfg$search$ltt_start_slope,task8Bounds(cfg,g,candidate[g,"ndc"])$ltt[2])
            actions <- c(actions,paste(g,"start LTT"))
          } else {
            phase[[g]] <- "done"
            actions <- c(actions,paste(g,"initial path finished"))
          }
        } else if(z$value!=controls[g,if(is_ndc) "ndc" else "ltt"])
          actions <- c(actions,paste(g,kind,z$reason))
        next
      }
      # Repair observes only actual hard-cap misses. Once a cap is met, discard
      # its expansion jump so a later miss cannot revive an old large step.
      if(gap(g,"NDC")>0) {
        z <- advance(g,"NDC",ndc_repair[[g]]); ndc_repair[[g]] <- z$state
        candidate[g,"ndc"] <- max(controls[g,"ndc"],z$value)
        candidate[g,"ltt"] <- min(controls[g,"ltt"],task8Bounds(cfg,g,candidate[g,"ndc"])$ltt[2])
        ltt_repair[g] <- list(NULL)
        if(candidate[g,"ndc"]>controls[g,"ndc"])
          actions <- c(actions,paste(g,"repair NDC; hold/clamp middle slope"))
        else boundary <- c(boundary,paste(g,"NDC",round(gap(g,"NDC"),3),"Mt gap at price ceiling"))
        next
      }
      ndc_repair[g] <- list(NULL)
      if(!g %in% later || gap(g,"LTT")<=0) { ltt_repair[g] <- list(NULL); next }
      z <- advance(g,"LTT",ltt_repair[[g]]); ltt_repair[[g]] <- z$state
      candidate[g,"ltt"] <- max(controls[g,"ltt"],z$value)
      if(z$reason=="upper_bound_unmet") {
        price <- min(cfg$search$max_price,controls[g,"ndc"]+early_steps[[g]])
        if(price>controls[g,"ndc"]) {
          candidate[g,"ndc"] <- price
          candidate[g,"ltt"] <- min(controls[g,"ltt"],task8Bounds(cfg,g,price)$ltt[2])
          early_steps[[g]] <- early_steps[[g]]*2; ltt_repair[g] <- list(NULL)
          actions <- c(actions,paste(g,"repair LTT by strengthening early anchor"))
        } else boundary <- c(boundary,paste(g,"LTT",round(gap(g,"LTT"),3),"Mt gap at price ceiling"))
      } else if(candidate[g,"ltt"]>controls[g,"ltt"])
        actions <- c(actions,paste(g,"repair LTT"))
    }
    if(mode=="initial" && all(phase=="done")) {
      # Each stage settled on the currently observed value. Do not spend a
      # redundant world call solely to pass the initial/repair barrier.
      if(!isTRUE(all.equal(candidate,controls,tolerance=0))) stop("Initial-stage completion changed unevaluated controls")
      mode <- "repair"
      message("All initial regional paths finished; checking joint NDC/LTT constraints")
      next
    }
    if(isTRUE(all.equal(candidate,controls,tolerance=0))) {
      if(mode=="initial" && !identical(phase,previous_phase)) next
      if(mode=="initial") stop("Regional calibration incomplete: initial search made no progress")
      if(length(boundary)) message("  Search boundaries: ",paste(unique(boundary),collapse="; "))
      missed <- task8Unmet(result$checks)
      if (nrow(missed) && !task8AtPriceCeiling(cfg, result)) {
        stop("Regional repair stalled below the price ceiling: ", task8GapSummary(missed))
      }
      return(list(controls=controls,result=result))
    }
    if(mode=="repair") for(g in groups) for(r in cfg$groups[[g]]) {
      years <- (cfg$fixed_through_year+1):cfg$end_year
      before <- task8GroupPrices(cfg,g,controls,years,anchor=cfg$anchors[[r]])
      after <- task8GroupPrices(cfg,g,candidate,years,anchor=cfg$anchors[[r]])
      if(any(!is.finite(after) | after<0 | after>cfg$search$max_price+1e-8) ||
          any(diff(after)< -1e-8) || any(after<before-1e-8)) stop("Regional repair lowered an annual price or violated path bounds: ",g)
    }
    message("  Next regional actions: ",paste(actions,collapse="; "))
    controls <- candidate; world_iteration <- world_iteration+1L
    result <- evaluate(controls,paste("Regional",mode))
  }
}

# ---- Model flags and final region-year solve checks ------------------------
task8Flags <- function(run_config,cfg) {
  flags <- task7Flags(run_config$scenario$gams_flags,cfg)
  flags$CountrySolveMode <- cfg$execution$country_solve_mode
  flags
}

task8SolveArgs <- function(flags,cfg,confirmation=FALSE) {
  args <- c("main.gms",paste0("--",names(flags),"=",unlist(flags)),if(confirmation) "lo=4" else "lo=3","-Idir=./data")
  if(cfg$execution$country_solve_mode=="parallel")
    args <- c(args,paste0("threadsAsync=",cfg$execution$country_solve_jobs),paste0("threads=",cfg$execution$solver_threads))
  args
}

# In serial solves, listing LOOPS fields identify the region, year and attempt.
# Keep every summary, including failed attempts preceding a successful retry.
task8SolveDiagnostics <- function(trial,regions,years,reason) {
  expected <- as.vector(outer(regions,years,paste,sep=":"))
  stats <- file.path(trial,"modelstat.txt"); listing <- file.path(trial,"main.lst")
  model <- list(present=file.exists(stats),records=0L,malformed=0L,non2=list(),missing=expected)
  if(model$present) {
    lines <- readLines(stats,warn=FALSE); lines <- lines[nzchar(trimws(lines))]
    fields <- regmatches(lines,regexec("^\\s*Country:\\s*(\\S+)\\s+Model Status:\\s*([0-9.]+)\\s+Year:\\s*([0-9]+)\\s*$",lines,perl=TRUE))
    model$malformed <- sum(lengths(fields)!=4L)
    good <- fields[lengths(fields)==4L]; model$records <- length(good)
    if(length(good)) {
      d <- do.call(rbind,good); key <- paste(d[,2],d[,4],sep=":")
      model$missing <- setdiff(expected,key); model$duplicates <- unique(key[duplicated(key)])
      model$unexpected <- setdiff(key,expected)
      model$non2 <- lapply(which(!is.finite(as.numeric(d[,3])) | as.numeric(d[,3])!=2),function(i) list(region=d[i,2],year=as.integer(d[i,4]),model_status=as.numeric(d[i,3])))
    }
  }
  attempts <- list(); country <- NA_character_; year <- NA_integer_; attempt <- NA_character_
  if(file.exists(listing)) {
    con <- file(listing,"r"); on.exit(close(con),add=TRUE); line_number <- 0L
    repeat {
      block <- readLines(con,n=10000L,warn=FALSE)
      if(!length(block)) break
      # Most listing lines are equation/statistics output. Filter in C before
      # parsing contexts, avoiding an R regex loop over millions of lines.
      relevant <- grep("(?:LOOPS|L O O P S)\\s+an\\s+[0-9]{4}|^\\s*(?:runCyL|rcc)\\s+\\S+\\s*$|(?:SOLVER|MODEL) STATUS\\s+[0-9]+",block,perl=TRUE)
      for(i in relevant) {
        line <- block[i]; number <- line_number+i
        y <- regmatches(line,regexec("(?:LOOPS|L O O P S)\\s+an\\s+([0-9]{4})\\s*$",line,perl=TRUE))[[1]]
        r <- regmatches(line,regexec("^\\s*runCyL\\s+(\\S+)\\s*$",line,perl=TRUE))[[1]]
        a <- regmatches(line,regexec("^\\s*rcc\\s+(\\S+)\\s*$",line,perl=TRUE))[[1]]
        if(length(y)==2L) { year <- as.integer(y[2]); country <- NA_character_; attempt <- NA_character_ }
        if(length(r)==2L) country <- r[2]
        if(length(a)==2L) attempt <- a[2]
        z <- regmatches(line,regexec("SOLVER STATUS\\s+([0-9]+)",line,perl=TRUE))[[1]]
        if(length(z)==2L) attempts[[length(attempts)+1L]] <- list(region=country,year=year,attempt=attempt,
          solver_status=as.integer(z[2]),model_status=NA_integer_,listing_line=number,summary=trimws(line))
        z <- regmatches(line,regexec("MODEL STATUS\\s+([0-9]+)",line,perl=TRUE))[[1]]
        if(length(z)==2L && length(attempts)) attempts[[length(attempts)]]$model_status <- as.integer(z[2])
      }
      line_number <- line_number+length(block)
    }
  }
  codes <- vapply(attempts,function(a) a$solver_status,integer(1))
  bad <- attempts[which(is.na(codes) | codes!=1L)]
  counts <- table(codes,useNA="ifany")
  classification <- if(!model$present || model$malformed || length(model$missing) || length(model$duplicates)) "missing_or_invalid_model_status_records" else
    if(length(model$non2)) "non_optimal_final_model_status" else if(length(bad)) "non_normal_solver_attempt" else
      if(length(codes)<length(expected)) "missing_solver_status_records" else "other_validation_or_process_error"
  list(reason=reason,classification=classification,expected_region_years=length(expected),final_model_status=model,
    listing_present=file.exists(listing),solver_status_records=length(codes),solver_status_counts=as.list(counts),
    abnormal_attempts=bad,all_attempts=attempts,acceptance_rule="final-region-year-v1: each region-year's last solver status 1 / model status 2; earlier anomalies retained as warnings")
}

# Full world coverage is mandatory in both files. A recovered earlier attempt
# can warn only after that same region/year has an explicitly normal last solve.
task8CheckSolves <- function(trial,regions,years) {
  d <- task8SolveDiagnostics(trial,regions,years,"solve validation")
  m <- d$final_model_status; expected <- as.vector(outer(regions,years,paste,sep=":"))
  if(!m$present || m$malformed || m$records!=length(expected) || length(m$missing) ||
      length(m$duplicates) || length(m$unexpected) || length(m$non2))
    stop("Missing region/year or non-optimal final model status")
  attempts <- d$all_attempts
  if(!length(attempts) || any(vapply(attempts,function(a)
      is.na(a$region) || is.na(a$year) || is.na(a$solver_status) || is.na(a$model_status),logical(1))))
    stop("Missing or unassociated solver/model status records")
  key <- vapply(attempts,function(a) paste(a$region,a$year,sep=":"),character(1))
  if(!setequal(key,expected)) stop("Missing or unexpected region/year in solver summaries")
  final <- which(!duplicated(key,fromLast=TRUE))
  bad <- final[vapply(attempts[final],function(a) a$solver_status!=1L || a$model_status!=2L,logical(1))]
  if(length(bad)) {
    a <- attempts[[bad[1L]]]
    stop("Non-normal final solve: ",a$region," ",a$year," solver=",a$solver_status," model=",a$model_status)
  }
  earlier <- setdiff(seq_along(attempts),final)
  warnings <- attempts[earlier[vapply(attempts[earlier],function(a) a$solver_status!=1L || a$model_status!=2L,logical(1))]]
  list(final_region_years=length(final),solver_attempts=length(attempts),acceptance="final-region-year-v1",
    retry_region_years=sum(table(key)>1L),warning_count=length(warnings),retry_warnings=warnings)
}

# ---- Durable warning and failure evidence ----------------------------------
task8PreserveWarnings <- function(campaign,result,trial) {
  if(is.null(result$solves$warning_count) || !result$solves$warning_count) return(invisible(NULL))
  folder <- file.path(campaign,"calibration-warnings",sprintf("attempt-%06d",result$model_attempt))
  dir.create(folder,recursive=TRUE,showWarnings=FALSE)
  record <- list(trial=result$iteration,physical_attempt=result$model_attempt,solves=result$solves)
  path <- file.path(folder,"warnings.rds")
  if(file.exists(path) && !identical(readRDS(path),record)) stop("Conflicting solver warning archive; keeping raw trial")
  for(name in c("modelstat.txt","main.lst","gams.log")) {
    source <- file.path(trial,name); target <- file.path(folder,name)
    if(!file.exists(source)) stop("Missing retry-warning evidence: ",source)
    if(file.exists(target)) {
      if(!identical(task7Hash(source),task7Hash(target))) stop("Conflicting warning log; keeping raw trial")
    } else if(!file.copy(source,target) || !identical(task7Hash(source),task7Hash(target))) stop("Could not preserve retry warning log")
  }
  if(!file.exists(path)) {
    staged <- paste0(path,".tmp"); saveRDS(record,staged); task7ReplaceFile(staged,path)
  }
  staged <- file.path(folder,"warnings.json.tmp")
  jsonlite::write_json(record,staged,pretty=TRUE,auto_unbox=TRUE,na="null",digits=NA)
  task7ReplaceFile(staged,file.path(folder,"warnings.json"))
  invisible(folder)
}

# Keep failed results independently of the reusable trial number. Resume can
# replace trial 7 while its failed physical attempt 7 remains durably available.
# Ordinary successful trial cleanup and the physical-attempt budget are unchanged.
task8PreserveFailure <- function(campaign,result,annual,trial=NULL) {
  attempt <- if(is.null(result$model_attempt)) result$iteration else result$model_attempt
  folder <- file.path(campaign,"calibration-failures",sprintf("attempt-%06d",attempt))
  dir.create(folder,recursive=TRUE,showWarnings=FALSE)
  path <- file.path(folder,"failure.rds")
  if(file.exists(path)) {
    old <- readRDS(path)
    if(!identical(old$result,result) || !identical(old$annual,annual)) stop("Conflicting retained failure; keeping both sources: ",folder)
  } else {
    record <- list(result=result,annual=annual,recorded_utc=format(Sys.time(),"%Y-%m-%dT%H:%M:%OS3Z",tz="UTC"))
    staged <- paste0(path,".tmp"); saveRDS(record,staged)
    if(!identical(readRDS(staged),record)) stop("Could not verify failure archive; keeping trial")
    task7ReplaceFile(staged,path)
  }
  if(!is.null(trial) && dir.exists(trial)) {
    if(file.exists(file.path(trial,"task6-process.rds"))) stop("Retained process marker; keeping failed trial in place: ",trial)
    target <- file.path(folder,"trial")
    if(dir.exists(target) || !file.rename(trial,target)) stop("Could not retain failed trial; keeping existing artifacts: ",trial)
  }
  metadata <- list(trial=result$iteration,physical_attempt=attempt,stage=result$stage,reason=result$reason,
    diagnostics=result$diagnostics,full_trial_retained=dir.exists(file.path(folder,"trial")),
    legacy_logs_unavailable=is.null(result$diagnostics) && !dir.exists(file.path(folder,"trial")))
  staged <- file.path(folder,"failure.json.tmp")
  jsonlite::write_json(metadata,staged,pretty=TRUE,auto_unbox=TRUE,na="null",null="null",digits=NA)
  task7ReplaceFile(staged,file.path(folder,"failure.json"))
  invisible(folder)
}

# ---- Completed archive validation ------------------------------------------
task8CompletionStatus <- function(checks) {
  if (nrow(task8Unmet(checks))) "complete_with_unmet_targets" else "complete"
}

task8IsComplete <- function(status) {
  length(status) == 1L && status %in% c("complete", "complete_with_unmet_targets")
}

task8CheckArchivedPrices <- function(paths, prices, cfg) {
  rows <- paths[paths$Metric == "Carbon price", ]
  if (anyDuplicated(rows$Region) || !setequal(rows$Region, cfg$regions)) stop("Incomplete archived price paths")
  rows <- rows[match(prices[[1L]], rows$Region), ]
  years <- as.character(2010:2100)
  expected <- as.numeric(as.matrix(prices[years]))
  observed <- as.numeric(as.matrix(rows[years]))
  if (!isTRUE(all.equal(observed, expected, tolerance = 1e-12))) stop("Archived price paths differ from candidate controls")
}

# Rebuild the accepted matrix and cap checks from the durable workbook.
# Completed campaigns can be reopened after the private state is removed.
task8ValidateArchive <- function(campaign) {
  rc <- jsonlite::read_json(file.path(campaign,"config.json"),simplifyVector=FALSE)
  input <- task7ReadPolicy(file.path(campaign,"data/iEnvPolicies.csv"))
  regions <- task7ReadRegions(campaign)
  settings <- rc$regional_carbon_price_calibration
  cfg <- task8Setup(settings, input, regions, task8Targets(campaign, regions, settings))
  history <- file.path(campaign,"calibration-history.xlsx")
  sheets <- lapply(c("AnnualPaths","SearchSummary","Settings"),function(n) openxlsx::read.xlsx(history,sheet=n,check.names=FALSE))
  status <- sheets[[3]]$Value[sheets[[3]]$Parameter == "Status"]
  if (!task8IsComplete(status)) stop("Archive is not complete")
  selected <- sheets[[2]][sheets[[2]]$Accepted,]
  if(!nrow(selected) || length(unique(selected$Trial))!=1 || any(selected$Stage!="Confirmation" | !selected$ValidRun)) stop("Invalid archived confirmation")
  controls <- as.matrix(selected[!duplicated(selected$Group),c("NDCPrice","LTTSlope")]);rownames(controls)<-unique(selected$Group);colnames(controls)<-c("ndc","ltt")
  prices <- task8Selected(cfg,task8MakePrices(cfg,input,controls))
  for(g in unique(selected$Group[selected$Enabled])) {
    recorded <- selected[selected$Group==g,c("TailSlope","TailMultiplier")]
    expected <- task8Tail(cfg,g,controls)
    if(any(!is.finite(as.matrix(recorded))) || any(abs(recorded$TailSlope-expected["slope"])>1e-8) ||
       any(abs(recorded$TailMultiplier-expected["multiplier"])>1e-8)) stop("Completed tail settings disagree: ",g)
  }
  csv <- file.path(campaign,"calibrated-iEnvPolicies.csv")
  if(!task7SamePrices(task7ReadPolicy(csv),prices)) stop("Completed CSV differs from confirmed controls")
  paths <- sheets[[1]][sheets[[1]]$Trial==selected$Trial[1],]
  reported <- do.call(rbind,lapply(2010:cfg$end_year,function(y) {
    d <- paths[paths$Metric=="Kyoto GHG emissions" & paths$Region %in% cfg$regions,]
    data.frame(region=d$Region,year=y,value=d[[as.character(y)]])
  }))
  checks <- task8Check(cfg,reported)
  if (!identical(task8CompletionStatus(checks), status) || !identical(checks$Met, selected$Met) ||
      !isTRUE(all.equal(checks$Emissions, selected$Emissions, tolerance = 1e-10)) ||
      (nrow(task8Unmet(checks)) && !task8AtPriceCeiling(cfg, list(checks = checks, controls = controls)))) {
    stop("Completed annual cap checks disagree")
  }
  task8CheckArchivedPrices(paths, prices, cfg)
  required <- c(task7ModelFiles(campaign),csv,file.path(campaign,c("reporting.mif","emissions.csv","plot.pdf","Validation.pdf")))
  if(!all(file.exists(required)) || any(file.info(required)$size<=0 & basename(required)!="git_diff.txt")) stop("Completed archive lacks research results")
  task8CheckSolves(campaign,cfg$regions,2024:cfg$end_year)
  invisible(cfg)
}

# ---- Task entry point and campaign lifecycle -------------------------------
runTask8 <- function() {
  root <- normalizePath(getwd(),winslash="/")
  requested <- config$regional_carbon_price_calibration
  args <- commandArgs(trailingOnly=TRUE)
  if (any(!sub("=.*$","",args) %in% c("task_id","resume_from"))) stop("Unsupported Task 8 CLI option")
  override <- sub("^resume_from=","",grep("^resume_from=",args,value=TRUE))
  if (length(override)>1) stop("Supply one resume_from path")
  resume <- if(length(override)) override else requested$resume_from
  resuming <- !is.null(resume)
  requested_budget <- requested$search$max_evaluations
  if (resuming && !is.null(requested_budget)) {
    task7Number(requested_budget, "search.max_evaluations", minimum = 2, integer = TRUE)
  }
  if (!resuming) task8Validate(requested)
  for (package in c("openxlsx","filelock","processx")) if (!requireNamespace(package,quietly=TRUE)) stop("Required package: ",package)
  campaign <- if (resuming) normalizePath(resume,mustWork=TRUE) else file.path(root,"runs",paste0("calibrate-regional-carbon-price-",Sys.getpid(),"_",format(Sys.time(),"%Y-%m-%d_%H-%M-%S")))
  if (!resuming && !dir.create(campaign,recursive=TRUE)) stop("Cannot create regional campaign")
  lock <- filelock::lock(file.path(dirname(tempdir()),paste0("openprom-task8-",digest::digest(campaign),".lock")),timeout=0)
  if (is.null(lock)) stop("Campaign already running")
  on.exit(filelock::unlock(lock),add=TRUE)
  if (!resuming) {
    targetHashes <- function(folder) {
      targets <- file.path(folder, "targets")
      files <- file.path(targets, c("tNDCLTT.csv", "tNDCLTT_coverage.csv"))
      if (dir.exists(file.path(targets, ".ndcltt-publish")) || any(file.exists(paste0(files, ".previous")))) {
        stop("NDC/LTT export is active or needs recovery in ", targets)
      }
      vapply(files, task7Hash, character(1), USE.NAMES = FALSE)
    }
    expectedTargets <- targetHashes(root)
    task7Snapshot(root, campaign, config)
    if (!identical(expectedTargets, targetHashes(campaign)) || !identical(expectedTargets, targetHashes(root))) {
      stop("NDC/LTT inputs changed during the Task 8 snapshot")
    }
  }
  run_config <- jsonlite::read_json(file.path(campaign,"config.json"),simplifyVector=FALSE)
  input <- task7ReadPolicy(file.path(campaign,"data/iEnvPolicies.csv")); regions <- task7ReadRegions(campaign)
  state_dir <- task7StateFolder(campaign); work <- file.path(campaign,".work"); history <- file.path(campaign,"calibration-history.xlsx")
  state_path <- file.path(state_dir,"checkpoint.rds"); pending <- file.path(state_dir,"checkpoint.pending.rds")
  csv <- file.path(campaign,"calibrated-iEnvPolicies.csv")
  # Complete workbooks are self-contained after private state has been removed.
  if (resuming && file.exists(history)) {
    settings <- openxlsx::read.xlsx(history,sheet="Settings")
    if (task8IsComplete(settings$Value[settings$Parameter == "Status"])) {
      task8ValidateArchive(campaign)
      for(folder in task7TrialFolders(work)) task7Cleanup(folder,work,history,task7Hash(history))
      if(dir.exists(work)) task7Cleanup(work,campaign,history,task7Hash(history))
      if(dir.exists(state_dir) && !file.exists(file.path(campaign,"task6-process.rds"))) unlink(state_dir,recursive=TRUE)
      message("Regional calibration already complete: ",campaign); return(invisible(campaign))
    }
  }
  cfg <- task8Setup(run_config$regional_carbon_price_calibration,input,regions,task8Targets(campaign,regions,run_config$regional_carbon_price_calibration))
  search_strategy <- "Finish each NDC/LTT path first; all-group barrier; upward joint repair of current misses"
  if (resuming) {
    retained <- if (file.exists(pending)) readRDS(pending) else if (file.exists(state_path)) readRDS(state_path)$state else NULL
    if (!is.null(retained) && !identical(retained$cfg$search_algorithm, cfg$search_algorithm) &&
        is.na(task8BoundaryOrigin(retained))) {
      stop("Campaign uses an older Task 8 search algorithm; preserve it and start a fresh campaign with this controller")
    }
  }
  default_execution <- cfg$execution
  dir.create(work,showWarnings=FALSE)
  controls <- task8InitialControls(cfg)
  trials <- list(); annual <- list(); status <- "running"; reason <- NA_character_; accepted <- NA_integer_
  repair_from <- NA_integer_ # Latest failed-cap confirmation; durable repair replay origin.
  boundary_from <- NA_integer_ # Archived candidate selected for boundary-only confirmation.
  model_attempts <- 0L # Physical solves, including failures; cached observations cost no attempt.
  # Reconcile a pending checkpoint against the workbook before any new solve.
  same_sheets <- function(st) file.exists(history) && is.null(task7HistoryIssue(history, st$sheets))
  if (resuming) {
    task7StopRetainedProcess(campaign,expected_wd=root)
    if (file.exists(pending)) {
      st <- readRDS(pending)
      if (!same_sheets(st)) {
        old <- if(file.exists(state_path)) readRDS(state_path) else NULL
        prefix <- if(is.null(old)) FALSE else isTRUE(all.equal(head(st$trials,length(old$state$trials)),old$state$trials,tolerance=0))
        if(is.null(old) || !identical(old$hash,task7Hash(history)) || !prefix ||
            length(st$trials)>length(old$state$trials)+1L) stop("Unverified pending checkpoint; keeping all temporary results")
        # A model result completed before Excel publication failed. Archive the
        # durable pending record first; do not discard its unsaved model output.
        if(length(st$trials)>length(old$state$trials) && isTRUE(tail(st$trials,1)[[1]]$valid)) {
          last <- tail(st$trials,1)[[1]]
          task8CheckSolves(file.path(work,sprintf("trial-%03d",last$iteration)),st$cfg$regions,2024:st$cfg$end_year)
        }
        backup <- paste0(history,".previous")
        if(file.exists(backup)) {
          if(!identical(task7Hash(backup),old$hash)) stop("Ambiguous Excel backup; retaining all results")
          unlink(backup)
        }
        task7SaveHistory(history,st$sheets[[1]],st$sheets[[2]],st$sheets[[3]])
        if(!same_sheets(st)) stop("Pending result could not be verified in Excel; keeping trial")
      }
      saveRDS(list(state=st,hash=task7Hash(history)),state_path)
      unlink(pending)
    }
    if (!file.exists(state_path)) stop("Missing regional resume checkpoint; temporary results retained")
    record <- readRDS(state_path)
    if (!identical(record$hash,task7Hash(history))) stop("Checkpoint/Excel mismatch; preserving recovery data")
    # Release stale publication backups only after the canonical pair matches.
    for(backup in paste0(c(state_path,history),".previous")) if(file.exists(backup)) unlink(backup)
    st <- record$state; cfg <- st$cfg; controls <- st$controls; trials <- st$trials; annual <- st$annual
    status <- st$status; accepted <- st$accepted; reason <- st$reason
    boundary_from <- task8BoundaryOrigin(st)
    if (!is.na(boundary_from)) {
      origin <- trials[[boundary_from]]
      if (!isTRUE(origin$valid) || !task8AtPriceCeiling(cfg, origin)) stop("Invalid retained boundary candidate")
      prices <- task8Selected(cfg, task8MakePrices(cfg, input, origin$controls))
      task8CheckArchivedPrices(annual[[boundary_from]], prices, cfg)
      if (is.null(cfg$execution)) cfg$execution <- default_execution
      saved_strategy <- st$sheets$Settings$Value[st$sheets$Settings$Parameter == "Search strategy"]
      if (length(saved_strategy) == 1L) search_strategy <- saved_strategy
      if (is.null(cfg$search_algorithm)) cfg$search_algorithm <- "legacy-unversioned"
    }
    repair_from <- if(is.null(st$repair_from)) NA_integer_ else st$repair_from
    model_attempts <- task7Number(if(is.null(st$model_attempts)) length(trials) else st$model_attempts,
      "retained physical model attempts",integer=TRUE)
    # A solve can be interrupted before its result reaches Excel/checkpoint.
    # Retain its attempt number before an incomplete trial directory is cleared.
    for(folder in task7TrialFolders(work)) {
      request_path <- file.path(folder,"request.rds")
      if(file.exists(request_path)) {
        attempt <- readRDS(request_path)$model_attempt
        if(!is.null(attempt)) model_attempts <- max(model_attempts,
          task7Number(attempt,"retained trial model attempt",integer=TRUE))
      }
    }
    # Confirmation is archived before control returns to the repair loop. If
    # interrupted in that gap, reconstruct the origin from the durable record.
    failed_confirmations <- which(vapply(trials,function(a) isTRUE(a$valid) && a$stage=="Confirmation" &&
      any(a$checks$Enabled & !a$checks$Met),logical(1)))
    if(length(failed_confirmations)) repair_from <- tail(failed_confirmations,1L)
    # Only the evaluation cap can be increased; all physical/target/maturity settings stay frozen.
    cfg$search$max_evaluations <- max(cfg$search$max_evaluations, requested_budget)
  }
  # Publish trial history and controller state as a recoverable transaction.
  summary <- function() {
    if (!length(trials)) return(data.frame(Trial=integer(),Stage=character(),Group=character(),Kind=character(),Year=integer(),Cap=numeric(),Coverage=numeric(),Enabled=logical(),Emissions=numeric(),Gap=numeric(),Met=logical(),NDCPrice=numeric(),LTTSlope=numeric(),TailSlope=numeric(),TailMultiplier=numeric(),ValidRun=logical(),Accepted=logical(),FailureReason=character(),LogExcerpt=character(),PhysicalAttempt=integer(),SolverRetryWarnings=integer(),SolveAcceptance=character()))
    do.call(rbind,lapply(trials,function(a) {
      d <- a$checks
      tail <- lapply(d$Group,function(g) if(any(cfg$conditions$Group==g & cfg$conditions$Kind=="NDC" & cfg$conditions$Enabled)) task8Tail(cfg,g,a$controls) else c(slope=NA_real_,multiplier=NA_real_))
      enabled <- unique(cfg$conditions$Group[cfg$conditions$Enabled & cfg$conditions$Kind=="NDC"])
      later <- unique(cfg$conditions$Group[cfg$conditions$Enabled & cfg$conditions$Kind=="LTT"])
      data.frame(Trial=a$iteration,Stage=a$stage,d,NDCPrice=ifelse(d$Group %in% enabled,a$controls[d$Group,"ndc"],NA_real_),LTTSlope=ifelse(d$Group %in% later,a$controls[d$Group,"ltt"],NA_real_),TailSlope=vapply(tail,function(t) unname(t["slope"]),numeric(1)),TailMultiplier=vapply(tail,function(t) unname(t["multiplier"]),numeric(1)),ValidRun=a$valid,Accepted=!is.na(accepted) && a$iteration==accepted,
        FailureReason=if(is.null(a$reason)) NA_character_ else a$reason,LogExcerpt=if(is.null(a$log_excerpt)) NA_character_ else a$log_excerpt,
        PhysicalAttempt=if(is.null(a$model_attempt)) a$iteration else a$model_attempt,
        SolverRetryWarnings=if(is.null(a$solves$warning_count)) NA_integer_ else a$solves$warning_count,
        SolveAcceptance=if(is.null(a$solves$acceptance)) NA_character_ else a$solves$acceptance,row.names=NULL,check.names=FALSE)
    }))
  }
  settings <- function() {
    values <- c(Status=status,Reason=reason,"Accepted trial"=as.character(accepted),"Target mode"=cfg$target_mode,"Target variant"=cfg$target_variant,
      "Annual metric"=cfg$annual_metric,"Coverage threshold"=cfg$min_target_coverage,"Maximum continuation slope multiplier"=cfg$continuation_slope_multiplier_max,
      "Search strategy"=search_strategy,"Search algorithm"=cfg$search_algorithm,
      "Confirmation repair origin"=as.character(repair_from),"Boundary candidate trial"=as.character(boundary_from),
      "Unmet enabled caps"=if (is.na(accepted)) NA_integer_ else nrow(task8Unmet(trials[[accepted]]$checks)),
      "Physical model attempts"=model_attempts,
      "Solver acceptance"="Final solver status 1 and model status 2 for every region-year; intermediate anomalies warn",
      "Recorded solver retry warnings"=sum(vapply(trials,function(a) if(is.null(a$solves$warning_count)) 0L else as.integer(a$solves$warning_count),integer(1))),
      "Country solve mode"=cfg$execution$country_solve_mode,"Parallel jobs"=cfg$execution$country_solve_jobs,"Parallel solver threads"=cfg$execution$solver_threads,
      "Keep input prices through"=cfg$fixed_through_year,"NDC year"=cfg$ndc_year,"End year"=cfg$end_year,
      "Maximum evaluations"=cfg$search$max_evaluations,"Accounting"="Research Kyoto-GHG convention; source scopes/GWP differ; missing historical weights use known-emissions coverage")
    data.frame(Parameter=names(values),Value=as.character(values),row.names=NULL)
  }
  checkpoint <- function() {
    paths <- if (length(annual)) do.call(rbind, annual) else task8Annual(cfg, 0, input)[FALSE, ]
    sheets <- task7HistorySheets(paths, summary(), settings())
    st <- list(cfg=cfg,controls=controls,trials=trials,annual=annual,status=status,reason=reason,accepted=accepted,repair_from=repair_from,boundary_from=boundary_from,model_attempts=model_attempts,solve_acceptance="final-region-year-v1",sheets=sheets)
    saveRDS(st,pending)
    hash <- task7SaveHistory(history,sheets[[1]],sheets[[2]],sheets[[3]])
    staged <- paste0(state_path,".tmp"); saveRDS(list(state=st,hash=hash),staged); task7ReplaceFile(staged,state_path)
    if (!identical(readRDS(state_path)$hash,task7Hash(history))) stop("Checkpoint verification failed")
    unlink(pending); hash
  }
  clean <- function(path,parent) task7Cleanup(path,parent,history,task7Hash(history))
  # Preserve failed physical attempts before reusing their logical trial number.
  # Failure evidence stays outside private state even after eventual completion.
  if (resuming) {
    while(length(trials) && !isTRUE(tail(trials,1)[[1]]$valid)) {
      failed <- tail(trials,1)[[1]]; folder <- file.path(work,sprintf("trial-%03d",failed$iteration))
      if(dir.exists(folder)) task7StopRetainedProcess(folder)
      task8PreserveFailure(campaign,failed,tail(annual,1)[[1]],folder)
      trials <- head(trials,-1); annual <- head(annual,-1)
    }
    if(status %in% c("unfinished","interrupted","running")) { status <- "running"; reason <- NA_character_ }
    checkpoint()
    for (folder in task7TrialFolders(work)) {
      task7StopRetainedProcess(folder)
      idx <- as.integer(sub("trial-","",basename(folder)))
      if (idx<=length(trials) && trials[[idx]]$stage=="Confirmation") next
      request <- file.path(folder,"request.rds")
      if(idx>length(trials) && file.exists(request)) {
        # Interruption/save failure may leave an attempted call outside Excel.
        # Its request already charged the budget; keep the raw evidence too.
        failed <- readRDS(request)
        failed$reason <- "Interrupted before valid trial archival"
        failed$diagnostics <- task8SolveDiagnostics(folder,regions,2024:cfg$end_year,failed$reason)
        paths <- task8Annual(cfg,idx,task8MakePrices(cfg,input,failed$controls))
        task8PreserveFailure(campaign,failed,paths,folder)
        next
      }
      clean(folder,work)
    }
  }
  # Reuse the frozen reporting worker for trial emissions and final reports.
  worker <- file.path(campaign,"scripts/tasks/task7CalibrateGlobalCarbonPrice.R")
  env <- task7ProcessEnvironment(run_config,campaign)
  flags <- task8Flags(run_config,cfg)
  report_process <- function(mode,trial=NULL) task7RunProcess(file.path(R.home("bin"),"Rscript"),
    c(worker,"--task7-report",mode,if(mode=="full") campaign else work,trial),
    if(mode=="full") root else if(is.null(trial)) work else trial,
    if(mode=="full") NULL else file.path(if(is.null(trial)) work else trial,"report.log"),env=env,
    marker_folder=if(mode=="full") campaign else if(is.null(trial)) work else trial)
  if(resuming && cfg$search$max_evaluations != run_config$regional_carbon_price_calibration$search$max_evaluations) {
    run_config$regional_carbon_price_calibration$search$max_evaluations <- cfg$search$max_evaluations
    staged_config <- file.path(work,"updated-config.json")
    jsonlite::write_json(run_config,staged_config,pretty=TRUE,auto_unbox=TRUE,null="null",digits=NA)
    task7ReplaceFile(staged_config,file.path(campaign,"config.json"))
  }
  saveRDS(cfg,file.path(work,"config.rds"))
  if (!file.exists(file.path(state_dir,"package-versions.rds"))) report_process("freeze")
  if (!identical(task7PackageVersions(),readRDS(file.path(state_dir,"package-versions.rds")))) stop("Reporting package versions changed")
  checkpoint()
  # Archive each physical attempt before cleanup or handing its result to search.
  evaluate <- function(candidate,stage="NDC",confirmation=FALSE) {
    prices <- task8MakePrices(cfg,input,candidate)
    if (!confirmation) {
      cached <- task8CachedTrial(trials,candidate)
      if(!is.null(cached)) return(cached)
    }
    if (model_attempts>=cfg$search$max_evaluations-if(confirmation) 0 else 1) stop("evaluation_budget_exhausted; increase max_evaluations and resume")
    idx <- length(trials)+1L; trial <- file.path(work,sprintf("trial-%03d",idx))
    if(!dir.create(trial)) stop("Uncleared trial directory: ",trial)
    message("Trial ",idx," (",stage,")")
    result <- list(iteration=idx,stage=stage,controls=candidate,valid=FALSE)
    saveRDS(result,file.path(trial,"request.rds"))
    report <- NULL
    result <- tryCatch({
      if (!all(file.copy(task7Sources(campaign),trial,recursive=TRUE))) stop("Incomplete trial snapshot")
      task7WritePrices(file.path(trial,"data/iEnvPolicies.csv"),prices)
      if(confirmation) task7SaveMetadata(root,trial)
      # Persist before launching so interruption/resume cannot recycle budget
      # when the incomplete trial number itself is reused.
      model_attempts <<- model_attempts+1L
      result$model_attempt <- model_attempts
      saveRDS(result,file.path(trial,"request.rds"))
      message("  Physical model attempt ",model_attempts)
      task7RunProcess(gams,task8SolveArgs(flags,cfg,confirmation),trial,file.path(trial,"gams.log"),env=env)
      result$solves <- task8CheckSolves(trial,regions,2024:cfg$end_year)
      report_process("evaluate",trial); report <- readRDS(file.path(trial,"report.rds"))
      task8PreserveWarnings(campaign,result,trial)
      result$checks <- task8Check(cfg,report$annual); result$valid <- TRUE; result
    },error=function(e) { result$reason <- conditionMessage(e); result })
    if(!result$valid) {
      result$log_excerpt <- task7LogExcerpt(file.path(trial,c("gams.log","report.log")))
      result$diagnostics <- tryCatch(task8SolveDiagnostics(trial,regions,2024:cfg$end_year,result$reason),
        error=function(e) list(reason=result$reason,diagnostic_error=conditionMessage(e)))
      result$checks <- cfg$conditions; result$checks$Emissions<-NA_real_; result$checks$Gap<-NA_real_;result$checks$Met<-FALSE
    }
    trials[[idx]] <<- result; annual[[idx]] <<- task8Annual(cfg,idx,prices,report)
    controls <<- candidate
    checkpoint() # Persistence errors propagate; never clean unarchived output.
    if(!result$valid) {
      task8PreserveFailure(campaign,result,annual[[idx]],trial)
      stop("Trial ",idx," failed: ",result$reason)
    }
    if (!confirmation) clean(trial,work)
    if(!is.null(result$solves$warning_count) && result$solves$warning_count)
      message("  Solver retry warnings: ",result$solves$warning_count,"; all final region-year solves normal")
    message("  Unmet active caps: ",sum(!result$checks$Met & result$checks$Enabled),"; largest gap: ",round(max(result$checks$Gap[result$checks$Enabled]),3)," Mt CO2eq/yr")
    result
  }
  # Publish only an independently confirmed price path and its model outputs.
  publish <- function(result) {
    trial <- file.path(work,sprintf("trial-%03d",result$iteration))
    files <- task7ModelFiles(trial)
    if(!all(file.exists(files))) stop("Confirmation files missing; preserving state")
    for(f in files) if(!file.copy(f,campaign,overwrite=TRUE) || !identical(task7Hash(f),task7Hash(file.path(campaign,basename(f))))) stop("Final model publication failed")
    staged <- file.path(work,"calibrated-iEnvPolicies.csv")
    task7WritePrices(staged,task8Selected(cfg,task8MakePrices(cfg,input,result$controls)))
    task7ReplaceFile(staged,csv)
    if(!task7SamePrices(task7ReadPolicy(csv),task8Selected(cfg,task8MakePrices(cfg,input,result$controls)))) stop("Final CSV differs from confirmation")
  }
  run <- function() {
    if (!is.na(accepted) && status %in% c("verified","postprocessing","postprocessing_failed")) {
      if(status=="verified") publish(trials[[accepted]])
      return(trials[[accepted]])
    }
    # A cap failure in confirmation starts a durable repair-only replay. Resume
    # from that observation, not from an old cached success or first-pass stages.
    if (!is.na(boundary_from)) {
      origin <- trials[[boundary_from]]
      message("Confirming archived price-ceiling candidate from trial ", boundary_from)
      search <- list(controls = origin$controls, result = origin)
    } else if(!is.na(repair_from)) {
      if(length(repair_from)!=1L || repair_from<1L || repair_from>length(trials) ||
          !isTRUE(trials[[repair_from]]$valid) || trials[[repair_from]]$stage!="Confirmation" ||
          !any(trials[[repair_from]]$checks$Enabled & !trials[[repair_from]]$checks$Met))
        stop("Invalid retained confirmation repair origin")
      origin <- trials[[repair_from]]
      search <- task8Search(cfg,evaluate,controls=origin$controls,result=origin,repair_only=TRUE)
    } else search <- task8Search(cfg,evaluate)
    repeat {
      controls <<- search$controls; result <- search$result
      if (is.na(boundary_from) && task8AtPriceCeiling(cfg, result)) {
        boundary_from <<- result$iteration
        checkpoint()
      }
      confirmation <- evaluate(controls,"Confirmation",TRUE)
      missed <- task8Unmet(confirmation$checks)
      if (nrow(missed) && is.na(boundary_from)) {
        repair_from <<- confirmation$iteration
        status <<- "running"; reason <<- "Independent confirmation found cap misses; joint repair resumed"
        checkpoint()
        message("Independent confirmation found cap misses; continuing upward joint repair")
        search <- task8Search(cfg,evaluate,controls=confirmation$controls,result=confirmation,repair_only=TRUE)
        next
      }
      if (!identical(confirmation$checks$Met, result$checks$Met) ||
          !isTRUE(all.equal(confirmation$checks$Emissions, result$checks$Emissions, tolerance = 1e-10)) ||
          (nrow(missed) && !task8AtPriceCeiling(cfg, confirmation))) {
        stop("Independent confirmation changed results")
      }
      accepted <<- confirmation$iteration; status <<- "verified"; reason <<- NA_character_
      checkpoint(); publish(confirmation)
      return(confirmation)
    }
  }
  result <- tryCatch(run(),error=function(e) {
    # If the workbook/save failed, leave its pending transaction and trial intact.
    # A publication failure must not discard an already accepted confirmation;
    # resume can retry its retained files even after the solve budget is spent.
    if(!file.exists(pending)) { if(status!="verified") status <<- "unfinished"; reason <<- conditionMessage(e); checkpoint() }
    stop(e)
  },interrupt=function(e) {
    if(status!="verified") status <<- "interrupted"
    reason <<- if(status=="verified") "Publication interrupted; accepted confirmation retained for resume" else
      "Interrupted; incomplete trial will be cleared and its number reused on resume"
    if(!file.exists(pending)) checkpoint()
    stop("Regional calibration interrupted; recovery state retained for resume",call.=FALSE)
  })
  status <- "postprocessing"; checkpoint()
  tryCatch({
    report_process("full")
    required <- c(task7ModelFiles(campaign),csv,file.path(campaign,c("reporting.mif","emissions.csv","plot.pdf","Validation.pdf")))
    if(!all(file.exists(required)) || any(file.info(required)$size<=0 & basename(required)!="git_diff.txt")) stop("Missing final research outputs")
  },error=function(e) { status <<- "postprocessing_failed"; reason <<- conditionMessage(e); checkpoint(); stop(e) })
  status <- task8CompletionStatus(result$checks)
  reason <- if (identical(status, "complete")) "All enabled annual caps independently confirmed" else
    paste0("Independently confirmed at the price ceiling with unmet caps: ", task8GapSummary(task8Unmet(result$checks)))
  checkpoint()
  task8ValidateArchive(campaign)
  # Full reporting is complete and the final workbook has been reopened/verified.
  for(folder in task7TrialFolders(work)) clean(folder,work)
  clean(work,campaign)
  if(file.exists(pending) || file.exists(file.path(campaign,"task6-process.rds"))) stop("Unfinished publication/process; keeping recovery state")
  if(unlink(state_dir,recursive=TRUE)!=0 || dir.exists(state_dir)) stop("Could not clean completed recovery state")
  message("Regional calibration ", status, ": ", campaign)
  invisible(campaign)
}
