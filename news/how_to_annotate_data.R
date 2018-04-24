# 1. Load libraries
# We will use the tidyverse for general data manipulation and functional programming, 
# and udpipe for annotating the data.
library(tidyverse)
library(udpipe)

# 2. Load in data ----
# You can use the functions in the scraper folder to get articles from either
# Der Standard in Austria or Nivinky in the Czech republic.

# These are empty for now. Fill it with your own data:
articles_cz # czech articles
articles_de # german articles

# 3. download models ----
# You have to download the appropriate language model for your udpipe. 
# mod_ger <- udpipe_download_model(language = "german")
# mod_cze <- udpipe_download_model(language = "czech")


# 4. Annotate Novinky ----
# Load the czech language model
lang_model <- udpipe_load_model(file = "czech-ud-2.0-170801.udpipe")

# Assuming your text is in the "text" column in the data set then you 
# annotate it like this:
anno_data_cz <- udpipe_annotate(lang_model, x = articles_cz$text)
anno_data_cz <-  as_tibble(as.data.frame(anno_data_cz))

# 5. Annotate Standard ----
# Load the german language model
lang_model <- udpipe_load_model(file = "german-ud-2.0-170801.udpipe")

# Assuming your text is in the "text" column in the data set then you 
# annotate it like this:
anno_data_de <- udpipe_annotate(lang_model, x = articles_de$text)
anno_data_de <-  as_tibble(as.data.frame(anno_data_de))