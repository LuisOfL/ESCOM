# nnet.R
library(nnet)
run_nnet <- function(train, test, f, size_val) {
  train[[2]] <- as.factor(train[[2]])
  
  mod <- nnet(f, data = train, size = size_val, trace = FALSE, 
              MaxNWts = 10000, maxit = 200, Maxit = 200)
  
  pred <- predict(mod, test, type = "class")
  acc <- sum(pred == test[[2]]) / nrow(test)
  
  return(list(acc = acc, ids = test[[1]], real = test[[2]], pred = pred))
}