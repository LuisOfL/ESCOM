library(rpart)
run_cart <- function(train, test, f, cp_val) {
  mod <- rpart(f, data = train, control = rpart.control(cp = cp_val))
  pred <- predict(mod, test, type = "class")
  acc <- sum(pred == test[[2]]) / nrow(test)
  return(list(acc = acc, ids = test[[1]], real = test[[2]], pred = pred))
}