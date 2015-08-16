library(dplyr)
library(data.table)
library(tidyr)
## Creating data table for the .txt files
filesPath <- "C:\\Users\\rupakgautam\\Documents\\UCI HAR Dataset"
##process to read subject files
dataSubjectTrain <- tbl_df(read.table(file.path(filesPath, "train", "subject_train.txt")))
dataSubjectTest  <- tbl_df(read.table(file.path(filesPath, "test" , "subject_test.txt" )))

##process to read data files
dataTrain <- tbl_df(read.table(file.path(filesPath, "train", "X_train.txt" )))
dataTest  <- tbl_df(read.table(file.path(filesPath, "test" , "X_test.txt" )))


##process to read activity files
dataActivityTrain <- tbl_df(read.table(file.path(filesPath, "train", "Y_train.txt")))
dataActivityTest  <- tbl_df(read.table(file.path(filesPath, "test" , "Y_test.txt" )))

#1 Merges the training and the test sets to create one data set.
alldataSubject <- rbind(dataSubjectTrain, dataSubjectTest)
setnames(alldataSubject, "V1", "subject")

alldataActivity<- rbind(dataActivityTrain, dataActivityTest)
setnames(alldataActivity, "V1", "activityNum")

##merging alldatasubject and alldataActivity using rbind
dataTable <- rbind(dataTrain, dataTest)

# name variables according to feature e.g.(V1 = "tBodyAcc-mean()-X")
dataFeatures <- tbl_df(read.table(file.path(filesPath, "features.txt")))
setnames(dataFeatures, names(dataFeatures), c("featureNum", "featureName"))
colnames(dataTable) <- dataFeatures$featureName

#column names for activity labels
activityLabels<- tbl_df(read.table(file.path(filesPath, "activity_labels.txt")))
setnames(activityLabels, names(activityLabels), c("activityNum","activityName"))

# Merge columns
alldataSubjAct<- cbind(alldataSubject, alldataActivity)
dataTable <- cbind(alldataSubjAct, dataTable)


#2Extracts only the measurements on the mean and standard deviation for each measurement.

dataFeaturesMeanStd <- grep("mean\\(\\)|std\\(\\)",dataFeatures$featureName,value=TRUE) #var name

# Taking only measurements for the mean and standard deviation and add "subject","activityNum"

dataFeaturesMeanStd <- union(c("subject","activityNum"), dataFeaturesMeanStd)
dataTable<- subset(dataTable,select=dataFeaturesMeanStd) 

#3  Uses descriptive activity names to name the activities in the data set


dataTable <- merge(activityLabels, dataTable , by="activityNum", all.x=TRUE)
dataTable$activityName <- as.character(dataTable$activityName)




#4 Appropriately labels the data set with descriptive variable names.

names(dataTable)<-gsub("std()", "SD", names(dataTable))
names(dataTable)<-gsub("mean()", "MEAN", names(dataTable))
names(dataTable)<-gsub("^t", "time", names(dataTable))
names(dataTable)<-gsub("^f", "frequency", names(dataTable))
names(dataTable)<-gsub("Acc", "Accelerometer", names(dataTable))
names(dataTable)<-gsub("Gyro", "Gyroscope", names(dataTable))
names(dataTable)<-gsub("Mag", "Magnitude", names(dataTable))
names(dataTable)<-gsub("BodyBody", "Body", names(dataTable))



#5 From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
write.table(dataTable, "tidyData.txt", row.name = FALSE)
