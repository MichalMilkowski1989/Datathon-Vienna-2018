# Classify the emotion of a message based on contained emojis.
# c.f. <http://kt.ijs.si/data/Emoji_sentiment_ranking/index.html>

# (0) Obtain emoji sentiment data ####
# Source: <https://www.clarin.si/repository/xmlui/handle/11356/1048>

emojis <- fread("~/Downloads/Emoji_Sentiment_Data_v1.0.csv")
emojis$name2 <- stringi::stri_replace_all_fixed(emojis$`Unicode name`, " ", "_")


# (1) Load required libraries and data ####

library(SparkR)
library(magrittr)
library(data.table)
library(stringi)

sp_conf <- list(spark.driver.memory = "2g")

sparkR.session(master = "yarn",
               appName = paste0("SparkR_", Sys.getenv("USER")),
               sparkConfig = sp_conf)


tw_sdf <- sql("SELECT status_id, text FROM sm.twitter")
tw <- tw_sdf %>% repartition(25) %>% dapplyCollect(function(x) x)
tw <- as.data.table(tw)

yt_sdf <- sql("SELECT id, text FROM sm.youtube_comments")
yt <- yt_sdf %>% repartition(25) %>% dapplyCollect(function(x) x)
yt <- as.data.table(yt)

sparkR.session.stop()

# (2) Setup emoji detection ####
detect_emoji <- function(txt) {
  # Returns for a single text a logical vector for each emoji, `TRUE` if it occurs in the message.
  res <- stri_detect_regex(txt, pattern = emojis$Emoji)
}


# (3) Classify Twitter & YouTube data ####

tw_occurances <- sapply(as.list(tw[, text]), detect_emoji)
yt_occurances <- sapply(as.list(yt[, text]), detect_emoji)


# (4) Reshape occurance data to long format and enrich with sentiment data ####

tw_occurances <- data.table(id = tw$status_id, as.data.table(t(tw_occurances)))
setnames(tw_occurances, c("status_id", emojis$name2))
yt_occurances <- data.table(id = yt$id, as.data.table(t(yt_occurances)))
setnames(yt_occurances, c("id", emojis$name2))

tw_final <- melt(tw_occurances, id.vars = "status_id", variable_name = "emoji", value.name = "hasEmoji")
yt_final <- melt(yt_occurances, id.vars = "id", variable_name = "emoji", value.name = "hasEmoji")

tw_final <- merge(tw_final, emojis, by.x = "emoji", by.y = "name2", all.x = TRUE)
yt_final <- merge(yt_final, emojis, by.x = "emoji", by.y = "name2", all.x = TRUE)


# (5) Remove messages without emojis ####
tw_final <- tw_final[hasEmoji == TRUE]
yt_final <- yt_final[hasEmoji == TRUE]


# (6) Aggregate averages per message ####

tw_aggregate <- tw_final[, .(nEmojis = .N,
                             Negative = mean(Negative/Occurences), 
                             Neutral = mean(Neutral/Occurrences), 
                             Positive = mean(Positive/Occurrences)), by = status_id]

yt_aggregate <- yt_final[, .(nEmojis = .N,
                             Negative = mean(Negative/Occurences), 
                             Neutral = mean(Neutral/Occurrences), 
                             Positive = mean(Positive/Occurrences)), by = id]
