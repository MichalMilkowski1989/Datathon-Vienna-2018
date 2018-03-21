### This script is used for data preparation of civil society indices provided by several organisations
# it's main purpose is to prepar ethe challenge "Open government Data"
# for the Datathon in Vienna

library(dplyr)
library(readxl)

########################################################################################
#
# OECD volunteering DATA
### http://www.oecd.org/els/family/database.htm
#   CO4.1??Participation in voluntary work and membership of NGOs for young adults, 15-29
#
########################################################################################

list.files()
# Where is the file?
file1 <- "./OECD_volunteering_data/CO4.1-Participation-voluntary-work.xls"
list.files(file1)
# Which sheet contains the historical data
world_value_survey_2014 <- "Table CO4.1.A"
gallup_world_poll <- "Table CO4.1.B"
ESS_2012 <- "Table CO4.1.C"

# World value survey wave 6: 2010-2014
# Table CO4.1.A 
# Proportion (%) of young people who are members (active or inactive) of organisations by type of group, around 2012								
# Men and women age 15 to 29 <- that's incorrect!!!!!!!
volunteers_wvs <- as.data.frame(
                    read_excel(file1, 
                        sheet = world_value_survey_2014, 
                        range = cell_rows(4:21)
                        )
)

class(volunteers_wvs)

volunteers_wvs <- volunteers_wvs %>% rename(Country = X__1) %>% mutate(year = 2014)
#clean Cyprus1,2
volunteers_wvs$Country <- gsub("[0-9\\,]","",volunteers_wvs$Country)

# change weird missing values into proper missing values
volunteers_wvs[volunteers_wvs=='..'] <- NA

#clean names
names(volunteers_wvs) <- gsub("[ \\,]+","_",names(volunteers_wvs))

# convert Other_groups into numeric 
volunteers_wvs$Other_groups <- as.numeric(volunteers_wvs$Other_groups)


class(volunteers_wvs)

# save data
save(volunteers_wvs,file = "./OECD_volunteering_data/volunteers_wvs.Rdata")


# Gallup world poll 
# Table CO4.1.B. 
# Proportion of people who volunteered time to an organization in the past month, 
# 2015 or last year available:
# 1) Data refer to 2014 for Bulgaria, Canada, Chile, Croatia, Czech Rep, Estonia, Israel, 
# Japan, Korea, Latvia, Lithuania, New Zealand, Portugal, Romania, Slovak Republic, 
# Switzerland, United States and to 2013 for Iceland, Turkey.							

volunteer_lastmonth_gallup <- as.data.frame(
                                read_excel(file1, 
                                   sheet = gallup_world_poll, 
                                   range = cell_rows(5:46))
)

class(volunteer_lastmonth_gallup)

# drop totally empty columns
all_empty <- sapply(volunteer_lastmonth_gallup,function(x) all(is.na(x)))
names_non_empty <- names(volunteer_lastmonth_gallup)[!all_empty]
volunteer_lastmonth_gallup <- volunteer_lastmonth_gallup %>% select(names_non_empty)
# change weird missing values into proper missing values
volunteer_lastmonth_gallup[volunteer_lastmonth_gallup=='..'] <- NA
#rename
names(volunteer_lastmonth_gallup) <- c("country", "pct_volunteered_total_last_month",
                                       "pct_volunteered_Men_last_month",
                                       "pct_volunteered_Women_last_month",
                                       "pct_volunteered_age15_29_last_month",
                                       "year"
                                       )

# convert age 15-29 into numeric 
volunteer_lastmonth_gallup$pct_volunteered_age15_29_last_month <- as.numeric(volunteer_lastmonth_gallup$pct_volunteered_age15_29_last_month)

class(volunteer_lastmonth_gallup)

# save the data
save(volunteer_lastmonth_gallup,file = "./OECD_volunteering_data/volunteer_lastmonth_gallup.Rdata")

# European Social Survey 
# Table CO4.1.C 
# Proportion of people involved in work for voluntary or charitable organisations 
# in the past year		
# 1) In the 2012 European Surveys, respondents were asked whether, 
# over the last 12 months, they have been involved 
# in work for voluntary or charitable organizations. 
# The estimates derived here correspond to the proportion respondents who answered positively.		

volunteered_lastyear_ess_2012 <- as.data.frame(read_excel(file1, sheet = ESS_2012, 
                              range = cell_rows(5:29)) %>% mutate(year = 2012)
)

class(volunteered_lastyear_ess_2012)

names(volunteered_lastyear_ess_2012)<-c("Country",
                                        "pct_volunteered_age_15_29_last_year",
                                        "pct_volunteered_age_30_49_last_year",
                                        "year"
                                        )
#clean Cyprus
volunteered_lastyear_ess_2012$Country <- gsub("[0-9\\,]","",volunteered_lastyear_ess_2012$Country)

class(volunteered_lastyear_ess_2012)

# save the data
save(volunteered_lastyear_ess_2012,file = "./OECD_volunteering_data/volunteered_lastyear_ess_2012.Rdata")


