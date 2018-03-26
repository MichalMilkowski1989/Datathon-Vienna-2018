# The aim of this script is to join all the important metrics downloaded from World Bank into one wide table

library(dplyr)
library(tidyr)
# set proper working directory and load the Rdata files
files <- list.files(pattern = ".Rdata")

for (file in files){
  load(file)
}

# Let's analyse a bit all the data
sets <- setdiff(ls(),c("file","files","files_csv"))

k<-0
for (i in sets){
  k<-k+1
  data <- eval(parse(text=i))
  print("")
  print(k)
  print("!!! Next dataset:")
  print(paste("The name of this data set is ",i))
  print(paste("Number of variables ",nrow(unique(data %>% select(indicator.value)))))
  print(paste("List of variables ",paste(unique(data %>% select(indicator.value))[,1],collapse=",")))
  print(paste("Number of countries ",nrow(unique(data %>% select(country.value)))))
  print(paste("List of countries ",paste(unique(data %>% select(country.value))[,1],collapse=",")))
  print(paste("Number of data points ",nrow(unique(data %>% select(date)))))
  print(paste("List of data points ",paste(unique(data %>% select(date))[,1],collapse=",")))
}

# after a quick look: 
### list of unuseful sets
# - ReadinessforInvestmentinSustainableEnergy_LL - only 17 countries and one year (non-European)
# - LACEquityLab_LL - only Latin and Carribean
# - CountryPartnershipStrategyforIndia_FY2013_17__LL - India-specific
# - CommodityPrices_HistoryandProjections_LL - on the whole world level
# - IndonesiaDatabaseforPolicyandEconomicResearch_LL - Indonesian specific

###
# take a look at this: GlobalPartnershipforEducation_LL -  It might require cleaning

##
# this one G20FinancialInclusionIndicators_LL - only 2011-2015

###
# to take the closer look because it's quarterly. Check if this data is not included in yearly statistics. 
# - QuarterlyExternalDebtStatisticsSDDS_LL
# - QuarterlyExternalDebtStatisticsGDDS_LL
# - QuarterlyPublicSectorDebt_LL
# - JointExternalDebtHub_LL

# SubnationalPopulation presents regional levels only

# This one is only on a 'world' level: GlobalEconomicMonitorCommodities_LL

excluded <- c("ReadinessforInvestmentinSustainableEnergy_LL","LACEquityLab_LL",
              "CountryPartnershipStrategyforIndia_FY2013_17__LL","CommodityPrices_HistoryandProjections_LL",
              "IndonesiaDatabaseforPolicyandEconomicResearch_LL",
              "SubnationalPopulation_LL", "SubnationalMalnutritionDatabase_LL",
              "GlobalEconomicMonitorCommodities_LL")

# exclude dem from list of sets
sets <- setdiff(sets,excluded)

#For the quarterly data select Q4 only as a yearly represatation
QuarterlyExternalDebtStatisticsSDDS_LL <- QuarterlyExternalDebtStatisticsSDDS_LL %>% filter(grepl('Q4',date)) %>% 
                                                    mutate(date = as.numeric(substr(date,1,4)))

QuarterlyExternalDebtStatisticsGDDS_LL <- QuarterlyExternalDebtStatisticsGDDS_LL %>% filter(grepl('Q4',date)) %>% 
  mutate(date = as.numeric(substr(date,1,4)))

QuarterlyPublicSectorDebt_LL <- QuarterlyPublicSectorDebt_LL %>% filter(grepl('Q4',date)) %>% 
  mutate(date = as.numeric(substr(date,1,4)))

JointExternalDebtHub_LL <- JointExternalDebtHub_LL %>% filter(grepl('Q4',date)) %>% 
  mutate(date = as.numeric(substr(date,1,4)))

# GlobalPartnershipforEducation_LL has strange values in date

# Let's get rid of all the targets. Analyse only vaues
GlobalPartnershipforEducation_LL <- GlobalPartnershipforEducation_LL %>% filter(!grepl('target',tolower(date)))%>% 
  mutate(date = as.numeric(substr(date,1,4)))

