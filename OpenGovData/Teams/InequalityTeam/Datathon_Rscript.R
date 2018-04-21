library(dplyr)
library(ggplot2)
library(plm)
library(stargazer)

################################################
############## Data Preparation ################
################################################

### To load the data, put the coresponding files in the project-folder
load("civil_society_selected.Rdata")
load("world_bank_selected.Rdata")

### Choose VDEMS from Civil Society dataset (as we want to focus on VDEM and Worldbank)
civil_society_vdm <- civil_society_selected[,c(1:2,grep("VDEM", colnames(civil_society_selected)))]

### Join VDEM and Worldbank Data
alldata <- left_join(civil_society_vdm, world_bank_selected, by=c("COUNTRY", "YEAR"))

### Create a Subset with CEEs and Austria
ceedata <- subset(alldata, alldata$SUB_REGION=="Eastern Europe"|alldata$COUNTRY=="Austria")

### exclude Ukraine as it is found to be an exception in several dimensions
ceedata_exclUkr<-subset(ceedata, ceedata$COUNTRY!="Ukraine")

### exclude Ukraine, Russian Federation and Moldova (for the same reasons)
ceedata_exclUkrRusMold<-subset(ceedata, ceedata$COUNTRY!="Ukraine"&ceedata$COUNTRY!="Russian Federation"&ceedata$COUNTRY!="Moldova")

################################################
############## Model estimation ################
################################################

###dependent variable

#V2X_CSPART_VDEM: Civil Society Participation

###explanatory variables

#lag of dependent variable (control for previous level of civil society participation)
#NY_GDP_PCAP_CD: gdp per capita
#NY_GDP_MKTP_KD_ZG: gdp growth
#PV_EST: political stability and absence of violence
#CC_EST: control of corruption
#SI_POV_GINI: gini
#GE_EST: government effectiveness
#SE_XPD_TOTL_GD_ZS: Government expenditure on education, total (% of GDP)
#EG_ELC_RNEW_ZS: Renewable electricity output (% of total electricity output)
#SM_POP_NETM: Net migration

# add Top 10 positively and negatively correlated variables with civil society participation (from Python group)
#V2JUPOATCK_VDEM                                  -0.918912
#EN_ATM_CO2E_KD_GD                                -0.839324
#SP_POP_TOTL                                      -0.825213
#SL_TLF_CACT_FM_ZS                                -0.813114
#SH_DYN_NMRT                                      -0.797805
#SH_DYN_MORT__POPULATIONESTIMATESANDPROJECTIONS   -0.793853
#V2XCL_SLAVE_VDEM                                 -0.776884
#V2PEHEALTH_VDEM                                  -0.763274
#SH_ANM_CHLD_ZS                                   -0.761907

#V2X_CSPART_VDEM                               1.000000
#V2CSPRTCPT_VDEM                               0.948018
#AG_LND_FRST_ZS__WorldDevelopmentIndicators    0.883797
#V2CSCNSULT_VDEM                               0.881897
#V2X_GENPP_VDEM                                0.863001
#V2CSRLGCON_VDEM                               0.857855
#1_1_ACCESS_ELECTRICITY_TOT                    0.839591
#V2CLSTOWN_VDEM                                0.838088
#IT_CEL_SETS_P2__JOBS                          0.765118


myplm_top20 <- plm(V2X_CSPART_VDEM~lag(V2X_CSPART_VDEM)+NY_GDP_PCAP_CD+NY_GDP_MKTP_KD_ZG
                   +PV_EST+CC_EST+SI_POV_GINI+GE_EST+SE_XPD_TOTL_GD_ZS+SM_POP_NETM+V2JUPOATCK_VDEM+EN_ATM_CO2E_KD_GD+SP_POP_TOTL+SL_TLF_CACT_FM_ZS+SH_DYN_NMRT+SH_DYN_MORT__POPULATIONESTIMATESANDPROJECTIONS+V2XCL_SLAVE_VDEM+V2PEHEALTH_VDEM+SH_ANM_CHLD_ZS+
                    +AG_LND_FRST_ZS__WORLDDEVELOPMENTINDICATORS+V2CSRLGCON_VDEM+V2CLSTOWN_VDEM+IT_CEL_SETS_P2__JOBS,data=ceedata_exclUkrRusMold, effect="individual", model="within")

summary(myplm_top20)

### Prepare for Latex table

stargazer(myplm_top20)




#####################################################
################## Visualise ########################
#####################################################

#overall civil society participation over time

ggplot(data = ceedata)+  
  geom_point(aes(YEAR, V2X_CSPART_VDEM,colour = COUNTRY))

ggplot(data = ceedata)+  
  geom_point(aes(YEAR, V2X_CSPART_VDEM,colour = COUNTRY))+
  geom_smooth(aes(YEAR, V2X_CSPART_VDEM,colour = COUNTRY),method = "lm")

#overall civil society particaption and gdp growth

ggplot(data = ceedata)+  
  geom_point(aes(NY_GDP_MKTP_KD_ZG, V2X_CSPART_VDEM,colour = COUNTRY))

