### This script is used for data preparation of civil society indices provided by several organisations
# it's main purpose is to prepar ethe challenge "Open government Data"
# for the Datathon in Vienna

library(dplyr)

########################################################################################
#
# World Value Survey
### http://www.worldvaluessurvey.org/WVSDocumentationWV6.jsp
########################################################################################

list.files()
# Where is the file?
file_long <- "./group 3 limited use/world values survey/WVS_Longitudinal_1981_2014_R_v2015_04_18.rdata"
country_dict <- "./group 3 limited use/world values survey/country_dictionary.csv"

load(file_long)
country_dictionary <- read.csv2(country_dict)
names(country_dictionary)<-c("Country_code","Country")

####################################
# Selection of important columns
###################################

#######################
# Longitudinal data
#######
### S002: Wave
# S003: The country
# S009: The country code (alphanumeric)
# S025: The country and year
# S017: The original weight
# S019: The original weight equilibrated to an homogeneous N of 1500 for each country
#
### X001	Sex
# X002	Year of birth
# x002_01	Having [countrys] nationality
# x002_01a	Respondents nationality - ISO 3166-1 code
# x002_02	Respondent born in [country]
# x002_02a	Respondents country of birth - ISO 3166-1 code
# x002_03	Year in which respondent came to live in [country]
# X003	Age
# X003R	Age recoded
# X003R2	Age recoded (3 intervals)
#
# # 
# A001	Important in life: Family
# A001_CO	Family important
# A002	Important in life: Friends
# A002_CO	Friends important
# A003	Important in life: Leisure time
# A003_CO	Leisure time
# A004	Important in life: Politics
# A004_CO	Politics important
# A005	Important in life: Work
# A005_CO	Work important
# A006	Important in life: Religion
# A006_CO	Religion important
# A007	Service to others important in life
# A008	Feeling of happiness
# A009	State of health (subjective)
# 
# A098	Active/Inactive membership of church or religious organization
# A099	Active/Inactive membership of sport or recreation
# A100	Active/Inactive membership of art, music, educational
# A101	Active/Inactive membership of labour unions
# A102	Active/Inactive membership of political party
# A103	Active/Inactive membership of environmental organization
# A104	Active/Inactive membership of professional organization
# A105	Active/Inactive membership of charitable/humanitarian organization
# A106	Active/Inactive membership of any other organization
# A106B	Active/Inactive membership: Consumer organization
# A106C	Active/Inactive membership: Self-help group, mutual aid group
#
#
# E001	Aims of country: first choice
# E001_HK	Aims of country: first choice (HK)
# E002	Aims of country: second choice
# E002_HK	Aims of country: second choice (HK)
# E003	Aims of respondent: first choice
# e003_f	Flag variable: aims of this country - most/second important
# E004	Aims of respondent: second choice
# E005	Most important: first choice
# E005_HK	Most important: second choice (HK)
# E006	Most important: second choice
# E006_HK	Most important: first choice (HK)
#
# E023	Interest in politics
# E024	Interest in politics (ii)
# E025	Political action: signing a petition
# E025B	Political action recently done: signing a petition
# E026	Political action: joining in boycotts
# E026B	Political action recently done: joining in boycotts
# E027	Political action: attending lawful/peaceful demonstrations
# E028	Political action: joining unofficial strikes
# E028B	Political acition recently done: Joining strikes
# E029	Political action: occupying buildings or factories
# E030	Political action: damaging things, breaking windows, street violence
# E031	Political action: personal violence
######################


# Longitudinal Data
long_vars <- c("S002","S003","S009","S025","S017","S019", "X001","X002","X003","X003R","X003R2",
               "A001","A001_CO","A002","A002_CO","A003","A003_CO","A004","A004_CO","A005","A005_CO",
               "A006","A006_CO","A007","A008","A009",
               "A098","A099","A100","A101","A102","A103","A104","A105","A106","A106B","A106C",
               "E001","E002","E003","E004","E005","E006",
               "E023","E025","E025B","E026","E026B",
               "E027","E028","E028B","E029","E030","E031")


