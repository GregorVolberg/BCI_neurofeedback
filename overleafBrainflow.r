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
  

## to connect with Cyton board
Id      <- brainflow_python$BoardIds$CYTON_BOARD 
params  <- brainflow_python$BrainFlowInputParams()   
params.serial_port <- "COM3" # subject to change
myboard <- brainflow_python$BoardShim(Id, params) 

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