# TheAtlasofSocialProtection_IndicatorsofResilienceandEquity_LL need unique indicator.id - it has only value "Country context."

TheAtlasofSocialProtection_IndicatorsofResilienceandEquity_LL <- TheAtlasofSocialProtection_IndicatorsofResilienceandEquity_LL %>% 
      mutate(indicator.id = gsub('\\.{2,}','.',gsub('[^a-zA-Z0-9]','.',indicator.value)))


# UniversalHealthCoverage_LL: there are duplicates of values for some dates and countries
### let's choose max

columns_health <- colnames(UniversalHealthCoverage_LL)
UniversalHealthCoverage_LL <- UniversalHealthCoverage_LL %>% unique() %>% 
   mutate(value = as.numeric(value), date = as.numeric(date)) %>% 
   group_by(decimal, indicator.value, date,indicator.id,country.id,country.value) %>% 
   summarise(value = max(value,na.rm=TRUE)) %>% mutate(value = ifelse(value == -Inf,NA,value)) %>% 
    as.data.frame() %>% select(columns_health)


########################################################################
# Even in some data bases names of the countries are still not unique !!!! 
# for different variables countries may have inconsistent names
########################################################################

countries <- list()
k <- 0
for (i in sets){
  k<-k+1
  temp <- eval(parse(text=i))
  print("")
  print(paste(k,"th iteration. Dataset: ",i))
  countries[i] <- temp %>%  select(country.value) %>% distinct()
}

### print countries names containing coma
for (i in names(countries)){
  print("")
  print(i)
  print(countries[[i]][grepl("\\,",countries[[i]])])
}
### print number of different country names
for (i in names(countries)){
  print(i)
  print(length(countries[[i]]))
}



### all the countries
all_countries_wb <- data.frame(country = sort(unique(Reduce(c,countries))))
all_countries_wb$source <- "World Bank"
dim(all_countries_wb)

# Now let's read the data with civil society variables
load(file = "./../civil_society.Rdata")
all_countries_cs <- data.frame(country=unique(civil_society_big$country))
all_countries_cs$source <- "Civil society"


# Let's join it and clean it
all_countries <- rbind(all_countries_wb,all_countries_cs) %>% arrange(country)
all_countries$country <- as.character(all_countries$country)

dim(all_countries_wb)
dim(all_countries_cs)
dim(all_countries)
length(unique(all_countries$country))
str(all_countries)

# prepare list of countries for exclusion
# 1. those with
exclude_countries1<- grep('^\\(',unique(all_countries$country),value = TRUE)
exclude_countries2 <- c('Africa','Arab World',
                        'BES Islands','DAC reporting countries',
                        'Early-demographic dividend',
                        'Europe and Central Asia',
                        'Fragile and conflict affected situations',
                        'French Southern Territories',
                        'Heavily indebted poor countries (HIPC)',
                        'IMF CPIS Countries',
                        'Jersey','Jersey, Channel Islands','Channel Islands',
                        'Least developed countries: UN classification',
                        'Multilateral lending agencies',
                        'North Africa','North America',
                        'Northern America','Oceania',
                        'West Bank and Gaza',
                        'Belgium-Luxembourg',
                        'British Overseas Territories' , 'British Indian Ocean Territory',
                        'Not classified',
                        'Western Asia',
                        'Nothern America'
)

exclude_countries3<- grep('(OECD|Oceania|mall states|World|South.+Asia|dividend| income|IBRD|IDA|Middle East|Sub-Saharan)',
                          unique(all_countries$country),value = TRUE)

exclude_countries4 <- grep('(Bangladesh|Brazil|China|Indonesia|India|Japan|Mexico|Nigeria|United States|Pakistan|Russian Federation) -',
                           unique(all_countries$country),value = TRUE)

exclude_countries5 <- grep('(Central Asia|Latin America|East Asia|Eastern Asia|Europe & Central Asia|Europe and Central Asia)',
                           unique(all_countries$country),value = TRUE)

### prepare a valid list of countries

countries_selected<- setdiff(unique(all_countries$country),
                             c(exclude_countries1,exclude_countries2,exclude_countries3,
                               exclude_countries4,exclude_countries5)
)

