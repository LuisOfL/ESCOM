# Archivo: knn_normal.R
library(class) 

predict_knn_normal <- function(train_data, new_id_row, target_col = "Clase", k = 5) {
  
  train_labels <- train_data[[target_col]]
  feature_cols <- names(train_data)[!names(train_data) %in% c(target_col, "ID")]
  
  train_features <- train_data[, feature_cols, drop = FALSE] 
  test_features <- new_id_row[, feature_cols, drop = FALSE]
  
  train_matrix <- as.matrix(train_features)
  test_matrix <- as.matrix(test_features)
  
  prediction <- class::knn( 
    train = train_matrix,
    test = test_matrix,
    cl = train_labels, 
    k = k
  )
  
  return(list(prediction = as.character(prediction[1]), features = feature_cols))
}