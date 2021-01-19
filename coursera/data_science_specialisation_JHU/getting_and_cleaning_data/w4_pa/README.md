# Getting and Cleaning Data Course Project (Peer-graded Assignment)

This is a repo for the Getting and Cleaning Data course project. The repo contains:

1. two tidy data sets (tidy_dataset_1.txt and tidy_dataset_2.txt)
2. R scripts performing the analyses (run_analysis.R)
3. code book describing the variables, the data, and any transformations performed to clean up the data (CodeBook.md)
4. README file explaining how all of the scripts work (README.md)

All the analyses were performed using R version 4.0.2 (2020-06-22) and RStudio version 1.2.5033.

In run_analysis.R script we first clean the datasets using descriptive activity names (for rows) and feature names (for columns). Then, we merge the test and train datastes and extract measurments on mean and standard deviation (mean and std features) to create the first tidy dataset. Lastly, we calculate the mean for each variable for each activity and each individual.
