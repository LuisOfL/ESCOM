library(e1071)
run_bayes <- function(train, test, f) {
  mod <- naiveBayes(f, data = train)
  pred <- predict(mod, test)
  acc <- sum(pred == test[[2]]) / nrow(test)
  return(list(acc = acc, ids = test[[1]], real = test[[2]], pred = pred))
}