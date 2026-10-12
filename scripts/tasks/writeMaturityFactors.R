# Writes the maturity-factor multiplier CSVs that core/input.gms and
# modules/04_PowerGeneration/simple/input.gms include:
#   data/iMatFacMultSupply.csv    (PGALL, years)         data/iMatFacMultSupplyCy.csv  (allCy, PGALL, years)
#   data/iMatFacMultDemand.csv    (DSBS, TECH, years)    data/iMatFacMultDemandCy.csv  (allCy, DSBS, TECH, years)
# main.gms runs this on every compile, so the files always match the scenario.
# Config syntax: tutorials/15_Pushing technologies through maturity factors.md

`%||%` <- function(a, b) if (is.null(a)) b else a
years  <- 2010:2100                            # must match ytime in core/sets.gms
fields <- c("tech", "mult", "sector", "region", "from", "to")
header <- list(Supply   = "PGALL",            SupplyCy = c("allCy", "PGALL"),
               Demand   = c("DSBS", "TECH"),  DemandCy = c("allCy", "DSBS", "TECH"))

fail <- function(...) { cat("maturity_factors ", ..., "\n", sep = ""); quit(status = 1) }

# ---- scenario: env var set by start.R, else the config file, else nothing ----
raw <- Sys.getenv("OPENPROM_SCENARIO")
cfg <- Sys.getenv("OPENPROM_CONFIG", unset = "config.json")
mf  <- NULL
if (nzchar(raw)) {
  mf <- jsonlite::fromJSON(raw, simplifyVector = FALSE)$maturity_factors
} else if (file.exists(cfg)) {
  mf <- jsonlite::fromJSON(cfg, simplifyVector = FALSE)$scenario$maturity_factors
}
mf  <- mf %||% list()

if (length(mf) && is.null(names(mf)))
  fail('must be an object: { "levels": {...}, "changes": [...] }')
unknown <- setdiff(names(mf), c("levels", "changes"))
if (length(unknown))
  fail("has unknown key(s) ", paste(unknown, collapse = ", "), '. Only "levels" and "changes" are allowed.')
levels  <- modifyList(list(low = 0.5, def = 1, high = 2), mf$levels %||% list())
changes <- mf$changes %||% list()
if (length(changes) && (!is.list(changes) || is.null(names(changes))))
  fail('"changes" must be named: { "solar": { "tech": "PGSOL", "mult": "high" }, ... }')
dup <- unique(names(changes)[duplicated(names(changes))])
if (length(dup)) fail("has duplicate change name(s): ", paste(dup, collapse = ", "))

# Changes are defined in the config file only. A batch CSV
# may override their fields but not introduce new names, so a misspelled name is caught here.
if (nzchar(raw) && length(changes)) {
  if (!file.exists(cfg)) fail("cannot check change names: ", cfg, " not found in ", getwd())
  defined <- names(jsonlite::fromJSON(cfg, simplifyVector = FALSE)$scenario$maturity_factors$changes)
  extra   <- setdiff(names(changes), defined)
  if (length(extra))
    fail("change(s) not defined in ", cfg, ": ", paste(extra, collapse = ", "),
         ". A batch CSV can only override existing changes (defined: ",
         if (length(defined)) paste(defined, collapse = ", ") else "none", ").")
}

# ---- changes -> one line per (file, keys); later changes overwrite earlier ones where they overlap ----
lines <- list()
for (i in seq_along(changes)) {
  r  <- changes[[i]]
  nm <- names(changes)[i]
  at <- paste0("changes.", nm)
  if (!nzchar(nm)) fail('every change needs a name, e.g. "solar": { "tech": "PGSOL", "mult": "high" }')
  if (!is.list(r) || is.null(names(r)))
    fail(at, ': must be an object like { "tech": "PGSOL", "mult": "high" }')
  bad <- setdiff(names(r), fields)
  if (length(bad)) fail(at, ": unknown field(s) ", paste(bad, collapse = ", "))
  if (is.null(r$tech) || is.null(r$mult)) fail(at, ': needs "tech" and "mult"')
  mult <- r$mult
  if (is.character(mult)) {
    if (is.null(levels[[mult]]))
      fail(at, ": unknown level '", mult, "'. Levels: ", paste(names(levels), collapse = ", "))
    mult <- levels[[mult]]
  }
  if (!is.numeric(mult) || length(mult) != 1 || is.na(mult) || mult <= 0)
    fail(at, ': "mult" must be a level name or a positive number')
  from <- suppressWarnings(as.integer(r$from %||% years[1]))
  to   <- suppressWarnings(as.integer(r$to   %||% years[length(years)]))
  if (is.na(from) || is.na(to) || from > to) fail(at, ': "from"/"to" must be years with from <= to')

  file <- paste0(if (is.null(r$sector)) "Supply" else "Demand", if (is.null(r$region)) "" else "Cy")
  keys <- c(r$region, r$sector, r$tech)
  id   <- paste(c(file, keys), collapse = "|")
  if (is.null(lines[[id]])) lines[[id]] <- list(file = file, keys = keys, vals = rep(0, length(years)))
  lines[[id]]$vals[years >= from & years <= to] <- mult
}

# ---- write; 0 means "not set", so GAMS leaves that cell untouched ----
dir.create("data", showWarnings = FALSE)
for (f in names(header)) {
  rows <- Filter(function(l) l$file == f, lines)
  writeLines(c(paste(sprintf('"%s"', c(header[[f]], years)), collapse = ","),
               vapply(rows, function(l) paste(c(sprintf('"%s"', l$keys), as.character(l$vals)),
                                              collapse = ","), "")),
             file.path("data", paste0("iMatFacMult", f, ".csv")))
}
if (length(lines))
  cat("Maturity-factor multipliers:", length(changes), "change(s) from",
      if (nzchar(raw)) "OPENPROM_SCENARIO" else cfg, "\n")
