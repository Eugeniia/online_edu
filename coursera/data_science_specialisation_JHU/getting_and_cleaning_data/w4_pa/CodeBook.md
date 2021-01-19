# Getting and Cleaning Data Course Project (Peer-graded Assignment)

The goal of this course project is to prepare two tidy data sets (that can be used in the downstream analysis). Additionally, to ensure reproducibility, it is also required to provide:

1. R scripts performing the analyses (i.e. run_analysis.R)
2. code book describing the variables, the data, and any transformations performed to clean up the data
3. README file explaining how all of the scripts work

All the analyses were performed using R version 4.0.2 (2020-06-22) and RStudio version 1.2.5033.

# Description of the data

For this project, the [Human Activity Recognition Using Smartphones Dataset (Version 1.0)](http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones) was used. It represents the recordings of 30 individuals performing activities of daily living (ADL) while carrying a waist-mounted Samsung Galaxy S smartphone with embedded inertial sensors. Let's download the dataset and explore it.

## Downloading the raw dataset.

First, create and clone github repository for your project. Then, set/get the working directory to your cloned github repo on your computer. Use the following lines of code to download the raw dataset and unzip it into "UCI HAR Dataset" folder:

    fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
    temp <- tempfile(); download.file(fileURL,temp)
    file.copy(from = temp, to = paste0(getwd(),"/raw_data.zip")) # download zip file as raw_data.zip
    unlink(temp) # delete the temp file or use file.remove(temp)
    unzip("raw_data.zip") # unzip the raw_data.zip into "UCI HAR Dataset" folder

Each of 30 individuals performed six activities (walking, walking upstairs, walking downstairs, sitting, standing and laying) labelled in the "activity_labels.txt" file in the "UCI HAR Dataset" folder. For example, label 1 corresponds to walking activity, label 2 - to walking upstairs actvivity etc.

These 30 individuals were randomly partitioned into two sets, where 70% of the volunteers was selected for generating the training data (see "train" folder, 0.7 multiplied by 30 is equal to 21 individuals in the train set) and 30% the test data (see "test" folder, 0.3 multiplied by 30 is equal to 9 individuals in test set). Each individual has an ID number (from 1 to 30 correspondingly).

In total, 2947 activity recordings were done for 9 individuals in the testing set, 7352 activity recordings for 21 individuals in the training set. Each recording has individual ID, activity label and 561 features. For example, the "test" folder contains "y_test.txt" file with activity label, "subject_test.txt" file with individual ID, and "X_test.txt" with 561 feature measurments for 2947 recordings. Similarly, the "train" folder contains "y_train.txt" file with activity label, "subject_train.txt" file with individual ID, and "X_train.txt" with 561 feature measurments for 7352 recordings.

The old names for 561 features are described in 'features_info.txt' in the "UCI HAR Dataset" folder. We renamed them. After renaming, these 561 features (see the "features.txt" file) correspond to 3-axial (see "x", "y", "x" in the feature's name) sensor signals that were obtained from accelerometer and gyroscope (see "accel" and "gyro" in the feature's name), pre-processed by applying noise filters, and then sampled in fixed-width sliding windows of 2.56 sec and 50% overlap (128 readings/window). From each window, a vector of features was obtained by calculating variables from the time (prefix 'time' to denote time) and Fast Fourier Transform frequency (prefix 'freq' to denote frequency) domain. The acceleration signal was subsequently separated into body and gravity acceleration signals (see "body_accel" and "gravity_accel" in the feature's name), the gyroscope signal only has body measurments (see "body_gyro"). Next, the body linear acceleration and angular velocity were derived in time to obtain Jerk signals (see "body_accel_jerk" and "body_gyro_jerk"). Also, the magnitude of the three-dimensional signals were calculated using the Euclidean norm (see "magn" in the feature's name). Next, the signals described above were used to calculate the following set of statistcis: mean value (mean), standard deviation (std), median absolute deviation (mad), largest value in array (max), smallest value in array (min), signal magnitude area (sma), energy measure (energy), interquartile range (iqr), signal entropy (entropy), autorregresion coefficients with Burg order equal to 4 (arcoeff), correlation coefficient between two signals (correlation), index of the frequency component with largest magnitude (maxinds), weighted average of the frequency components to obtain a mean frequency (meanfreq), skewness of the frequency domain signal (skewness), kurtosis of the frequency domain signal (kurtosis), energy of a frequency interval within the 64 bins of the FFT of each window (bandsenergy) and angle between two vectors (angle).


