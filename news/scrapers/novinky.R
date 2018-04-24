# 1. Load libraries ----
# First load the necesarry libraries. We use the tidyverse suite for general data 
# manipulation and the rvest package for scraping. We use glue to glue strings
# together (see below).

library(rvest)
library(tidyverse)
library(glue)

# 2. Set dates ----
# Novinky's date is not organized by day, but by month

# First we create a data frame of all combinations of years and months that we want
dates <- paste0("1.", 1:12, ".") %>% expand.grid(., 20016:2017, stringsAsFactors = FALSE)

# Then we paste them together to create a string for each month in each year
dates <- map2_chr(dates$Var1, dates$Var2, paste0, collapse = ".")

# And reverse them to get the newest dates first.
dates <- rev(dates)

# 3. Create a scraper function ----
get_novinky <- function(date){
  # The function takes the month (as date) to scrape as input
  
  # And "glues" it to the url
  url <- glue("https://www.novinky.cz/archiv?id=1&listType=month&date={date}")
  
  # Then it reads the page into memory
  html_data <- read_html(url)
  
  # And scrapes all the articles and puts them in a data frame
  items <- html_data %>% html_nodes(".item")
  
  articles <- items %>% map_df(function(item){
      
      title <- item %>% html_nodes("h3") %>% html_text(trim = TRUE)
      description <- item %>% html_nodes("p") %>% html_text(trim = TRUE)
      
      dateline <- item %>% html_nodes(".dateLine") %>% html_text(trim = TRUE)
      time <- item %>% html_nodes(".time") %>% html_text(trim = TRUE)
      pubdate <- str_c(dateline, " ", time)
      
      link <- item %>% html_nodes("h3 a") %>% html_attr("href")
      
      out <- tibble::tibble(
        title, description, pubdate, link
      )
      
      out
    })
  
  return(articles)
}

# 4. Scrape ----
# You scrape by looping over the days and applying the function:
articles <- map_df(dates, get_novinky)
