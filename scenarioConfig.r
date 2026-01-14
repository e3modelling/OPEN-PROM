library(jsonlite)

fromcsv <- read.csv("scenarioConfig.csv")

for (i in rownames(fromcsv)) {
  if (fromcsv[i, "start"] != 1) next
  print(fromcsv[i, ])
  write(toJSON(fromcsv[i, ], pretty = TRUE), file = "config2.json")
  system(paste("Rscript start.R", "task=2"))
}