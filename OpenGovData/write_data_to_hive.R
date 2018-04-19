# Run with `sparkR --master yarn --driver-memory 4G`

library(magrittr)
library(data.table)

# (1) Loading local data files ####

load('world_bank_data_big_selected_SK.Rdata')

colnames(world_bank_data_big_selected) <- gsub('\\.',"_",colnames(world_bank_data_big_selected))
colnames(world_bank_data_big_selected) <- toupper(colnames(world_bank_data_big_selected))

# (5) Joining components to form single Spark DataFrame ####
wb <- as.DataFrame(world_bank_data_big_selected)

rm(world_bank_data_big_selected)
createOrReplaceTempView(wb, "world_bank_selected")

sql("DROP TABLE opengovdata.world_bank_selected") %>% collect()
sql("CREATE TABLE opengovdata.world_bank_selected AS SELECT * FROM world_bank_selected") %>% collect()

########################################################################

load('civil_society_big_selected_SK.Rdata')

colnames(civil_society_big_selected) <- gsub('\\.',"_",colnames(civil_society_big_selected))
colnames(civil_society_big_selected) <- toupper(colnames(civil_society_big_selected))

# (5) Joining components to form single Spark DataFrame ####
cs <- as.DataFrame(civil_society_big_selected)

rm(civil_society_big_selected)
createOrReplaceTempView(cs,'civil_society_selected')

sql("DROP TABLE opengovdata.civil_society_selected") %>% collect()
sql("CREATE TABLE opengovdata.civil_society_selected AS SELECT * FROM civil_society_selected") %>% collect()

########################################################################

load('world_bank_selected_vars_metadata.Rdata')

colnames(world_bank_selected_vars_metadata) <- gsub('\\.',"_",colnames(world_bank_selected_vars_metadata))
colnames(world_bank_selected_vars_metadata) <- toupper(colnames(world_bank_selected_vars_metadata))


# (5) Joining components to form single Spark DataFrame ####
wb <- as.DataFrame(world_bank_selected_vars_metadata)

rm(world_bank_selected_vars_metadata)
createOrReplaceTempView(wb, "world_bank_selected_vars_metadata")

#sql("DROP TABLE opengovdata.world_bank_selected_vars_metadata") %>% collect()
sql("CREATE TABLE opengovdata.world_bank_selected_vars_metadata AS SELECT * FROM world_bank_selected_vars_metadata") %>% collect()


########################################################################

load('world_bank_data_selected_vars_without_padding.Rdata')

colnames(world_bank_data_selected) <- gsub('\\.',"_",colnames(world_bank_data_selected))
colnames(world_bank_data_selected) <- toupper(colnames(world_bank_data_selected))


# (5) Joining components to form single Spark DataFrame ####
wb <- as.DataFrame(world_bank_data_selected)

rm(world_bank_selected_vars_metadata)
createOrReplaceTempView(wb, "world_bank_selected_without_padding")

#sql("DROP TABLE opengovdata.world_bank_selected_without_padding") %>% collect()
sql("CREATE TABLE opengovdata.world_bank_selected_without_padding AS SELECT * FROM world_bank_selected_without_padding") %>% collect()


########################################################################

load('civil_society_selected_vars_metadata.Rdata')

colnames(civil_society_selected_vars_metadata) <- gsub('\\.',"_",colnames(civil_society_selected_vars_metadata))
colnames(civil_society_selected_vars_metadata) <- toupper(colnames(civil_society_selected_vars_metadata))


# (5) Joining components to form single Spark DataFrame ####
cs <- as.DataFrame(civil_society_selected_vars_metadata)

rm(civil_society_selected_vars_metadata)
createOrReplaceTempView(cs, "civil_society_selected_vars_metadata")

#sql("DROP TABLE opengovdata.civil_society_selected_vars_metadata") %>% collect()
sql("CREATE TABLE opengovdata.civil_society_selected_vars_metadata AS SELECT * FROM civil_society_selected_vars_metadata") %>% collect()



########################################################################

load('civil_society_selected_without_padding.Rdata')

colnames(civil_society_selected_without_padding) <- gsub('\\.',"_",colnames(civil_society_selected_without_padding))
colnames(civil_society_selected_without_padding) <- toupper(colnames(civil_society_selected_without_padding))


# (5) Joining components to form single Spark DataFrame ####
cs <- as.DataFrame(civil_society_selected_without_padding)

rm(civil_society_selected_without_padding)
createOrReplaceTempView(cs, "civil_society_selected_without_padding")

#sql("DROP TABLE opengovdata.civil_society_selected_without_padding") %>% collect()
sql("CREATE TABLE opengovdata.civil_society_selected_without_padding AS SELECT * FROM civil_society_selected_without_padding") %>% collect()



########################################################################

load('civil_society_big_SK.Rdata')

colnames(civil_society_big) <- gsub('\\.',"_",colnames(civil_society_big))
colnames(civil_society_big) <- toupper(colnames(civil_society_big))

if(any(duplicated(colnames(civil_society_big)))){
	civil_society_big[,duplicated(colnames(civil_society_big) )] <- NULL
}

n <-50
# (5) Joining components to form single Spark DataFrame ####
rowsToAdd <- as.integer(nrow(civil_society_big)/n)
cs_ls <- list()
for(i in 0:n){
  zw <- as.DataFrame(civil_society_big[(i*rowsToAdd+1):((i+1)*rowsToAdd),])
  cs_ls <- append(cs_ls,assign(paste0('cs_',i),zw))
}
cs_ls[[(n+1)]] <- as.DataFrame(civil_society_big[((i+1)*rowsToAdd+1):nrow(civil_society_big),])


# (5) Joining components to form single Spark DataFrame ####
cs <- cs_ls[[1]]
for(i in 2:(n+1)){
  cs <-cs %>% union(cs_ls[[i]])
}

rm(civil_society_big)
createOrReplaceTempView(cs,'civil_society_big')

sql("CREATE TABLE opengovdata.civil_society_full AS SELECT * FROM civil_society_big") %>% collect()

########################################################################

#load('../DataSources/world_bank_data_big_SK.Rdata')
load('world_bank_data_big_SK.Rdata')

colnames(world_bank_data_big) <- gsub('\\.',"_",colnames(world_bank_data_big))
colnames(world_bank_data_big) <- toupper(colnames(world_bank_data_big))

n <-30
# (5) Joining components to form single Spark DataFrame ####
rowsToAdd <- as.integer(nrow(world_bank_data_big)/n)
cs_ls <- list()
for(i in 0:n){
  zw <- as.DataFrame(world_bank_data_big[(i*rowsToAdd+1):((i+1)*rowsToAdd),])
  cs_ls <- append(cs_ls,assign(paste0('cs_',i),zw))
}
cs_ls[[(n+1)]] <- as.DataFrame(world_bank_data_big[((i+1)*rowsToAdd+1):nrow(world_bank_data_big),])


# (5) Joining components to form single Spark DataFrame ####
cs <- cs_ls[[1]]
for(i in 2:(n+1)){
  cs <-cs %>% union(cs_ls[[i]])
}

rm(world_bank_data_big)
createOrReplaceTempView(cs,'world_bank')

sql("CREATE TABLE opengovdata.world_bank_full AS SELECT * FROM world_bank") %>% collect()
