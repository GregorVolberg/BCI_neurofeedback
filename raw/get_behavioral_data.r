library(tidyverse)
library(lubridate) # for time / date data type; package is part of tidyverse
library(R.matlab)  # for reading Matlab's *.mat-files into R; you might need to install that package

fileListBehavioral <- c("AL1_BCIcar.mat", "AW7_BCIcar.mat", "SD1_BCIcar.mat", 
                        "JG1_BCIcar.mat", "NH1_BCIcar.mat", "SB1_BCIcar.mat")

fileListEEG        <- str_replace(fileListBehavioral, 'car', 'car_EEG')
fileListEEG        <- setdiff(fileListEEG, c("SD1_BCIcar_EEG.mat","JG1_BCIcar_EEG.mat")) # exclude subject SD1


# define function for reading in single subject behavioral data
get_rawDataBehavioral <- function(fileName){
    tmp             <- readMat(fileName)$BCIcar
    height_mm       <- 165 # Monitor height in mm, Dell Latitude 6320
    collisionDist   <- 468 # pixels between obstacle and car at trial start
    yResolution     <- tmp[["resolution", 1, 1]][2]
    hz              <- tmp[["hz", 1, 1]][1]
    outmat          <- tmp[["outmat", 1, 1]]
    bugCorrIndex    <- which(diff(outmat[, 2]) == 0 & diff(outmat[, 4]) == -1) +1
    outmat[bugCorrIndex, 2] <- outmat[bugCorrIndex, 2] + 1
    outmat %>% 
      as_tibble() %>%
      mutate(vp = as_factor(tmp[["vp", 1, 1]]),
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
             experiment = tmp[["experiment", 1, 1]][1],
             date    = as_datetime(tmp[["date", 1, 1]][1])) %>%
      select(vp, trial, speed, ttc, obstacle, outcome, experiment, date)    
}

# define function for reading in single subject EEG data
get_rawDataEEG <- function(fileName){
  tmp             <- readMat(fileName)$BCIcar
  height_mm       <- 310 # Monitor height in mm, ViewPixx
  collisionDist   <- 720 # pixels between obstacle and car at trial start
  yResolution     <- tmp[["resolution", 1, 1]][2]
  hz              <- tmp[["hz", 1, 1]][1]
  outmat          <- tmp[["outmat", 1, 1]]
  bugCorrIndex    <- which(diff(outmat[, 2]) == 0 & diff(outmat[, 4]) == -1) +1
  outmat[bugCorrIndex, 2] <- outmat[bugCorrIndex, 2] + 0.45
  outmat %>% 
    as_tibble() %>%
    mutate(vp = as_factor(tmp[["vp", 1, 1]]),
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
           r_HFleft  = V5,
           r_LFright = V6,
           experiment = tmp[["experiment", 1, 1]][1],
           date    = as_datetime(tmp[["date", 1, 1]][1])) %>%
    select(vp, trial, speed, ttc, obstacle, outcome, r_HFleft, r_LFright, experiment, date)    
}

# apply function to all raw data files and concatenate to tibble
allVpBeh <- map_df(fileListBehavioral, get_rawDataBehavioral)
allVpEEG <- map_df(fileListEEG, get_rawDataEEG)

# compute cumulative probability for success at increasing levels of ttc 
behavResults <-  allVpBeh %>%
             group_by(vp, ttc) %>%
             summarize(n       = n(),
                       n_pass  = sum(outcome == 'pass')) %>%
              group_by(vp)  %>%
              mutate(cumsum_pass  = cumsum(n_pass),
                     cumprop_pass = cumsum_pass / sum(n)) %>%
              select(vp, ttc, n, n_pass, cumprop_pass)

EEGResults <-  allVpEEG %>%
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

# aggregate across participants
grandMeanEEG = EEGResults %>%
  group_by(ttc) %>%
  summarize(m  = mean(cumprop_pass),
            se = sd(cumprop_pass)/sqrt(n())) %>%
  ungroup()

# plot descriptives
plot(NULL,
     ylim = c(0,1), xlim = c(300, 3100), xaxt = 'n',
     ylab = 'Cumulative p passed', xlab = 'Time to collision (s)')
axis(1, at = seq(400, 3000, 200), labels = seq(0.4, 3.0, 0.2))
xpoly <- c(grandMean$ttc, rev(grandMean$ttc))
se <- grandMean$se
se[is.na(se)] = 0
ypoly <- c(grandMean$m + se, rev(grandMean$m) - rev(se))
polygon(xpoly, ypoly, col = 'lightblue', border = 'lightblue')
lines(grandMean$m ~ grandMean$ttc, lwd=2, type = 'l', col= 'blue')
xpolyE <- c(grandMeanEEG$ttc, rev(grandMeanEEG$ttc))
se <- grandMeanEEG$se
se[is.na(se)] = 0
ypolyE <- c(grandMeanEEG$m + se, rev(grandMeanEEG$m) - rev(se))
polygon(xpolyE, ypolyE, col = 'orange', border = 'orange')
lines(grandMeanEEG$m ~ grandMeanEEG$ttc, lwd=2, type = 'l', col= 'red')
legend(x=800, y=0.4, legend = c('behavioral', 'BCI-EEG'), lty = 'solid', lwd = 2, col = c('blue', 'red'), bty='n')

# Wilcoxon signed rank test
wilcox.test(quantile(grandMean$m, seq(0,1,0.1)),
            quantile(grandMeanEEG$m, seq(0,1,0.1)),
            alternative = c("two.sided"),
            paired = FALSE, exact = NULL, correct = TRUE),
# statistics; e.g., dependent t-tests on pre-defined ttc quantiles between behavioral and BCI data
allVp %>% 
  filter(outcome == 'pass') %>%
  group_by(vp) %>%
  summarize(q1  = quantile(ttc, 0.25),
            q2  = quantile(ttc, 0.50),
            q3  = quantile(ttc, 0.75))
 # to be continued