long_data_temp <- WVS_Longitudinal_1981_2014_R_v2015_04_18[,long_vars]

class(long_data_temp)

########################
# Data preparation
########################

long_data_converted <- long_data_temp %>% 
  rename(Country_code = S003,
         Wave = S002,
         Gender = X001,
         Country_abb = S009,
         Age = X003, Age_recoded = X003R, Age_recoded2 = X003R2,
         church_member = A098,
         sport_member = A099,
         artmusicedu_member = A100,
         laborunion_member = A101,
         political_member = A102,
         environmental_member = A103,
         professional_member = A104,
         charity_member = A105,
         other_member = A106,
         consumer_member = A106B,
         help_group_member = A106C,
         weight = S017,
         weight_equi1500 = S019
  ) %>% left_join(country_dictionary,by="Country_code") %>% 
  mutate(Wave_desc = case_when(Wave==1~"1981-1984",
                               Wave==2~"1989-1993",
                               Wave==3~"1994-1998",
                               Wave==4~"1999-2004",
                               Wave==5~"2005-2009",
                               Wave==6~"2010-2014",
                               TRUE ~ "N/A"),
         Wave_end_year = case_when(Wave==1~1984,
                               Wave==2~1993,
                               Wave==3~1998,
                               Wave==4~2004,
                               Wave==5~2009,
                               Wave==6~2014),
         year = as.numeric(substr(as.character(S025), 4, 7)),
         Gender_desc = case_when(Gender==1~"Male",
                                 Gender==2~"Female",
                                 TRUE ~ "N/A"),
         Age_recoded_desc = case_when(Age_recoded==1~"15-24",
                                      Age_recoded==2~"25-34",
                                      Age_recoded==3~"35-44",
                                      Age_recoded==4~"45-54",
                                      Age_recoded==5~"55-64",
                                      Age_recoded==6~"65+",
                                      TRUE ~ "N/A"),
         Age_recoded2_desc = case_when(Age_recoded2==1~"15-29",
                                      Age_recoded2==2~"30-49",
                                      Age_recoded2==3~"50+",
                                      TRUE ~ "N/A"),
         church_member_desc = case_when(church_member==0~"Not a member",
                                            church_member==1~"Inactive",
                                            church_member==2~"Active",
                                            TRUE ~ "N/A"),
         sport_member_desc = case_when(sport_member==0~"Not a member",
                                        sport_member==1~"Inactive",
                                        sport_member==2~"Active",
                                        TRUE ~ "N/A"),
         artmusicedu_member_desc = case_when(artmusicedu_member==0~"Not a member",
                                             artmusicedu_member==1~"Inactive",
                                             artmusicedu_member==2~"Active",
                                             TRUE ~ "N/A"),
         laborunion_member_desc = case_when(laborunion_member==0~"Not a member",
                                            laborunion_member==1~"Inactive",
                                            laborunion_member==2~"Active",
                                             TRUE ~ "N/A"),
         political_member_desc = case_when(political_member==0~"Not a member",
                                           political_member==1~"Inactive",
                                           political_member==2~"Active",
                                            TRUE ~ "N/A"),
         environmental_member_desc = case_when(environmental_member==0~"Not a member",
                                               environmental_member==1~"Inactive",
                                               environmental_member==2~"Active",
                                            TRUE ~ "N/A"),
         professional_member_desc = case_when(professional_member==0~"Not a member",
                                              professional_member==1~"Inactive",
                                              professional_member==2~"Active",
                                            TRUE ~ "N/A"),
         charity_member_desc = case_when(charity_member==0~"Not a member",
                                         charity_member==1~"Inactive",
                                         charity_member==2~"Active",
                                            TRUE ~ "N/A"),
         other_member_desc = case_when(other_member==0~"Not a member",
                                            other_member==1~"Inactive",
                                            other_member==2~"Active",
                                            TRUE ~ "N/A"),
         consumer_member_desc = case_when(consumer_member==0~"Not a member",
                                          consumer_member==1~"Inactive",
                                          consumer_member==2~"Active",
                                       TRUE ~ "N/A"),
         help_group_member_desc = case_when(help_group_member==0~"Not a member",
                                            help_group_member==1~"Inactive",
                                            help_group_member==2~"Active",
                                       TRUE ~ "N/A")
         
         
  ) %>% 
  mutate(any_member_desc = ifelse(church_member_desc == 'Active' | 
                                  sport_member_desc == 'Active' | 
                                  artmusicedu_member_desc == 'Active' | 
                                  laborunion_member_desc == 'Active' | 
                                  political_member_desc == 'Active' | 
                                  environmental_member_desc == 'Active' | 
                                  professional_member_desc == 'Active' | 
                                  charity_member_desc == 'Active' | 
                                  other_member_desc == 'Active' | 
                                  consumer_member_desc == 'Active' | 
                                  help_group_member_desc == 'Active',
                                  'Active',
                                    ifelse(church_member_desc == 'Inactive' | 
                                           sport_member_desc == 'Inactive' | 
                                           artmusicedu_member_desc == 'Inactive' | 
                                           laborunion_member_desc == 'Inactive' | 
                                           political_member_desc == 'Inactive' | 
                                           environmental_member_desc == 'Inactive' | 
                                           professional_member_desc == 'Inactive' | 
                                           charity_member_desc == 'Inactive' | 
                                           other_member_desc == 'Inactive' | 
                                           consumer_member_desc == 'Inactive' | 
                                           help_group_member_desc == 'Inactive',
                                          'Inactive',
                                           ifelse(church_member_desc == 'Not a member' | 
                                                  sport_member_desc == 'Not a member' | 
                                                  artmusicedu_member_desc == 'Not a member' | 
                                                  laborunion_member_desc == 'Not a member' | 
                                                  political_member_desc == 'Not a member' | 
                                                  environmental_member_desc == 'Not a member' | 
                                                  professional_member_desc == 'Not a member' | 
                                                  charity_member_desc == 'Not a member' | 
                                                  other_member_desc == 'Not a member' | 
                                                  consumer_member_desc == 'Not a member' | 
                                                  help_group_member_desc == 'Not a member',
                                                'Not a member','N/A')
                                           )
                                  
                                  )
  ) %>% 
  select(Country_code,Country,Country_abb,
         Wave, Wave_desc,Wave_end_year,year,
         Gender, Gender_desc,
         Age,Age_recoded,Age_recoded_desc,Age_recoded2,Age_recoded2_desc,
         church_member,church_member_desc,
         sport_member,sport_member_desc,
         artmusicedu_member,artmusicedu_member_desc,
         laborunion_member,laborunion_member_desc,
         political_member,political_member_desc,
         environmental_member,environmental_member_desc,
         professional_member,professional_member_desc,
         charity_member,charity_member_desc,
         other_member,other_member_desc,
         consumer_member,consumer_member_desc,
         help_group_member,help_group_member_desc,
         any_member_desc,
         weight, weight_equi1500
         )


