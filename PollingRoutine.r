library(tidyverse)
library(brainflow) 
library(DescTools)
library(signal)

source('./helperFunctions.r')

Id      <- brainflow_python$BoardIds$PLAYBACK_FILE_BOARD 
params  <- brainflow_python$BrainFlowInputParams()   
params$file         <- "scene_aff_visual_2024-05-07-103106.csv"
params$master_board <- brainflow_python$BoardIds$CYTON_BOARD
myboard             <- brainflow_python$BoardShim(Id, params) 

boardinfo <- setBoardInfo() # see helper functions

myboard$release_all_sessions()
myboard$prepare_session() # start session
myboard$start_stream()    # start stream

### polling 
previousSample <- myboard$get_board_data_count()
invisible(myboard$get_board_data()) # empty buffer
polls <- 0
npolls <- 10 # 
begsample <- NULL
endsample <- NULL

while(polls < npolls){
  polls <- polls + 1
  begsample[polls]  <- previousSample + 1
  endsample[polls]  <- previousSample + boardinfo$pollnum
  while (myboard$get_board_data_count() < boardinfo$pollnum) {
    Sys.sleep(0.02) # wait until buffer is filled
   }
  poll <- myboard$get_board_data(as.integer(boardinfo$pollnum))
    ##### routines within the loop
    eeg  <- poll[c(boardinfo$eegchannels, boardinfo$markerchannel),]
    eeg  <- demean(eeg)
    eeg <- lpfilt(eeg, boardinfo)
    plotEEG(eeg, boardinfo, polls)
    #####
  previousSample <- endsample[polls]
}

myboard$stop_stream()     # stop stream
myboard$release_session() # end session

