# Authenticating with the Twitter API
# In order to use the Twitter API you need an OAuth authentication token. Follow
# these steps to generate one for you:
# 
# 1. Follow the steps outlined in <http://rtweet.info/articles/auth.html> to set
#    up a Twitter application. Be sure to note the `App name`, the 
#    `Consumer Key (API Key)` and `Consumer Secret (API Secret)`.
# 2. Execute the code below to generate your OAuth token for Twitter. This will
#    open a browser window for you to complete the OAuth dance.
# 3. Save the generated token to a file called `twitter-token` and copy it to
#    whereveer you might need Twitter API access at.

library(rtweet)

# (1) Set API Key and API Secret ####
app_name <- "DDDCEE18" # use your own value here
api_key <- "useYourOwnKey"
api_secret <- "useYourOwnSecret"

# This is what a key would look like: `TyF1kcYfUTBBVHnmReXC8VYXW`
# And this is what the secret would look like:
# `Om9HPiopoiaKLeTEejaykCErMdo27FwEkInWp1N6BpIUj0oY8`

# (2) Do the OAuth dance ####

twitter_token <- create_token(
  app = appname,
  consumer_key = api_key,
  consumer_secret = api_secret)

# (3) Save the token ####

saveRDS(twitter_token, file = "twitter-token")
