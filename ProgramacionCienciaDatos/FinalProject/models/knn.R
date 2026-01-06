library(class)
source("../utils/utils.R")


knn_function <- function(PATH, k, id){
  data <- csv.read(PATH)
  temp <- split_ml(data)
  X_train <- temp[1]
  y_train <- temp[2]
  X_test <- temp[3]
  y_test <- temp[4]
  
  
  #accuracy
  pred <- knn(
    train = X_train,
    test  = X_test,
    cl    = y_train,
    k     = 5
  )
  
  return()
}