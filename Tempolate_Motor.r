library(tidyverse)
library(brainflow) 
library(gsignal)
library(dbcsp) # for common spatial filters, https://journal.r-project.org/articles/RJ-2022-044/

source('./filterFuncs.r')
source('./helperFunctions.r')

# first: training on previous data
markers <- read_delim('test_run_motor.csv', 
                      col_names = FALSE) %>%
           select(val = 24) %>%
           mutate(spoint = 1:n()) %>%
           dplyr::filter(val > 0)  %>%
           group_by(val) %>%
           group_split()


eegdat <- read_delim('test_run_motor.csv', 
            col_names = FALSE) %>%
    select(c(2:9)) %>%
    t()


bpfilt <- function(eegin, srate, lf, hf, forder){
  coef <- butter(forder, c(lf, hf) / srate, 'pass')
  eegout <- t(apply(eegin, 1, function(x) filtfilt(coef, x)))
}

# create list of real motor conditions
# find out: 
# - best lf and hf 
# - raw data (eegm), filtered data (eegf) or hilbert amplitude (eegh) 
lf = 8
hf = 30
pollnum = 256
srate = 250
X1 = list(); X2 = list()
cspdataM = list(X1, X2)
for (con in 1:2){
  lstnum = 0
  for (sp in markers[[con]]$spoint){
    lstnum = lstnum + 1
    eegm <- t(apply(eegdat[, sp:(sp+pollnum-1)], 1, function(x) x - mean(x)))
    eegf  <- bpfilt(eegm, srate, lf, hf, 6)
    eegh  <- t(apply(eegf, 1, function(x) abs(hilbert(x))))
    cspdataM[[con]][lstnum] = list(eegf)
  }
}

# create list of imagined motor conditions
X1 = list(); X2 = list()
cspdataI = list(X1, X2)
for (con in 1:2){
  lstnum = 0
  for (sp in markers[[con]]$spoint){
    lstnum = lstnum + 1
    eegm <- t(apply(eegdat[, sp:(sp+pollnum-1)], 1, function(x) x - mean(x)))
    eegf  <- bpfilt(eegm, srate, lf, hf, 6)
    eegh  <- t(apply(eegf, 1, function(x) abs(hilbert(x))))
    cspdataI[[con]][lstnum] = list(eegf)
  }
}

# training with csp
library(dbcsp)
mydbcsp <- new('dbcsp', X1=cspdataM[[1]], X2=cspdataM[[2]], q = 8, type='dtw',
               labels = c('left', 'right'))
summary(mydbcsp)
selectQ(mydbcsp, Q = c(1, 2, 3, 4, 6, 8))
myd <- train(mydbcsp, selected_q = 3)

# test with csp
ergleft  <- predict(myd, X_test=cspdataI[[1]])$posterior[,'left']
ergright <- predict(myd, X_test=cspdataI[[2]])$posterior[,'right']
ergleft > 0.5
ergright > 0.5
sum(c(ergleft, ergright)) / length(c(ergleft, ergright))
# or plot, ....


# test with live data during polling 
# change that to cyton board, as in test recording
Id      <- brainflow_python$BoardIds$PLAYBACK_FILE_BOARD 
params  <- brainflow_python$BrainFlowInputParams()   
params$file         <- "test_run_motor.csv"
params$master_board <- brainflow_python$BoardIds$CYTON_BOARD
myboard             <- brainflow_python$BoardShim(Id, params) 


boardinfo <- setBoardInfo(1) # see helper functions

myboard$release_all_sessions()
myboard$prepare_session() # start session
myboard$start_stream()    # start stream

### directly after stimulus presentation (replace marker)
previousSample <- myboard$get_board_data_count()
invisible(myboard$get_board_data()) # empty buffer

while (myboard$get_board_data_count() < boardinfo$pollnum) {
  Sys.sleep(0.02) # wait until buffer is filled
}
poll <- myboard$get_board_data(as.integer(boardinfo$pollnum))
eeg   <- poll[boardinfo$eegchannels,]
eegm1 <- t(apply(eeg, 1, function(x) x - mean(x)))
eegf1  <- bpfilt(eegm, srate, lf, hf, 6)
eegh1  <- t(apply(eegf, 1, function(x) abs(hilbert(x))))
pleft <- predict(myd, X_test=list(eegf1))$posterior[,'left']
# see if pleft > 0.5 is for left abd pleft < 0.5 is for right imagined movements

myboard$stop_stream()     # stop stream
myboard$release_session() # end session

# 
# library(dbcsp)
# mydbcsp <- new('dbcsp', X1=cspdata[[1]], X2=cspdata[[2]], q = 8, type='dtw',
#                labels = c('left', 'right'))
# summary(mydbcsp)
# 
# # built-in example
# x1 <- AR.data$come
# x2 <- AR.data$five
# mydbcsp <- new('dbcsp', X1=x1, X2=x2, q=15, labels=c("C1", "C2"))
# summary(mydbcsp)
# selectQ(mydbcsp)
# myd <- train(mydbcsp, selected_q = 2)
# 
# xt = x2[1:5]
# predict(myd, X_test=xt)
# 
# 
# 
# # eeg 
# 
# # test
# eegb  <- bpfilt(eegm, boardinfo, 8, 12)
# eegh  <- bphilbert(eegm, boardinfo, 8, 12)
# 
# chan=6
# plot(eegm[chan,], type='l')
# lines(eegf[chan,], type='l', col='red')
# lines(eegb[chan,], type='l', col='blue')
# lines(eegh[chan,], type='l', col='green')
# 
# 
# # for csp, two lists (k = 1, 2) with matrices cannel x Time points, i elements (trials) per list.
# 
