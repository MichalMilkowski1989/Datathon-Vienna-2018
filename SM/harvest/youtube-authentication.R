# Authenticating with the YouTube API
#
# In order to use the YouTube API you need an OAuth authentication token. Follow
# these steps to generate one for you:
# 
# 1. Go to the [Google Developer Console](https://developers.google.com/youtube/v3/getting-started)
#    and enable all the YouTube APIs and get your `Application ID` and
#    `Application Password`.
# 2. Fill in those values below as `app_id` and `app_secret`.
# 3. Run the `yt_oauth()` function below and follow the on-screen instructions
#    in the browser window that just opened.
#
# This will write a file called `.httr-oauth` to the current working directory.
# Rename this file to `youtube-token` and copy it to whereever you need to run 
# YouTube API access from.

library(tuber)

# (1) Setting Appliation ID and Application Password ####
app_id <- "useyourown"
app_secret <- "heheNoWay"

# The app id will look something like this:
# `475219630021-0gat1tb1qhjft3e8nud8umcfqlr91867.apps.googleusercontent.com`
# and the secret like this: `tZeS3liSYoS03nCos2roP1_9`

# (2) Run `yt_oauth()` ####
yt_oauth(app_id, app_secret)

# (3) Next steps ####
# If you need to use the YouTube API from any other location, be sure to copy
# the file `.httr-oauth` to that new location; then you don't need to do the
# OAuth dance with that browser window again.