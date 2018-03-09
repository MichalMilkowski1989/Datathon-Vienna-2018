# Youtube harvester
#
# These functions can be used to retrieve fhe following data from the Youtube 
# API:
#
# * Channel details
# * Videos and video details
# * Video comments

# (1) Loading required libraries ####

library(tuber)
library(data.table)


# (2) Setting up authentication ####
# This requires the API App ID and API App secret to be stored as character
# under `app_id` and `app_secret`. Also a YouTube OAuth token needs to exists
# in the harvesting folder. If these objects do not exist, then this an error 
# is thrown.

if(exists("app_id") & 
   exists("app_secret") & 
   file.exists("SM/harvest/youtube-token")) {
  yt_oauth(app_id, app_secret, token = "SM/harvest/youtube-token")
} else {
  stop("Auth error")
}
  


# (3) Function defintion ####

harvest_youtube <- function(channel_id, verbose = FALSE) {
  # c_resources <- list_channel_resources(filter = c(channel_id = channel_id), 
  #                                       part = "contentDetails")
  
  if (verbose) message("Retrieving channel comments... ", appendLF = FALSE)
  c_comments <- parseComments(get_comment_threads(c(channel_id = channel_id)))
  if (verbose) message("Comments: ", nrow(c_comments))
  
  if (verbose) message("Retrieving video list... ", appendLF = FALSE)
  c_videos <- as.data.table(list_channel_videos(channel_id, max_results = 100))
  c_videos <- c_videos[, .(contentDetails.videoId,
                           contentDetails.videoPublishedAt)]
  setnames(c_videos, c("videoId", "publishedAt"))
  c_videos[, `:=`(videoId = as.character(c_videos$videoId),
                  publishedAt = as.POSIXct(as.character(c_videos$publishedAt),
                                           tz = "GMT",
                                           format = "%Y-%m-%dT%H:%M:%S"))]
  if(verbose) message("Videos: ", nrow(c_videos))
  
  if (verbose) message("Retrieving video stats")
  v_stats <- lapply(as.list(c_videos$videoId), 
                    function(vid) as.data.table(get_stats(vid)))
  v_stats <- rbindlist(v_stats, fill = TRUE)
  
  if (verbose) message("Retrieving video details")
  v_details <- lapply(as.list(c_videos$videoId),
                      function(vid) parseDetails(get_video_details(vid)))
  v_details <- rbindlist(v_details, fill = TRUE)
  
  # if (verbose) message("Sleeping for 90 seconds to reset quota")
  # Sys.sleep(90)
  
  if (verbose) message("Retrieving video comments")
  v_comments <- lapply(as.list(c_videos$videoId),
                       function(vid) try(parseComments(get_comment_threads(c(video_id = vid)))))
  v_comments <- lapply(v_comments,
                       function(x) {
                         if (class(x)[1] == "try-error") {
                           return(data.table(error = TRUE))
                         } else {
                           return(x)
                         }
                       })
  v_comments <- rbindlist(v_comments, fill = TRUE)
  
  return(list(c_videos = c_videos, c_comments = c_comments, v_stats = v_stats, 
              v_details = v_details, v_comments = v_comments))
}

parseDetails <- function(d) {
  d <- d$items[[1]]$snippet
  r <- data.table(title = d$title,
                  description = d$description,
                  thumbnail = d$thumbnails$maxres$url,
                  tags = paste(unlist(d$tags), collapse = " "),
                  categoryId = d$categoryId,
                  localized_title = d$localized$title,
                  localized_desc = d$localized$description)
  return(r)
}

parseComments <- function(d) {
  if(! "publishedAt" %in% colnames(d)) {
    message("Caught error!")
    return(data.table(error = TRUE))
  }
  r <- as.data.table(d)
  #r[, videoId := video_id]
  r[, `:=`(publishedAt = as.POSIXct(as.character(publishedAt),
                                    tz = "GMT",
                                    format = "%Y-%m-%dT%H:%M:%S"),
           updatedAt = as.POSIXct(as.character(updatedAt),
                                  tz = "GMT",
                                  format = "%Y-%m-%dT%H:%M:%S"))]
  return(r)
}

# (4) Demo ####
# channel_id <- "UC_MNgEkOK_crUltwOlTiCCA"
# demo_results <- harvest_youtube(channel_id, verbose = TRUE)