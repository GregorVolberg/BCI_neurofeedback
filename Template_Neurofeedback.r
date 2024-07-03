library(tidyverse)
library(brainflow) 
library(gsignal)

## read previously recorded data
# markers
markers <- read_delim('feedbackGroup.csv', 
                      col_names = FALSE) %>%
  select(val = 24) %>%
  mutate(spoint = 1:n()) %>%
  dplyr::filter(val > 0)  %>%
  group_by(val) %>%
  group_split()

# data
eeg <- read_delim('test_run_motor.csv', 
                     col_names = FALSE) %>%
  select(c(2:9)) %>%
  t()

# channel names
cnames <- data.frame(name = c("AF1", "AF2", "AFz", "Cz",
                             "F1",  "Fz",  "C1",  "C2",
                             "Oz",  "Pz"),
                      easyCapNumber = numeric(10),
                      OpenBCI =  c("N1P", "N2P", "N3P", "N4P", "N5P", 
                                   "N6P", "N7P", "N8P",
                                   "SRB2(REF)", "BIAS(GND)"))

# set arguments, zb beta, theta
lf1 <- 4
hf1 <- 7
lf2 <- 13
hf2 <- 30
pollnum <- 256 # number of samples per poll
srate   <- 250
secs    <- 30 # trial was 30 s long
pickChannels <- c("AF1", "AF2", "Cz")
chanIndex <- which(cnames$name %in% pickChannels)

# function demean
demean <- function(eegin){
  t(apply(eegin, 1, function(x) x - mean(x)))
}

# function for segmentation
segmentation <- function(onst, cindex, eegin){
      lapply(onst, 
           function(x) eegin[cindex, x:(x+pollnum-1)])
}

# function for Welch PSD
welchpsd <- function(eegin, srate){
  tmp <- apply(eegin, 1, function(x) pwelch(x, window = hanning(dim(eegin)[2]), fs = srate))
  arr <- simplify2array(map(tmp, 'spec'))
  pwr <- apply(arr, 1, mean)
}

onsets = data.frame(concentrate = simplify(lapply(markers[[1]]$spoint,
                            function (x) seq(x, x+secs*srate, by = pollnum))),
                    relax = simplify(lapply(markers[[2]]$spoint,
                            function (x) seq(x, x+secs*srate, by = pollnum))))

seg  <- segmentation(onsets$relax, chanIndex, eeg)
eegm <- lapply(seg, demean)
eegf <- lapply(eegm, function(x) welchpsd(x, srate = 250))
powerEstimateRelax <- simplify2array(eegf)

seg  <- segmentation(onsets$concentrate, chanIndex, eeg)
eegm <- lapply(seg, demean)
eegf <- lapply(eegm, function(x) welchpsd(x, srate = 250))
powerEstimateConcentrate <- simplify2array(eegf)

freqScale <- pwelch(eegm[[1]][1,],
                    window = hanning(dim(eegm[[1]])[2]),
                    fs = srate)$freq

freq1indices <- which(freqScale > lf1 & freqScale < hf1)
freq2indices <- which(freqScale > lf2 & freqScale < hf2)

plot(freqScale, apply(powerEstimateRelax, 1, mean),
     type='l', col = 'blue')
lines(freqScale, apply(powerEstimateConcentrate, 1, mean), 
      type='l', col = 'red')


# zu klären:
# - was sind gute Frequenzbereiche für h1 und h2?
# - welche Elektroden funktionieren gut?
# - hierzu möglichst plots, zur Begründung der Selektion
f1pow <- apply(powerEstimateRelax[freq1indices,], 2, mean)
f2pow <- apply(powerEstimateRelax[freq2indices,], 2, mean)
plot(f1pow / f2pow, type='l', col = 'blue')

