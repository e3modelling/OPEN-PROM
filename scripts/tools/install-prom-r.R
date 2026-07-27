#!/usr/bin/env Rscript
# ==============================================================================
# install-prom-r.R
#
# Installs the R packages mrprom and postprom (E3-Modelling / OPEN-PROM).
# Runs identically on Windows R (incl. from Git Bash / PowerShell / cmd),
# on WSL, and on native Linux or macOS.
#
# TWO MODES
#
#   Self-contained (recommended for testing and for trying a new machine):
#     Rscript install-prom-r.R --prefix=~/prom-env
#       -> everything lives under that one folder: library, madrat data,
#          settings. Nothing outside it is read or written. Delete the
#          folder and the machine is exactly as it was.
#
#   System (a normal install for daily use):
#     Rscript install-prom-r.R
#       -> installs into your user library and records settings in ~/.Renviron
#
# OPTIONS
#   --prefix=DIR    self-contained environment rooted at DIR (implies isolation)
#   --clean         wipe the prefix library before installing (prefix mode only)
#   --check         verify only, change nothing (honours --prefix)
#   --extras        also install optional Suggests dependencies
#   --lib=DIR       override the library location
#   --madrat=DIR    override the madrat main folder
#   --gams=DIR      point gdxrrw at a GAMS system directory
#   --also=a,b      extra packages to install alongside (e.g. --also=jsonlite)
#   --no-renviron   never modify ~/.Renviron
#
# RUNTIME OVERRIDES
#   In --prefix mode the environment is written with deferred defaults, so
#   MADRAT_MAINFOLDER and R_GAMS_SYSDIR set in the shell win over the baked-in
#   values. The generated prom-R / prom-Rscript launchers expose that as
#   --madrat=DIR, e.g.
#       ~/prom-env/prom-R --madrat=/data/shared-madrat
#
# On Windows you need R and Rtools installed first.
# On Ubuntu/WSL use install-prom-r.sh, which installs the system libraries
# and then calls this script.
#
# Safe to re-run.
# ==============================================================================

# ------------------------------------------------------------------------------
# Arguments
# ------------------------------------------------------------------------------
args <- commandArgs(trailingOnly = TRUE)

optval <- function(name, default = "") {
  hit <- grep(paste0("^--", name, "="), args, value = TRUE)
  if (length(hit) == 0) return(default)
  sub(paste0("^--", name, "="), "", hit[[1]])
}
flag <- function(name) any(args == paste0("--", name))

msg  <- function(...) cat(sprintf("==> %s\n", paste0(...)))
warn <- function(...) cat(sprintf("[!] %s\n", paste0(...)))
fail <- function(...) { cat(sprintf("[x] %s\n", paste0(...))); quit(status = 1) }

if (flag("help") || flag("h")) {
  self <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE)[1])
  writeLines(sub("^# ?", "", grep("^#", readLines(self)[2:35], value = TRUE)))
  quit(status = 0)
}

CHECK_ONLY <- flag("check")
EXTRAS     <- flag("extras")
CLEAN      <- flag("clean")
ALSO       <- if (nzchar(optval("also"))) {
  setdiff(trimws(strsplit(optval("also"), ",", fixed = TRUE)[[1]]), "")
} else character(0)

PREFIX   <- optval("prefix")
ISOLATED <- nzchar(PREFIX)
if (ISOLATED) PREFIX <- normalizePath(path.expand(PREFIX), winslash = "/", mustWork = FALSE)
TOUCH_RENVIRON <- !(flag("no-renviron") || ISOLATED)

if (CLEAN && !ISOLATED) fail("--clean only works together with --prefix, to avoid deleting a shared library.")

# ------------------------------------------------------------------------------
# Platform
# ------------------------------------------------------------------------------
IS_WINDOWS <- .Platform$OS.type == "windows"
IS_MAC     <- Sys.info()[["sysname"]] == "Darwin"
IS_LINUX   <- !IS_WINDOWS && !IS_MAC

