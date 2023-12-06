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

#add model OPEN-PROM
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
#add moedel MENA_EDS
a <- readSource("MENA_EDS", subtype =  "CF")
a <- as.quitte(a)
a["model"] <- "MENA_EDS"
a["unit"] <- "Mtoe"

# 25 balance fuels so nrow(k) = 25
#example k[2,1] <- "HCL" "LGN" and is for Solids
for (i in 1:nrow(k)) {
  z <- rbind(blabla_variables, a)
  q <- unlist(strsplit(k[i, 1], ","))
  #filter data and keep only model fuels that are for each balance fuel
  #example q for solids is "HCL" "LGN", so keep from z["EF"] only "HCL" and "LGN"
  z <- z %>% filter(EF %in% q)
  z['fuel'] <- name[i, 1]
  #take the sum from the fuels we kept in line 49 by region, period and model(MENA or OPEN-PROM)
  reportOutput[[i]] <- mutate(z, value = sum(value, na.rm = TRUE), .by = c("period", "region", "model"))
  reportOutput[[i]] <- select(reportOutput[[i]] , -c("EF"))
  reportOutput[[i]] <- reportOutput[[i]]  %>% distinct()
  
}

names(reportOutput) <- name[,1]
# use rbind to have the 24 model fuels (except total) in one dataframe
sum <- NULL
sum2 <- NULL
# starts from two (except the first which is the total)
for (i in 2:length(reportOutput)) {
  sum <- rbind(reportOutput[[i]], sum2)
  sum2 <- sum
}
#sum all the 24 model fuels to compare it with total
sum3 <- mutate(sum2, value = sum(value, na.rm = TRUE), .by = c("period", "region", "model"))
sum4 <- sum3 %>% select(-c('fuel'))
sum4 <- sum4  %>% distinct()
#the total is the first one
total <- reportOutput[[1]]
diff_total_othermdels <- total
#the total minus the sum we calculated  
diff_total_othermdels["value"] <- total["value"] - sum4["value"]
diff_total_othermdels["fuel"] <- "diff_total_othermodels"
reportOutput[[26]] <- diff_total_othermdels
names(reportOutput)[26] <- "diff_total_othermodels"
#rbind total, the 24 models and the difference between models and total 
x <- rbind(reportOutput[[1]], sum2, reportOutput[[26]])
x <- as.quitte(x)

x$fuel <- gsub("\"", " ", x$fuel)
#rename variables
x["variable"] <- paste0("Final Energy ", x$fuel)
fuel <- x["fuel"]
x <- select(x , -c("fuel"))
x["scenario"] <- "missing"
x <- as.quitte(x)

#filter enerdata by onsumption
b <- readSource("ENERDATA", subtype =  "onsumption", convert = TRUE)
#map of enerdta and balance fuel
map <- toolGetMapping(name = "enerdata-by-fuel.csv",
                      type = "sectoral",
                      where = "mappingfolder")
#keep the variables from the map
b <- b[, , map[, 1]]
b <- as.quitte(b)
names(map) <- sub("ENERDATA", "variable", names(map))
#remove units
map[,1] <- sub("\\..*", "", map[,1])
#add a column with the fuels that match each variable of enerdata
b <- left_join(b, map, by = "variable")
#rename the enerdata variables to match the other two models 
b["variable"] <- paste0("Final Energy ", b$fuel)
b <- select(b , -c("fuel"))
b["model"] <- "ENERDATA"
b["scenario"] <- "missing"
#rbind the open prom and mena with enerdata
v <- rbind(x, b)
v <- as.magpie(v)

write.report(v, "Final Energy.mif")

#I think write.mif is faster(no need to convert it to magpie)
#write.mif(v, "Final Energy.mif", append = FALSE)
