# Task 4: OPEN-PROM DEBUGGING
# No run folder, no metadata. Just invoke GAMS with default flags to see raw output.

runTask4 <- function() {
  extra <- Sys.getenv("OPENPROM_EXTRA_FLAGS")
  base_cmd <- paste(gams, "main.gms", extra,
                    "-logOption 4 -AsyncSolLst 1 -Idir=./data 2>&1")
  if (.Platform$OS.type == "unix") {
    system(base_cmd)
  } else {
    shell(base_cmd)
  }
}
