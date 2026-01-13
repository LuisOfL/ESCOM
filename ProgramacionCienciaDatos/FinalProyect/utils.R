# utils.R
split_ml <- function(data, p = 0.8, seed = 123) {
  set.seed(seed)
  data <- na.omit(data)
  
  normalize <- function(x) {
    if(is.numeric(x)) {
      return((x - min(x, na.rm = TRUE)) / (max(x, na.rm = TRUE) - min(x, na.rm = TRUE)))
    }
    return(x)
  }
  
  data_norm <- data
  if(ncol(data) > 2) {
    data_norm[,-c(1,2)] <- as.data.frame(lapply(data[,-c(1,2)], normalize))
  }
  
  data_norm[[2]] <- as.factor(data_norm[[2]])
  
  n <- nrow(data_norm)
  idx <- sample(n)
  cut <- floor(p * n)
  
  return(list(
    train = data_norm[idx[1:cut], ],
    test  = data_norm[idx[(cut + 1):n], ],
    full  = data_norm
  ))
}
