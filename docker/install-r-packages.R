repos <- c(CRAN = "https://cloud.r-project.org")

r_universe <- Sys.getenv("R_UNIVERSE_REPOS", unset = "")
r_universe <- trimws(unlist(strsplit(r_universe, ",", fixed = TRUE)))
r_universe <- r_universe[nzchar(r_universe)]
if (length(r_universe)) {
  names(r_universe) <- paste0("runiverse", seq_along(r_universe))
  repos <- c(r_universe, repos)
}

options(repos = repos)

cran_or_runiverse_packages <- c(
  "crayon",
  "data.table",
  "devtools",
  "dplyr",
  "gdx",
  "gms",
  "jsonlite",
  "madrat",
  "magclass",
  "quitte",
  "remotes",
  "reticulate",
  "stringr",
  "tidyr"
)

install_from_repos <- function(packages) {
  for (pkg in packages) {
    if (!requireNamespace(pkg, quietly = TRUE)) {
      install.packages(pkg, dependencies = TRUE)
    }
  }
}

install_from_repos(cran_or_runiverse_packages)

github_packages <- Sys.getenv("GITHUB_R_PACKAGES", unset = "")
github_packages <- trimws(unlist(strsplit(github_packages, ",", fixed = TRUE)))
github_packages <- github_packages[nzchar(github_packages)]

normalize_github_spec <- function(spec) {
  spec <- trimws(spec)
  spec <- sub("^https?://github\\.com/", "", spec)
  spec <- sub("^git@github\\.com:", "", spec)
  spec <- sub("/+$", "", spec)
  spec <- sub("\\.git(@.*)?$", "\\1", spec)
  spec
}

if (length(github_packages)) {
  if (!requireNamespace("remotes", quietly = TRUE)) {
    install.packages("remotes")
  }
  for (pkg in github_packages) {
    remotes::install_github(
      normalize_github_spec(pkg),
      dependencies = TRUE,
      upgrade = "never"
    )
  }
}

required_packages <- c(cran_or_runiverse_packages, "mrprom", "postprom")
missing_after_install <- required_packages[
  !vapply(required_packages, requireNamespace, logical(1), quietly = TRUE)
]

if (length(missing_after_install)) {
  stop(
    "The following R packages are still missing: ",
    paste(missing_after_install, collapse = ", "),
    call. = FALSE
  )
}
