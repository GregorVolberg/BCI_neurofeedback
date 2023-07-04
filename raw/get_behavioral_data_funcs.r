library(tidyverse)
library(lubridate) # for time / date data type; package is part of tidyverse
library(R.matlab)  # for reading Matlab's *.mat-files into R; you might need to install that package

# file list with subjects SD1 and JG1 in EEG excluded
fileList <- c("AL1_BCIcar.mat", "AW7_BCIcar.mat", "SD1_BCIcar.mat", 
              "JG1_BCIcar.mat", "NH1_BCIcar.mat", "SB1_BCIcar.mat",
              "AL1_BCIcar_EEG.mat", "AW7_BCIcar_EEG.mat",
              "NH1_BCIcar_EEG.mat", "SB1_BCIcar_EEG.mat")

# define function for reading in single subject behavioral data
get_raw <- function(fileName){
    
    # read protocol file and extract information on monitor refresh rate and resolution
    tmp                <- readMat(fileName)$BCIcar
    yResolution        <- tmp[["resolution", 1, 1]][2]
    hz                 <- tmp[["hz", 1, 1]][1]
    outmat             <- tmp[["outmat", 1, 1]]

    # set monitor dimensions etc. contingent on experimental setup
    if(str_detect(fileName, 'car_EEG')){
      height_mm       <- 310 # Monitor height in mm, ViewPixx
      collisionDist   <- 720 # pixels between obstacle and car at trial start
      bugPlus <- 0.45        # increment in pixel speed
      r1 <- outmat[, 5]      # correlation between SSVEP and luminance modulation of HF (left) stimulus
      r2 <- outmat[, 6]      # correlation between SSVEP and luminance modulation of LF (right) stimulus
      } else {
      height_mm     <- 165 # Monitor height in mm, Dell Latitude 6320
      collisionDist <- 468 # pixels between obstacle and car at trial start
      bugPlus <- 1         # increment in pixel speed
      r1 <- NA             # SSVEP correlation, NA in behavioral task
      r2 <- NA             # SSVEP correlation, NA in behavioral task
      }
    
    # correct bug in stimulation routine (outmat entries after failed trails)
    bugIndx            <- which(diff(outmat[, 2]) == 0 & diff(outmat[, 4]) == -1) +1
    outmat[bugIndx, 2] <- outmat[bugIndx, 2] + bugPlus
    
    # construct tibble, compute time to collide (ttc)
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
             date    = as_datetime(tmp[["date", 1, 1]][1]),
             HFleft      = as.numeric(r1),
             LFright     = as.numeric(r2)) %>%
      select(vp, trial, speed, ttc, obstacle, outcome, HFleft, LFright, experiment, date)    
}

# apply function to each raw data file and concatenate
allVp <- map_df(fileList, get_raw)

# compute cumulative probability for success at increasing levels of ttc 
allProb <- allVp %>%
             group_by(vp, ttc, experiment) %>%
             summarize(n       = n(),
                       n_pass  = sum(outcome == 'pass')) %>%
              group_by(vp, experiment)  %>%
              mutate(cumsum_pass  = cumsum(n_pass),
                     cumprop_pass = cumsum_pass / sum(n)) %>%
              ungroup() %>%
              select(vp, ttc, n, n_pass, cumprop_pass, experiment)

# aggregate across participants
grandMean = allProb %>%
            group_by(ttc, experiment) %>%
            summarize(m  = mean(cumprop_pass),
                      se = sd(cumprop_pass)/sqrt(n())) %>%
            ungroup()

## plot 
# plotting function for mean (line) and standard error (shade)
plotProb <- function(df, bgcol, fgcol){
  xpoly <- c(df$ttc, rev(df$ttc))
  se <- df$se
  se[is.na(se)] = 0
  ypoly <- c(df$m + se, rev(df$m) - rev(se))
  polygon(xpoly, ypoly, col = bgcol, border = bgcol)
  lines(df$m ~ df$ttc, lwd=2, type = 'l', col= fgcol)
}

# plotting layout
plot(NULL,
     ylim = c(0,1), xlim = c(300, 3100), xaxt = 'n',
     ylab = 'Cumulative p', xlab = 'Time to collision (s)')
axis(1, at = seq(400, 3000, 200), labels = seq(0.4, 3.0, 0.2))
legend(x = 2000, y = 0.8, legend = c('behavioral', 'BCI-EEG'),
       lty = 'solid', lwd = 2, col = c('blue', 'red'), bty='n')

grandMean %>% 
  filter(experiment == 'BCIcar') %>%
  plotProb(., 'lightblue', 'blue')

grandMean %>% 
  filter(experiment == 'BCIcar_EEG') %>%
  plotProb(., 'orange', 'red')


## Stats
# mean ttc quantiles in both experiments
q <- allVp %>% 
      filter(outcome == 'pass') %>%
      group_by(vp, experiment) %>%
      summarize(ttcq = quantile(ttc, seq(0,1,0.1))) %>%
      mutate(q = seq(0,1,0.1)) %>%
      group_by(experiment, q) %>%
      summarize(mttcq = mean(ttcq))

# Wilcoxon signed rank test
wilcox.test(q$mttcq[q$experiment == 'BCIcar'],
            q$mttcq[q$experiment == 'BCIcar_EEG'],
            alternative = c("two.sided"),
            paired = TRUE, exact = FALSE, correct = TRUE)

