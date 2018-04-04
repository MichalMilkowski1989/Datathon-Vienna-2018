### Load data

local_path = "/Users/mm186159/OneDrive - Teradata/Datathon/group3"

load(paste0(local_path,"/WorldBank/world_bank_data.Rdata"))
load(paste0(local_path,"/WorldBank/world_bank_data_without_padding.Rdata"))
load(paste0(local_path,"/civil_society.Rdata"))
load(paste0(local_path,"/civil_society_without_padding.Rdata"))

load(paste0(local_path,"/WorldBank/world_bank_metadata.Rdata"))

# libraries

library(dplyr)

dim(world_bank_data_big)
#[1] 16974  1374
dim(civil_society_big)
#[1] 15042  3834

#################################################################
#
#   The plan for cleaning
#   1. prepare metadata
#   2. get rid of variables with too many missing values
#   3. delete unnecessary columns
#
#
################################################################

CEE_countries <- c('Albania',
                   'Bosnia and Herzegovina',
                   'Bulgaria',
                   'Czech Republic',
                   'Croatia',
                   'Hungary',
                   'Kosovo',
                   'Macedonia',
                   'Montenegro',
                   'Serbia and Montenegro',
                   'Montenegro',
                   'Moldova',
                   'Poland',
                   'Romania',
                   'Slovakia',
                   'Czechoslovakia',
                   'Slovenia',
                   'Serbia',
                   'Austria'
)


###############################################
##
##
##                1. Time period
##
##
###############################################

### Select the time period

###################
# World Bank Data
###################

# 1.1. how many missing values per year
world_bank_NA_per_country_year <- data.frame(country = world_bank_data_big$country,
                                             year = world_bank_data_big$year,
                                             missings_row = apply(world_bank_data_big,1,function(x) sum(is.na(x))))

world_bank_NA_per_year <- world_bank_NA_per_country_year %>% group_by(year) %>% 
                                summarise(avg_missing_cols = mean(missings_row))

CEE_world_bank_NA_per_year <- world_bank_NA_per_country_year %>% filter(country %in% CEE_countries) %>% 
  group_by(year) %>% summarise(avg_missing_cols = mean(missings_row))

###################
# Civil Society
###################

# 1.1. how many missing values per year
civil_society_NA_per_country_year <- data.frame(country = civil_society_big$country,
                                             year = civil_society_big$year,
                                             missings_row = apply(civil_society_big,1,function(x) sum(is.na(x))))

civil_society_NA_per_year <- civil_society_NA_per_country_year %>% group_by(year) %>% 
                      summarise(avg_missing_cols = mean(missings_row))

CEE_civil_society_NA_per_year <- civil_society_NA_per_country_year %>% filter(country %in% CEE_countries) %>% 
  group_by(year) %>% summarise(avg_missing_cols = mean(missings_row))


#############
# DECISION:
#
# 1990-2017
############

world_bank_data <- world_bank_data %>% filter(year>=1990,year<=2017) 
world_bank_data_big <- world_bank_data_big %>% filter(year>=1990,year<=2017) 
civil_society <- civil_society %>% filter(year>=1990,year<=2017) 
civil_society_big <- civil_society_big %>% filter(year>=1990,year<=2017) 


###############################################
##
##
##                Countries covered
##
##
###############################################

###################
# World Bank
###################

# get rid of variables with low level of country coverage

# count number of countries with nonmissing values per variable
world_bank_nonmissing_countries <- world_bank_data_big %>% group_by(country) %>% 
  summarise_all(.funs= function(x) sum(!is.na(x))) %>% 
  mutate_all(.funs=function(x) ifelse(x>0,1,0)) %>% 
  summarise_all(.funs=sum)

library(tidyr)
# transpose
world_bank_nonmissing_countries <- world_bank_nonmissing_countries %>% 
                                                        gather(key = "variable",
                                                                value ="Number_nonMissing_countries")

####################################################                                                                     
######### Let's do the same with CEE
# count number of countries with nonmissing values per variable
CEE_world_bank_nonmissing_countries <- world_bank_data_big %>% 
  filter(country %in% CEE_countries) %>% 
  group_by(country) %>% 
  summarise_all(.funs= function(x) sum(!is.na(x))) %>% 
  mutate_all(.funs=function(x) ifelse(x>0,1,0)) %>% 
  summarise_all(.funs=sum)