# Data analysis

The run_analysis.R script contains the following steps:

## 1. Cleaning and merging the train and test sets.

Loading the datasets:

    testset <- read.table("./UCI HAR Dataset/test/X_test.txt") # load testing set
    trainset <- read.table("./UCI HAR Dataset/train/X_train.txt") # load training set

Loading the 561 features:

    features <- read.table("./UCI HAR Dataset/features.txt")
    feature_names <- features$V2
    
Rename the features:

    f <- gsub("-", "_", features$V2)
    f <- gsub("\\()", "", f)
    f <- gsub("\\(", "_", f)
    f <- gsub("\\)", "", f)
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
    f <- gsub("__", "_", f); f <- tolower(f)

Rename columns in test and train data sets:

    colnames(testset) <- f; colnames(trainset) <- f

Read the individual IDs in sets:

    testID <- readLines("./UCI HAR Dataset/test/subject_test.txt")
    testset$individual_id <- factor(testID) # create a new column in dataset for individual IDs
    trainID <- readLines("./UCI HAR Dataset/train/subject_train.txt")
    trainset$individual_id <- factor(trainID) # create a new column in dataset for individual IDs
    
Read the activity labels in sets:

    testActivity <- readLines("./UCI HAR Dataset/test/y_test.txt")
    trainActivity <- readLines("./UCI HAR Dataset/train/y_train.txt")
    activities <- read.table("./UCI HAR Dataset/activity_labels.txt"); head(activities)

Convert activity labels to activity names, returns a vector of categorical values:

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

Get recording ID:

    testRec <- row.names(testset)
    trainRec <- row.names(trainset)
    
Create descriptive activity names to name the activities in the data set:

    for(i in 1:length(testID)){
        testID[i] <- paste0("test_", testRec[i], "_individual_", testID[i], "_", testActivity[i])
    }
    for(i in 1:length(trainID)){
        trainID[i] <- paste0("train_", trainRec[i], "_individual_", trainID[i], "_", trainActivity[i])
    }

Get row names for test and train sets

    row.names(testset); row.names(testset) <- testID
    row.names(trainset); row.names(trainset) <- trainID

Merge test and train sets

    merged <- rbind(testset, trainset)
    
## 2. First tidy dataset.

It contains only the measurements on the mean and standard deviation. Let's assume that we are not including the angle variables and mean frequency variables. Thus, this should result in 66 features. 

Get the column names for merged dataset and extract measurments on mean and standard deviation:

    cols <- colnames(merged)
    cols[grep("mean|std", cols)] # if we we include angle and mean frequencies then we use this
    meanstd <- cols[grep("((_mean|_std)(_[xyz])?)$", cols)]; length(meanstd) # 66 features

Use dyplr select function to extract these columns:

    library(dplyr)
    meanstd.tidy1 <- select(merged, all_of(meanstd))
    write.table(meanstd.tidy1, file = "tidy_dataset_1.txt", row.names = FALSE, sep = "\t")

## 3. Second tidy dataset.

It represents a table with the average of each variable for each activity and each individual.

    # including individual ID and activity columns
    meanstd.tidy1 <- select(merged, all_of(meanstd), individual_id, activity)
    library(reshape2)
    meanstd.tidy1.melt <- melt(meanstd.tidy1, id=c("individual_id", "activity"), measure.vars = 1:66)
    meanstd.tidy2 <- dcast(meanstd.tidy1.melt, individual_id + activity ~ variable, mean)
    head(meanstd.tidy2)
    write.table(meanstd.tidy2, file = "tidy_dataset_2.txt", row.names = FALSE, sep = "\t")
    