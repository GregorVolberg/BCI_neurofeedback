library(tidyverse)
library(ggplot2)


tapping <- tibble(x = c(0, 1, 2, 3, 4), y = rep(0, 5))

# plot layout
ggplot(tapping, aes(x, y)) +
  geom_point(color = c('red', 'blue', 'red', 'blue', 'red')) + 
  scale_x_continuous(limits = c(-5,5)) + 
  scale_y_continuous(limits = c(-5,5))

# use for animation
screen <- ggplot(tapping, aes(x, y)) + 
  scale_x_continuous(limits = c(-5,5)) + 
  scale_y_continuous(limits = c(-5,5)) +
  theme_void()

screen + geom_point(color = c('yellow', 'white', 'white', 'white', 'white'))
Sys.sleep(1)
screen + geom_point(color = c('green', 'white', 'white', 'white', 'white'))
Sys.sleep(1)
screen + geom_point(color = c('red', 'white', 'white', 'white', 'white'))
Sys.sleep(1)
screen + geom_point(color = c('white', 'red', 'white', 'white', 'white'))
Sys.sleep(1)
# etc. 
# use loops as you like

# directly after relevant events, insert a marker for brainflow
myboard$insert_marker(1); # only works with active board






geom_link(aes(x = c(10, 10, 10),
              y = c(10, 10, 30),
              xend = c(10, 30, 30),
              yend = c(30, 20, 20))) +
  geom_circle(aes(x0 = x0, y0 = y0, r = r), # gehört zu ggforce
              data = Jorah,
              size = 1,
              fill = "white",
              show.legend = FALSE) +
  scale_x_continuous(limits = c(0,40)) +
  scale_y_continuous(limits = c(0,40)) +
  annotate("text",
           x = Jorah$x0,
           y = Jorah$y0,
           label = Jorah$lab) +
  geom_label(aes(x = c(20, 10, 20),
                 y = c(15, 20, 25),
                 label = c("0.9", "0.29", "0.03")),
             label.size = 0,
             fill = "white") +
  theme_void()