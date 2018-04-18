library(DBI)
library(sparklyr)
library(dplyr)

# disconnect all current sessions
spark_disconnect_all()
#configuration
#standard configuration
config=spark_config()

# Establish connection
sc <- spark_connect(master="yarn-client",app_name = "sparklyr",config = config )

# print all the available databases
DBI::dbGetQuery(sc, "show databases")

# select open government database
DBI::dbGetQuery(sc, "use opengovdata")

# print all the tables
DBI::dbGetQuery(sc, "show tables")

# create Spark data frames to be used with dplyr e.g.
civil_society <- tbl(sc,"civil_society_selected")
world_bank <- tbl(sc,"world_bank_selected")

#it's Spark data frame
class(civil_society)

# or download data to R data frame
civil_society_Rdf <- DBI::dbGetQuery(sc, "select * from civil_society_selected")
world_bank_Rdf <- DBI::dbGetQuery(sc, "select * from world_bank_selected")

#it's well-known data frame
class(civil_society_Rdf)