codename <- NA_character_
if (IS_LINUX && file.exists("/etc/os-release")) {
  os  <- readLines("/etc/os-release", warn = FALSE)
  hit <- grep("^(UBUNTU_CODENAME|VERSION_CODENAME)=", os, value = TRUE)
  if (length(hit)) codename <- gsub('"', "", sub("^[A-Z_]+=", "", hit[[1]]))
}
is_wsl <- IS_LINUX && file.exists("/proc/version") &&
  grepl("microsoft", tolower(paste(readLines("/proc/version", warn = FALSE), collapse = " ")))

msg("Platform: ", Sys.info()[["sysname"]],
    if (is_wsl) " (WSL)" else "",
    if (!is.na(codename)) paste0(" / ", codename) else "",
    " | R ", getRversion())
msg("Mode: ", if (ISOLATED) paste0("self-contained at ", PREFIX) else "system install")

# ------------------------------------------------------------------------------
# Locations
# ------------------------------------------------------------------------------
default_lib <- if (ISOLATED) {
  file.path(PREFIX, "library")
} else {
  lp <- Sys.getenv("R_LIBS_USER")
  if (nzchar(lp)) strsplit(lp, .Platform$path.sep, fixed = TRUE)[[1]][1]
  else path.expand(file.path("~", "R", paste0(R.version$platform, "-library"),
                             paste(R.version$major,
                                   strsplit(R.version$minor, ".", fixed = TRUE)[[1]][1],
                                   sep = ".")))
}

LIB <- optval("lib", default_lib)
LIB <- normalizePath(path.expand(LIB), winslash = "/", mustWork = FALSE)

# madrat folder, in order of precedence. The source is reported, because
# "why is it using that folder" is otherwise guesswork.
recorded_madrat <- function() {
  f <- file.path(PREFIX, ".Renviron")
  if (!ISOLATED || !file.exists(f)) return("")
  ln <- grep("^MADRAT_MAINFOLDER=", readLines(f, warn = FALSE), value = TRUE)
  if (!length(ln)) return("")
  v <- sub("^MADRAT_MAINFOLDER=", "", ln[[1]])
  sub("\\}$", "", sub("^\\$\\{MADRAT_MAINFOLDER-", "", v))   # unwrap ${VAR-default}
}

MADRAT_DIR <- optval("madrat"); madrat_src <- "--madrat flag"
if (!nzchar(MADRAT_DIR)) {
  MADRAT_DIR <- Sys.getenv("MADRAT_MAINFOLDER", unset = "")
  madrat_src <- "MADRAT_MAINFOLDER environment variable"
}
if (!nzchar(MADRAT_DIR)) {
  MADRAT_DIR <- recorded_madrat()
  madrat_src <- "recorded by a previous install in the prefix"
}
if (!nzchar(MADRAT_DIR)) {
  MADRAT_DIR <- if (ISOLATED) file.path(PREFIX, "madrat") else path.expand("~/madrat")
  madrat_src <- "built-in default"
}
MADRAT_DIR <- normalizePath(path.expand(MADRAT_DIR), winslash = "/", mustWork = FALSE)

if (CLEAN && dir.exists(LIB)) {
  if (!startsWith(LIB, PREFIX)) fail("--clean refused: ", LIB, " is outside the prefix.")
  msg("Removing ", LIB, " ...")
  unlink(LIB, recursive = TRUE, force = TRUE)
}

if (!CHECK_ONLY) dir.create(LIB, recursive = TRUE, showWarnings = FALSE)

# In isolated mode, .libPaths(LIB) resolves to LIB plus R's own base library
# only -- the user and site libraries drop out of the search path entirely.
# That is what makes this a genuine test: nothing can be satisfied by a package
# that happens to already be installed elsewhere on the machine.
if (ISOLATED) {
  .libPaths(LIB)
} else if (dir.exists(LIB)) {
  .libPaths(c(LIB, .libPaths()))
}
msg("Library: ", LIB)
msg("Search path: ", paste(.libPaths(), collapse = " | "))

# ------------------------------------------------------------------------------
# Repositories
#
# The PIK r-universe is not optional: mrdrivers, gdx, gdxrrw, mip and
# piamValidation are not on CRAN. It also serves prebuilt Windows binaries,
# which spares Rtools most of the work.
#
# On known Ubuntu releases, Posit Package Manager supplies precompiled Linux
# binaries -- minutes instead of an hour -- but only if the HTTP user agent
# identifies the platform.
# ------------------------------------------------------------------------------
p3m <- if (IS_LINUX && !is.na(codename) && codename %in% c("focal", "jammy", "noble")) {
  sprintf("https://packagemanager.posit.co/cran/__linux__/%s/latest", codename)
} else NULL

