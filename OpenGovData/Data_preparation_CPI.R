### This script is used for data preparation of civil society indices provided by several organisations
# it's main purpose is to prepar ethe challenge "Open government Data"
# for the Datathon in Vienna

library(dplyr)
library(readxl)

########################################################################################
#
# Transparency International
### Corruption Perception Index
### https://www.transparency.org/news/feature/corruption_perceptions_index_2017
# Source description: 
# http://files.transparency.org/content/download/2181/13740/file/CPI_2017_SourceDescription%20Document_EN.pdf
########################################################################################


# Where is the file?
file1 <- "./TransparencyInternational/CPI2017_FullDataSet.xlsx"
# Which sheet contains the historical data
CPI_sheet <- "CPI historical data 2012-2017"
# Read the sheet 
CPI_wide <- read_excel(file1, sheet = CPI_sheet, range = cell_rows(c(3, NA)))

#select column names
CPI_cols <- colnames(CPI_wide)

CPI_new_column_names <- c("Country","ISO3","Region","CPI_score","CPI_std_error","CPI_source","year")

# The data is in a wide format. Let's convert it to long iterating over years
# initiate empty data.frame which is gonna be appended
CPI <- data.frame()

for (y in 2012:2017){
  #find indices of columns describing specific year
  idx_y <- grep(as.character(y), CPI_cols, value=F)
  #join year-soecific indices with first 3 columns
  position_y <- c(1:3,idx_y)
  # prepare the 1-year table with new column names and year column
  CPI_temp <- CPI_wide %>% select(position_y) %>% mutate(year = y) %>% setNames(CPI_new_column_names)
  print(paste0(as.character(y),": columns: ", paste0(position_y,collapse = ", ")))
  print(paste0("Number of countries: ", as.character(nrow(CPI_temp))))
  #merge with all the other processed so far years
  CPI <- bind_rows(CPI, CPI_temp) 
}

# let's check if the number of unique country names is 181
length(unique(CPI$Country))
# finally let's sort the data
CPI <- CPI %>% arrange(Country,year)

# save the data
save(CPI,file = "./TransparencyInternational/CPI.Rdata")
