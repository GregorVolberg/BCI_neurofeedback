library(brainflow) 

Id     <- brainflow_python$BoardIds$SYNTHETIC_BOARD 
          # board Id
params <- brainflow_python$BrainFlowInputParams()   
          # board parameters
board  <- brainflow_python$BoardShim(Id, params) 
          # set up board

board$prepare_session() # start session
board$start_stream()    # start stream
    #...
board$stop_stream()     # stop stream
board$release_session() # end session
  

  