repos <- c(
  if (!is.null(p3m)) c(P3M = p3m),
  PIK  = "https://pik-piam.r-universe.dev",
  CRAN = "https://cloud.r-project.org"
)

options(
  repos   = repos,
  Ncpus   = max(1L, parallel::detectCores(logical = FALSE) - 1L),
  timeout = 900,
  warn    = 1
)
if (!is.null(p3m)) {
  options(HTTPUserAgent = sprintf(
    "R/%s R (%s)", getRversion(),
    paste(getRversion(), R.version$platform, R.version$arch, R.version$os)))
  msg("Using Posit binary repository for ", codename)
}

# ------------------------------------------------------------------------------
# GAMS -- gdxrrw loads GAMS shared libraries at runtime.
#
# The libraries must match the R process: Windows R needs a Windows GAMS,
# Linux R needs a Linux GAMS. A Windows GAMS directory cannot serve WSL, so
# we confirm by looking for the actual library file, not the folder name.
# ------------------------------------------------------------------------------
find_gams <- function() {
  given <- optval("gams", Sys.getenv("R_GAMS_SYSDIR", unset = ""))
  if (nzchar(given) && dir.exists(given)) return(normalizePath(given, winslash = "/"))

  onpath <- Sys.which("gams")
  if (nzchar(onpath)) return(dirname(normalizePath(onpath, winslash = "/")))

  roots <- if (IS_WINDOWS) c("C:/GAMS", "C:/Program Files/GAMS", path.expand("~/GAMS"))
           else c("/opt/gams", path.expand("~/gams"), "/usr/local/gams")
  cands <- unlist(lapply(roots[dir.exists(roots)],
                         function(r) list.dirs(r, recursive = FALSE)), use.names = FALSE)
  # GAMS nests one level deeper on Windows: C:/GAMS/49/...
  cands <- c(cands, unlist(lapply(cands, function(d) list.dirs(d, recursive = FALSE)),
                           use.names = FALSE))
  lib   <- if (IS_WINDOWS) "gdxdclib64.dll" else "libgdxdclib64.so"
  cands <- cands[file.exists(file.path(cands, lib))]
  if (length(cands)) sort(cands)[length(cands)] else ""
}

GAMS_DIR <- find_gams()
if (nzchar(GAMS_DIR)) {
  msg("GAMS found: ", GAMS_DIR)
  Sys.setenv(R_GAMS_SYSDIR = GAMS_DIR)
} else {
  warn("No GAMS installation found for this platform.")
  warn("gdxrrw will install, but reading .gdx files will fail until GAMS is present.")
  if (is_wsl) warn("Note: a Windows GAMS directory will NOT work from WSL - install GAMS for Linux.")
}

