library(dplyr)

###### Load the data
setwd('~/Documents/Domains/datathon/DataSources/')
load('civil_society_selected.Rdata')
load('civil_society_full.Rdata')
load('world_bank_data_big_selected_selected.Rdata')
countries_regions <- read.csv('country_regions.csv',sep = ';')

###### Convert year from character to number
civil_society_big_selected$year <- as.numeric(civil_society_big_selected$year)

########### Unify some country names for civil society and worldbank
countries_left <- NULL
civil_society_big_selected$country[civil_society_big_selected$country == "Côte D'Ivoire"] <- "Cote d'Ivoire"
civil_society_big_selected$country[civil_society_big_selected$country == "Côte d'Ivoire"] <- "Cote d'Ivoire"
civil_society_big_selected$country[civil_society_big_selected$country == "Ivory Coast"] <- "Cote d'Ivoire"
civil_society_big_selected$country[civil_society_big_selected$country == "Saint Vincent and The Grenadines"] <- "Saint Vincent and the Grenadines"
civil_society_big_selected$country[civil_society_big_selected$country == "Korea"] <- "North Korea"
civil_society_big_selected$country[civil_society_big_selected$country == "Lao People's Dem. Republic"] <- "Laos"
civil_society_big_selected$country[civil_society_big_selected$country ==  "Micronesia, Federated States of" ] <-  "Micronesia"
civil_society_big_selected$country[civil_society_big_selected$country ==  "Burma/Myanmar" ] <-  "Myanmar"
civil_society_big_selected$country[civil_society_big_selected$country ==  "Republic of Vietnam" ] <-  "Vietnam"
civil_society_big_selected$country[civil_society_big_selected$country ==  "Virgin Islands, British" ] <-  "British Virgin Islands"
civil_society_big_selected$country[civil_society_big_selected$country ==  "Yugoslavia, SFR (1943-1992)" ] <-  "Yugoslavia"
countries_left$name <- unique(civil_society_big_selected$country[which(!civil_society_big_selected$country %in% countries_regions$country)])

civil_society_big$country[civil_society_big$country == "Côte D'Ivoire"] <- "Cote d'Ivoire"
civil_society_big$country[civil_society_big$country == "Côte d'Ivoire"] <- "Cote d'Ivoire"
civil_society_big$country[civil_society_big$country == "Ivory Coast"] <- "Cote d'Ivoire"
civil_society_big$country[civil_society_big$country == "Saint Vincent and The Grenadines"] <- "Saint Vincent and the Grenadines"
civil_society_big$country[civil_society_big$country == "Korea"] <- "North Korea"
civil_society_big$country[civil_society_big$country == "Lao People's Dem. Republic"] <- "Laos"
civil_society_big$country[civil_society_big$country ==  "Micronesia, Federated States of" ] <-  "Micronesia"
civil_society_big$country[civil_society_big$country ==  "Burma/Myanmar" ] <-  "Myanmar"
civil_society_big$country[civil_society_big$country ==  "Republic of Vietnam" ] <-  "Vietnam"
civil_society_big$country[civil_society_big$country ==  "Virgin Islands, British" ] <-  "British Virgin Islands"
civil_society_big$country[civil_society_big$country ==  "Yugoslavia, SFR (1943-1992)" ] <-  "Yugoslavia"
countries_left$name <- unique(civil_society_big$country[which(!civil_society_big$country %in% countries_regions$country)])


world_bank_data_big_selected$country[world_bank_data_big_selected$country == "Germany, Fed. Rep. (former)" ] <- "Germany"
world_bank_data_big_selected$country[world_bank_data_big_selected$country == "French Guyana" ] <- "French Guiana"
world_bank_data_big_selected$country[world_bank_data_big_selected$country ==  "Hong Kong, China" ] <- "Hong Kong"
world_bank_data_big_selected$country[world_bank_data_big_selected$country ==  "Ivory Coast" ] <-  "Cote d'Ivoire"
world_bank_data_big_selected$country[world_bank_data_big_selected$country ==  "Macau" ] <-  "Macao"
world_bank_data_big_selected$country[world_bank_data_big_selected$country ==  "Micronesia, Federated States of" ] <-  "Micronesia"
world_bank_data_big_selected$country[world_bank_data_big_selected$country ==  "Saint Pierre et Miquelon" ] <-  "Saint Pierre and Miquelon"
world_bank_data_big_selected$country[world_bank_data_big_selected$country ==  "Saint Vincent and The Grenadines" ] <-  "Saint Vincent and the Grenadines"
world_bank_data_big_selected$country[world_bank_data_big_selected$country ==  "St. Helena" ] <-  "Saint Helena, Ascension and Tristan da Cunha"
world_bank_data_big_selected$country[world_bank_data_big_selected$country ==  "St. Martin (French part)" ] <-  "Saint Martin (French part)" 
countries_left$name_wb <- unique(world_bank_data_big_selected$country[which(!world_bank_data_big_selected$country %in% countries_regions$country)])

countries_regions <- countries_regions[,c('name','region','sub.region','intermediate.region')]
colnames(countries_regions)[1] <- 'country'



world_bank_data_big$country[world_bank_data_big$country == "Germany, Fed. Rep. (former)" ] <- "Germany"
world_bank_data_big$country[world_bank_data_big$country == "French Guyana" ] <- "French Guiana"
world_bank_data_big$country[world_bank_data_big$country ==  "Hong Kong, China" ] <- "Hong Kong"
world_bank_data_big$country[world_bank_data_big$country ==  "Ivory Coast" ] <-  "Cote d'Ivoire"
world_bank_data_big$country[world_bank_data_big$country ==  "Macau" ] <-  "Macao"
world_bank_data_big$country[world_bank_data_big$country ==  "Micronesia, Federated States of" ] <-  "Micronesia"
world_bank_data_big$country[world_bank_data_big$country ==  "Saint Pierre et Miquelon" ] <-  "Saint Pierre and Miquelon"
world_bank_data_big$country[world_bank_data_big$country ==  "Saint Vincent and The Grenadines" ] <-  "Saint Vincent and the Grenadines"
world_bank_data_big$country[world_bank_data_big$country ==  "St. Helena" ] <-  "Saint Helena, Ascension and Tristan da Cunha"
world_bank_data_big$country[world_bank_data_big$country ==  "St. Martin (French part)" ] <-  "Saint Martin (French part)" 
countries_left$name_wb <- unique(world_bank_data_big$country[which(!world_bank_data_big$country %in% countries_regions$country)])

countries_regions <- countries_regions[,c('name','region','sub.region','intermediate.region')]
colnames(countries_regions)[1] <- 'country'


######### Join the data
civil_society_big_selected <- left_join(civil_society_big_selected, countries_regions)
civil_society_big <- left_join(civil_society_big, countries_regions)
world_bank_data_big_selected <- left_join(world_bank_data_big_selected, countries_regions)
world_bank_data_big <- left_join(world_bank_data_big, countries_regions)


save(civil_society_big_selected,file = 'civil_society_big_selected_SK.Rdata')
save(civil_society_big,file = 'civil_society_big_SK.Rdata')
save(world_bank_data_big_selected,file = 'world_bank_data_big_selected_SK.Rdata')
save(world_bank_data_big,file = 'world_bank_data_big_SK.Rdata')


