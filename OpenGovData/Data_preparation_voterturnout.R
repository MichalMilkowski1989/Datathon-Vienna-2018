### This script is used for data preparation of civil society indices provided by several organisations
# it's main purpose is to prepar ethe challenge "Open government Data"
# for the Datathon in Vienna

library(dplyr)
library(readxl)

########################################################################################
#
### Voter turnout:
## Elections:
# parliamentary
# presidential
### https://www.idea.int/data-tools/vt-advanced-search
########################################################################################

list.files()
# Where is the file?
file1 <- "./Internationalinstitutefordemocracyandelectoralassistance/voting turnout/idea_export_40_5aa1387995a84.xls"
list.files(file1)
# Which sheet contains the historical data
turnout_sheet<- "Worksheet"

voter_turnout_all <- as.data.frame(read_excel(file1, sheet = turnout_sheet))
class(voter_turnout_all)
#take a look
str(voter_turnout_all)
table(voter_turnout_all$`Election type`)

# convert the data

voter_turnout <- voter_turnout_all %>% mutate(voter_turnout = as.numeric(sub(' %',"",`Voter Turnout`))/100,
                             registration = as.numeric(gsub(",","",Registration)),
                             invalid_votes = as.numeric(sub(' %',"",`Invalid votes`))/100
                             ) %>% rename(election_type = `Election type`) %>% 
                      select(Country,Year,election_type,voter_turnout,registration,invalid_votes) %>% 
                      arrange(Country, Year)

class(voter_turnout)
# save the data
save(voter_turnout,file = "./Internationalinstitutefordemocracyandelectoralassistance/voter_turnout.Rdata")