# ------------------------------------------------------------------------------
# Settings: written inside the prefix when isolated, to ~/.Renviron otherwise
# ------------------------------------------------------------------------------
write_settings <- function() {
  if (CHECK_ONLY) return(invisible(NULL))

  entries <- c(R_LIBS_USER = LIB, MADRAT_MAINFOLDER = MADRAT_DIR)
  if (nzchar(GAMS_DIR)) entries["R_GAMS_SYSDIR"] <- GAMS_DIR

  if (TOUCH_RENVIRON) {
    target <- path.expand("~/.Renviron")
    lines  <- if (file.exists(target)) readLines(target, warn = FALSE) else character(0)
    added  <- FALSE
    for (k in names(entries)) {
      if (!any(grepl(paste0("^", k, "="), lines))) {
        lines <- c(lines, sprintf("%s=%s", k, entries[[k]])); added <- TRUE
      }
    }
    if (added) { writeLines(lines, target); msg("Updated ", target) }
    else msg("~/.Renviron already configured - left untouched")
    return(invisible(NULL))
  }

  if (!ISOLATED) { msg("--no-renviron: no settings written"); return(invisible(NULL)) }

  # Self-contained: a private .Renviron plus activation helpers.
  #
  # The ${VAR-default} form is understood by R when it reads .Renviron: the
  # value already present in the environment wins, and the baked-in path is
  # only a fallback. That is what makes the madrat folder overridable at
  # runtime without reinstalling. R_LIBS_USER is deliberately NOT deferred --
  # the library must always be this prefix.
  renv <- c(sprintf("R_LIBS_USER=%s", LIB),
            sprintf("MADRAT_MAINFOLDER=${MADRAT_MAINFOLDER-%s}", MADRAT_DIR))
  if (nzchar(GAMS_DIR))
    renv <- c(renv, sprintf("R_GAMS_SYSDIR=${R_GAMS_SYSDIR-%s}", GAMS_DIR))
  writeLines(renv, file.path(PREFIX, ".Renviron"))

  writeLines(c(
    "#!/usr/bin/env bash",
    "# Activate this self-contained R environment:  source activate.sh",
    sprintf('export R_LIBS_USER="%s"', LIB),
    'export R_LIBS_SITE=""',
    sprintf('export MADRAT_MAINFOLDER="${MADRAT_MAINFOLDER:-%s}"', MADRAT_DIR),
    if (nzchar(GAMS_DIR)) sprintf('export R_GAMS_SYSDIR="${R_GAMS_SYSDIR:-%s}"', GAMS_DIR) else
      '# export R_GAMS_SYSDIR="/path/to/gams"',
    sprintf('export R_ENVIRON_USER="%s/.Renviron"', PREFIX),
    'echo "prom-env active: $R_LIBS_USER"'
  ), file.path(PREFIX, "activate.sh"))

  writeLines(c(
    "@echo off",
    "REM Activate this self-contained R environment:  activate.bat",
    sprintf('set "R_LIBS_USER=%s"', gsub("/", "\\\\", LIB)),
    'set "R_LIBS_SITE="',
    sprintf('if not defined MADRAT_MAINFOLDER set "MADRAT_MAINFOLDER=%s"',
            gsub("/", "\\\\", MADRAT_DIR)),
    if (nzchar(GAMS_DIR))
      sprintf('if not defined R_GAMS_SYSDIR set "R_GAMS_SYSDIR=%s"',
              gsub("/", "\\\\", GAMS_DIR))
    else 'REM set "R_GAMS_SYSDIR=C:\\GAMS\\49"',
    sprintf('set "R_ENVIRON_USER=%s\\.Renviron"', gsub("/", "\\\\", PREFIX)),
    'echo prom-env active: %R_LIBS_USER%'
  ), file.path(PREFIX, "activate.bat"))

  # --- launchers: an R terminal (and Rscript) inside this environment --------
  for (prog in c("R", "Rscript")) {
    writeLines(c(
      "#!/usr/bin/env bash",
      sprintf("# %s inside this self-contained environment.", prog),
      sprintf("#   ./prom-%s                     %s", prog,
              if (prog == "R") "start an R terminal here" else "run a script here"),
      sprintf("#   ./prom-%s --madrat=/other/dir  use a different madrat folder", prog),
      "set -euo pipefail",
      'HERE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"',
      "ARGS=()",
      'for a in "$@"; do',
      '  case "$a" in',
      '    --madrat=*) export MADRAT_MAINFOLDER="${a#--madrat=}" ;;',
      '    *) ARGS+=("$a") ;;',
      "  esac",
      "done",
      '# activate.sh defers to MADRAT_MAINFOLDER if we just set it above',
      '. "$HERE/activate.sh" >/dev/null',
      'echo "library: $R_LIBS_USER"',
      'echo "madrat : $MADRAT_MAINFOLDER"',
      sprintf('exec %s %s${ARGS[@]+"${ARGS[@]}"}', prog,
              if (prog == "R") "--no-save " else "")
    ), file.path(PREFIX, paste0("prom-", prog)))
    Sys.chmod(file.path(PREFIX, paste0("prom-", prog)), "0755")

    writeLines(c(
      "@echo off",
      sprintf("REM %s inside this self-contained environment.", prog),
      sprintf("REM   prom-%s.bat --madrat=D:\\other\\madrat", prog),
      "setlocal",
      'set "HERE=%~dp0"',
      'set "RARGS="',
      ":parse",
      'if "%~1"=="" goto run',
      'set "A=%~1"',
      'if "%A:~0,9%"=="--madrat=" (set "MADRAT_MAINFOLDER=%A:~9%") else (set "RARGS=%RARGS% %1")',
      "shift",
      "goto parse",
      ":run",
      'call "%HERE%activate.bat" >nul',
      "echo library: %R_LIBS_USER%",
      "echo madrat : %MADRAT_MAINFOLDER%",
      sprintf("%s %s%%RARGS%%", prog, if (prog == "R") "--no-save " else ""),
      "endlocal"
    ), file.path(PREFIX, paste0("prom-", prog, ".bat")))
  }

  Sys.chmod(file.path(PREFIX, "activate.sh"), "0755")
  msg("Wrote .Renviron, activate.*, prom-R and prom-Rscript into ", PREFIX)
}

