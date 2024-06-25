library(tidyverse)
library(brainflow) 
#library(DescTools)
#library(infotheo)
library(gsignal)
library(dbcsp) # for common spatial filters, https://journal.r-project.org/articles/RJ-2022-044/

source('./simplePlot.r')
source('./filterFuncs.r')

Id      <- brainflow_python$BoardIds$PLAYBACK_FILE_BOARD 
params  <- brainflow_python$BrainFlowInputParams()   
params$file         <- "scene_aff_visual_2024-05-07-103106.csv"
params$master_board <- brainflow_python$BoardIds$CYTON_BOARD
myboard             <- brainflow_python$BoardShim(Id, params) 

# TODO
# - select channels at start, only 1:8 und marker
# -

boardinfo <- setBoardInfo(1) # see helper functions

myboard$release_all_sessions()
myboard$prepare_session() # start session
myboard$start_stream()    # start stream
### polling 
previousSample <- myboard$get_board_data_count()
invisible(myboard$get_board_data()) # empty buffer

polls <- 0
npolls <- 10
dummyConditions <- sample(c(rep(1,5), rep(2,5)))
X1 <- list(); X2 <- list()
cspdata <- list(X1, X2)
while(polls < npolls){
while (myboard$get_board_data_count() < boardinfo$pollnum) {
  Sys.sleep(0.02) # wait until buffer is filled
}
polls <- polls + 1
poll  <- myboard$get_board_data(as.integer(boardinfo$pollnum))
eeg   <- poll[c(boardinfo$eegchannels, boardinfo$markerchannel),]
eegm  <- demean(eeg)
eegf  <- lpfilt(eegm, boardinfo, 40)
cspdata[[dummyConditions[polls]]] <- c(cspdata[[dummyConditions[polls]]], list(eegf[1:8,]))
}

myboard$stop_stream()     # stop stream
myboard$release_session() # end session

library(dbcsp)
mydbcsp <- new('dbcsp', X1=cspdata[[1]], X2=cspdata[[2]], q = 8, type='dtw',
               labels = c('left', 'right'))
summary(mydbcsp)

# built-in example
x1 <- AR.data$come
x2 <- AR.data$five
mydbcsp <- new('dbcsp', X1=x1, X2=x2, q=15, labels=c("C1", "C2"))
summary(mydbcsp)
selectQ(mydbcsp)
myd <- train(mydbcsp, selected_q = 2)

xt = x2[1:5]
predict(myd, X_test=xt)



# eeg 

# test
eegb  <- bpfilt(eegm, boardinfo, 8, 12)
eegh  <- bphilbert(eegm, boardinfo, 8, 12)

chan=6
plot(eegm[chan,], type='l')
lines(eegf[chan,], type='l', col='red')
lines(eegb[chan,], type='l', col='blue')
lines(eegh[chan,], type='l', col='green')


# for csp, two lists (k = 1, 2) with matrices cannel x Time points, i elements (trials) per list.

