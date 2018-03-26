### This script is used for data preparation of civil society indices provided by several organisations
# it's main purpose is to prepare the challenge "Open government Data"
# for the Datathon in Vienna

list.files()

#load data stored locally
load("./group3/red cross/red_cross_notcleaned.Rdata")
load("./group3/TransparencyInternational/CPI.Rdata")
load("./group3/V-dem/VDEM.Rdata")
load("./group3/BertelsmannStiftung/BTI.Rdata")
load("./group 3 limited use/world values survey/WVS_aggregates.Rdata")
load("./group3/Internationalinstitutefordemocracyandelectoralassistance/voter_turnout.Rdata")


### static data:
load("./group3/OECD_volunteering_data/volunteered_lastyear_ess_2012.Rdata")
load("./group3/OECD_volunteering_data/volunteer_lastmonth_gallup.Rdata")
load("./group3/OECD_volunteering_data/volunteers_wvs.Rdata")

# print classes of data
for (i in setdiff(ls(),c("i","y"))){
print(paste0("class of ",i," is ",as.character(class(eval(as.symbol(i))))))
}

#print year range
for (i in setdiff(ls(),c("y","i"))){
  y <- grep("year",names(eval(as.symbol(i))),ignore.case=TRUE,value=TRUE)
  print(paste0("Year variable for ",i," is ",y))
  print(paste0("minimum year for ",i," is ",as.character(min(eval(as.symbol(i)) %>% select_(y)))))
  print(paste0("maximum year for ",i," is ",as.character(max(eval(as.symbol(i)) %>% select_(y)))))
}

#print number of countries covered
for (i in setdiff(ls(),c("y","i"))){
  y <- grep("country",names(eval(as.symbol(i))),ignore.case=TRUE,value=TRUE)
  print(paste0("country variable for ",i," is ",y))
  print(paste0("Number of countries covered for ",i," is ",as.character(nrow(unique(eval(as.symbol(i)) %>% select_(y))))))
}

###################################################################
#
# Let's start joining
#
###################################################################

# 1. prepare the dictionary of all the countries

BTI_countries <- unique(BTI$Country)
CPI_countries <- unique(CPI$Country)
VDEM_countries <- unique(VDEM$country_name)
WVS_countries <- unique(WVS_aggregates$Country)
red_cross_countries <- unique(red_cross$country)
volunteer_lastmonth_gallup_countries <- unique(volunteer_lastmonth_gallup$country)
volunteers_wvs_countries <- unique(volunteers_wvs$Country)
volunteered_lastyear_ess_2012_countries <- unique(volunteered_lastyear_ess_2012$Country)
voter_turnout_countries <- unique(voter_turnout$Country)

all_countries <- sort(unique(c(BTI_countries,CPI_countries,VDEM_countries,WVS_countries,
                          red_cross_countries,red_cross_countries,red_cross_countries,volunteer_lastmonth_gallup_countries,
                          volunteers_wvs_countries,volunteered_lastyear_ess_2012_countries,voter_turnout_countries)))


length(all_countries)
### It means we need to spend some time preparing names

df_countries<-data.frame(country = all_countries)
df_countries$country <- as.character(df_countries$country)

# correct one by one
df_countries$country_corrected <- ifelse(df_countries$country=='Bosnia',"Bosnia and Herzegovina",df_countries$country)
df_countries$country_corrected <- ifelse(grepl("Ivory|Ivoire",df_countries$country),
                                         "Ivory Coast",df_countries$country_corrected)

df_countries$country_corrected <- ifelse(df_countries$country=='Cabo Verde',"Cape Verde",df_countries$country_corrected)
df_countries$country_corrected <- ifelse(df_countries$country=='Comores',"Comoros",df_countries$country_corrected)

df_countries$country_corrected <- ifelse(df_countries$country %in%
                                            c('Congo',
                                              'Congo, Rep.',
                                              'Republic of The Congo (Brazzaville)',
                                              'Republic of the Congo'
                                              ),
                                         "Congo",df_countries$country_corrected)

df_countries$country_corrected <- ifelse(df_countries$country %in%
                                           c('Congo, DR',
                                             'Congo, Democratic Republic of',
                                             'Congo, The Democratic Republic of',
                                             'Democratic Republic of Congo',
                                             'Democratic Republic of the Congo'
                                           ),
                                         "Democratic Republic of Congo",df_countries$country_corrected)


df_countries$country_corrected <- ifelse(df_countries$country=='Cyprus3,4',"Cyprus",df_countries$country_corrected)

df_countries$country_corrected <- ifelse(df_countries$country=='Czech Rep.',"Czech Republic",df_countries$country_corrected)

df_countries$country_corrected <- ifelse(df_countries$country=='Dominican Rep.',"Dominican Republic",df_countries$country_corrected)

df_countries$country_corrected <- ifelse(df_countries$country=='Guinea-Bissau',"Guinea Bissau",df_countries$country_corrected)

df_countries$country_corrected <- ifelse(df_countries$country=='Iran, Islamic Republic of',"Iran",df_countries$country_corrected)