msg("madrat main folder: ", MADRAT_DIR, "   [from: ", madrat_src, "]")
if (!dir.exists(MADRAT_DIR)) {
  warn("That folder does not exist yet - it will be created empty.")
  warn("If you meant to reuse existing madrat sources, pass --madrat=/path/to/them.")
} else if (!dir.exists(file.path(MADRAT_DIR, "sources"))) {
  warn("That folder has no sources/ subfolder, so madrat will download everything")
  warn("from scratch on the first retrieveData(). Pass --madrat= to reuse an")
  warn("existing madrat folder instead.")
}
if (!CHECK_ONLY) dir.create(MADRAT_DIR, recursive = TRUE, showWarnings = FALSE)
write_settings()

# ------------------------------------------------------------------------------
# Report helper
# ------------------------------------------------------------------------------
TARGETS <- c("mrprom", "postprom")
WATCH   <- c("madrat", "magclass", "mrdrivers", "quitte", "gdx", "gdxrrw",
             "mip", "piamValidation", TARGETS,
             sub(".*/", "", sub("^github::", "", ALSO)))

report <- function() {
  cat("\n---------------------------------------------\n")
  ok <- TRUE
  for (p in WATCH) {
    v <- tryCatch(as.character(utils::packageVersion(p, lib.loc = .libPaths())),
                  error = function(e) NA_character_)
    cat(sprintf("  %-16s %s\n", p, if (is.na(v)) "MISSING" else v))
    if (is.na(v)) ok <- FALSE
  }
  cat(sprintf("  %-16s %s\n", "pandoc",
              if (nzchar(Sys.which("pandoc"))) "system" else "not found"))
  cat("---------------------------------------------\n")
  ok
}

# ------------------------------------------------------------------------------
# Check mode
# ------------------------------------------------------------------------------
if (CHECK_ONLY) {
  msg("Checking installation...")
  rec <- recorded_madrat()
  if (nzchar(rec) && !identical(normalizePath(rec, winslash = "/", mustWork = FALSE), MADRAT_DIR))
    warn("Prefix has a different madrat folder recorded: ", rec)
  loaded <- vapply(TARGETS, function(p)
    isTRUE(suppressWarnings(requireNamespace(p, quietly = TRUE))), logical(1))
  report()
  if (!all(loaded)) fail("mrprom and/or postprom are missing or fail to load.")
  cat("\nBoth packages load correctly.\n")
  quit(status = 0)
}

# ------------------------------------------------------------------------------
# Install
# ------------------------------------------------------------------------------
if (IS_WINDOWS && !nzchar(Sys.which("make"))) {
  warn("Rtools does not appear to be on PATH.")
  warn("Most dependencies come as binaries, but a source-only package will fail.")
  warn("If the install breaks, install Rtools from https://cran.r-project.org/bin/windows/Rtools/")
}

# Hard dependencies only. Suggests (comtradr, OECD, wpp2022, tinytex) are opt-in,
# because wpp2022 is not on CRAN and would otherwise abort the whole install.
DEPS <- c("Depends", "Imports", "LinkingTo")
PKGS <- c("github::e3modelling/mrprom", "github::e3modelling/postprom")

# In isolated mode pak itself must live in the prefix -- the user's copy, if any,
# is no longer on the search path.
if (!requireNamespace("pak", quietly = TRUE)) {
  msg("Installing pak into ", LIB, " ...")
  try(install.packages("pak", lib = LIB), silent = TRUE)
}

