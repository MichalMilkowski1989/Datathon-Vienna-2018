## load libraries
library(data.table)
library(magrittr)
library(SparkR)

## set up connection to spark
sparkR.session(master = 'yarn')

## Show the databases in hive
sql("SHOW DATABASES") %>% collect

## Show tables available in opengovdata (the database where you find the Open Data)
sql("SHOW TABLES") %>% collect

## Extract some data from opengovdata.civil_society_selected to see what is there inside
civil_society <- sql("SELECT * FROM opengovdata.civil_society_selected LIMIT 20") %>% collect

## Load the whole data opengovdata.civil_society_selected 
civil_society <- sql("SELECT * FROM opengovdata.civil_society_selected") %>% collect

## You can load the other tables in the same way, just replacing the names. 