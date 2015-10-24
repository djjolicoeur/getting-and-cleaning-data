library(data.table)
library(reshape2)

#read in activity labael data
activity_labels <- read.table("~/uci-dataset/activity_labels.txt")$V2

#read in feature names (column names)
feature_labels <- read.table("~/uci-dataset/features.txt")$V2

#We are only interested in the mean and std. dev. for each measure 
mean_and_std <- grepl("mean|std", feature_labels)

# we will have to do this a few times, so might as well keep it DRY
load_x <- function(filename){
  x_data <- read.table(filename)
  names(x_data) <- feature_labels
  x_data <- x_data[, mean_and_std]
  x_data
}

load_y <- function(filename){
  y_data <- read.table(filename)
  y_data$V2 <- activity_labels[y_data$V1]
  names(y_data) <- c("ActivityID", "ActivityName")
  y_data
}

load_subject <- function(filename){
  subject_data <- read.table(filename)
  names(subject_data) <- c("Subject")
  subject_data
}

#bind all columns
bind_columns <- function(subject_data, y_data, x_data){
  all_data <- cbind(as.data.table(subject_data), y_data, x_data)
  all_data
}


#load test datasets

#load up x test data
x_test_data <- load_x("~/uci-dataset/test/X_test.txt")
#y test data
y_test_data <- load_y("~/uci-dataset/test/y_test.txt")

#subject test data
subject_test_data <- load_subject("~/uci-dataset/test/subject_test.txt")

#bind columns together into coherent data table
all_test_data <- bind_columns(subject_test_data, y_test_data, x_test_data)


#load training datasets

#x training
x_train_data <- load_x("~/uci-dataset/train/X_train.txt")

#y training
y_train_data <- load_y("~/uci-dataset/train/y_train.txt")

#subject training data
subject_train_data <- load_subject("~/uci-dataset/train/subject_train.txt")

#all training data
all_train_data <- bind_columns(subject_train_data, y_train_data, x_train_data)

#bind test and training data together
all_data <- rbind(all_test_data, all_train_data)

#prepare to "melt" data
id_labels <- c("Subject", "ActivityID", "ActivityName")
data_labels <- setdiff(colnames(all_data), id_labels)
molten_data <- melt(all_data, id = id_labels, measure.vars = data_labels)

#apply mean to "molten" data
data <- dcast(molten_data, Subject + ActivityName ~ variable, mean)

#write final analysis to file
write.table(data, file = "./tidy_data.csv", sep = ",")















