# Twitter harvester

# These functions can be used to retrieve Tweets that contain certain hashtags

# (1) Load required libraries ####
library(dplyr)
library(rtweet)

# (2) Setting up authentication ####
# This requires a Twitter OAuth token to be available as a file called 
# `twitter-token` in the harvest folder.
Sys.setenv(TWITTER_PAT = "SM/harvest/twitter-token")
twitter_token <- get_tokens()
Sys.unsetenv("TWITTER_PAT")

# (3) Function definition ####

get_tweets <- function(hts, n = 18000, rts = FALSE) {
  query_string <- paste(paste0("#", hts), collapse = " OR ")
  res <- search_tweets(q = query_string, n = n, include_rts = rts)
  res <- data.table::as.data.table(rt)
  return(res)
}

# (4) Demo ####
# demo_hts <- c("rstats", "deeplearning")
# r_tweets <- get_tweets(demo_hts)