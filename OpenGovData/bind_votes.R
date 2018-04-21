
library(Rcpp)
library(openxlsx)
library(plyr)
library(dplyr)
library(lubridate)

## http://www.data.gv.at

## Load data
dateien <- system("find ~/Documents/Domains/datathon/DataSources/Votes/Austria   -name '*.xlsx'",intern = TRUE)
dateien <- dateien[-grep("~",dateien)]

## read xlsx data and clean it
votes_austria <- list()
for(i in dateien){
  sheets <- getSheetNames(i)
  zw <- read.xlsx(i,sheet  = sheets[1],detectDates = T) %>% as.data.frame
  ye <- gsub(".xlsx","",i)
  ye <- gsub('/Users/sk186171/Documents/Domains/datathon/DataSources/Votes/Austria/stat_download_nr',"20",ye) %>% as.numeric()
  colnames(zw) <- sapply(1:ncol(zw),function(i) paste(zw[1,i],zw[2,i]))
  zw$YEAR <- ye
  zw <- zw[3:nrow(zw),] %>% as.data.frame()
  votes_austria[[i]] <- zw
}

any(!colnames(votes_austria[[1]]) %in% colnames(votes_austria[[5]]))
names_col <- c('YEAR')
names_col <- sapply(1:5,function(i) union(colnames(votes_austria[[i]]),names_col)) %>% last


###  Bind data for all years together
votes_austria <- rbind.fill(votes_austria)

#### Data is downloaded from https://vdb.czso.cz/vdbvo2/faces/en/index.jsf?page=vystup-objekt-vyhledavani&vyhltext=election&bkvt=ZWxlY3Rpb24.&pvo=VOL02-PS2017&z=T&f=TABULKA&skupId=2105&katalog=all&pvo=VOL02-PS2017&str=v82#w=

dateien <- system("find ~/Documents/Domains/datathon/DataSources/Votes/Czech   -name '*_1.xlsx'",intern = TRUE)
dateien <- dateien[grep('ptc',dateien)]

## read xlsx data and clean it

votes_czech <- list()
for(i in dateien){
  sheets <- getSheetNames(i)
  zw <- read.xlsx(i,sheet  = sheets[1],detectDates = T) %>% as.data.frame() 
  ye <- gsub("_ptc_1.xlsx","",i)
  ye <- gsub('/Users/sk186171/Documents/Domains/datathon/DataSources/Votes/Czech/VOL02-PS',"",ye) %>% as.numeric()
  colnames(zw) <- zw[3,]#sapply(1:ncol(zw),function(i) paste(zw[1,i],zw[2,i]))
  colnames(zw)[1] <- 'weg'
  zw$weg <- NULL
  zw <- zw[5:nrow(zw),] %>% as.data.frame()
  zw <- t(zw)
  colnames(zw) <- zw[1,]
  colnames(zw) <- sapply(1:ncol(zw),function(i) paste((strsplit(colnames(zw)[i],' ') %>% unlist)[c(2,3)],collapse = ' '))
  zw <- zw[2:nrow(zw),] %>% as.data.frame()
  zw$YEAR <- ye
  zw$REGION <- rownames(zw)
  votes_czech[[i]] <- zw
}

###  Bind data for all years together
votes_czech <- rbind.fill(votes_czech)

to_keep <- sapply(1:ncol(votes_czech), function(i) sum(is.na(votes_czech[,i])))
votes_czech <- votes_czech[,which(to_keep < 40)]
save(votes_czech, file =  'czech.Rdata')


