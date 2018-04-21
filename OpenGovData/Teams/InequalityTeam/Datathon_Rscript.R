library(dplyr)
library(ggplot2)
library(plm)
library(stargazer)

################################################
############## Data Preparation ################
################################################

load("civil_society_selected.Rdata")
load("world_bank_selected.Rdata")

### Choose VDEMS from Civil Society dataset
civil_society_vdm <- civil_society_selected[,c(1:2,grep("VDEM", colnames(civil_society_selected)))]

### Join VDEM and Worldbank Data
alldata <- left_join(civil_society_vdm, world_bank_selected, by=c("COUNTRY", "YEAR"))

### Create a Subset with CEEs and Austria
ceedata <- subset(alldata, alldata$SUB_REGION=="Eastern Europe"|alldata$COUNTRY=="Austria")

### exclude Ukraine as it is found to be an exception in several dimensions
ceedata_exclUkr<-subset(ceedata, ceedata$COUNTRY!="Ukraine")

### exclude Ukraine, Russian Federation and Moldova (for the same reasons)
ceedata_exclUkrRusMold<-subset(ceedata_exclUkr, ceedata_exclUkr$COUNTRY!="Ukraine"&ceedata_exclUkr$COUNTRY!="Russian Federation"&ceedata_exclUkr$COUNTRY!="Moldova")

################################################
############## Model estimation ################
################################################

### Dynamic panel fixed effects model
myplm <- plm(V2X_CSPART_VDEM~lag(V2X_CSPART_VDEM)+NY_GDP_PCAP_CD+NY_GDP_MKTP_KD_ZG
+PV_EST+CC_EST+SI_POV_GINI+GE_EST+SE_XPD_TOTL_GD_ZS+EG_ELC_RNEW_ZS+SM_POP_NETM, data=ceedata_exclUkrRus, effect="individual", model="within")
summary(myplm)

stargazer(myplm)

#lag of dependent variable
#gdp per capita
#gdp growth
#political stability and absence of violence
#control of corruption
#gini
#government effectiveness
#Government expenditure on education, total (% of GDP)
#Renewable electricity output (% of total electricity output)
#Net migration


#use gdp growth instead?
#use migration and environmental issues

### Prepare a cross-country analysis


table( ceedata$COUNTRY, ceedata$CC_EST)


######
######

#overall civil society participation vs. women civil society participation
ggplot(data = civil_society_selected[civil_society_selected$SUB_REGION == "Eastern Europe",])+  
  geom_point(aes(V2X_CSPART_VDEM, V2X_GENCS_VDEM,colour = COUNTRY)) +
  geom_smooth(aes(V2X_CSPART_VDEM, V2X_GENCS_VDEM,colour = COUNTRY),method = "lm")

#overall civil society participation vs. freedom of expression
ggplot(data = civil_society_selected[civil_society_selected$SUB_REGION == "Eastern Europe",])+  
  geom_point(aes(V2X_CSPART_VDEM, V2X_FREEXP_VDEM,colour = COUNTRY)) +
  geom_smooth(aes(V2X_CSPART_VDEM, V2X_FREEXP_VDEM,colour = COUNTRY),method = "lm")

#overall civil society participation vs. political corruption index
ggplot(data = civil_society_selected[civil_society_selected$SUB_REGION == "Eastern Europe",])+  
  geom_point(aes(V2X_CSPART_VDEM, V2X_CORR_VDEM,colour = COUNTRY)) +
  geom_smooth(aes(V2X_CSPART_VDEM, V2X_CORR_VDEM,colour = COUNTRY),method = "lm")




ukraine_data <- alldata[civil_society_selected$COUNTRY == 'Ukraine',grep('VDEM',colnames(civil_society_selected))]
correlations <- cor(ukraine_data) %>% as.data.frame()
correlations$indicator <- rownames(correlations)

ukraine_data <- civil_society_selected[civil_society_selected$COUNTRY == 'Ukraine',grep('VDEM',colnames(civil_society_selected))]
grep('VDEM',colnames(civil_society_selected))
colnames(civil_society_selected)[grep('VDEM',colnames(civil_society_selected))]
correlations <- cor(ukraine_data)
correlations
correlations <- cor(ukraine_data) %>% as.data.frame()
correlations$V2X_CSPART_VDEM
rownames(correlations)
View(correlations$V2X_CSPART_VDEM)
correlations$indicator <- rownames(correlations)
View(correlations[,c("V2X_CSPART_VDEM",'indicator')])

