# 1. Load libraries ----
# First load the necesarry libraries. We use the tidyverse suite for general data 
# manipulation and the rvest package for scraping.

library(tidyverse)
library(rvest)

# 2. Set dates ----

# First create a vector of dates you want data for. We choose day up until 
# yesterday
all_days <- seq.Date(lubridate::ymd("2018-03-13"), Sys.Date() - 1, by = "day")
all_days <- as.character(all_days)

# We replace - with / to fit url pattern of the Standard
all_days <- all_days %>% str_replace_all("-", "/")

# We reverse the days to take newest first.
all_days <- rev(all_days)

# 3. Create a scraper function ----
get_standard <- function(day){
  # The function takes the day to scrape as input
  
  base_url <- "https://derstandard.at/archiv/"
  
  # And adds the day to the baseurl of Der Standar archive webpage.
  url <- paste0(base_url, day)
  
  # The it reads that page in to memory
  html_data <- read_html(url)
  
  # And scrapes all the articles and puts them in a data frame
  results <- html_data %>% html_nodes("#resultlist li")
  
  articles <- results %>% map_df(function(li) {
    title <- li %>% html_node("h3") %>% html_text(trim = TRUE)
    description <- li %>% html_node("p") %>% html_text(trim = TRUE)
    pubdate <- li %>% html_node(".date") %>% html_text(trim = TRUE) %>% str_squish()
    link <- li %>% html_node("h3 a") %>% html_attr("href") %>% str_c("https://derstandard.at", .)
    
    tibble::tibble(title, description, pubdate, link)
  })
  
  return(articles)
}


# 4. Scrape ----
# You scrape by looping over the days and applying the function:

articles <- map_df(all_days, get_standard)