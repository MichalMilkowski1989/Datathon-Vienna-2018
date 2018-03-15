### This script is used for data preparation of civil society indices provided by several organisations
# it's main purpose is to prepar ethe challenge "Open government Data"
# for the Datathon in Vienna

library(dplyr)
library(readxl)

########################################################################################
#
# Bertelsmann Stiftung
### Bertelsmann Transformation Index
### https://www.bti-project.org/en/index/overview/
########################################################################################

list.files()
# Where is the file?
file1 <- "./BertelsmannStiftung/BTI_2006-2016_Scores.xlsx"
list.files(file1)
# Which sheet contains the historical data
BTI_sheet_core <- "BTI "

# initiate empty data.frame which is gonna be appended
BTI <- data.frame()

for (y in seq(2006,2016,2)){
  # Read the sheet - 1 year of data
  BTI_y <- read_excel(file1, sheet = paste0(BTI_sheet_core, y), range = cell_cols("A:DL"))
  #Add year column
  BTI_y <- BTI_y %>% mutate(year = y)
  #merge with previous tables
  # Let's clean the names and get rid of empty rows
  
  # first change the names
  columns_names <- colnames(BTI_y)
  dict <- columns_names[1]
  
  columns_names_ready <- gsub("[^a-z0-9\\.]","_",x = tolower(columns_names))
  #get rid of multiple ____
  columns_names_ready <- gsub("_{2,}","_",x = columns_names_ready)
  # set first column name to country
  columns_names_ready[1] <- "Country"
  # rename
  colnames(BTI_y) <- columns_names_ready
  
  # find totally empty columns
  all_empty <- sapply(BTI_y,function(x) all(is.na(x)))
  
  BTI_y <- BTI_y %>% select(names(all_empty[all_empty==FALSE]))
  
  ### Let's get rid of missing values in other forms
  BTI_y[BTI_y == "-"] <- NA
  BTI_y[BTI_y == "n/a"] <- NA
  BTI_y[BTI_y == "?"] <- NA
  
  # What should stay character?
  
  #some signals for trends
  exclude_vars <- c("x_2","x_3")
  BTI_y <- BTI_y %>% select_(.dots=setdiff(names(BTI_y),exclude_vars))
  
  
  char_vars <- c("Country", "democracy_autocracy", "x_6", "x_7", "x_8", "x_9", "x_10")
  
  for (i in setdiff(colnames(BTI_y),char_vars)){
    BTI_y[,i] <- as.vector(apply(BTI_y[,i],2,as.numeric))
  }
  
  democracy_status_idx <- grep(pattern = "^democracy_status_", x=names(BTI_y),value=TRUE)
  market_economy_idx <- grep(pattern = "^market_economy_status_", x=names(BTI_y),value=TRUE)
  
  BTI_y <- BTI_y %>% rename(status_category = category,
                             status_description = x_6,
                            democracy_status_category = category_1,
                            democracy_status_description = x_7,
                            market_economy_status_category = category_2,
                            market_economy_status_description = x_8,
                            management_index_category = category_3,
                            management_index_description = x_9,
                            level_of_difficulty_category = category_4,
                            level_of_difficulty_description = x_10) %>% 
    rename_("democracy_status_prev" = democracy_status_idx[1]) %>% 
    rename_("democracy_status_current" = democracy_status_idx[2]) %>% 
    rename_("market_economy_status_prev" = market_economy_idx[1]) %>% 
    rename_("market_economy_status_current" = market_economy_idx[2])
  
  #check if the 
  print(paste0("If all the columns are the same as previously: year ",as.character(y)))
  print(as.character(all(colnames(BTI)==colnames(BTI_y))))
  
  BTI <- bind_rows(BTI, BTI_y)
}

BTI <- BTI %>% arrange(Country,year)

# save the script
save(BTI,file = "./BertelsmannStiftung/BTI.Rdata")