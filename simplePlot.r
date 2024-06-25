
simplePlot <- function(poll, boardinfo){
  minmax  <- range(poll)
  absdiff <- minmax[2] - minmax[1]
  scaleF  <- floor(absdiff/10)*10
  poll[9,] <- poll[9,] * 25 # increase value of marker channel for plotting
  poll    <- poll + (dim(poll)[1]:1 * scaleF)

  eeg <- data.frame(t(poll)) 
  matplot(eeg, type='l', lty='solid',
          xaxt = "n", yaxt = "n", bty="n",
          ylab = "microVolt", 
          xlab = 'time', col = 'black')
  axis(1, at = seq(1, boardinfo$pollnum, 50), labels = seq(0, 1, 0.2))
  axis(2, at = 1:dim(poll)[1] * scaleF,
       labels = rev(c(boardinfo$channames, "Mrk")),
       col = NA)
}