installed <- FALSE
if (requireNamespace("pak", quietly = TRUE)) {
  msg("Resolving and installing (pak)...")
  installed <- tryCatch({
    pak::pkg_install(PKGS, lib = LIB, dependencies = DEPS, ask = FALSE, upgrade = FALSE)
    TRUE
  }, error = function(e) { warn("pak failed: ", conditionMessage(e)); FALSE })
}

if (!installed) {
  msg("Falling back to remotes...")
  if (!requireNamespace("remotes", quietly = TRUE)) install.packages("remotes", lib = LIB)
  for (repo in c("e3modelling/mrprom", "e3modelling/postprom")) {
    remotes::install_github(repo, lib = LIB, dependencies = DEPS,
                            upgrade = "never", build_vignettes = FALSE)
  }
}

if (length(ALSO)) {
  msg("Installing additional packages: ", paste(ALSO, collapse = ", "))
  ok <- tryCatch({
    if (requireNamespace("pak", quietly = TRUE)) {
      pak::pkg_install(ALSO, lib = LIB, ask = FALSE, upgrade = FALSE)
    } else {
      install.packages(ALSO, lib = LIB)
    }
    TRUE
  }, error = function(e) { warn("extra packages failed: ", conditionMessage(e)); FALSE })
}

if (EXTRAS) {
  msg("Installing optional extras...")
  try({
    if (requireNamespace("pak", quietly = TRUE)) {
      pak::pkg_install(c("comtradr", "OECD", "github::PPgp/wpp2022", "tinytex"),
                       lib = LIB, ask = FALSE)
    } else {
      install.packages(c("comtradr", "OECD", "tinytex"), lib = LIB)
      remotes::install_github("PPgp/wpp2022", lib = LIB, upgrade = "never")
    }
  }, silent = TRUE)
  if (requireNamespace("tinytex", quietly = TRUE) && !nzchar(tinytex::tinytex_root()))
    try(tinytex::install_tinytex(), silent = TRUE)
}

# postprom renders rmarkdown reports, which need a pandoc binary.
if (!nzchar(Sys.which("pandoc")) && requireNamespace("pandoc", quietly = TRUE)) {
  if (length(pandoc::pandoc_installed_versions()) == 0) {
    msg("Installing a pandoc binary...")
    try(pandoc::pandoc_install(), silent = TRUE)
  }
}

# ------------------------------------------------------------------------------
# Verify
# ------------------------------------------------------------------------------
msg("Verifying...")
for (p in TARGETS) {
  ok <- tryCatch({
    suppressPackageStartupMessages(library(p, character.only = TRUE, lib.loc = .libPaths()))
    TRUE
  }, error = function(e) {
    cat(sprintf("  %s failed to load: %s\n", p, conditionMessage(e))); FALSE
  })
  if (!ok) { report(); fail("Installation incomplete.") }
}
if (!report()) warn("Some dependencies are missing - see the table above.")

cat("\nmrprom and postprom installed and loading cleanly.\n\n")
if (ISOLATED) {
  cat("This environment is self-contained. Nothing outside the prefix was modified.\n\n")
  cat("  R terminal:  ", PREFIX, "/prom-R\n", sep = "")
  cat("               ", gsub("/", "\\\\", PREFIX), "\\prom-R.bat            (cmd)\n", sep = "")
  cat("  Run a script:", PREFIX, "/prom-Rscript your-script.R\n", sep = " ")
  cat("  Other folder:", PREFIX, "/prom-R --madrat=/data/shared-madrat\n", sep = " ")
  cat("  Or activate: source ", PREFIX, "/activate.sh    (bash / WSL / Git Bash)\n", sep = "")
  cat("  One-shot:    R_ENVIRON_USER=", PREFIX, "/.Renviron Rscript your-script.R\n", sep = "")
  cat("  Re-verify:   Rscript install-prom-r.R --check --prefix=", PREFIX, "\n", sep = "")
  cat("  Remove it:   rm -rf ", PREFIX, "\n", sep = "")
} else {
  cat("  Test with:   Rscript -e 'library(mrprom); library(postprom)'\n")
}
