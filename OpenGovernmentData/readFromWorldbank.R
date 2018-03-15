library(jsonlite)
library(RCurl)
library(ggplot2)
library(dplyr)

GenderStatsIndicators <- fromJSON('https://api.worldbank.org/v2/sources/14/indicators?format=json') 
GenderStats <- list()
for(i in GenderStatsIndicators[[2]]$id){
  print(paste('I start now with... ',i))
  zw <- fromJSON(paste0('http://api.worldbank.org/countries/all/indicators/',i,'/?format=json&date=1960:2017&per_page=20000'))  
  zw <- jsonlite::flatten(zw[[2]])
  GenderStats[[i]] <- zw
  #write.csv(zw,file = paste0('GenderStats_',i,'.csv'))
}
GenderStatsLonglist <- bind_rows(GenderStats)
write.csv(GenderStatsLonglist,file = 'GenderStats_LL.csv')

SustainableDevelopmentGoalsIndicators <- fromJSON('https://api.worldbank.org/v2/sources/46/indicators?format=json') # annual til 2014
SustainableDevelopmentGoals <- list()
for(i in SustainableDevelopmentGoalsIndicators[[2]]$id){
  print(paste('I start now with... ',i))
  zw <- fromJSON(paste0('http://api.worldbank.org/countries/all/indicators/',i,'/?format=json&date=1960:2017&per_page=20000'))  
  zw <- jsonlite::flatten(zw[[2]])
  SustainableDevelopmentGoals[[i]] <- zw
  #write.csv(jsonlite::flatten(SustainableDevelopmentGoals[[i]][[2]]),file = paste0('SustainableDevelopmentGoals_',i,'.csv'))
}
SustainableDevelopmentGoalsLonglist <- bind_rows(SustainableDevelopmentGoals)
write.csv(SustainableDevelopmentGoalsLonglist,file = 'SustainableDevelopmentGoals_LL.csv')

WealthAccountingIndicators <- fromJSON('https://api.worldbank.org/v2/sources/59/indicators?format=json')   # every 5 years only
WealthAccounting <- list()
for(i in WealthAccountingIndicators[[2]]$id){
  print(paste('I start now with... ',i))
  zw <- fromJSON(paste0('http://api.worldbank.org/countries/all/indicators/',i,'/?format=json&date=1960:2017&per_page=20000'))  
  zw <- jsonlite::flatten(zw[[2]])
  WealthAccounting[[i]]  <- zw
  #write.csv(jsonlite::flatten(WealthAccounting[[i]][[2]]),file = paste0('WealthAccounting_',i,'.csv'))
}
WealthAccountingLonglist <- bind_rows(WealthAccounting)
write.csv(WealthAccountingLonglist,file = 'WealthAccounting_LL.csv')



GlobalEconomicMonitorIndicators <- fromJSON('http://api.worldbank.org/v2/indicators?format=json&per_page=20000')
GlobalEconomicMonitor <- list()
for(i in GlobalEconomicMonitorIndicators[[2]]$id){
  print(paste('I start now with... ',i))
  zw <- fromJSON(paste0('http://api.worldbank.org/countries/all/indicators/',i,'/?format=json&date=1960:2017&per_page=20000'))  
  zw <- jsonlite::flatten(zw[[2]])
  GlobalEconomicMonitor[[i]]  <- zw
 # write.csv(jsonlite::flatten(GlobalEconomicMonitor[[i]][[2]]),file = paste0('GlobalEconomicMonitor_',i,'.csv'))
}
GlobalEconomicMonitorLonglist <- bind_rows(GlobalEconomicMonitor)
write.csv(GlobalEconomicMonitorLonglist,file = 'GlobalEconomicMonitor_LL.csv')