# transpose
CEE_world_bank_nonmissing_countries <- CEE_world_bank_nonmissing_countries %>% 
                                      gather(key = "variable",
                                             value="Number_nonMissing_countries")

######################
### Print what is the relation between the minimum number of countries and the number of variables

# CEE only
summary(CEE_world_bank_nonmissing_countries)
for (i in 0:18){
  print(paste0("Number of variables with at least ",i," CEE countries is: ",
               nrow(CEE_world_bank_nonmissing_countries %>% 
                      filter(Number_nonMissing_countries>=i))
               )
        )  
}


# Whole world
summary(world_bank_nonmissing_countries)
for (i in (0:20)*10){
  print(paste0("Number of variables with at least ",i," countries is: ",
               nrow(world_bank_nonmissing_countries %>% 
                      filter(Number_nonMissing_countries>=i))
    )
  )  
}


###################
# Civil Society
###################

# get rid of variables with low level of country coverage

# count number of countries with nonmissing values per variable
civil_society_nonmissing_countries <- civil_society_big %>% group_by(country) %>% 
  summarise_all(.funs= function(x) sum(!is.na(x))) %>% 
  mutate_all(.funs=function(x) ifelse(x>0,1,0)) %>% 
  summarise_all(.funs=sum)

# transpose
civil_society_nonmissing_countries <- civil_society_nonmissing_countries %>% 
  gather(key = "variable",
         value="Number_nonMissing_countries")

####################################################                                                                     
######### Let's do the same with CEE
# count number of countries with nonmissing values per variable
CEE_civil_society_nonmissing_countries <- civil_society_big %>% 
  filter(country %in% CEE_countries) %>% 
  group_by(country) %>% 
  summarise_all(.funs= function(x) sum(!is.na(x))) %>% 
  mutate_all(.funs=function(x) ifelse(x>0,1,0)) %>% 
  summarise_all(.funs=sum)

# transpose
CEE_civil_society_nonmissing_countries <- CEE_civil_society_nonmissing_countries %>% 
  gather(key = "variable",
         value="Number_nonMissing_countries")

######################
### Print what is the relation between the minimum number of countries and the number of variables

# CEE only
summary(CEE_civil_society_nonmissing_countries)
for (i in 0:18){
  print(paste0("Number of civil society variables with at least ",i," CEE countries is: ",
               nrow(CEE_civil_society_nonmissing_countries %>% 
                      filter(Number_nonMissing_countries>=i))
  )
  )  
}


# Whole world
summary(civil_society_nonmissing_countries)
for (i in (0:20)*10){
  print(paste0("Number of civil society variables with at least ",i," countries is: ",
               nrow(civil_society_nonmissing_countries %>% 
                      filter(Number_nonMissing_countries>=i))
  )
  )  
}


#######################################
# DECISION:
#
# Variables with:
#  at least 10 CEE
#  at least 100 countries in general
# for world bank
#
#  at least 10 CEE
#  at least 80 countries in general
#   for civil society
######################################

###################
# World Bank
###################

wb_vars100 <- world_bank_nonmissing_countries %>% filter(Number_nonMissing_countries>=100) %>% 
  select(variable)
wb_vars10 <- CEE_world_bank_nonmissing_countries %>% filter(Number_nonMissing_countries>=10) %>% 
  select(variable)
wb_vars <- intersect(wb_vars100[[1]],wb_vars10[[1]])
wb_vars_idx <- which(colnames(world_bank_data_big) %in% wb_vars)

world_bank_data <- world_bank_data %>% select(wb_vars_idx)
world_bank_data_big <- world_bank_data_big %>% select(wb_vars_idx)


###################
# Civil Society
###################

cs_vars80 <- civil_society_nonmissing_countries %>% filter(Number_nonMissing_countries>=80) %>% 
                                select(variable)
cs_vars10 <- CEE_civil_society_nonmissing_countries %>% filter(Number_nonMissing_countries>=10) %>% 
  select(variable)
cs_vars <- intersect(cs_vars80[[1]],cs_vars10[[1]])
cs_vars_idx <- which(colnames(civil_society_big) %in% cs_vars)

