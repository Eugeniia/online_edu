# 1. Downloading the raw data
fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
temp <- tempfile(); download.file(fileURL,temp)
file.copy(from = temp, to = paste0(getwd(),"/raw_data.zip")) # download zip file as raw_data.zip
unlink(temp) # delete the temp file or use file.remove(temp)
unzip("raw_data.zip") # unzip the raw_data.zip into "UCI HAR Dataset" folder

# 2. Cleaning and merging the train and test sets.
# Loading the datasets
testset <- read.table("./UCI HAR Dataset/test/X_test.txt") # load testing set
trainset <- read.table("./UCI HAR Dataset/train/X_train.txt") # load training set

# Loading the 561 features
features <- read.table("./UCI HAR Dataset/features.txt")
feature_names <- features$V2

# Rename the features
f <- gsub("-", "_", features$V2)
f <- gsub("\\()", "", f)
f <- gsub("\\(", "_", f)
f <- gsub("\\)", "", f)
# Use expression to remove comma in cases like "fBodyGyro_bandsEnergy_49,64"
t <- grep("([0-9]+(\\,*)[0-9]+)$", f)
for(i in 1:length(f)){
    if(i %in% t){
        f[i] <- sub(",","_", f[i])
    }
}
f <- gsub(",","_",f) # to remove all other commas
f <- gsub("^t", "time_", f) # t means time
f <- gsub("^f", "freq_", f) # f means freq or frequency
f <- gsub("Body", "body_", f); f <- gsub("tbody", "time_body", f);
f <- gsub("Gyro", "gyro_", f); f <- gsub("Acc", "accel_", f)
f <- gsub("Jerk", "jerk_", f); f <- gsub("Mag", "magn", f)
f <- gsub("__", "_", f); f <- tolower(f) # remove double underscores and make lowercase

# Rename columns in test and train data sets
colnames(testset) <- f; colnames(trainset) <- f

# Read the individual IDs in sets
testID <- readLines("./UCI HAR Dataset/test/subject_test.txt")
testset$individual_id <- factor(testID) # create a new column in dataset for individual IDs
trainID <- readLines("./UCI HAR Dataset/train/subject_train.txt")
trainset$individual_id <- factor(trainID) # create a new column in dataset for individual IDs

# Read the activity labels in sets
testActivity <- readLines("./UCI HAR Dataset/test/y_test.txt")
trainActivity <- readLines("./UCI HAR Dataset/train/y_train.txt")
activities <- read.table("./UCI HAR Dataset/activity_labels.txt"); head(activities)
# function to convert activity labels to activity names, returns a vector of categorical values
convert_activity <- function(x = as.vector(x)){
    for(i in 1:length(x)){
        if(x[i] == "1"){
            x[i] <- "walking"
        } else if(x[i] == "2"){
            x[i] <- "walking_upstairs"
        } else if(x[i] == "3"){
            x[i] <- "walking_downstairs"
        } else if(x[i] == "4"){
            x[i] <- "sitting"
        } else if(x[i] == "5"){
            x[i] <- "standing"
        } else if(x[i] == "6"){
            x[i] <- "laying"
        }
    }
    return(x = factor(x, levels = c("walking", "walking_upstairs", "walking_downstairs",
                                    "sitting", "standing", "laying")))
}
testActivity <- convert_activity(testActivity)
trainActivity <- convert_activity(trainActivity)
testset$activity <- testActivity # create a new column in dataset for activity
trainset$activity <- trainActivity # create a new column in dataset for activity

# Get recording ID
testRec <- row.names(testset)
trainRec <- row.names(trainset)

# Create descriptive activity names to name the activities in the data set
for(i in 1:length(testID)){
    testID[i] <- paste0("test_", testRec[i], "_individual_", testID[i], "_", testActivity[i])
}
for(i in 1:length(trainID)){
    trainID[i] <- paste0("train_", trainRec[i], "_individual_", trainID[i], "_", trainActivity[i])
}

# Get row names for test and train sets
row.names(testset); row.names(testset) <- testID
row.names(trainset); row.names(trainset) <- trainID

# Merge test and train sets
merged <- rbind(testset, trainset)

# Extracts only the measurements on the mean and standard deviation for each measurement.
# Let's assume that we are not including the angle variables and mean frequency variables. 
# Thus, this should result in 66 features.
# Get the column names for merged dataset. Extract measurments on mean and standard deviation.
cols <- colnames(merged)
cols[grep("mean|std", cols)] # if we we include angle and mean frequencies then we use this
meanstd <- cols[grep("((_mean|_std)(_[xyz])?)$", cols)]; length(meanstd) # 66 features

# Use dypl select function to extract these columns
library(dplyr)
# including individual ID and activity columns; first tidy dataset
meanstd.tidy1 <- select(merged, all_of(meanstd))
write.table(meanstd.tidy1, file = "tidy_dataset_1.txt", row.names = FALSE, sep = "\t")

# A second tidy data set with the average of each variable for each activity and each subject.
# including individual ID and activity columns
meanstd.tidy1 <- select(merged, all_of(meanstd), individual_id, activity)
library(reshape2)
meanstd.tidy1.melt <- melt(meanstd.tidy1, id=c("individual_id", "activity"), measure.vars = 1:66)
meanstd.tidy2 <- dcast(meanstd.tidy1.melt, individual_id + activity ~ variable, mean); meanstd.tidy2
write.table(meanstd.tidy2, file = "tidy_dataset_2.txt", row.names = FALSE, sep = "\t")
