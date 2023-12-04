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

blabla_variables <- as.quitte(blabla_variables)
reportOutput <- list() 
blabla_variables["model"] <- "OPEN-PROM"
blabla_variables["region"] <- blabla_variables["allcy"]
blabla_variables <- select(blabla_variables , -c("allcy"))
blabla_variables["period"] <- blabla_variables["ytime"]
blabla_variables <- select(blabla_variables , -c("ytime"))
blabla_variables["EF"] <- blabla_variables["ef"]
blabla_variables <- select(blabla_variables , -c("ef"))
blabla_variables["unit"] <- "Mtoe"

a <- readSource("MENA_EDS", subtype =  "CF")
a <- as.quitte(a)
a["model"] <- "MENA_EDS"
a["unit"] <- "Mtoe"

for (i in 1:nrow(k)) {
  z <- rbind(blabla_variables, a)
  q <- unlist(strsplit(k[i, 1], ","))
  z <- z %>% filter(EF %in% q)
  z['fuel'] <- name[i, 1]
  reportOutput[[i]] <- mutate(z, value = sum(value, na.rm = TRUE), .by = c("period", "region", "model"))
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

sum3 <- mutate(sum2, value = sum(value, na.rm = TRUE), .by = c("period", "region", "model"))
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

x$fuel <- gsub("\"", " ", x$fuel)
x["variable"] <- paste0("Final Energy", x$fuel)
fuel <- x["fuel"]
x <- select(x , -c("fuel"))
x["scenario"] <- "missing"
x <- as.quitte(x)

b <- readSource("ENERDATA", subtype =  "onsumption", convert = TRUE)

map <- toolGetMapping(name = "enerdata-by-fuel.csv",
                      type = "sectoral",
                      where = "mappingfolder")

b <- b[, , map[, 1]]
b <- as.quitte(b)
names(map) <- sub("ENERDATA", "variable", names(map))
map[,1] <- sub("\\..*", "", map[,1])

b <- left_join(b, map, by = "variable")
b["variable"] <- paste0("Final Energy ", b$fuel)
b <- select(b , -c("fuel"))
b["model"] <- "ENERDATA"
b["scenario"] <- "missing"

v <- rbind(x, b)
v <- as.magpie(v)

write.report(v, "DataOutput3.mif")

