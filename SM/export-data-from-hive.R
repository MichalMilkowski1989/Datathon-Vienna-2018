# Export all data from hive

library(SparkR)
library(magrittr)

sp_conf <- list(spark.driver.memory = "2g")

sparkR.session(master = "yarn",
               appName = paste0("SparkR_", Sys.getenv("USER")),
               sparkConfig = sp_conf)


twitter_sdf <- sql("SELECT * FROM sm.twitter")
twitter <- twitter_sdf %>% repartition(25) %>% dapplyCollect(function(x) x)

ytch_sdf <- sql("SELECT * FROM sm.youtube_channels")
ytch <- ytch_sdf %>% repartition(25) %>% dapplyCollect(function(x) x)

ytvi_sdf <- sql("SELECT * FROM sm.youtube_videos")
ytvi <- ytvi_sdf %>% repartition(25) %>% dapplyCollect(function(x) x)

ytco_sdf <- sql("SELECT * FROM sm.youtube_comments")
ytco <- ytco_sdf %>% repartition(25) %>% dapplyCollect(function(x) x)

sparkR.session.stop()
save(twitter, ytch, ytvi, ytco, file = "sm-data.RData")