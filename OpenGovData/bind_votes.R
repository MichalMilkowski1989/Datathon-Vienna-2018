
library(Rcpp)
library(openxlsx)
library(plyr)
library(dplyr)
library(lubridate)
library(reshape)

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

pop_Aus <- read.csv(file = '../population_birthCountry_austria.csv',header = T)



## Load data from http://www.bmi.gv.at/412/Nationalratswahlen/Nationalratswahl_2006/start.aspx
dateien <- system("find ~/Documents/Domains/datathon/DataSources/Votes/Austria   -name 'NRW*.xlsx'",intern = TRUE)
#dateien <- dateien[-grep("~",dateien)]

## read xlsx data and clean it
votes_austria <- list()
for(i in dateien){
  sheets <- getSheetNames(i)
  zw <- read.xlsx(i,sheet  = sheets[1],detectDates = T) %>% as.data.frame
  colnames(zw) <- ifelse(!is.na(zw[1,]),zw[1,],colnames(zw)) %>% as.vector()
  ye <- gsub("_endgueltiges_Gesamtergebnis.xlsx","",i)
  ye <- gsub('/Users/sk186171/Documents/Domains/datathon/DataSources/Votes/Austria/NRW',"20",ye) %>% as.numeric()
  #colnames(zw) <- sapply(1:ncol(zw),function(i) paste(zw[1,i],zw[2,i]))
  zw$YEAR <- ye
  zw <- zw[2:nrow(zw),] %>% as.data.frame()
  #zw <- zw[,which(zw[3,] > 0.5)]
  to_keep <- sapply(1:ncol(zw), function(i) sum(is.na(zw[,i])))
  zw <- zw[,to_keep < 10]
  if(length(grep("Gebietsname",colnames(zw)))>0) colnames(zw)[grep("Gebietsname",colnames(zw))] <- 'Gebiet'
  colnames(zw)[grep("\\%",colnames(zw))] <- paste0(colnames(zw)[(grep("\\%",colnames(zw))-1)],"_pct")
  zw <- zw[,order(colnames(zw))]
  votes_austria[[i]] <- zw
}


###  Bind data for all years together
votes_austria <- rbind.fill(votes_austria)
to_keep <- sapply(1:ncol(votes_austria), function(i) sum(is.na(votes_austria[,i])))
votes_austria <- votes_austria[,which(to_keep < 40)]
votes_austria$GKZ <- gsub("G","",votes_austria$GKZ)
votes_austria$GKZ_ag <- as.integer(votes_austria$GKZ %>% as.numeric/10000)
votes_austria$YEAR <- as.numeric(votes_austria$YEAR)

votes_austria <- votes_austria[!is.na(votes_austria$GKZ_ag),]
votes_austria$Gebiet <- NULL

##aggregate data by country and GKZ
impute_mean <- function(x) mean(x,na.rm = T)
votes_austria_agg <- aggregate(votes_austria,by = list(votes_austria$YEAR,votes_austria$GKZ_ag),FUN = impute_mean)

## map to bundesland
bndl <- NULL
bndl$bundesland <- c('Burgenland',
'Kärnten',
'Niederösterreich',
'Oberösterreich',
'Salzburg',
'Steiermark',
'Tirol',
'Vorarlberg',
'Wien'
)
bndl$GKZ_ag <- c(1:9)
bndl <- as.data.frame(bndl)

votes_austria_agg <- left_join(votes_austria_agg,bndl)
colnames(votes_austria_agg)[c(1,2)] <- c('Year','Region')
votes_austria_agg$GKZ <- NULL
votes_austria_agg$Gebiet <- NULL

## melt to get long table
votes_austria_agg <- melt(votes_austria_agg,id.vars = c('Region','Year','bundesland'),measure.vars = c('ÖVP_pct','SPÖ_pct','FPÖ_pct','GRÜNE_pct','KPÖ_pct'))
votes_austria_agg <- votes_austria_agg[order(votes_austria_agg$Year),]
votes_austria_agg$Region <- as.factor(votes_austria_agg$Region) 

## plot and save
p<-ggplot(votes_austria_agg) + geom_path(aes(Year,value,colour = variable),size = 1.5) + facet_grid(bundesland~.) + theme_bw(base_size = 20) + ylab('Percentage')
ggsave(plot = p,filename = 'votes_austria.pdf')


