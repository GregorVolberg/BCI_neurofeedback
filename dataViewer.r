library(tidyverse)
library(brainflow) 
library(ggfortify)

Id      <- brainflow_python$BoardIds$PLAYBACK_FILE_BOARD 
params  <- brainflow_python$BrainFlowInputParams()   
params$file <- "scene_aff_visual_2024-05-07-103106.csv"
params$master_board <- brainflow_python$BoardIds$CYTON_BOARD
params$channames <- c('F1','F3','C3','C4','O1','O2','TP9','TP10', 'Marker')
myboard <- brainflow_python$BoardShim(Id, params) 

myboard$prepare_session() # start session
myboard$start_stream()    # start stream
Sys.sleep(2)
firstSample = 1
# see polling routine from matlab
poll <- myboard$get_current_board_data(as.integer(250))
myboard$stop_stream()     # stop stream
myboard$release_session() # end session

makeTS <- function(poll, params, startsample = 0){
  eeg <- data.frame(t(poll[c(2:9, 24),])) %>%
         mutate(across(1:8, ~ .x - mean(.x, na.rm=T))) %>%
         setNames(params$channames) %>%
         ts(., frequency = 250, start = startsample)
}

eeg <- makeTS(poll, params)
plot(eeg, col='blue')

# or autoplot(eeg)
autoplot(eeg, 
  columns = params$channames,
  facets = TRUE) + 
  theme_bw()