ggplot(data = ceedata)+  
  geom_point(aes(NY_GDP_MKTP_KD_ZG, V2X_CSPART_VDEM,colour = COUNTRY))+
  geom_smooth(aes(NY_GDP_MKTP_KD_ZG, V2X_CSPART_VDEM,colour = COUNTRY),method = "lm")

ggplot(data = ceedata)+  
  geom_point(aes(NY_GDP_MKTP_KD_ZG, V2X_CSPART_VDEM))+
  geom_smooth(aes(NY_GDP_MKTP_KD_ZG, V2X_CSPART_VDEM),method = "lm")

#overall civil society participation vs. freedom of expression

ggplot(data = ceedata)+  
  geom_point(aes(V2X_FREEXP_VDEM, V2X_CSPART_VDEM,colour = COUNTRY))

ggplot(data = ceedata)+  
  geom_point(aes(V2X_FREEXP_VDEM, V2X_CSPART_VDEM,colour = COUNTRY))+
  geom_smooth(aes(V2X_FREEXP_VDEM, V2X_CSPART_VDEM,colour = COUNTRY),method = "lm")

ggplot(data = ceedata)+  
  geom_point(aes(V2X_FREEXP_VDEM, V2X_CSPART_VDEM))+
  geom_smooth(aes(V2X_FREEXP_VDEM, V2X_CSPART_VDEM),method = "lm")

#####################################################
######### Repeat plots without Ukraine ##############
#####################################################

ggplot(data = ceedata_exclUkr)+  
  geom_point(aes(YEAR, V2X_CSPART_VDEM,colour = COUNTRY))

ggplot(data = ceedata_exclUkr)+  
  geom_point(aes(YEAR, V2X_CSPART_VDEM,colour = COUNTRY))+
  geom_smooth(aes(YEAR, V2X_CSPART_VDEM,colour = COUNTRY),method = "lm")

#overall civil society particaption and gdp growth

ggplot(data = ceedata_exclUkr)+  
  geom_point(aes(NY_GDP_MKTP_KD_ZG, V2X_CSPART_VDEM,colour = COUNTRY))

ggplot(data = ceedata_exclUkr)+  
  geom_point(aes(NY_GDP_MKTP_KD_ZG, V2X_CSPART_VDEM,colour = COUNTRY))+
  geom_smooth(aes(NY_GDP_MKTP_KD_ZG, V2X_CSPART_VDEM,colour = COUNTRY),method = "lm")

ggplot(data = ceedata_exclUkr)+  
  geom_point(aes(NY_GDP_MKTP_KD_ZG, V2X_CSPART_VDEM))+
  geom_smooth(aes(NY_GDP_MKTP_KD_ZG, V2X_CSPART_VDEM),method = "lm")

#overall civil society participation vs. freedom of expression

ggplot(data = ceedata_exclUkr)+  
  geom_point(aes(V2X_FREEXP_VDEM, V2X_CSPART_VDEM,colour = COUNTRY))

ggplot(data = ceedata_exclUkr)+  
  geom_point(aes(V2X_FREEXP_VDEM, V2X_CSPART_VDEM,colour = COUNTRY))+
  geom_smooth(aes(V2X_FREEXP_VDEM, V2X_CSPART_VDEM,colour = COUNTRY),method = "lm")

ggplot(data = ceedata_exclUkr)+  
  geom_point(aes(V2X_FREEXP_VDEM, V2X_CSPART_VDEM))+
  geom_smooth(aes(V2X_FREEXP_VDEM, V2X_CSPART_VDEM),method = "lm")

#overall civil society participation vs. forrestation

ggplot(data = ceedata_exclUkr)+  
  geom_point(aes(YEAR,AG_LND_FRST_ZS__WORLDDEVELOPMENTINDICATORS,colour = COUNTRY))+
  geom_smooth(aes(YEAR,AG_LND_FRST_ZS__WORLDDEVELOPMENTINDICATORS,colour = COUNTRY),method = "lm")

ggplot(data = ceedata_exclUkr)+  
  geom_point(aes(AG_LND_FRST_ZS__WORLDDEVELOPMENTINDICATORS, V2X_CSPART_VDEM,colour = COUNTRY))+
  geom_smooth(aes(AG_LND_FRST_ZS__WORLDDEVELOPMENTINDICATORS, V2X_CSPART_VDEM,colour = COUNTRY),method = "lm")

#vs. net migration
ggplot(data = ceedata_exclUkr)+  
  geom_point(aes(SM_POP_NETM, V2X_CSPART_VDEM, colour = COUNTRY))+
  geom_smooth(aes(SM_POP_NETM, V2X_CSPART_VDEM, colour=COUNTRY),method = "lm")

#vs. inequality (gini)
ggplot(data = ceedata_exclUkr)+  
  geom_point(aes(SI_POV_GINI, V2X_CSPART_VDEM, colour = COUNTRY))+
  geom_smooth(aes(SI_POV_GINI, V2X_CSPART_VDEM, colour=COUNTRY),method = "lm")

ggplot(data = ceedata_exclUkr)+  
  geom_point(aes(SI_POV_GINI, V2X_CSPART_VDEM))+
  geom_smooth(aes(SI_POV_GINI, V2X_CSPART_VDEM),method = "lm")



