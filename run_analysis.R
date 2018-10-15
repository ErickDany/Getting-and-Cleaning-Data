v_temp<-tempfile()
download.file('https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip',v_temp)

v_file_features<-"UCI HAR Dataset/features.txt"
v_file_activity_labels<-"UCI HAR Dataset/activity_labels.txt"

v_file_subject_train<-"UCI HAR Dataset/train/subject_train.txt"
v_file_X_train<-"UCI HAR Dataset/train/X_train.txt"
v_file_y_train<-"UCI HAR Dataset/train/y_train.txt"

v_file_subject_test<-"UCI HAR Dataset/test/subject_test.txt"
v_file_X_test<-"UCI HAR Dataset/test/X_test.txt"
v_file_y_test<-"UCI HAR Dataset/test/y_test.txt"

v_data_features<- read.table(unz(v_temp, v_file_features))
v_data_activity_labels<- read.table(unz(v_temp, v_file_activity_labels))

v_data_subject_train<- read.table(unz(v_temp, v_file_subject_train))
v_data_X_train<- read.table(unz(v_temp, v_file_X_train))
v_data_y_train<- read.table(unz(v_temp, v_file_y_train))

v_data_subject_test<- read.table(unz(v_temp, v_file_subject_test))
v_data_X_test<- read.table(unz(v_temp, v_file_X_test))
v_data_y_test<- read.table(unz(v_temp, v_file_y_test))

unlink(v_temp)


library(dplyr)
library(purrr)
library(stringr)

#set columns names
names(v_data_X_train)<-v_data_features$V2
#Only take mean and std columns 
v_data_train<-v_data_X_train[,str_detect(v_data_features$V2,'mean')|str_detect(v_data_features$V2,'std')]
#Add information about subject
v_data_train$subject<-v_data_subject_train$V1
#set names to activities datasets
names(v_data_y_train)<-c('id_activity')
names(v_data_activity_labels)<-c('id_activity','activity')
#Get dataset with id and description of activities
v_activity_train<-reduce(list(v_data_y_train,v_data_activity_labels),left_join,by='id_activity')
#Add activity description to the final train dataset
v_data_train$activity<-v_activity_train$activity


#set columns names
names(v_data_X_test)<-v_data_features$V2
#Only take mean and std columns 
v_data_test<-v_data_X_test[,str_detect(v_data_features$V2,'mean')|str_detect(v_data_features$V2,'std')]
#Add information about subject
v_data_test$subject<-v_data_subject_test$V1
#set names to activities datasets
names(v_data_y_test)<-c('id_activity')
#Get dataset with id and description of activities
v_activity_test<-reduce(list(v_data_y_test,v_data_activity_labels),left_join,by='id_activity')
#Add activity description to the final test dataset
v_data_test$activity<-v_activity_test$activity

#Union test and train datasets
v_data<-rbind(v_data_test,v_data_train)

#Group by activity and subject
v_final_sumarise<-v_data %>% group_by(subject,activity) %>% summarise_all(funs(mean))

#Export final file
write.table(v_final_sumarise,file='final.sumarise.txt',row.names=FALSE)