df_countries$country_corrected <- ifelse(df_countries$country=='Israel2',"Israel",df_countries$country_corrected)


df_countries$country_corrected <- ifelse(df_countries$country %in%
                                           c('Korea, North',
                                             "Korea, Democratic People's Republic"
                                           ),
                                         "North Korea",df_countries$country_corrected)
df_countries$country_corrected <- ifelse(df_countries$country %in%
                                           c('Korea, South',
                                             "Korea, Republic of"
                                           ),
                                         "South Korea",df_countries$country_corrected)



df_countries$country_corrected <- ifelse(df_countries$country %in%
                                           c("Lao People's Democratic Republic",
                                            "Lao People's Dem. Republic"),
                                            "Laos",df_countries$country_corrected)

df_countries$country_corrected <- ifelse(df_countries$country=='Libyan Arab Jamahiriya',"Libya",df_countries$country_corrected)

df_countries$country_corrected <- ifelse(df_countries$country=='Macedonia, former Yugoslav Republic (1993-)',
                                         "Macedonia",df_countries$country_corrected)

df_countries$country_corrected <- ifelse(df_countries$country=='Moldova, Republic of',"Moldova",df_countries$country_corrected)

df_countries$country_corrected <- ifelse(df_countries$country=='Slovak Republic',"Slovakia",df_countries$country_corrected)


df_countries$country_corrected <- ifelse(df_countries$country %in%
                                           c("Palestine/British",
                                             "Palestine/Gaza",
                                             "Palestine/West Bank",
                                             "Palestinian Territory, Occupied",
                                             "State of Palestine"),
                                         "Palestine",df_countries$country_corrected)

df_countries$country_corrected <- ifelse(df_countries$country %in%
                                           c(#"Republic of Vietnam", - Republic of Vietnam is a country that was joined with Democratic Republic
                                             "Democratic Republic of Vietnam",
                                             "Vietnam",
                                             "Viet Nam"),
                                         "Vietnam",df_countries$country_corrected)

df_countries$country_corrected <- ifelse(df_countries$country=='Russia',"Russian Federation",df_countries$country_corrected)


df_countries$country_corrected <- ifelse(df_countries$country=='Saint Vincent and the Grenadines',
                                         "Saint Vincent and The Grenadines",df_countries$country_corrected)


df_countries$country_corrected <- ifelse(df_countries$country=="Serbia*","Serbia",df_countries$country_corrected)

df_countries$country_corrected <- ifelse(df_countries$country %in% 
                                           c('Yugoslavia, FR/Union of Serbia and Montenegro',
                                             "*Serbia and Montenegro"),
                                         "Serbia and Montenegro",df_countries$country_corrected)

# Serbia
# Serbia and Montenegro
# Serbia*
# *Serbia and Montenegro
# Yugoslavia, FR/Union of Serbia and Montenegro
# Yugoslavia, SFR (1943-1992)


df_countries$country_corrected <- ifelse(df_countries$country=='United States',
                                         "United States of America",df_countries$country_corrected)

df_countries$country_corrected <- ifelse(df_countries$country=='Tanzania, United Republic of',
                                         "Tanzania",df_countries$country_corrected)

df_countries$country_corrected <- ifelse(df_countries$country=='Syrian Arab Republic',
                                         "Syria",df_countries$country_corrected)

df_countries$country_corrected <- ifelse(df_countries$country=='Solomon Island',
                                         "Solomon Islands",df_countries$country_corrected)


df_countries$country_corrected <- ifelse(grepl("ncipe",df_countries$country),
                                         "Sao Tome and Principe",df_countries$country_corrected)


### Only in World Value Survey, there is Great Britain instead of United Kingdom
df_countries$country_corrected <- ifelse(df_countries$country=='Great Britain',
                                         "United Kingdom",df_countries$country_corrected)


length(unique(df_countries$country))
length(unique(df_countries$country_corrected))


# Assumption:
# Let's get rid of Palestine because it's history is quite hard and sometimes there are 2 states reported (West Bank and Gaza), sometimes only one

dim(df_countries)
df_countries <- df_countries %>% filter(country_corrected!="Palestine")
dim(df_countries)


##############################################################################
# Let's start from 1950
#
##############################################################################
# 2. prepare the vector of years
years <- 1950:2018

# 3. let's join data.frames with dictionaries of countries

library(dplyr)
BTI2 <- unique(inner_join(BTI,df_countries, by = c("Country"="country")))
names(BTI2)<-paste0(names(BTI2),"_BTI")
BTI2$year_data_BTI<-BTI2$year_BTI

CPI2 <- unique(inner_join(CPI,df_countries, by = c("Country"="country")))
names(CPI2)<-paste0(names(CPI2),"_CPI")
CPI2$year_data_CPI<-CPI2$year_CPI


red_cross2 <- unique(inner_join(red_cross, df_countries, by = "country"))
names(red_cross2)<-paste0(names(red_cross2),"_red_cross")
red_cross2$year_data_red_cross<-red_cross2$year_red_cross

VDEM2 <- unique(inner_join(VDEM, df_countries, by = c("country_name"="country")))
names(VDEM2)<-paste0(names(VDEM2),"_VDEM")
VDEM2$year_data_VDEM<-VDEM2$year_VDEM

