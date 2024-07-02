setBoardInfo <- function(ExpCode){
motorImagery <- data.frame(name = c('C3','C4','Cz','CP3',
                                    'CP4','C1', "C2", 'CPz',
                                    'AFz', "FCz"),
                           easyCap = c("16",  "10",  "Ref", "15",
                                       "11",  "5",  "3",  "4",
                                       "19", "1"),
                           OpenBCI = c("N1P", "N2P", "N3P", "N4P", "N5P", 
                                       "N6P", "N7P", "N8P",
                                       "SRB2(REF)", "BIAS(GND)"))
neurofeedback <- data.frame(name = c("AF1", "AF2", "AFz", "Cz",
                                     "F1",  "Fz",  "C1",  "C2",
                                     "Oz",  "Pz"),
                           easyCapNumber = numeric(10),
                           OpenBCI =  c("N1P", "N2P", "N3P", "N4P", "N5P", 
                                          "N6P", "N7P", "N8P",
                                          "SRB2(REF)", "BIAS(GND)"))
sceneAffordanceVisual <- data.frame(name = c('F2','F4','C3','C4',
                                             'O1','O2','TP9','TP10',
                                             NaN, NaN),
                           easyCapNumber = numeric(10),
                           OpenBCIpin    = c("N1P", "N2P", "N3P", "N4P",
                                             "N5P", "N6P", "N7P", "N8P",                                                     "SRB2(REF)", "BIAS(GND)"))

allExperiments <- list(motorImagery, neurofeedback, sceneAffordanceVisual)

boardinfo <- NULL
boardinfo$channames <- allExperiments[[ExpCode]]$name[1:8]
boardinfo$REF <- allExperiments[[ExpCode]]$name[9]
boardinfo$GND <- allExperiments[[ExpCode]]$name[10]
boardinfo$eegchannels   <- c(2:9)
boardinfo$markerchannel <- c(24)
boardinfo$samplerate    <- c(as.integer(250))
boardinfo$blocksize     <- 1.024 # polling interval, in seconds
boardinfo$pollnum       <- boardinfo$samplerate * boardinfo$blocksize
return(boardinfo)
}

# plotEEG <- function(poll, boardinfo, polls, isArtifact = 0){
#   plotcols <- c('blue', 'red')
#   eeg <- data.frame(t(poll)) %>%
#     setNames(c(boardinfo$channames, 'marker')) %>%
#     ts(., frequency = boardinfo$samplerate, start = 0)
#   plot(eeg, col = plotcols[isArtifact + 1],
#        main = paste0('EEG, polling interval ', polls))
# }
# 
# plotEEG <- function(EEGin, boardinfo, polls, isArtifact){
#   eeg <- data.frame(t(EEGin)) %>%
#     mutate(across(1:length(boardinfo$eegchannels), ~ .x - mean(.x, na.rm=T)),
#            seq(0, boardinfo$pollnum/boardinfo$samplerate - 1/boardinfo$samplerate, 1/boardinfo$samplerate)) %>%
#     setNames(c(boardinfo$channames, "Marker", "Time")) %>% 
#     select(Time, boardinfo$channames[1]:Marker) %>%
#     pivot_longer(boardinfo$channames[1]:Marker,
#                  names_to = "Channel",
#                  values_to = "microVolt") %>%
#     mutate(Channel = factor(Channel, levels = c(boardinfo$channames, "Marker")), # for plotting order
#            Artifact = factor(rep(c(isArtifact, 0),
#                                  boardinfo$pollnum), levels = c(0,1))) 
#   
#   eegplot <- ggplot(eeg, aes(Time, microVolt, color = Artifact)) + 
#     geom_line() +
#     facet_wrap(~ Channel, , ncol = 1, strip.position = "left") +
#     scale_color_manual(values = c("black", "red")) + 
#     theme_classic() +
#     theme(legend.position = "none",
#           strip.background = element_blank()) +
#     xlab(paste0("Time (s) at polling interval ", polls))
#   
#   print(eegplot)
# }
# 