#excluded "countries"
unique(c(exclude_countries1,exclude_countries2,exclude_countries3,
         exclude_countries4,exclude_countries5))

all_countries_temp <- all_countries %>% filter(country %in% countries_selected)


# manual correction
all_countries_temp$country_corrected <- ifelse(all_countries_temp$country == 'Taiwan, China',
                                               "Taiwan",all_countries_temp$country)

all_countries_temp$country_corrected <- ifelse(all_countries_temp$country %in%
                                                 c('Macao SAR, China',
                                                   'Macao, China',
                                                   'Macau SAR, China'
                                                 ),
                                               "Macau",all_countries_temp$country_corrected)


all_countries_temp$country_corrected <- ifelse(all_countries_temp$country == 'Hong Kong SAR, China',
                                               "Hong Kong, China",all_countries_temp$country_corrected)

all_countries_temp$country_corrected <- ifelse(all_countries_temp$country == 'Faeroe Islands',
                                               "Faroe Islands",all_countries_temp$country_corrected)

all_countries_temp$country_corrected <- ifelse(all_countries_temp$country == 'Gambia, The',
                                               "Gambia",all_countries_temp$country_corrected)

all_countries_temp$country_corrected <- ifelse(all_countries_temp$country == 'French Guiana',
                                               "French Guyana",all_countries_temp$country_corrected)

all_countries_temp$country_corrected <- ifelse(all_countries_temp$country == 'Falkland Islands (Malvinas)',
                                               "Falkland Islands",all_countries_temp$country_corrected)

all_countries_temp$country_corrected <- ifelse(all_countries_temp$country == 'Russia',
                                               "Russian Federation",all_countries_temp$country_corrected)


all_countries_temp$country_corrected <- ifelse(all_countries_temp$country == 'St. Kitts and Nevis',
                                               "Saint Kitts and Nevis",all_countries_temp$country_corrected)

all_countries_temp$country_corrected <- ifelse(all_countries_temp$country == 'St. Lucia',
                                               "Saint Lucia",all_countries_temp$country_corrected)

all_countries_temp$country_corrected <- ifelse(all_countries_temp$country == 'St. Vincent and the Grenadines',
                                               "Saint Vincent and The Grenadines",all_countries_temp$country_corrected)

all_countries_temp$country_corrected <- ifelse(all_countries_temp$country %in%
                                                 c('Micronesia',
                                                   'Micronesia, Fed. Sts.'
                                                 ),
                                               "Micronesia, Federated States of",all_countries_temp$country_corrected)

all_countries_temp$country_corrected <- ifelse(all_countries_temp$country == 'Slovak Republic',
                                               "Slovakia",all_countries_temp$country_corrected)

all_countries_temp$country_corrected <- ifelse(all_countries_temp$country == 'Venezuela, RB',
                                               "Venezuela",all_countries_temp$country_corrected)

all_countries_temp$country_corrected <- ifelse(all_countries_temp$country == 'Syrian Arab Republic',
                                               "Syria",all_countries_temp$country_corrected)

all_countries_temp$country_corrected <- ifelse(all_countries_temp$country == 'Anguila',
                                               "Anguilla",all_countries_temp$country_corrected)

all_countries_temp$country_corrected <- ifelse(grepl('Principe',all_countries_temp$country)==T,
                                               "Sao Tome and Principe",all_countries_temp$country_corrected)

all_countries_temp$country_corrected <- ifelse(grepl('Cura.{1}ao',all_countries_temp$country)==T,
                                               "Curacao",all_countries_temp$country_corrected)


all_countries_temp$country_corrected <- ifelse(all_countries_temp$country == 'Egypt, Arab Rep.',
                                               "Egypt",all_countries_temp$country_corrected)

all_countries_temp$country_corrected <- ifelse(all_countries_temp$country == 'Iran, Islamic Rep.',
                                               "Iran",all_countries_temp$country_corrected)

all_countries_temp$country_corrected <- ifelse(all_countries_temp$country == 'Macedonia, FYR',
                                               "Macedonia",all_countries_temp$country_corrected)

