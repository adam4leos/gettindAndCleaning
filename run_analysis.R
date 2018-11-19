dataDirPath = "./data"
dataName <- "UCI HAR Dataset"
dataPath <- paste(dataDirPath, dataName, sep="/")

# creating data directory if not exists
if (!file.exists(dataDirPath)) {
  dir.create(dataDirPath)
}

# getting data if not exists
if (!file.exists(dataPath)) {
  zipPath = paste(dataPath, 'zip', sep=".")
  
  # downloading zip if not exists
  if (!file.exists(zipPath)) {
    fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
    download.file(fileUrl, destfile=zipPath)
  }
  
  # unziping dataSet to /data directory
  unzip(zipfile=zipPath, exdir=dataDirPath)
}

# reading trainings tables:
x_train <- read.table(file.path(dataPath, "train", "X_train.txt"))
y_train <- read.table(file.path(dataPath, "train", "y_train.txt"))
subject_train <- read.table(file.path(dataPath, "train", "subject_train.txt"))

# reading testing tables:
x_test <- read.table(file.path(dataPath, "test", "X_test.txt"))
y_test <- read.table(file.path(dataPath, "test", "y_test.txt"))
subject_test <- read.table(file.path(dataPath, "test", "subject_test.txt"))

# reading feature vector:
features <- read.table(file.path(dataPath, "features.txt"))

# reading activity labels:
activityLabels = read.table(file.path(dataPath, "activity_labels.txt"))

# adding names to columns
colnames(x_train) <- features[,2] 
colnames(y_train) <-"activityId"
colnames(subject_train) <- "subjectId"

colnames(x_test) <- features[,2] 
colnames(y_test) <- "activityId"
colnames(subject_test) <- "subjectId"

colnames(activityLabels) <- c("activityId", "activityType")

# mergin data in one set
mergedTrain <- cbind(y_train, subject_train, x_train)
mergedTest <- cbind(y_test, subject_test, x_test)
mergedSet <- rbind(mergedTrain, mergedTest)

# grabbing column names
colNames <- colnames(mergedSet)

# vector of needed IDs
meanAndStd <- (
  grepl("activityId" , colNames) | 
  grepl("subjectId" , colNames) | 
  grepl("mean.." , colNames) | 
  grepl("std.." , colNames) 
)

# grabbing needed subset of merged set
neededSubset <- mergedSet[ , meanAndStd == TRUE]

# adding activity names to subset
namedSet <- merge(
  neededSubset,
  activityLabels,
  by = 'activityId',
  all.x = TRUE
)

# creating tidy set
tidySet <- aggregate(. ~subjectId + activityId, namedSet, mean)
tidySey <- tidySet[order(tidySet$subjectId, tidySet$activityId),]

# writing tidy set to new file
write.table(tidySet, "tidySet.txt", row.name = FALSE, quote = FALSE)