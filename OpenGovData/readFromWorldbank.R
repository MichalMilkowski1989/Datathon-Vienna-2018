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

#################################################################### 
## Due to errors in API connection several indicators where ommited
#12th ommited: MillenniumDevelopmentGoals
#36th ommited: IndonesiaDatabaseforPolicyandEconomicResearch
#41st ommited  WDIDatabaseArchives

for(j in 1:nrow(indicators)){
  print(paste0(j,"th step out of ",nrow(indicators)," started"))
  
  inds <- fromJSON(paste0('https://api.worldbank.org/v2/sources/',indicators$APIind[j],'/indicators?format=json'))
  dat <- list()
  for(i in inds[[2]]$id){
    print(paste('I start now with... ',i, 'from topic', indicators$name[j]))
    zw <- fromJSON(paste0('http://api.worldbank.org/countries/all/indicators/',i,'/?format=json&date=1960:2017&per_page=20000'))  
    if(length(zw)==2) {
      zw <- jsonlite::flatten(zw[[2]])
      dat[[i]]  <- zw
    }
  }
  Longlist <- bind_rows(dat)
  #save as csv
  write.csv(Longlist,file = paste0(indicators$name[j],'_LL.csv'))
  
  ### save as data frame and Rdata file
  # save as data.frame with_proper name
  text <- paste0(gsub(pattern = '[^a-zA-Z0-9]+','_',indicators$name[j]),'_LL <- Longlist')
  eval(parse(text=text))
  
  # save the properly named data.frame as Rdata file
  text2 <- paste0("save(",gsub(pattern = '[^a-zA-Z0-9]+','_',indicators$name[j]),"_LL,file='",
                  gsub(pattern = '[^a-zA-Z0-9]+','_',indicators$name[j]),"_LL.Rdata')")
  eval(parse(text=text2))
  
  #remove data.frame
  text3 <- paste0("rm(",gsub(pattern = '[^a-zA-Z0-9]+','_',indicators$name[j]),"_LL)")
  eval(parse(text=text3))
  print(paste0(j,"th step out of ",nrow(indicators)," done"))
}

