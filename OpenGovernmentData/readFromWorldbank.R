library(jsonlite)
library(RCurl)
library(ggplot2)
library(dplyr)

indicators <- list()
for(i in c(1:60)){
  test <- fromJSON(paste0('https://api.worldbank.org/v2/sources/',i,'/indicators?format=json'))  
  if(length(test) > 1){
    indicators[[i]] <- c(i,first(test[[2]]$source$value) )
  }
}


indicators <- unlist(indicators)
indicators <- matrix(indicators,ncol = 2, byrow = T) %>% as.data.frame()
colnames(indicators) <- c('APIind','name')
indicators$name <- gsub(' ','',indicators$name)
indicators <- indicators[indicators$APIind != 15,]


for(j in 1:nrow(indicators)){
  inds <- fromJSON(paste0('https://api.worldbank.org/v2/sources/',indicators$APIind[j],'/indicators?format=json'))
  dat <- list()
  for(i in inds[[2]]$id){
    print(paste('I start now with... ',i, 'from topic', indicators$name[j]))
    zw <- fromJSON(paste0('http://api.worldbank.org/countries/all/indicators/',i,'/?format=json&date=1960:2017&per_page=20000'))  
    zw <- jsonlite::flatten(zw[[2]])
    dat[[i]]  <- zw
  }
  Longlist <- bind_rows(dat)
  write.csv(Longlist,file = paste0(indicators$name[j],'_LL.csv'))
}





