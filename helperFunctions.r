setBoardInfo <- function(){
boardinfo <- NULL
boardinfo$channames <- c('F1','F3','C3','C4',
                         'O1','O2','TP9','TP10', 'Marker')
boardinfo$eegchannels   <- c(2:9)
boardinfo$markerchannel <- c(24)
boardinfo$samplerate    <- c(as.integer(250))
boardinfo$blocksize     <- 1.024 # polling interval, in seconds
boardinfo$pollnum       <- boardinfo$samplerate * boardinfo$blocksize
return(boardinfo)
}

poll2eeg <- function(poll, boardinfo){
  eeg <- data.frame(t(poll[c(boardinfo$eegchannels, boardinfo$markerchannel),])) %>%
    mutate(across(1:8, ~ .x - mean(.x, na.rm=T))) %>%
    setNames(boardinfo$channames)
}

pollcorr <- function(poll, boardinfo){
  pnew <- poll[1:boardinfo$eegchannels]
  ent <- apply(pnew,1, FUN = Entropy) # function entropy from DescTools
  kur <- apply(pnew,1, FUN = Kurt) # function entropy from DescTools
  ske <- apply(pnew,1, FUN = Skew) # function entropy from DescTools
  eeg <- poll[c(boardinfo$eegchannels, boardinfo$markerchannel),]
  numpy_data <- np$array(eeg[2,]) %>%
    mutate(across(1:8, ~ .x - mean(.x, na.rm=T))) %>%
    setNames(boardinfo$channames)
# see https://www.eneuro.org/content/7/2/ENEURO.0293-19.2020 for periodicity and also first comment in https://www.researchgate.net/post/Signal-periodicity-measurement-How-to-compare-the-periodicity-between-two-signals
}

makeTS <- function(poll, params, startsample = 0){
  eeg <- data.frame(t(poll[c(2:9, 24),])) %>%
    mutate(across(1:8, ~ .x - mean(.x, na.rm=T))) %>%
    setNames(params$channames) %>%
    ts(., frequency = 250, start = startsample)
}

plotEEG <- function(poll, boardinfo, polls, isArtifact = 0){
  plotcols <- c('blue', 'red')
  eeg <- data.frame(t(poll)) %>%
    setNames(boardinfo$channames) %>%
    ts(., frequency = boardinfo$samplerate, start = 0)
  plot(eeg, col = plotcols[isArtifact + 1],
       main = paste0('EEG, polling interval ', polls))
}

demean <- function(poll){
  eegchan <- t(apply(poll[1:8,], 1, function(x) x - mean(x)))
  pollback <- rbind(eegchan, poll[9,])
}

lpfilt <- function(poll, boardinfo, lf = 40, forder = 6){
  coef <- butter(forder, lf / (boardinfo$samplerate/2), 'low')
  eegchan <- t(apply(poll[1:8,], 1, function(x) filter(coef, x)))
  pollback <- rbind(eegchan, poll[9,])
}



# numpy_data <- np$array(poll[2,])
# #print(numpy_data)
# sampling_rate <- boardinfo$samplerate
# brainflow_python$DataFilter$perform_lowpass(numpy_data, sampling_rate, 20.0, as.integer(3), as.integer(brainflow_python$FilterTypes$BESSEL), 0)
# print(numpy_data)