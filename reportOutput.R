library(dplyr)
library(gdx)
library(quitte)
library(tidyr)
library(utils)
library(mrprom)
library(stringr)

sets <- readSets(system.file(file.path("extdata", "sets.gms"), package = "mrprom"), "BALEF2EFS")
name <- sub("\\..*", "", sets)
k <- NULL
name <- NULL
for (i in 1:nrow(sets)) {
  k[i] <- gsub(".*\\.", "", sets[i, 1])
  name[i] <- sub("\\..*", "", sets[i, 1])
  if (str_detect(k[i], ",")) {
    k[i] <- str_extract(string = k[i], pattern = "(?<=\\().*(?=\\))")
  }
}
k <- as.data.frame(k)
name <- as.data.frame(name)

#blabla_variables <- read.gdx('./openprom_p.gdx', "VFeCons", field = 'l')
blabla_variables <- read.gdx('./blabla.gdx', "VFeCons", field = 'l')
names(blabla_variables) <- c("allCy","EF","ytime","value")
reportOutput <- list() 

for (i in 1:nrow(k)) {
  z <- blabla_variables
  q <- unlist(strsplit(k[i, 1], ","))
  z <- z %>% filter(EF %in% q)
  z['fuel'] <- name[i, 1]
  reportOutput[[i]] <- mutate(z, value = sum(value, na.rm = TRUE), .by = c("allCy", "ytime"))
  reportOutput[[i]] <- select(reportOutput[[i]] , -c("EF"))
  reportOutput[[i]] <- reportOutput[[i]]  %>% distinct()
  
}

names(reportOutput) <- name[,1]

sum <- NULL
sum2 <- NULL
for (i in 2:length(reportOutput)) {
  sum <- rbind(reportOutput[[i]], sum2)
  sum2 <- sum
}

sum3 <- mutate(sum2, value = sum(value, na.rm = TRUE), .by = c("allCy", "ytime"))
sum4 <- sum3 %>% select(-c('fuel'))
sum4 <- sum4  %>% distinct()
total <- reportOutput[[1]]
diff_total_othermdels <- total
diff_total_othermdels["value"] <- total["value"] - sum4["value"]
diff_total_othermdels["fuel"] <- "diff_total_othermodels"
reportOutput[[26]] <- diff_total_othermdels
names(reportOutput)[26] <- "diff_total_othermodels"

x <- rbind(reportOutput[[1]], sum3, reportOutput[[26]])
x <- as.quitte(x)
x["period"] <- x["ytime"]
x <- select(x , -c("ytime"))
x["region"] <- x["allcy"]
x <- select(x , -c("allcy"))
x["model"] <- "OPEN-PROM"
x["variable"] <- x["fuel"]
x <- select(x , -c("fuel"))
x["scenario"] <- "missing"
x["unit"] <- "missing"
x <- as.quitte(x)
x <- as.magpie(x)
write.report(x, "DataOutput2.mif")

