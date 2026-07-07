# ============================================================
# Extract a variable (default: Emissions|CO2|Cumulated) from a reporting.mif
# ============================================================
#
# Reads a reporting.mif, filters to a chosen variable, a set of regions, and a
# single year or a range of years, and prints a Region x Year table to the
# terminal. Optionally also writes the result to a CSV (long format).
#
# Usage (Rscript):
#   Rscript scripts/tasks/extractCumulatedEmissions.R <mif> <years> <regions> <variable> <out>
#
#   <mif>      path to reporting.mif (default: latest runs/*/reporting.mif)
#   <years>    "2100"  or  "2050:2100"  or  "2030,2050,2100"   (default: 2100)
#   <regions>  comma-separated region codes, or "ALL"          (default: ALL)
#   <variable> variable to select (default: Emissions|CO2|Cumulated)
#   <out>      optional csv path; if omitted, only prints to terminal
#
# Or source() this file and call extractVariableFromMif() directly.

suppressPackageStartupMessages({
  library(data.table)
})

# Find the most recently modified runs/*/reporting.mif.
latestReportingMif <- function(runsDir = "runs") {
  mifs <- list.files(runsDir, pattern = "^reporting\\.mif$",
                     recursive = TRUE, full.names = TRUE)
  if (!length(mifs)) stop("No reporting.mif found under ", runsDir)
  mifs[which.max(file.info(mifs)$mtime)]
}

# Parse "2100", "2050:2100", or "2030,2050,2100" into an integer vector.
parseYears <- function(spec) {
  spec <- trimws(as.character(spec))
  if (grepl(":", spec, fixed = TRUE)) {
    bounds <- as.integer(strsplit(spec, ":", fixed = TRUE)[[1]])
    return(seq(bounds[1], bounds[2]))
  }
  as.integer(trimws(strsplit(spec, ",", fixed = TRUE)[[1]]))
}

extractVariableFromMif <- function(mifPath,
                                   years    = 2100,
                                   regions  = "ALL",
                                   variable = "Emissions|CO2|Cumulated",
                                   outPath  = NULL) {
  if (!file.exists(mifPath)) stop("MIF not found: ", mifPath)

  # MIF is ';'-separated; a trailing ';' produces an empty final column we drop.
  dt <- data.table::fread(mifPath, sep = ";", header = TRUE, check.names = FALSE)
  emptyCols <- names(dt)[names(dt) == "" | grepl("^V[0-9]+$", names(dt))]
  if (length(emptyCols)) dt[, (emptyCols) := NULL]

  metaCols <- c("Model", "Scenario", "Region", "Variable", "Unit")
  if (!all(metaCols %in% names(dt))) {
    stop("Unexpected MIF header. Expected columns: ", paste(metaCols, collapse = ", "))
  }

  # Filter to the requested variable.
  sub <- dt[Variable == variable]
  if (!nrow(sub)) stop("Variable not found in MIF: ", variable)

  # Filter regions (skip if "ALL").
  if (!(length(regions) == 1 && toupper(regions[1]) == "ALL")) {
    missing <- setdiff(regions, unique(sub$Region))
    if (length(missing)) warning("Regions not found and skipped: ", paste(missing, collapse = ", "))
    sub <- sub[Region %in% regions]
    if (!nrow(sub)) stop("No rows after region filter.")
  }

  # Keep only requested year columns that actually exist.
  yearWanted <- as.character(parseYears(years))
  yearCols   <- intersect(yearWanted, names(sub))
  missingYrs <- setdiff(yearWanted, yearCols)
  if (length(missingYrs)) warning("Years not in MIF and skipped: ", paste(missingYrs, collapse = ", "))
  if (!length(yearCols)) stop("None of the requested years are present in the MIF.")

  keep <- c("Model", "Scenario", "Region", "Variable", "Unit", yearCols)
  sub  <- sub[, ..keep]

  # Long format: one row per region x year.
  long <- data.table::melt(
    sub,
    id.vars       = c("Model", "Scenario", "Region", "Variable", "Unit"),
    measure.vars  = yearCols,
    variable.name = "Year",
    value.name    = "Value"
  )
  long[, Year := as.integer(as.character(Year))]
  data.table::setorder(long, Region, Year)

  # Pretty terminal print: Region rows, Year columns.
  wide <- data.table::dcast(long, Region ~ Year, value.var = "Value")
  cat(sprintf("\n%s  [%s]\n", variable, unique(sub$Unit)[1]))
  print(wide, row.names = FALSE)
  cat("\n")

  # Write CSV only if an output path was requested.
  if (!is.null(outPath)) {
    data.table::fwrite(long, outPath)
    message(sprintf("Wrote %d rows to %s", nrow(long), outPath))
  }
  invisible(long)
}

# ----------------------------
# Command-line entry point
# ----------------------------
if (sys.nframe() == 0) {
  args     <- commandArgs(trailingOnly = TRUE)
  mifPath  <- if (length(args) >= 1 && nzchar(args[1])) args[1] else latestReportingMif()
  message("Using MIF: ", mifPath)
  years    <- if (length(args) >= 2 && nzchar(args[2])) args[2] else 2100
  regions  <- if (length(args) >= 3 && nzchar(args[3])) trimws(strsplit(args[3], ",")[[1]]) else "ALL"
  variable <- if (length(args) >= 4 && nzchar(args[4])) args[4] else "Emissions|CO2|Cumulated"
  outPath  <- if (length(args) >= 5 && nzchar(args[5])) args[5] else NULL

  invisible(extractVariableFromMif(
    mifPath  = mifPath,
    years    = years,
    regions  = regions,
    variable = variable,
    outPath  = outPath
  ))
}