volunteer_lastmonth_gallup2 <- unique(inner_join(volunteer_lastmonth_gallup, df_countries, by = "country"))
names(volunteer_lastmonth_gallup2)<-paste0(names(volunteer_lastmonth_gallup2),"_gallup")
volunteer_lastmonth_gallup2$year_data_gallup <- volunteer_lastmonth_gallup2$year_gallup


volunteered_lastyear_ess_20122 <- unique(inner_join(volunteered_lastyear_ess_2012, df_countries, by = c("Country"="country")))
names(volunteered_lastyear_ess_20122)<-paste0(names(volunteered_lastyear_ess_20122),"_ess")
volunteered_lastyear_ess_20122$year_data_ess <- volunteered_lastyear_ess_20122$year_ess


voter_turnout2 <- unique(inner_join(voter_turnout, df_countries, by = c("Country"="country")))
names(voter_turnout2)<-paste0(names(voter_turnout2),"_turnout")

WVS_aggregates2 <- unique(inner_join(WVS_aggregates, df_countries, by = c("Country"="country")))
names(WVS_aggregates2)<-paste0(names(WVS_aggregates2),"_WVS")
WVS_aggregates2$year_data_WVS <- WVS_aggregates2$year_WVS


# What is lost in BTI?
setdiff(unique(BTI$Country),unique(BTI2$Country))
# It's NA :)


# 4. Now the cross join of dates and countries

df_country_year <- merge(x = years, y = sort(unique(df_countries$country_corrected)))
names(df_country_year) <- c("year","country")
df_country_year$country <- as.character(df_country_year$country)
head(df_country_year)

# 5. Let's split the voter turnout data into parliamentary and presidential, because both may happen in the same year. 
## And there are consistent differences in turnouts

voter_turnout2_pres <- voter_turnout2 %>% filter(election_type_turnout == 'Presidential')
names(voter_turnout2_pres)<-c("Country","Year","election_type",
                               "voter_turnout_presidential","registration_presidential","invalid_votes_presidential",
                               "country_corrected")
voter_turnout2_pres$year_pres <- voter_turnout2_pres$Year


voter_turnout2_parl <- voter_turnout2 %>% filter(election_type_turnout == 'Parliamentary')
names(voter_turnout2_parl)<-c("Country","Year","election_type",
                               "voter_turnout_parliamentary","registration_parliamentary","invalid_votes_parliamentary",
                               "country_corrected")
voter_turnout2_parl$year_parl <- voter_turnout2_parl$Year

# 6. start joining
dim(df_country_year)

civil_society_temp <- left_join(df_country_year,WVS_aggregates2, 
                                by = c("year"="Wave_end_year_WVS","country"="country_corrected_WVS"))
dim(civil_society_temp)

civil_society_temp <- left_join(civil_society_temp,CPI2, 
                                by = c("year"="year_CPI","country"="country_corrected_CPI"))
dim(civil_society_temp)


civil_society_temp <- left_join(civil_society_temp,voter_turnout2_pres, 
                                by = c("year"="Year","country"="country_corrected"))
dim(civil_society_temp)

civil_society_temp <- left_join(civil_society_temp,voter_turnout2_parl, 
                                by = c("year"="Year","country"="country_corrected"))
dim(civil_society_temp)

civil_society_temp <- left_join(civil_society_temp,volunteered_lastyear_ess_20122, 
                                by = c("year"="year_ess","country"="country_corrected_ess"))
dim(civil_society_temp)

civil_society_temp <- left_join(civil_society_temp,volunteer_lastmonth_gallup2, 
                                by = c("year"="year_gallup","country"="country_corrected_gallup"))
dim(civil_society_temp)

civil_society_temp <- left_join(civil_society_temp,BTI2, by = c("year"="year_BTI","country"="country_corrected_BTI"))
dim(civil_society_temp)

civil_society_temp <- left_join(civil_society_temp,red_cross2, by = c("year"="KPI_Year_red_cross",
                                                                      "country"="country_corrected_red_cross")
)
dim(civil_society_temp)

civil_society_temp <- left_join(civil_society_temp,VDEM2, by = c("year"="year_VDEM","country"="country_corrected_VDEM"))
dim(civil_society_temp)

# 7. Last observation carried forward!!
library(zoo)
civil_society <- civil_society_temp %>% arrange(country,year)

### But last observation should be carried forward only within the same country!!
### I will use parallelisation for that

library(doParallel)

registerDoParallel(cores=(detectCores()-2) )
print(paste0("number of workers is: ", getDoParWorkers()))
print(paste0("The name of the parallelisation: ", getDoParName()))
print(paste0("The version of the parallelisation: ", getDoParVersion()))


civil_society_big <- foreach(i=unique(civil_society$country), .combine=rbind) %dopar% {
    cs <- na.locf(civil_society[civil_society$country == i,])
}

# save data

### without padding
save(civil_society, file = "./group3/civil_society_without_padding.Rdata")

### after padding
save(civil_society_big, file = "./group3/civil_society.Rdata")



