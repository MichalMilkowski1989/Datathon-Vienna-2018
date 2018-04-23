# Classifying sentiment of a message using pre-trained RNN.
# c.f. <https://github.com/minimaxir/reactionrnn>

# (0) Installation ####
# If the package is not available, you can install it using `devtools`.
# NB: the package requires Keras to be available.

#devtools::install_github("minimaxir/reactionrnn", subdir="R-package")

# (1) Load libraries and data from Spark ####

library(reactionrnn)
library(SparkR)
library(magrittr)
library(data.table)

sp_conf <- list(spark.driver.memory = "2g")

sparkR.session(master = "yarn",
               appName = paste0("SparkR_", Sys.getenv("USER")),
               sparkConfig = sp_conf)


tw_sdf <- sql("SELECT status_id, translatedText FROM sm.twitter_translations")
tw <- tw_sdf %>% repartition(25) %>% dapplyCollect(function(x) x)

yt_sdf <- sql("SELECT id, translatedText, FROM sm.youtube_translations")
yt <- yt_sdf %>% repartition(25) %>% dapplyCollect(function(x) x)

sparkR.session.stop()

# (2) Initialize network ####
react <- reactionrnn()
react$model %>% summary()


# (3) Classify Twitter sentiment ####

twa <- tw[!is.na(input) & input != ""]
results_tw <- react %>% predict(twa$translatedText)

tw_final <- data.table(twa, results_tw)

# (4) Classify Youtube sentiment ####

yta <- yt_all_translated[!is.na(input) & input != ""]
results_yt <- react %>% predict(yta$translatedText)

yt_final <- data.table(yta, results_yt)

