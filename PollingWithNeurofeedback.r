library(tidyverse)
library(brainflow) 
library(gsignal)

# see template
cnames <- data.frame(name = c("AF1", "AF2", "AFz", "Cz",
                              "F1",  "Fz",  "C1",  "C2",
                              "Oz",  "Pz"),
                     easyCapNumber = numeric(10),
                     OpenBCI =  c("N1P", "N2P", "N3P", "N4P", "N5P", 
                                  "N6P", "N7P", "N8P",
                                  "SRB2(REF)", "BIAS(GND)"))

# set arguments
lf1 <- 4
hf1 <- 7
lf2 <- 13
hf2 <- 30
pollnum <- 256 # number of samples per poll
srate   <- 250
pickChannels <- c("AF1", "AF2", "Cz")
chanIndex <- which(cnames$name %in% pickChannels)
freqScale <- pwelch(rnorm(pollnum),
               window = hanning(pollnum),
               fs = 250)$freq
freq1indices <- which(freqScale > lf1 & freqScale < hf1)
freq2indices <- which(freqScale > lf2 & freqScale < hf2)

# function for Welch PSD
welchpsd <- function(eegin, srate){
  tmp <- apply(eegin, 1, function(x) pwelch(x, window = hanning(dim(eegin)[2]), fs = srate))
  arr <- simplify2array(map(tmp, 'spec'))
  pwr <- apply(arr, 1, mean)
}

# demean
demean <- function(eegin){
  t(apply(eegin, 1, function(x) x - mean(x)))
}


Id      <- brainflow_python$BoardIds$PLAYBACK_FILE_BOARD 
params  <- brainflow_python$BrainFlowInputParams()   
params$file         <- "scene_aff_visual_2024-05-07-103106.csv"
params$master_board <- brainflow_python$BoardIds$CYTON_BOARD
myboard             <- brainflow_python$BoardShim(Id, params) 

myboard$release_all_sessions()
myboard$prepare_session() # start session
myboard$start_stream()    # start stream

## polling 
polls <- NULL
NFmetric <- NULL
invisible(myboard$get_board_data()) # empty buffer

while(TRUE){ # endless polling, close with ESC
  while (myboard$get_board_data_count() < pollnum) {
    Sys.sleep(0.02) # wait until buffer is filled
  }
poll  <- myboard$get_board_data(as.integer(boardinfo$pollnum))
polls <- polls + 1
eeg   <- poll[2:9, ]
eegm  <- demean(eeg)
eegf  <- welchpsd(eegm, srate = 250)
powerEstimate <- simplify2array(eegf)

f1pow <- apply(powerEstimateRelax[freq1indices,], 2, mean)
f2pow <- apply(powerEstimateRelax[freq2indices,], 2, mean)

NFmetric[polls] <- f1pow / f2pow
if (polls < runMedian){
  feedback <- 0} else {
  feedback <- median(NFmetric[(polls-runMedian):polls])
}

myboard$stop_stream()     # stop stream
myboard$release_session() # end session


x11()
testdat = round(runif(20)*100) # 20 random integers from 0 - 100
hcol <- heat.colors(100) # from light yellow to red

for (j in 1:length(testdat)){
  Sys.sleep(1)
  barplot(testdat[j], space = 0.2,
          xlim = c(-0.5,2),
          ylim = c(0,100),
          col = hcol[testdat[j]],
          ylab = "Concentration")
}