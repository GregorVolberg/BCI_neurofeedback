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
nSamp = as.integer(250)
myboard$get_current_board_data(nSamp)
m=myboard$get_board_data(nSamp)
myboard$get_board_data_count()

## save file to disk
myboard$add_streamer('file://myfile.csv:w')
eeg <- read_csv('myfile.csv') # readr::read_csv

## to connect with Cyton board
Id      <- brainflow_python$BoardIds$CYTON_BOARD 
params  <- brainflow_python$BrainFlowInputParams()   
params.serial_port <- "COM3" # subject to change
myboard <- brainflow_python$BoardShim(Id, params) 

# dummy playback board
Id      <- brainflow_python$BoardIds$PLAYBACK_FILE_BOARD 
params  <- brainflow_python$BrainFlowInputParams()   
params.file <- "myfile.csv"
params.master_board <- brainflow_python$BoardIds$SYNTHETIC_BOARD

myboard <- brainflow_python$BoardShim(Id, params) 


brainflow_python$BoardShim$release_all_sessions();


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
