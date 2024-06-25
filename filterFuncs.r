
lpfilt <- function(poll, boardinfo, lf = 40, forder = 6){
  coef <- butter(forder, lf / (boardinfo$samplerate/2), 'low')
  eegchan <- t(apply(poll[1:8,], 1, function(x) filtfilt(coef, x)))
  pollback <- rbind(eegchan, poll[9,])
}


bpfilt <- function(poll, boardinfo, lf = 8, hf = 12, forder = 6){
  coef <- butter(forder, c(lf, hf) / (boardinfo$samplerate/2), 'pass')
  eegchan <- t(apply(poll[1:8,], 1, function(x) filtfilt(coef, x)))
  pollback <- rbind(eegchan, poll[9,])
}

bphilbert <- function(poll, boardinfo, lf = 8, hf = 12, 
                      forder = 6){
  coef <- butter(forder, c(lf, hf) / (boardinfo$samplerate/2), 'pass')
  eegchan <- t(apply(poll[1:8,], 1, function(x) filtfilt(coef, x)))
  eeghilb <- t(apply(eegchan, 1, function(x) abs(hilbert(x))))
  pollback <- rbind(eeghilb, poll[9,])
}

addcsp <- function(eeg, csp, condition){
  eeg1 <- eeg[1:8,] # remove marker
  csp[[condition]] <- c(csp[[condition]], list(eeg1))
}

