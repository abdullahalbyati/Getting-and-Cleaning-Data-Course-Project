# Getting-and-Cleaning-Data-Course-Project
## Getting and Cleaning Data Course Project
This project started with the data set located at https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

The final output is a data set called all_data_meanstd which satisfy all the following requirment 
1- Merges the training and the test sets to create one data set.
2- Extracts only the measurements on the mean and standard deviation for each measurement.
3- Uses descriptive activity names to name the activities in the data set
4- Appropriately labels the data set with descriptive variable names.

##The originals files that came zipped in the link above are:
- README.txt'

- 'features_info.txt': Shows information about the variables used on the feature vector.

- 'features.txt': List of all features.

- 'activity_labels.txt': Links the class labels with their activity name.

- 'train/X_train.txt': Training set.

- 'train/y_train.txt': Training labels.

- 'test/X_test.txt': Test set.

- 'test/y_test.txt': Test labels.

The following files are available for the train and test data. Their descriptions are equivalent. 

- 'train/subject_train.txt': Each row identifies the subject who performed the activity for each window sample. Its range is from 1 to 30. 

- 'train/Inertial Signals/total_acc_x_train.txt': The acceleration signal from the smartphone accelerometer X axis in standard gravity units 'g'. Every row shows a 128 element vector. The same description applies for the 'total_acc_x_train.txt' and 'total_acc_z_train.txt' files for the Y and Z axis. 

- 'train/Inertial Signals/body_acc_x_train.txt': The body acceleration signal obtained by subtracting the gravity from the total acceleration. 

- 'train/Inertial Signals/body_gyro_x_train.txt': The angular velocity vector measured by the gyroscope for each window sample. The units are radians/second. 

##Notes: 
- Features are normalized and bounded within [-1,1].
- Each feature vector is a row on the text file.

## The data sets in the global enviroment of the projects are as explained in the code below;


```
unzip("Dataset.zip")

#Load packages and install required packages
if (!require("data.table")) {
  install.packages("data.table")
}

if (!require("dplyr")) {
  install.packages("dplyr")
}

if (!require("tidyr")) {
  install.packages("tidyr")
}

filespath <- "D:/RData/Course3/UCI HAR Dataset"
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


```
