library(jsonlite)
library(RCurl)
library(ggplot2)
library(dplyr)

GlobalEconomicMonitorIndicators <- fromJSON('http://api.worldbank.org/v2/indicators?format=json&per_page=20000')
GlobalEconomicMonitor <- list()
for(i in GlobalEconomicMonitorIndicators[[2]]$id){
  print(paste('I start now with... ',i))
  GlobalEconomicMonitor[[i]] <- fromJSON(paste0('http://api.worldbank.org/countries/all/indicators/',i,'/?format=json&date=1960:2017&per_page=20000'))  
}


GenderStatsIndicators <- fromJSON('https://api.worldbank.org/v2/sources/14/indicators?format=json') 
GenderStats <- list()
for(i in GenderStatsIndicators[[2]]$id){
  print(paste('I start now with... ',i))
  GenderStats[[i]] <- fromJSON(paste0('http://api.worldbank.org/countries/all/indicators/',i,'/?format=json&date=1960:2017&per_page=20000'))  
}

SustainableDevelopmentGoalsIndicators <- fromJSON('https://api.worldbank.org/v2/sources/46/indicators?format=json') # annual til 2014
SustainableDevelopmentGoals <- list()
for(i in SustainableDevelopmentGoalsIndicators[[2]]$id){
  print(paste('I start now with... ',i))
  SustainableDevelopmentGoals[[i]] <- fromJSON(paste0('http://api.worldbank.org/countries/all/indicators/',i,'/?format=json&date=1960:2017&per_page=20000'))  
}

SustainableDevelopmentGoals[["GC.TAX.TOTL.CN"]][[2]]$country$id <- as.factor(SustainableDevelopmentGoals[["GC.TAX.TOTL.CN"]][[2]]$country$id )
ggplot(SustainableDevelopmentGoals[["GC.TAX.TOTL.CN"]][[2]]) + geom_path(aes(x=date,y=value,colour = country$id))  + theme_bw()


WealthAccountingIndicators <- fromJSON('https://api.worldbank.org/v2/sources/59/indicators?format=json')   # every 5 years only
WealthAccounting <- list()
for(i in WealthAccountingIndicators[[2]]$id){
  print(paste('I start now with... ',i))
  WealthAccounting[[i]] <- fromJSON(paste0('http://api.worldbank.org/countries/all/indicators/',i,'/?format=json&date=1960:2017&per_page=20000'))  
}


GenderStatsMerged <- bind_rows(lapply(1:length(GenderStats), function(i) jsonlite::flatten(GenderStats[[i]][[2]])))
write.csv(GenderStatsMerged,file = 'GenderStats.csv',row.names = F)

GlobalEconomicMonitorMerged <- bind_rows(lapply(1:length(GlobalEconomicMonitor), function(i) jsonlite::flatten(GlobalEconomicMonitor[[i]][[2]])))
write.csv(GlobalEconomicMonitorMerged,file = 'GlobalEconomicMonitor.csv',row.names = F)

WealthAccountingMerged <- bind_rows(lapply(1:length(WealthAccounting), function(i) jsonlite::flatten(WealthAccounting[[i]][[2]])))
write.csv(WealthAccounting,file = 'WealthAccounting.csv',row.names = F)

SustainableDevelopmentGoalsMerged <- bind_rows(lapply(1:length(SustainableDevelopmentGoals), function(i) jsonlite::flatten(SustainableDevelopmentGoals[[i]][[2]])))
write.csv(SustainableDevelopmentGoals,file = 'SustainableDevelopmentGoals.csv',row.names = F)