all_countries_temp$country_corrected <- ifelse(grepl('(Ivoire|Ivory)',all_countries_temp$country),
                                               "Ivory Coast",all_countries_temp$country_corrected)

all_countries_temp$country_corrected <- ifelse(all_countries_temp$country == 'Yemen, Rep.',
                                               "Yemen",all_countries_temp$country_corrected)

all_countries_temp$country_corrected <- ifelse(all_countries_temp$country == 'United States',
                                               "United States of America",all_countries_temp$country_corrected)


all_countries_temp$country_corrected <- ifelse(all_countries_temp$country == 'EURO Area',
                                               "Euro area",all_countries_temp$country_corrected)

all_countries_temp$country_corrected <- ifelse(all_countries_temp$country == 'Cabo Verde',
                                               "Cape Verde",all_countries_temp$country_corrected)

all_countries_temp$country_corrected <- ifelse(all_countries_temp$country == "Guinea-Bissau",
                                               "Guinea Bissau",all_countries_temp$country_corrected)

all_countries_temp$country_corrected <- ifelse(all_countries_temp$country == "Lao PDR",
                                               "Laos",all_countries_temp$country_corrected)


all_countries_temp$country_corrected <- ifelse(all_countries_temp$country %in%
                                                 c('Congo',
                                                   'Congo, Rep.',
                                                   'Republic of The Congo (Brazzaville)',
                                                   'Republic of the Congo'
                                                 ),
                                               "Congo",all_countries_temp$country_corrected)

all_countries_temp$country_corrected <- ifelse(all_countries_temp$country %in%
                                                 c('Congo, DR',
                                                   'Congo, Dem. Rep.',
                                                   'Congo, Democratic Republic of',
                                                   'Congo, The Democratic Republic of',
                                                   'Congo, The Democratic Republic of the',
                                                   'Democratic Republic of Congo',
                                                   'Democratic Republic of the Congo'
                                                 ),
                                               "Democratic Republic of Congo",all_countries_temp$country_corrected)



# South Yemen existed until 1990

all_countries_temp$country_corrected <- ifelse(all_countries_temp$country == "German democratic republic",
                                               "German Democratic Republic",all_countries_temp$country_corrected)


all_countries_temp$country_corrected <- ifelse(grepl('Korea, D',all_countries_temp$country),
                                               "North Korea",all_countries_temp$country_corrected)

all_countries_temp$country_corrected <- ifelse(all_countries_temp$country %in%
                                                 c('South Korea',
                                                   "Korea, Rep."
                                                 ),
                                               "South Korea",all_countries_temp$country_corrected)

all_countries_temp$country_corrected <- ifelse(all_countries_temp$country == "Bahamas, The",
                                               "Bahamas",all_countries_temp$country_corrected)

all_countries_temp$country_corrected <- ifelse(all_countries_temp$country == "Kyrgyz Republic",
                                               "Kyrgyzstan", all_countries_temp$country_corrected)


# 1. prepare countries
### dictionary
countries_dict <- unique(all_countries_temp %>% 
                           filter(source=='World Bank') %>% 
                           select(country,country_corrected)
)
str(countries_dict)


####################################################################################
#       reshape the data
####################################################################################



# Next step is to reshape the data
k<-0
for (i in sets){
  k<-k+1
  temp <- eval(parse(text=i))
  print("")
  print(paste(k,"th iteration. Dataset: ",i))
  temp <- unique(inner_join(countries_dict,temp, by = c('country'='country.value')) %>% 
                    select(-country.id, -country) %>% rename(country = country_corrected))
  #reshaping part with tidyr
  temp <- temp %>%  select(-decimal, -indicator.value) %>% unique() %>% 
    mutate(value = as.numeric(value), date = as.numeric(date)) %>% 
    spread(key = indicator.id, value = "value")
  # saving_with_proper_name
  text = paste0(gsub('_LL','',i),"_wide <- temp")
  eval(parse(text=text))
}

#############################################################################
#
# Let's join the data
#
############################################################################

