library(tidyverse)
setwd('C:/Users/Gregor/Filr/Meine Dateien/BCI/sampleData')
fname = c('OpenBCI-RAW-2021-03-25_13-08-24_Value1.txt')
fname = c('OpenBCI-RAW-2021-03-25_13-14-36_Value.txt')
df=read.csv(fname, skip=4)
head(df)

df = df[4:dim(df)[1],]

samp = c(3000:4000)
x11();matplot(df[samp, 10:12], type='l')
x11();matplot(df[samp, 2:9], type='l')