class(long_data_converted)
# convert country to character for the purpose of better joining

long_data_converted$Country <- as.character(long_data_converted$Country)

############################################################
# Aggregations
#
#
# LET'S SET A THRESHOLD OF 100 respondents!!!
#
#
#
###########################################################

### if you are not familiar with summarisations, THis should be very helpful:
##### https://www.r-bloggers.com/aggregation-with-dplyr-summarise-and-summarise_each/

WVS_aggregates <- long_data_converted %>% 
  group_by(Country,Country_code,Country_abb,
           Wave,Wave_desc,Wave_end_year) %>% 
  summarise(
  active_church_weight = sum(ifelse(church_member_desc=='Active',weight,0)),
    inactive_church_weight = sum(ifelse(church_member_desc=='Inactive',weight,0)),
    responded_church_weight = sum(ifelse(church_member_desc!='N/A',weight,0)),
    responded_church_N = sum(ifelse(church_member_desc!='N/A',1,0)),
  active_sport_weight = sum(ifelse(sport_member_desc=='Active',weight,0)),
    inactive_sport_weight = sum(ifelse(sport_member_desc=='Inactive',weight,0)),
    responded_sport_weight = sum(ifelse(sport_member_desc!='N/A',weight,0)),
    responded_sport_N = sum(ifelse(sport_member_desc!='N/A',1,0)),
  active_artmusicedu_weight = sum(ifelse(artmusicedu_member_desc=='Active',weight,0)),
    inactive_artmusicedu_weight = sum(ifelse(artmusicedu_member_desc=='Inactive',weight,0)),
    responded_artmusicedu_weight = sum(ifelse(artmusicedu_member_desc!='N/A',weight,0)),
    responded_artmusicedu_N = sum(ifelse(artmusicedu_member_desc!='N/A',1,0)),
  active_laborunion_weight = sum(ifelse(laborunion_member_desc=='Active',weight,0)),
    inactive_laborunion_weight = sum(ifelse(laborunion_member_desc=='Inactive',weight,0)),
    responded_laborunion_weight = sum(ifelse(laborunion_member_desc!='N/A',weight,0)),
    responded_laborunion_N = sum(ifelse(laborunion_member_desc!='N/A',1,0)),
  active_political_weight = sum(ifelse(political_member_desc=='Active',weight,0)),
    inactive_political_weight = sum(ifelse(political_member_desc=='Inactive',weight,0)),
    responded_political_weight = sum(ifelse(political_member_desc!='N/A',weight,0)),
    responded_political_N = sum(ifelse(political_member_desc!='N/A',1,0)),
  active_environmental_weight = sum(ifelse(environmental_member_desc=='Active',weight,0)),
    inactive_environmental_weight = sum(ifelse(environmental_member_desc=='Inactive',weight,0)),
    responded_environmental_weight = sum(ifelse(environmental_member_desc!='N/A',weight,0)),
    responded_environmental_N = sum(ifelse(environmental_member_desc!='N/A',1,0)),
  active_professional_weight = sum(ifelse(professional_member_desc=='Active',weight,0)),
    inactive_professional_weight = sum(ifelse(professional_member_desc=='Inactive',weight,0)),
    responded_professional_weight = sum(ifelse(professional_member_desc!='N/A',weight,0)),
    responded_professional_N = sum(ifelse(professional_member_desc!='N/A',1,0)),
  active_charity_weight = sum(ifelse(charity_member_desc=='Active',weight,0)),
    inactive_charity_weight = sum(ifelse(charity_member_desc=='Inactive',weight,0)),
    responded_charity_weight = sum(ifelse(charity_member_desc!='N/A',weight,0)),
    responded_charity_N = sum(ifelse(charity_member_desc!='N/A',1,0)),
  active_other_weight = sum(ifelse(other_member_desc=='Active',weight,0)),
    inactive_other_weight = sum(ifelse(other_member_desc=='Inactive',weight,0)),
    responded_other_weight = sum(ifelse(other_member_desc!='N/A',weight,0)),
    responded_other_N = sum(ifelse(other_member_desc!='N/A',1,0)),
  active_consumer_weight = sum(ifelse(consumer_member_desc=='Active',weight,0)),
    inactive_consumer_weight = sum(ifelse(consumer_member_desc=='Inactive',weight,0)),
    responded_consumer_weight = sum(ifelse(consumer_member_desc!='N/A',weight,0)),
    responded_consumer_N = sum(ifelse(consumer_member_desc!='N/A',1,0)),
  active_help_group_weight = sum(ifelse(help_group_member_desc=='Active',weight,0)),
    inactive_help_group_weight = sum(ifelse(help_group_member_desc=='Inactive',weight,0)),
    responded_help_group_weight = sum(ifelse(help_group_member_desc!='N/A',weight,0)),
    responded_help_group_N = sum(ifelse(help_group_member_desc!='N/A',1,0)),
  active_any_weight = sum(ifelse(any_member_desc=='Active',weight,0)),
    inactive_any_weight = sum(ifelse(any_member_desc=='Inactive',weight,0)),
    responded_any_weight = sum(ifelse(any_member_desc!='N/A',weight,0)),
    responded_any_N = sum(ifelse(any_member_desc!='N/A',1,0))
  ) %>% 
  mutate(
    active_church_pct = ifelse(responded_church_N>100, active_church_weight/responded_church_weight,NA),
    members_church_pct = ifelse(responded_church_N>100, (active_church_weight+inactive_church_weight)/responded_church_weight,NA),
    
    active_sport_pct = ifelse(responded_sport_N>100, active_sport_weight/responded_sport_weight,NA),
    members_sport_pct = ifelse(responded_sport_N>100, (active_sport_weight+inactive_sport_weight)/responded_sport_weight,NA),
    
    active_artmusicedu_pct = ifelse(responded_artmusicedu_N>100, active_artmusicedu_weight/responded_artmusicedu_weight,NA),
    members_artmusicedu_pct = ifelse(responded_artmusicedu_N>100, (active_artmusicedu_weight+inactive_artmusicedu_weight)/responded_artmusicedu_weight,NA),
    
    active_laborunion_pct = ifelse(responded_laborunion_N>100, active_laborunion_weight/responded_laborunion_weight,NA),
    members_laborunion_pct = ifelse(responded_laborunion_N>100, (active_laborunion_weight+inactive_laborunion_weight)/responded_laborunion_weight,NA),
    
    active_political_pct = ifelse(responded_political_N>100, active_political_weight/responded_political_weight,NA),
    members_political_pct = ifelse(responded_political_N>100, (active_political_weight+inactive_political_weight)/responded_political_weight,NA),
    
    active_environmental_pct = ifelse(responded_environmental_N>100, active_environmental_weight/responded_environmental_weight,NA),
    members_environmental_pct = ifelse(responded_environmental_N>100, (active_environmental_weight+inactive_environmental_weight)/responded_environmental_weight,NA),
    
    active_professional_pct = ifelse(responded_professional_N>100, active_professional_weight/responded_professional_weight,NA),
    members_professional_pct = ifelse(responded_professional_N>100, (active_professional_weight+inactive_professional_weight)/responded_professional_weight,NA),
    
    active_charity_pct = ifelse(responded_charity_N>100, active_charity_weight/responded_charity_weight,NA),
    members_charity_pct = ifelse(responded_charity_N>100, (active_charity_weight+inactive_charity_weight)/responded_charity_weight,NA),
    
    active_other_pct = ifelse(responded_other_N>100, active_other_weight/responded_other_weight,NA),
    members_other_pct = ifelse(responded_other_N>100, (active_other_weight+inactive_other_weight)/responded_other_weight,NA),
    
    active_consumer_pct = ifelse(responded_consumer_N>100, active_consumer_weight/responded_consumer_weight,NA),
    members_consumer_pct = ifelse(responded_consumer_N>100, (active_consumer_weight+inactive_consumer_weight)/responded_consumer_weight,NA),
    
    active_help_group_pct = ifelse(responded_help_group_N>100, active_help_group_weight/responded_help_group_weight,NA),
    members_help_group_pct = ifelse(responded_help_group_N>100, (active_help_group_weight+inactive_help_group_weight)/responded_help_group_weight,NA),
    
    active_any_pct = ifelse(responded_any_N>100, active_any_weight/responded_any_weight,NA),
    members_any_pct = ifelse(responded_any_N>100, (active_any_weight+inactive_any_weight)/responded_any_weight,NA)
    
  ) %>% as.data.frame()

class(WVS_aggregates)
  
### Save the data
# respondent level
save(long_data_converted,file = "./group 3 limited use/world values survey/WVS_respondents_answers.Rdata")

# aggregates
save(WVS_aggregates,file = "./group 3 limited use/world values survey/WVS_aggregates.Rdata")
