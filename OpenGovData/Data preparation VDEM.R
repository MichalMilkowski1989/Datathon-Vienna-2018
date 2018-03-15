### This script is used for data preparation of civil society indices provided by several organisations
# it's main purpose is to prepar ethe challenge "Open government Data"
# for the Datathon in Vienna

library(dplyr)

########################################################################################
#
# Varieties of Democracy
### https://www.v-dem.net/en/data/data-version-7-1/
########################################################################################

list.files()
# Where is the file?
file1 <- "./V-dem/Country_Year_V-Dem_CSV_v7.1/V-Dem-DS-CY-v7.1.csv"

# Read the data 
VDEM_yearly <- read.csv(file1)
#convert factors into text
VDEM_yearly$country_name <-as.character(VDEM_yearly$country_name)
VDEM_yearly$country_text_id <-as.character(VDEM_yearly$country_text_id)

# and into Dates
VDEM_yearly$historical_date <- as.Date(VDEM_yearly$historical_date)
VDEM_yearly$codingstart <- as.Date(VDEM_yearly$codingstart)
VDEM_yearly$codingend <- as.Date(VDEM_yearly$codingend)
VDEM_yearly$gapstart <- as.Date(VDEM_yearly$gapstart, format = "%Y-%m-%d")
VDEM_yearly$gapend <- as.Date(VDEM_yearly$gapend, format = "%Y-%m-%d")

# finally let's sort the data
VDEM <- VDEM_yearly %>% arrange(country_name,year)
save(VDEM,file = "./V-dem/VDEM.Rdata")




