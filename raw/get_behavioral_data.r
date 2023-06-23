library(tidyverse)
library(lubridate) # for time / date data type; you might need to install that package
library(R.matlab)  # for reading matlab *.mat-files into R; you might need to install that package

fileListBehavioral <- c("AL1_BCIcar.mat", "AW7_BCIcar.mat", "DS3_BCIcar.mat", "JG1_BCIcar.mat")

# define function for reading in single subject data
get_rawDataBehavioral <- function(fileName){
    tmp             <- readMat(fileName)$BCIcar
    height_mm       <- 165 # Monitor height in mm, Dell Latitude 6320
    collisionDist   <- 568 # pixels between obstacle and car at trial start
    yResolution     <- tmp[[5]][2]
    hz              <- tmp[[4]][1]
    outmat <- tmp[[8]] %>%
      as_tibble() %>%
      mutate(vp = as_factor(tmp[[1]]),
             trial = V1,
             speed   = round((V2 * hz) * (height_mm / yResolution)), # mm per second
             ttc     = round(collisionDist / (V2 * hz) * 1000), # time to collide, in milliseconds
             obstacle = as_factor(V3),
             obstacle = fct_recode(obstacle,
                                   left  = "-1",
                                   right = "1"),
             #outcome = V4,
             outcome = as_factor(V4),
             outcome = fct_recode(outcome,
                                  pass  = "1",
                                  fail  = "0"),
             experiment = tmp[[3]][1],
             date    = as_datetime(tmp[[2]][1])) %>%
      select(vp, trial, speed, ttc, obstacle, outcome, experiment, date)    
}

tst <- get_rawDataBehavioral(fileList[1])
tib <- map_df(fileList, get_rawDataBehavioral) # tibble with all participants

# max und min ttc rausschreiben, damit datenvektor für alle gleich ist
# Achtung, V2 korrigieren, schreibt 1 zu wenig raus bei fail (V2 ist bei fail V2+1)
behavRes <-  tib %>%
             group_by(vp, ttc) %>%
             summ  
  
plot(cumsum(table(tst$ttc, tst$outcome)[,2]) / sum(table(tst$ttc, tst$outcome)))

