split_ml <- function(data, p = 0.8, seed = 123) {
  set.seed(seed)
  
  n <- nrow(data)
  idx <- sample(n)
  
  cut <- floor(p * n)
  train_idx <- idx[1:cut]
  test_idx  <- idx[(cut + 1):n]
  
  X_train <- data[train_idx, -c(1,2)]
  y_train <- data[train_idx, 2, drop = TRUE]
  
  X_test  <- data[test_idx, -c(1,2)]
  y_test  <- data[test_idx, 2, drop = TRUE]
  
  return(list(
    X_train = X_train,
    y_train = y_train,
    X_test  = X_test,
    y_test  = y_test
  ))
}

