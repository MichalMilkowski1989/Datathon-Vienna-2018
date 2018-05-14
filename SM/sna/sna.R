library(SparkR)
library(reshape)
library(tidyr)
library(stringi)
library(data.table)

source("SM/harvest/twitter-harvester.R")

# (1) Open Spark session ####
library(SparkR)
library(magrittr)
sparkR.session(master = "yarn")

# (2) Retrieve base data for edge list ####
base_edge_sql <- "
SELECT  
  screen_name,
  mentions_screen_name,
  count(*) as mentioned_in_n_tweets
FROM (
  SELECT * 
  FROM (
    SELECT 
      screen_name, 
      mentions_screen_name,
      (CASE WHEN mentions_screen_name LIKE '%|%' then 1 ELSE 0 END) AS flg_requires_parsing,
      length(mentions_screen_name)
    FROM sm.twitter
    WHERE length(mentions_screen_name) > 2
    )
    WHERE flg_requires_parsing = 0
  )
GROUP BY
  screen_name,
  mentions_screen_name
"

data_graph <- sql(base_edge_sql) %>% collect()


# (3) Transform data for edge list ####
data_wide <- spread(data_graph, screen_name, mentioned_in_n_tweets)
data_wide[is.na(data_wide)] <- 0

rownames(data_wide) <- data_wide$mentions_screen_name
data_wide$mentions_screen_name <- NULL

data_wide$row_count = rowSums(data_wide, na.rm = TRUE, dims = 1)
data_wide_selection <- data_wide[which(data_wide$row_count>50), ]

dd1 <- data_wide_selection[,colSums(data_wide_selection) > 0]

g <- as.data.table(data_wide)
g2 <- melt(g, id.vars = "V1", variable.name = "target", value.name = "weight")
rs <- rowSums(g[,-1])
gfil <- g[rs > 5]
gfilRN <- gfil[,V1]
gfilCN <- colnames(gfil)[-1]
nmatch <- gfilCN[gfilCN %in% gfilRN]
nmatch2 <- gfilRN[gfilRN %in% gfilCN]
gfil2 <- gfil[V1 %in% nmatch][,c("V1", nmatch), with = FALSE]
g3 <- melt(gfil2, id.vars = "V1", value.name = "weight", variable.name = "target")
setnames(g3, "V1", "source")

edge_list <- g3
edge_list_wide <- spread(edge_list, source, weight)


# (4) Create node list ####

# (4.1) Nodes by dominant sentiments ####
required_screen_names <- data.table(rsn = unique(g3$source))

node_query_sql <- "
SELECT
  t.screen_name AS screen_name,
  count(distinct lang) AS nLang,
  count(distinct t.status_id) AS nTweets,
  min(created_at) AS firstTweet,
  max(created_at) AS lastTweet,
  avg(length(text)) AS avg_tweet_length,
  sum(cast(is_quote AS int)) AS nQuotes,
  sum(cast(is_retweet AS int)) AS nRetweets,
  avg(favorite_count) AS avg_favCount,
  avg(retweet_count) AS avg_rtCount,
  sum((case WHEN urls_url = 'NA' THEN 0 ELSE 1 END)) AS sum_urls,
  avg(love) AS avg_love,
  avg(wow) AS avg_wow,
  avg(haha) AS avg_haha,
  avg(sad) AS avg_sad,
  avg(angry) AS avg_angry
FROM
  sm.twitter AS t
  LEFT OUTER JOIN
  sm.twitter_sentiment_fb AS s
  ON t.status_id = s.status_id
GROUP BY t.screen_name
"

tw_sdf <- sql(node_query_sql)
tw_loc <- tw_sdf %>% dapplyCollect(function(x) x)
tw_loc <- as.data.table(tw_loc)

nodes_list <- tw_loc
nodes_list$maximum <- apply(nodes_list[,12:16], 1, FUN = max)
df <- cbind(nodes_list$screen_name, nodes_list$avg_love, nodes_list$avg_wow,
            nodes_list$avg_haha, nodes_list$avg_sad, nodes_list$avg_angry, 
            nodes_list$maximum)
names(df) <- c("screen_name","love","wow","haha","sad","angry","maximum")


#(4.2) Nodes by followers count ####
uln <- nl$Id
rau <- lookup_users(nl$Id)
n_followers <- as.data.table(rau)


# (5) Close Spark session ####
sparkR.session.stop()
