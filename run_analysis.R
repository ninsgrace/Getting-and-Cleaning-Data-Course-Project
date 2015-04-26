##Setting the directory path for needed files
path_rf <- file.path("Getting and Cleaning Data","UCI HAR DataSet")
feature_file <- paste(path_rf, "/features.txt", sep = "")
activity_labels_file <- paste(path_rf, "/activity_labels.txt", sep = "")
x_train_file <- paste(path_rf, "/train/X_train.txt", sep = "")
y_train_file <- paste(path_rf, "/train/y_train.txt", sep = "")
subject_train_file <- paste(path_rf, "/train/subject_train.txt", sep = "")
x_test_file  <- paste(path_rf, "/test/X_test.txt", sep = "")
y_test_file  <- paste(path_rf, "/test/y_test.txt", sep = "")
subject_test_file <- paste(path_rf, "/test/subject_test.txt", sep = "")

# Retrieve raw data 
data_features <- read.table(feature_file, colClasses = c("character"))
data_activity_labels <- read.table(activity_labels_file, col.names = c("ActivityId", "Activity"))
data_x_train <- read.table(x_train_file)
data_y_train <- read.table(y_train_file)
data_subject_train <- read.table(subject_train_file)
data_x_test <- read.table(x_test_file)
data_y_test <- read.table(y_test_file)
data_subject_test <- read.table(subject_test_file)

#### 1 Merges the training and the test sets to create one data set.

##Binding the data
training_data <- cbind(cbind(data_x_train, data_subject_train), data_y_train)
test_data <- cbind(cbind(data_x_test, data_subject_test), data_y_test)
complete_data <- rbind(training_data, test_data)

##Column Labels
data_labels <- rbind(rbind(data_features, c(562, "Subject")), c(563, "ActivityId"))[,2]
names(complete_data) <- data_labels

#### 2 Extracts only the measurements on the mean and standard deviation for each measurement.

data_mean_std <- complete_data[,grepl("mean|std|Subject|ActivityId", names(complete_data))]

#### 3 Uses descriptive activity names to name the activities in the data set

data_mean_std <- join(data_mean_std, data_activity_labels, by = "ActivityId", match = "first")
data_mean_std <- data_mean_std[,-1]

#### 4 Appropriately labels the data set with descriptive names.

# Remove parentheses
names(data_mean_std) <- gsub('\\(|\\)',"",names(data_mean_std), perl = TRUE)

# Make syntactically valid names
names(data_mean_std)  <- make.names(names(data_mean_std))

# Make clearer names
names(data_mean_std)  <- gsub('Acc',"Acceleration",names(data_mean_std))
names(data_mean_std)  <- gsub('GyroJerk',"AngularAcceleration",names(data_mean_std))
names(data_mean_std)  <- gsub('Gyro',"AngularSpeed",names(data_mean_std))
names(data_mean_std)  <- gsub('Mag',"Magnitude",names(data_mean_std))
names(data_mean_std)  <- gsub('^t',"TimeDomain.",names(data_mean_std))
names(data_mean_std)  <- gsub('^f',"FrequencyDomain.",names(data_mean_std))
names(data_mean_std)  <- gsub('\\.mean',".Mean",names(data_mean_std))
names(data_mean_std)  <- gsub('\\.std',".StandardDeviation",names(data_mean_std))
names(data_mean_std)  <- gsub('Freq\\.',"Frequency.",names(data_mean_std))
names(data_mean_std)  <- gsub('Freq$',"Frequency",names(data_mean_std))

#### 5 Creates a second, independent tidy data set with the average of each variable for each activity and each subject.
avg_by_act_sub = ddply(data_mean_std, c("Subject","Activity"), numcolwise(mean))
write.table(avg_by_act_sub, file = "data_avg_by_act_sub.txt", row.name=FALSE)