plotEEG <- function(poll, boardinfo, polls, isArtifact, waitpolls){
  minmax  <- range(poll)
  absdiff <- minmax[2] - minmax[1]
  scaleF  <- floor(absdiff/10)*10
  poll[9,] <- poll[9,] * 25 # increase value of marker channel for plotting
  poll    <- poll + (dim(poll)[1]:1 * scaleF)
  
  if(polls < waitpolls){ # let distribution build up
  plotcols = rep('black',9)} else {
  plotcols = rep('black',9)  
  plotcols[isArtifact == 1] = 'red'}
  
  eeg <- data.frame(t(poll)) 
  matplot(eeg, type='l', lty='solid',
          xaxt = "n", yaxt = "n", bty="n",
          ylab = "microVolt", 
          xlab = paste0("Time (s) at polling interval ", polls),
          col = plotcols)
  axis(1, at = seq(1, boardinfo$pollnum, 50), labels = seq(0, 1, 0.2))
  axis(2, at = 1:dim(poll)[1] * scaleF,
       labels = rev(c(boardinfo$channames, "Mrk")),
       col = NA)
}



demean <- function(poll){
  eegchan <- t(apply(poll[1:8,], 1, function(x) x - mean(x)))
  pollback <- rbind(eegchan, poll[9,])
}

lpfilt <- function(poll, boardinfo, lf = 40, forder = 6){
  coef <- butter(forder, lf / (boardinfo$samplerate/2), 'low')
  eegchan <- t(apply(poll[1:8,], 1, function(x) filter(coef, x)))
  pollback <- rbind(eegchan, poll[9,])
}

calc_EKS <- function(epoche) {
  pnew <- epoche[1:length(boardinfo$eegchannels),] # remove marker channel
  EKS <- cbind(apply(t(discretize(t(pnew), disc = "equalwidth", nbins = 100)),
                     1, FUN = infotheo::entropy),
               apply(pnew, 1, FUN = Kurt),
               apply(pnew, 1, FUN = Skew))
  return(unname(EKS))
}

f_prob_artifact <- function(epoche, dist_EKS, threshold, polls, waitPolls) {
  EKS      <- calc_EKS(epoche)
  EKS[EKS[,2] < 0, 2] = 0 # use only positive excess kurtosis ('peakdness')
  EKS[,3] = abs(EKS[,3])  # use positive and negative skewness
  dist_EKS <- rbind(dist_EKS, EKS)
  if (polls < waitPolls){
    p_entropy  <- rep(0, 8)
    p_kurtosis <- rep(0, 8)
    p_skewness <- rep(0, 8)
  } else {
    maxEKS <- apply(dist_EKS, 2, max)
    p_entropy  <- 1-(EKS[,1] / maxEKS[1])
    p_kurtosis <- 1-(EKS[,2] / maxEKS[2])
    p_skewness <- 1-(EKS[,3] / maxEKS[3])}
  
  p_artifact    <- (p_entropy + p_kurtosis + p_skewness) / 3
  t_artifact    <- p_artifact > threshold

  artfct <- data.frame(p_artifact, t_artifact)
  return(list(dist_EKS, artfct))
}

prob_artifact_ft <- function(epoche, boardinfo, polls, threshold, relChan) {
  # see https://www.fieldtriptoolbox.org/tutorial/automatic_artifact_rejection/
  pnew <- epoche[1:length(boardinfo$eegchannels),] # remove marker channel
  zeeg <- (pnew - mean(pnew)) / sd(pnew)
  avgz = apply(zeeg[relChan,], 2, mean)
  p_artifact <- rep(max(pnorm(abs(avgz))), 8)
  t_artifact <- p_artifact > threshold
  artfct <- data.frame(p_artifact, t_artifact)
  return(list(NA, artfct))
}