# 1. prepare countries
### dictionary was prepared previously

# 2. prepare the vector of years
years <- 1950:2018

# 3. Now the cross join of dates and countries

df_country_year <- merge(x = years, y = sort(unique(countries_dict$country_corrected)))
names(df_country_year) <- c("year","country")
df_country_year$country <- as.character(df_country_year$country)
head(df_country_year)

# let's copy it to the final world bank data.frame

world_bank_data_temp <- df_country_year
dim(world_bank_data_temp)

# 4. let's join data.frames with dictionaries of countries

reshaped_sets <- ls(pattern = '_wide')

for (i in reshaped_sets){
  # first add year with name of the dataset 
  text = paste0(i,"[,'",sub("_wide","_year",i),"'] <- ",i,"$date")
   
  eval(parse(text=text))
  
  # join 
  text2 <- paste0("world_bank_data_temp <- unique(left_join(world_bank_data_temp,",i,
                                                           ",
                                                           by=c('year'='date','country'='country'),
                                                            suffix = c('',paste0('__',sub('_wide','',i)))))"
                  )
  eval(parse(text=text2))
  # print dimension
  print(paste0("dimensions after joining table: ",i," is ",paste(dim(world_bank_data_temp),collapse = ",")))
}
 
# Let's check uniqueness of country and year pairs

for (i in reshaped_sets){
  data <- eval(parse(text=i))
  print("")
  print(i)
  print(data %>% group_by(country,date) %>% summarise(N= n()) %>% filter(N>1))
}


# 5. Last observation carried forward!!
library(zoo)
world_bank_data <- world_bank_data_temp %>% arrange(country,year)

### But last observation should be carried forward only within the same country!!
### I will use parallelisation for that

library(doParallel)

registerDoParallel(cores=(detectCores()-2) )
print(paste0("number of workers is: ", getDoParWorkers()))
print(paste0("The name of the parallelisation: ", getDoParName()))
print(paste0("The version of the parallelisation: ", getDoParVersion()))

world_bank_data_big <- foreach(i=unique(world_bank_data$country), .combine=rbind) %dopar% {
  cs <- na.locf(world_bank_data[world_bank_data$country == i,])
}

# save data

### without padding
save(world_bank_data, file = "./world_bank_data_without_padding.Rdata")

### after padding
save(world_bank_data_big, file = "./world_bank_data.Rdata")



#############################################
###         metadata
#############################################
variables <- list()

k <- 0
for (i in sets){
  k<-k+1
  temp <- eval(parse(text=i))
  print("")
  print(paste(k,"th iteration. Dataset: ",i))
  variables[[i]] <- as.data.frame(temp %>%  
                               select(indicator.id,indicator.value) %>% 
                               distinct()
                            )
}

metadata <- bind_rows(variables, .id = "database")
metadata$database <- sub("_LL","",metadata$database)

### because some variables are duplicated in different databases, the second occurence
#  is named with database name as suffix
metadata <- metadata %>% mutate(column = paste0(indicator.id,"__",database))

##### select proper column names
columns_world_bank <- names(world_bank_data)
# delete all the columns with countries and years
year_columns <- grep('_year',columns_world_bank,value = TRUE)
columns_world_bank <- setdiff(columns_world_bank,c("country","year",year_columns))

length(columns_world_bank)

### check if the value is named as it is or with database suffix
metadata$is.simple <- ifelse(metadata$indicator.id %in% columns_world_bank,1,0)
metadata$is.database.name <- ifelse(metadata$column %in% columns_world_bank,1,0)

metadata$variable <- ifelse(metadata$is.database.name == 1, metadata$column, metadata$indicator.id)
world_bank_metadata <- metadata %>% filter(is.simple == 1) %>% rename(variable_description = indicator.value) %>% 
                                select(variable, database, variable_description)


# check
setdiff(columns_world_bank,
        world_bank_metadata$variable)

setdiff(world_bank_metadata$variable,columns_world_bank)

length(columns_world_bank) == dim(world_bank_metadata)[1]

# save metadata

save(world_bank_metadata, file = "./world_bank_metadata.Rdata")