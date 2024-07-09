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
lf1 <- 12
hf1 <- 15
lf2 <- 15
hf2 <- 18
pollnum <- 256 # number of samples per poll
srate   <- 250
pickChannels <- c("C1", "C2", "Fz")
chanIndex <- which(cnames$name %in% pickChannels)
freqScale <- pwelch(rnorm(pollnum),
               window = hanning(pollnum),
               fs = 250)$freq
freq1indices <- which(freqScale > lf1 & freqScale < hf1)
freq2indices <- which(freqScale > lf2 & freqScale < hf2)
runMedian = 5

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


Id      <- brainflow_python$BoardIds$CYTON_BOARD 
params  <- brainflow_python$BrainFlowInputParams()
params$serial_port <- "COM3"
myboard             <- brainflow_python$BoardShim(Id, params) 

x11()
hcol <- heat.colors(100)

myboard$release_all_sessions()
myboard$prepare_session() # start session
myboard$start_stream()    # start stream

## polling 
polls <- 0
NFmetric <- 0
invisible(myboard$get_board_data()) # empty buffer

while(TRUE){ # endless polling, close with ESC
  while (myboard$get_board_data_count() < pollnum) {
    Sys.sleep(0.02) # wait until buffer is filled
  }
poll  <- myboard$get_board_data(as.integer(pollnum))
polls <- polls + 1
eeg   <- poll[2:9, ]
eegm  <- demean(eeg[chanIndex,])
eegf  <- welchpsd(eegm, srate = 250)
powerEstimate <- simplify2array(eegf)

f1pow <- mean(powerEstimate[freq1indices])
f2pow <- mean(powerEstimate[freq2indices])

NFmetric[polls] <- f1pow / f2pow
if (polls < runMedian){
  feedback <- 0} else {
  feedback <- median(NFmetric[(polls-runMedian):polls])
  }

barplot(feedback, space = 0.2,
        xlim = c(-0.5,2),
        ylim = c(0,3),
        col = hcol[round(feedback/3*100)],
        ylab = "Concentration")

}
myboard$stop_stream()     # stop stream
myboard$release_session() # end session

