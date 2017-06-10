#To download the zip file from the intrenet use the following code 
## temp <- tempfile()
## download.file("file URL",temp)
## data <- read.table(unz(temp, "a1.dat"))
## unlink(temp)

# If the download.file don't work use the following code to read and unzip the file
unzip("Dataset.zip")

#Load packages and install required packages
library(data.table)
library(dplyr)
library(tidyr)
filespath <- "D:/RData/Getting-and-Cleaning-Data-Course-Project/UCI HAR Dataset"
# Read subject files
subject_train <- tbl_df(read.table(file.path(filespath, "train", "subject_train.txt")))
subject_test  <- tbl_df(read.table(file.path(filespath, "test" , "subject_test.txt" )))

# Read activity files
activity_train <- tbl_df(read.table(file.path(filespath, "train", "Y_train.txt")))
activity_test  <- tbl_df(read.table(file.path(filespath, "test" , "Y_test.txt" )))

#Read data files.
train <- tbl_df(read.table(file.path(filespath, "train", "X_train.txt" )))
test  <- tbl_df(read.table(file.path(filespath, "test" , "X_test.txt" )))

#Merge the training and the test sets to create one data set and name the columns
## we are going to do this in little chunks to make easier
###subject
merged_subject <- rbind(subject_train, subject_test)
setnames(merged_subject, "V1", "subject")

### activity
merged_activity <- rbind(activity_train, activity_test)
setnames(merged_activity, "V1", "activitynumber")

### train test data
merged_data <- rbind(train, test)

# name variables according to features.txt  
## first we tell R to read features.txt as a table using the filespath we created at the bigning and store it in a vaiable named features
features <- tbl_df(read.table(file.path(filespath, "features.txt")))

## now we use the variable features to set the names for the coloumns of the features table and use them to lable merged_data
setnames(features, names(features), c("featurenumber", "featurename"))
colnames(merged_data) <- features$featurename

# name variables according to activity_lables.txt
## first we tell R to read activity_lables.txt as a table using the filespath we created at the bigning and store it in a vaiable named activity_lables
activit_labels <- tbl_df((read.table(file.path(filespath, "activity_labels.txt"))))

## now we use the variable activity_labels to set the names for the coloumns of the activity_labels table and use them to lable merged_data
setnames(activit_labels, names(activit_labels), c("activitynumber", "activityname"))

# merge the subject and the activity data using cbind and store it in a variable 
all_subject_activity <- cbind(merged_subject, merged_activity)

# merge all the data together by using cbind
all_data <- cbind(all_subject_activity, merged_data)

# Extract only the measurements on the mean and standard deviation for each measurement

featuresmeanstd <- grep("mean\\(\\)|std\\(\\)", features$featurename, value = TRUE)
featuresmeanstd <- union(c("subject", "activitynumber"), featuresmeanstd)

## now subset the data using the variables created above and store it in a new table
all_data_meanstd <- subset(all_data, select = featuresmeanstd)

# Use descriptive activity names to name the activities in the data set
all_data_meanstd <- merge(activit_labels, all_data_meanstd, by="activitynumber", all.x=TRUE)
all_data_meanstd$activityname <- as.character(all_data_meanstd$activityname)
agg_data <- aggregate(. ~subject - activityname, data = all_data_meanstd, mean)
all_data_meanstd <- tbl_df(arrange(agg_data, subject, activityname))

# Appropriately label the data set with descriptive variable names
names(all_data_meanstd) <- gsub("std()", "Standard_Deviation", names(all_data_meanstd))
names(all_data_meanstd) <- gsub("mean()", "Mean", names(all_data_meanstd))
names(all_data_meanstd) <- gsub("^t", "time", names(all_data_meanstd))
names(all_data_meanstd) <- gsub("^f", "frequency", names(all_data_meanstd))
names(all_data_meanstd) <- gsub("^Acc", "Accelerometer", names(all_data_meanstd))
names(all_data_meanstd) <- gsub("Gyro", "Gyroscope", names(all_data_meanstd))
names(all_data_meanstd) <- gsub("Mag", "Magnitude", names(all_data_meanstd))
names(all_data_meanstd) <- gsub("BodyBody", "Body", names(all_data_meanstd))

# From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject
write.table(all_data_meanstd, "tidy", row.names = FALSE)