civil_society <- civil_society %>% select(cs_vars_idx)
civil_society_big <- civil_society_big %>% select(cs_vars_idx)


############################################################
##
##
##    3. manual selection of meaningful variables
##
##
############################################################
###################
# World Bank
###################

# write.table(world_bank_metadata %>% filter(variable %in% colnames(world_bank_data_big)),
#                       paste0(local_path,"/world_bank_metadata_selected.csv"),
#             row.names = FALSE)

# Those columns were selected manually in a spreadsheet

wb_vars_chosen <- read.csv2(paste0(local_path,"/world_bank_metadata_selected.csv"),
                            stringsAsFactors = FALSE)
wb_vars_chosen2 <- wb_vars_chosen %>% filter(chosen==1) %>% arrange(database,variable)
str(wb_vars_chosen2)

world_bank_data_selected <- world_bank_data %>% select(c("country","year",wb_vars_chosen2$variable)) %>% arrange(country,year)

world_bank_data_big_selected <- world_bank_data_big %>% select(c("country","year",wb_vars_chosen2$variable)) %>% arrange(country,year)



### Some metadata about variables (dates ranges and number of unique years)

world_bank_data_selected_t <- world_bank_data_selected %>% gather(key = "variable",value = "value",-c(country,year)) %>% 
                                                  filter(!is.na(value)) %>% 
                                                  group_by(variable) %>% 
                                                  summarise(min_year = min(year),
                                                            max_year = max(year),
                                                            num_unique_years = length(unique(year)))


world_bank_selected_vars_metadata <- wb_vars_chosen2 %>% left_join(world_bank_data_selected_t,by = "variable") %>% select(-chosen)


#######################
#     Civil society
#######################
list.files(local_path)
cs_vars_chosen <- read.csv2(paste0(local_path,"/civil_society_metadata.csv"),
                            stringsAsFactors = FALSE)
cs_vars_chosen2 <- cs_vars_chosen %>% filter(chosen==1)
cs_vars_chosen3 <- cs_vars_chosen2 %>% filter(variable %in% names(civil_society))


civil_society_selected <- civil_society %>% select(cs_vars_chosen3$variable) %>% arrange(country,year)

civil_society_big_selected <- civil_society_big %>% select(cs_vars_chosen3$variable) %>% arrange(country,year)

### Some metadata about variables (dates ranges and number of unique years)

civil_society_selected_t <- civil_society_selected %>% gather(key = "variable",value = "value",-c(country,year)) %>% 
  filter(!is.na(value)) %>% 
  group_by(variable) %>% 
  summarise(min_year = min(year),
            max_year = max(year),
            num_unique_years = length(unique(year)))


civil_society_selected_vars_metadata <- cs_vars_chosen3 %>% left_join(civil_society_selected_t,
                                                                      by = "variable") %>% select(-chosen)



###############################
#         SAVE
###############################

save(world_bank_data_selected, 
     file = paste0(local_path,"/WorldBank/world_bank_data_selected_without_padding.Rdata"))

save(world_bank_data_big_selected, 
     file = paste0(local_path,"/WorldBank/world_bank_data_selected.Rdata"))


save(world_bank_selected_vars_metadata, 
     file = paste0(local_path,"/WorldBank/world_bank_selected_vars_metadata.Rdata"))

save(civil_society_selected, 
     file = paste0(local_path,"/civil_society_selected_without_padding.Rdata"))

save(civil_society_big_selected, 
     file = paste0(local_path,"/civil_society_selected.Rdata"))


save(civil_society_selected_vars_metadata, 
     file = paste0(local_path,"/civil_society_selected_vars_metadata.Rdata"))


# Loading

load(paste0(local_path,"/WorldBank/world_bank_data_selected_without_padding.Rdata"))

load(paste0(local_path,"/WorldBank/world_bank_data_selected.Rdata"))

load(paste0(local_path,"/WorldBank/world_bank_selected_vars_metadata.Rdata"))



load(paste0(local_path,"/civil_society_selected_without_padding.Rdata"))

load(paste0(local_path,"/civil_society_selected.Rdata"))

load(paste0(local_path,"/civil_society_selected_vars_metadata.Rdata"))
# Loading

