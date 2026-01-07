run_linear <- function(train, test, f) {
  train_lm <- train
  train_lm[[2]] <- as.numeric(as.factor(train[[2]])) - 1
  
  mod <- lm(f, data = train_lm)
  
  prob <- predict(mod, test)
  
  niveles <- levels(as.factor(train[[2]]))

  pred <- ifelse(prob > 0.5, niveles[2], niveles[1])
  
  acc <- sum(pred == test[[2]]) / nrow(test)
  
  return(list(
    acc = acc, 
    ids = test[[1]], 
    real = test[[2]], 
    pred = pred
  ))
}