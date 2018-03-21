### This script is used for data preparation of civil society indices provided by several organisations
# it's main purpose is to prepar ethe challenge "Open government Data"
# for the Datathon in Vienna

library(dplyr)

########################################################################################
#
# Red cross data
### http://data.ifrc.org/fdrs/data-download
########################################################################################

list.files()
# Where is the file?
file1 <- "./red cross/time_series_15032018114022.csv"
#list.files(file1)
# Which sheet contains the historical data
red_cross <- read.csv(file1)
red_cross$country <- as.character(red_cross$country)
# save data
save(red_cross,file = "./red cross/red_cross_notcleaned.Rdata")


