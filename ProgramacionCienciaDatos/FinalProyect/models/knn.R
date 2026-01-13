library(class)
run_knn <- function(train, test, k_val) {
  pred <- knn(train = train[, -c(1,2)], test = test[, -c(1,2)], 
              cl = train[[2]], k = k_val)
  acc <- sum(pred == test[[2]]) / nrow(test)
  return(list(acc = acc, ids = test[[1]], real = test[[2]], pred = pred))
}