library(tidyverse)
library(lubridate) # for time / date data type; package is part of tidyverse
library(R.matlab)  # for reading Matlab's *.mat-files into R; you might need to install that package

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
             outcome = as_factor(V4),
             outcome = fct_recode(outcome,
                                  pass  = "1",
                                  fail  = "0"),
             experiment = tmp[[3]][1],
             date    = as_datetime(tmp[[2]][1])) %>%
      select(vp, trial, speed, ttc, obstacle, outcome, experiment, date)    
}

# apply function to all raw data files and concatenate to tibble
allVp <- map_df(fileListBehavioral, get_rawDataBehavioral)

# compute cumulative probability for success at increasing levels of ttc 
behavResults <-  allVp %>%
             group_by(vp, ttc) %>%
             summarize(n       = n(),
                       n_pass  = sum(outcome == 'pass')) %>%
              group_by(vp)  %>%
              mutate(cumsum_pass  = cumsum(n_pass),
                     cumprop_pass = cumsum_pass / sum(n)) %>%
              select(vp, ttc, n, n_pass, cumprop_pass)

# aggregate across participants
grandMean = behavResults %>%
            group_by(ttc) %>%
            summarize(m  = mean(cumprop_pass),
                      se = sd(cumprop_pass)/sqrt(n())) %>%
            ungroup()

# plot descriptives
plot(NULL,
     ylim = c(0,1), xlim = c(300, 1600), xaxt = 'n',
     ylab = 'Cumulative p passed', xlab = 'Time to collision (s)')
axis(1, at = seq(400, 1600, 200), labels = seq(0.4, 1.6, 0.2))
xpoly <- c(grandMean$ttc, rev(grandMean$ttc))
se <- grandMean$se
se[is.na(se)] = 0
ypoly <- c(grandMean$m + se, rev(grandMean$m) - rev(se))
polygon(xpoly, ypoly, col = 'lightblue', border = 'lightblue')
lines(grandMean$m ~ grandMean$ttc, lwd=2, type = 'line', col= 'blue')
legend(x=1000, y=0.4, legend = c('behavioral', 'BCI-EEG'), lty = 'solid', lwd = 2, col = c('blue', 'orange'), bty='n')

# statistics; e.g., dependent t-tests on pre-defined ttc quantiles between behavioral and BCI data

allVp %>% 
  filter(outcome == 'pass') %>%
  group_by(vp) %>%
  summarize(q1  = quantile(ttc, 0.25),
            q2  = quantile(ttc, 0.50),
            q3  = quantile(ttc, 0.75))
 # to be continued