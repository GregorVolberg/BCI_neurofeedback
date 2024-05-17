library(brainflow) 

Id      <- brainflow_python$BoardIds$SYNTHETIC_BOARD 
          # board Id
params  <- brainflow_python$BrainFlowInputParams()   
          # board parameters
myboard <- brainflow_python$BoardShim(Id, params) 
          # set up board

myboard$prepare_session() # start session
myboard$start_stream()    # start stream
    #...
myboard$stop_stream()     # stop stream
myboard$release_session() # end session
  
# board info, query before starting the session
info <- myboard$get_board_descr(Id)
info$sampling_rate 
info$eeg_channels   # add 1
info$marker_channel # add 1

# polling (between start and stop stream)
nSamp <- as.integer(250)
myboard$get_current_board_data(nSamp)
myboard$get_board_data(nSamp)
myboard$get_board_data_count()

## full example, dummy board
Id      <- brainflow_python$BoardIds$SYNTHETIC_BOARD 
params  <- brainflow_python$BrainFlowInputParams()   
myboard <- brainflow_python$BoardShim(Id, params) 

brainflow_python$BoardShim$release_all_sessions();
myboard$prepare_session() # start session
myboard$add_streamer('file://twoseconds.csv:w')
myboard$start_stream()    # start stream
Sys.sleep(2)
poll <- myboard$get_current_board_data(as.integer(250))
myboard$stop_stream()     # stop stream
myboard$release_session() # end session

# read csv file (tidyverse required)
eeg <- t(read_delim('myfile.csv',
                    delim = '\t',
                    col_names = FALSE)) # readr::read_delim

## full example, CYTON board
Id      <- brainflow_python$BoardIds$CYTON_BOARD 
params  <- brainflow_python$BrainFlowInputParams()   
params$serial_port <- "COM3" # subject to change
myboard <- brainflow_python$BoardShim(Id, params) 

brainflow_python$BoardShim$release_all_sessions();
myboard$prepare_session() # start session
myboard$add_streamer('file://cyton2s.csv:w')
myboard$start_stream()    # start stream
Sys.sleep(2)
poll <- myboard$get_current_board_data(as.integer(250))
myboard$stop_stream()     # stop stream
myboard$release_session() # end session


# dummy playback board
Id      <- brainflow_python$BoardIds$PLAYBACK_FILE_BOARD 
params  <- brainflow_python$BrainFlowInputParams()   
params$file <- "scene_aff_visual_2024-05-07-103106.csv"
params$master_board <- brainflow_python$BoardIds$CYTON_BOARD

myboard <- brainflow_python$BoardShim(Id, params) 
brainflow_python$BoardShim$release_all_sessions();
myboard$prepare_session() # start session
myboard$start_stream()    # start stream
Sys.sleep(2)
poll <- myboard$get_current_board_data(as.integer(250))
myboard$stop_stream()     # stop stream
myboard$release_session() # end session






myboard$get_current_board_data(as.integer(10), preset)

## dummy boards
Id      <- brainflow_python$BoardIds$SYNTHETIC_BOARD 
params  <- brainflow_python$BrainFlowInputParams()
myboard <- brainflow_python$BoardShim(Ids, params)

Id     <- brainflow_python$BoardIds$PLAYBACK_FILE_BOARD
params <- brainflow_python$BrainFlowInputParams()
params.file <- "streamer_default.csv"
params.master_board <- brainflow_python$BoardIds$CYTON_BOARD
myboard = brainflow_python$BoardShim(Id, params)

## synchroneous write to file
myboard$prepare_session()
myboard$add_streamer('file://myfile.csv:w', preset);
myboard$start_stream()


# board parameters
