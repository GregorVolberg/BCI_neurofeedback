library(tidyverse)
library(brainflow) 
library(DescTools)
library(infotheo)
library(signal)

source('./helperFunctions.r')

Id      <- brainflow_python$BoardIds$PLAYBACK_FILE_BOARD 
params  <- brainflow_python$BrainFlowInputParams()   
params$file         <- "scene_aff_visual_2024-05-07-103106.csv"
params$master_board <- brainflow_python$BoardIds$CYTON_BOARD
myboard             <- brainflow_python$BoardShim(Id, params) 

boardinfo <- setBoardInfo(1) # see helper functions

myboard$release_all_sessions()
myboard$prepare_session() # start session
myboard$start_stream()    # start stream

### polling 
previousSample <- myboard$get_board_data_count()
invisible(myboard$get_board_data()) # empty buffer
polls <- 0
npolls <- 30 # 
begsample <- NULL
endsample <- NULL
distAndProb <- list(dist_EKS  <- NULL,
                    artfct    <- NULL)
artfct_thresh <- 0.999 # for fprob 0.7
numWaitPolls  <- 0 # take first numWaitPolls for distribution, for fprob 20
relevantChannels = c(1:4) # only for ft

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
    #distAndProb <- f_prob_artifact(eeg, distAndProb[[1]], artfct_thresh,                                    polls, numWaitPolls)
    distAndProb <- prob_artifact_ft(eeg, boardinfo, polls,
                                    artfct_thresh, relevantChannels)
    print(round(distAndProb[[2]]$p_artifact, 3))
    plotEEG(eeg, boardinfo, polls, 
            isArtifact = distAndProb[[2]]$t_artifact, waitpolls = numWaitPolls)
    #####
  previousSample <- endsample[polls]
}

myboard$stop_stream()     # stop stream
myboard$release_session() # end session

